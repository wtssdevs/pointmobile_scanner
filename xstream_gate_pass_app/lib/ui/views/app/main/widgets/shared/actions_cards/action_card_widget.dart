import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';

class ActionCardWidget extends StatelessWidget {
  const ActionCardWidget({
    super.key,
    required this.title,
    required this.isIn,
    required this.icon,
    required this.color,
    this.description,
    this.onTap,
  });

  final String title;
  final bool isIn;
  final IconData icon;
  final Color color;
  final String? description;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = isIn;

    return GestureDetector(
      onTap: onTap != null ? () => onTap!() : null,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[700],
              size: 32,
            ),
            verticalSpaceSmall,
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.black,
              ),
            ),
            if (description != null) ...[
              verticalSpaceTiny,
              Text(
                description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
