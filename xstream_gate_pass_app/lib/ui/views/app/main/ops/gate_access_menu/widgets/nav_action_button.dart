import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NavActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isVisible;
  final bool enabled;

  const NavActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isVisible = true,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    final effectiveColor = enabled ? color : Theme.of(context).disabledColor;
    return Expanded(
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              icon,
              color: effectiveColor,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: effectiveColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
