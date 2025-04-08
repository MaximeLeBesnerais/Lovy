import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback toggleTheme;
  
  const ProfileScreen({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Theme.of(context).brightness == Brightness.dark
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        Theme.of(context).brightness == Brightness.dark
                            ? 'Dark Mode Active'
                            : 'Light Mode Active',
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: toggleTheme,
                        child: const Text('Toggle Theme'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}