import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final Function(ThemeMode) setTheme;
  final Function(Color) setThemeColor;
  final Color currentThemeColor;

  const ProfileScreen({
    super.key,
    required this.setTheme,
    required this.setThemeColor,
    required this.currentThemeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Combined Theme card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Theme Settings',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  
                  // Theme mode section
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
                      DropdownButton<ThemeMode>(
                        value:
                            Theme.of(context).brightness == Brightness.dark
                                ? ThemeMode.dark
                                : ThemeMode.light,
                        onChanged: (ThemeMode? newThemeMode) {
                          if (newThemeMode != null) {
                            setTheme(newThemeMode);
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text('System'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text('Light'),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const Divider(height: 30),
                  
                  // Theme color section
                  Text(
                    'Theme Color',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildColorOption(context, const Color.fromARGB(255, 255, 11, 153), 'Pink'),
                      _buildColorOption(context, const Color.fromARGB(255, 26, 152, 255), 'Blue'),
                      _buildColorOption(context, const Color.fromARGB(255, 27, 255, 34), 'Green'),
                      _buildColorOption(context, const Color.fromARGB(255, 255, 198, 111), 'Orange'),
                      _buildColorOption(context, const Color.fromARGB(255, 222, 36, 255), 'Purple'),
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

  Widget _buildColorOption(BuildContext context, Color color, String label) {
    final isSelected = currentThemeColor == color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          InkWell(
            onTap: () => setThemeColor(color),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: Colors.black.withAlpha(77),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ]
                        : null,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
