import { Database } from "bun:sqlite";

const PORT = process.env.PORT || 8080;

const db = new Database(":memory:");

db.exec(`
    CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sender TEXT NOT NULL,
        receiver TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        status TEXT NOT NULL
    )
`);

const insertMessage = db.prepare(`
    INSERT INTO messages (sender, receiver, content, timestamp, status)
    VALUES (?, ?, ?, ?, ?) RETURNING id
`);

const updateMessageStatus = db.prepare(`
    UPDATE messages SET status = ? WHERE id = ?
`);

const getPendingMessages = db.prepare(`
    SELECT id, sender, content, timestamp FROM messages
    WHERE receiver = ? AND status = 'pending' ORDER BY timestamp ASC
`);

const users = {
  user1: null,
  user2: null,
};

console.log("Initializing WebSocket server...");

const server = Bun.serve({
  port: PORT,

  fetch(req, server) {
    const success = server.upgrade(req);
    if (success) {
      return;
    }
    return new Response(
      "WebSocket server is running. Connect via WebSocket protocol."
    );
  },

  websocket: {
    open(ws) {
      let userId = null;

      if (!users.user1) {
        userId = "user1";
        users.user1 = ws;
      } else if (!users.user2) {
        userId = "user2";
        users.user2 = ws;
      } else {
        ws.send(
          JSON.stringify({
            type: "error",
            content: "No slots available, please try again later",
          })
        );
        ws.close();
        console.log("Connection refused: No slots available.");
        return;
      }

      ws.data = { userId };

      console.log(`New connection assigned as ${userId}`);

      ws.send(
        JSON.stringify({
          type: "system",
          content: `Welcome to the chat! You are ${userId}`,
        })
      );

      const otherUserId = userId === "user1" ? "user2" : "user1";
      if (users[otherUserId]) {
        users[otherUserId].send(
          JSON.stringify({
            type: "system",
            content: `${userId} has joined the chat`,
          })
        );
        ws.send(
          JSON.stringify({
            type: "system",
            content: `${otherUserId} is already in the chat`,
          })
        );
      }

      deliverPendingMessages(userId);
    },

    message(ws, message) {
      const { userId } = ws.data;
      if (!userId) return;

      try {
        const messageString =
          message instanceof Buffer ? message.toString() : message;
        const parsedMessage = JSON.parse(messageString);
        const { content } = parsedMessage;

        if (typeof content !== "string" || content.trim() === "") {
          console.warn(`Received invalid message structure from ${userId}`);
          ws.send(
            JSON.stringify({ type: "error", content: "Invalid message format" })
          );
          return;
        }

        console.log(`Message from ${userId}: ${content}`);

        const recipientId = userId === "user1" ? "user2" : "user1";

        const timestamp = Date.now();
        const recipientWs = users[recipientId];
        const status = recipientWs ? "delivered" : "pending";

        const result = insertMessage.get(
          userId,
          recipientId,
          content,
          timestamp,
          status
        );

        const messageId = result.id;

        if (recipientWs) {
          recipientWs.send(
            JSON.stringify({
              type: "message",
              id: messageId,
              sender: userId,
              content,
              timestamp,
            })
          );

          ws.send(
            JSON.stringify({
              type: "status",
              messageId,
              status: "delivered",
            })
          );
        } else {
          ws.send(
            JSON.stringify({
              type: "status",
              messageId,
              status: "pending",
            })
          );
        }
      } catch (error) {
        console.error(`Error processing message from ${userId}:`, error);
        ws.send(
          JSON.stringify({
            type: "error",
            content: "Failed to process message",
          })
        );
      }
    },

    close(ws, code, reason) {
      const { userId } = ws.data;
      if (!userId) {
        console.log("An unassigned connection closed.");
        return;
      }

      console.log(`${userId} disconnected. Code: ${code}, Reason: ${reason}`);
      users[userId] = null;

      const otherUserId = userId === "user1" ? "user2" : "user1";
      if (users[otherUserId]) {
        users[otherUserId].send(
          JSON.stringify({
            type: "system",
            content: `${userId} has left the chat`,
          })
        );
      }
    },

    error(ws, error) {
      const userId = ws.data?.userId || "unknown user";
      console.error(`WebSocket error for ${userId}:`, error);
    },
  },
});

function deliverPendingMessages(userId) {
  const userWs = users[userId];
  if (!userWs) return;

  const pendingMessages = getPendingMessages.all(userId);

  if (pendingMessages.length === 0) return;

  console.log(
    `Delivering ${pendingMessages.length} pending messages to ${userId}`
  );

  pendingMessages.forEach((message) => {
    userWs.send(
      JSON.stringify({
        type: "message",
        id: message.id,
        sender: message.sender,
        content: message.content,
        timestamp: message.timestamp,
      })
    );

    updateMessageStatus.run("delivered", message.id);

    const senderWs = users[message.sender];
    if (senderWs) {
      senderWs.send(
        JSON.stringify({
          type: "status",
          messageId: message.id,
          status: "delivered",
        })
      );
    }
  });
}

console.log(
  `WebSocket server running on bun ${Bun.version} at http://${server.hostname}:${server.port}`
);
