import 'package:flutter/material.dart';

class ColorOption extends StatelessWidget {
  final Color color;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ColorOption({
    super.key,
    required this.color,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.onSurface
                          : Colors.transparent,
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
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
