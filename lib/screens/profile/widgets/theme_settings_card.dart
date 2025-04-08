import 'package:flutter/material.dart';
import 'color_option.dart';

class ThemeSettingsCard extends StatelessWidget {
  final Function(ThemeMode) setThemeMode;
  final Function(Color) setThemeColor;
  final Color currentThemeColor;
  final ThemeMode currentThemeMode;

  const ThemeSettingsCard({
    super.key,
    required this.setThemeMode,
    required this.setThemeColor,
    required this.currentThemeColor,
    required this.currentThemeMode,
  });

  static const List<Map<String, dynamic>> _colorOptions = [
    {'color': Color.fromARGB(255, 255, 11, 153), 'label': 'Pink'},
    {'color': Color.fromARGB(255, 26, 152, 255), 'label': 'Blue'},
    {'color': Color.fromARGB(255, 27, 255, 34), 'label': 'Green'},
    {'color': Color.fromARGB(255, 255, 198, 111), 'label': 'Orange'},
    {'color': Color.fromARGB(255, 222, 36, 255), 'label': 'Purple'},
  ];

  @override
  Widget build(BuildContext context) {
    final Brightness currentBrightness = Theme.of(context).brightness;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Theme Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  currentBrightness == Brightness.dark
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                  size: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  currentBrightness == Brightness.dark
                      ? 'Dark Mode'
                      : 'Light Mode',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 16),
                DropdownButton<ThemeMode>(
                  value: currentThemeMode,
                  onChanged: (ThemeMode? newThemeMode) {
                    if (newThemeMode != null) {
                      setThemeMode(newThemeMode);
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
                  underline: Container(height: 0),
                  style: Theme.of(context).textTheme.bodyMedium,
                  iconEnabledColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
            const Divider(height: 30),
            Text(
              'Accent Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  _colorOptions.map((option) {
                    final Color color = option['color'] as Color;
                    final String label = option['label'] as String;
                    return ColorOption(
                      color: color,
                      label: label,
                      isSelected: currentThemeColor.value == color.value,
                      onTap: () => setThemeColor(color),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
