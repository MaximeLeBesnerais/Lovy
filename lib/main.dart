import 'package:flutter/material.dart';
import 'package:werapp/services/mock_chat_service.dart' show MockChatService;
import 'package:werapp/services/websocket_chat_service.dart' show WebSocketChatService;
import 'home_screen.dart';
import 'services/chat_service.dart';
import 'services/chat_service_factory.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SharedPreferences.getInstance();


  final chatService = ChatServiceFactory.createChatService(
    ChatServiceType.mock,
    // For WebSocket, provide URL:
    // ChatServiceType.webSocket,
    // websocketUrl: 'ws://your-server.com/chat',
  );

  // Connect the chat service (important for either implementation)
  chatService.connect();

  runApp(MyApp(chatService: chatService));
}

class MyApp extends StatefulWidget {
  final ChatService chatService;

  const MyApp({super.key, required this.chatService});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Color _themeColor = Colors.pink;

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void setThemeColor(Color color) {
    setState(() {
      _themeColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Nav App',
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _themeColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _themeColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: HomeScreen(
        setTheme: setThemeMode,
        setThemeColor: setThemeColor,
        currentThemeColor: _themeColor,
        currentThemeMode: _themeMode,
        chatService: widget.chatService, // Pass the chat service
      ),
    );
  }

  @override
  void dispose() {
    // Properly dispose the service when the app is closed
    // This is just an example - in reality, you might want to handle
    // this differently if the service needs to stay alive
    if (widget.chatService is MockChatService) {
      (widget.chatService as MockChatService).dispose();
    } else if (widget.chatService is WebSocketChatService) {
      (widget.chatService as WebSocketChatService).dispose();
    }
    super.dispose();
  }
}
