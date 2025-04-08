import '../models/message.dart';

abstract class ChatService {
  Stream<Message> onMessage();
  Future<void> sendMessage(Message message);
  Future<void> connect();
  Future<void> disconnect();
}
