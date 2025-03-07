import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';

class BuildInfoCard extends StatelessWidget {
  final double width;
  final String title;
  final bool isIn;
  final IconData icon;
  final Color color;
  //inoput a list of strings
  final List<Widget> infoList;

  const BuildInfoCard({
    super.key,
    required this.width,
    required this.title,
    required this.isIn,
    required this.icon,
    required this.color,
    required this.infoList,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = isIn;
    return Column(
      children: [
        verticalSpaceSmall,
        Container(
          width: width, // MediaQuery.of(context).size.width * 0.95,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    icon,
                    color: isSelected ? color : Colors.grey[700],
                    size: 32,
                  ),
                ],
              ),
              verticalSpaceSmall,
              ...infoList,
            ],
          ),
        ),
      ],
    );
  }
}
