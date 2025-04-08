import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'screens/connect_screen.dart';
import 'screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  
  const HomeScreen({super.key, required this.toggleTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return const ChatScreen();
      case 1:
        return const ConnectScreen();
      case 2:
        return ProfileScreen(toggleTheme: widget.toggleTheme);
      default:
        return const ChatScreen();
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
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      label: 'Me',
    ),
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