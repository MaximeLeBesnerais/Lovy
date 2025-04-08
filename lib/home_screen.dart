import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'screens/connect_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'services/chat_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) setTheme;
  final Function(Color) setThemeColor;
  final Color currentThemeColor;
  final ThemeMode currentThemeMode;
  final ChatService chatService;

  const HomeScreen({
    super.key,
    required this.setTheme,
    required this.setThemeColor,
    required this.currentThemeColor,
    required this.currentThemeMode,
    required this.chatService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return ChatScreen(chatService: widget.chatService);
      case 1:
        return const ConnectScreen();
      case 2:
        return ProfileScreen(
          setThemeMode: widget.setTheme,
          setThemeColor: widget.setThemeColor,
          currentThemeColor: widget.currentThemeColor,
          currentThemeMode: widget.currentThemeMode,
        );
      default:
        return ChatScreen(chatService: widget.chatService);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_bubble_outline),
      label: 'Chat',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.connect_without_contact_outlined),
      label: 'Connect',
    ),
    BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Me'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
