import 'chat_service.dart';
import 'mock_chat_service.dart';
import 'websocket_chat_service.dart';

enum ChatServiceType { mock, webSocket }

class ChatServiceFactory {
  static ChatService createChatService(
    ChatServiceType type, {
    String? websocketUrl,
  }) {
    switch (type) {
      case ChatServiceType.mock:
        return MockChatService();
      case ChatServiceType.webSocket:
        if (websocketUrl == null) {
          throw ArgumentError(
            'WebSocket URL is required for WebSocket chat service',
          );
        }
        return WebSocketChatService(websocketUrl);
    }
  }
}
