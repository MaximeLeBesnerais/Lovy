import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/message.dart';
import 'chat_service.dart';

class WebSocketChatService implements ChatService {
  final String url;
  WebSocketChannel? _channel;
  final _messageController = StreamController<Message>.broadcast();
  bool _isConnected = false;

  WebSocketChatService(this.url);

  @override
  Stream<Message> onMessage() => _messageController.stream;

  @override
  Future<void> connect() async {
    if (!_isConnected) {
      try {
        _channel = WebSocketChannel.connect(Uri.parse(url));
        _isConnected = true;

        // Listen to incoming messages and transform them to Message objects
        _channel!.stream.listen(
          (dynamic data) {
            try {
              final Map<String, dynamic> jsonData = json.decode(data as String);
              final message = Message.fromJson(jsonData);
              _messageController.add(message);
            } catch (e) {
              // Handle parsing errors
              _messageController.add(
                Message(
                  content: 'Error processing message: $e',
                  sender: 'system',
                  timestamp: DateTime.now(),
                ),
              );
            }
          },
          onError: (error) {
            _messageController.add(
              Message(
                content: 'Connection error: $error',
                sender: 'system',
                timestamp: DateTime.now(),
              ),
            );
            disconnect();
          },
          onDone: () {
            _messageController.add(
              Message(
                content: 'Connection closed',
                sender: 'system',
                timestamp: DateTime.now(),
              ),
            );
            _isConnected = false;
          },
        );
      } catch (e) {
        _messageController.add(
          Message(
            content: 'Failed to connect: $e',
            sender: 'system',
            timestamp: DateTime.now(),
          ),
        );
        _isConnected = false;
      }
    }
  }

  @override
  Future<void> sendMessage(Message message) async {
    if (!_isConnected || _channel == null) {
      throw Exception('Not connected to chat service');
    }

    try {
      final String jsonMessage = json.encode(message.toJson());
      _channel!.sink.add(jsonMessage);
    } catch (e) {
      _messageController.add(
        Message(
          content: 'Failed to send message: $e',
          sender: 'system',
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  @override
  Future<void> disconnect() async {
    if (_isConnected && _channel != null) {
      await _channel!.sink.close();
      _isConnected = false;
    }
  }

  // Clean up resources
  void dispose() {
    disconnect();
    _messageController.close();
  }
}
