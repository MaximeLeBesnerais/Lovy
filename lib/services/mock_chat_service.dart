import 'dart:async';
import '../models/message.dart';
import 'chat_service.dart';

class MockChatService implements ChatService {
  final _controller = StreamController<Message>.broadcast();
  bool _isConnected = false;

  // Simulate auto-responses to make the mock more interactive
  final Map<String, String> _autoResponses = {
    'hi': 'Hello there!',
    'hello': 'Hi! How can I help?',
    'how are you': 'I\'m just a mock service, but I\'m working well!',
  };

  @override
  Stream<Message> onMessage() => _controller.stream;

  @override
  Future<void> sendMessage(Message message) async {
    if (!_isConnected) {
      throw Exception('Not connected to chat service');
    }

    // Add the sent message to the stream so it shows in the UI
    _controller.add(message);

    // Simulate a delay before "receiving" an auto-response
    await Future.delayed(const Duration(seconds: 1));

    // Check if we should send an auto-response
    final lowercaseContent = message.content.toLowerCase();
    for (final entry in _autoResponses.entries) {
      if (lowercaseContent.contains(entry.key)) {
        final response = Message(
          content: entry.value,
          sender: 'bot',
          timestamp: DateTime.now(),
        );
        _controller.add(response);
        break;
      }
    }
  }

  @override
  Future<void> connect() async {
    if (!_isConnected) {
      _isConnected = true;

      // Simulate a welcome message
      await Future.delayed(const Duration(milliseconds: 500));

      final welcomeMessage = Message(
        content: 'Welcome to the chat! This is a mock service.',
        sender: 'system',
        timestamp: DateTime.now(),
      );

      _controller.add(welcomeMessage);
    }
  }

  @override
  Future<void> disconnect() async {
    if (_isConnected) {
      _isConnected = false;

      // Optional: Send a disconnect message
      final disconnectMessage = Message(
        content: 'Disconnected from chat.',
        sender: 'system',
        timestamp: DateTime.now(),
      );

      _controller.add(disconnectMessage);
    }
  }

  // Clean up resources
  void dispose() {
    _controller.close();
  }
}
