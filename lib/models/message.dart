
class Message {
  final String content;
  final String sender;
  final DateTime timestamp;

  Message({
    required this.content,
    required this.sender,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'sender': sender,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'] as String,
      sender: json['sender'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return 'Message{content: $content, sender: $sender, timestamp: $timestamp}';
  }
}
