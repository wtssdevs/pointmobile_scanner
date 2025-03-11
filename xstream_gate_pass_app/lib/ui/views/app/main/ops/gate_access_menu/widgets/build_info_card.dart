import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';

class BuildInfoCard extends StatelessWidget {
  final Function? onTap;
  final double width;
  final String title;
  final bool isSelected;
  final bool hasInfo;
  final IconData icon;
  final Color color;
  //inoput a list of strings
  final List<Widget> infoList;

  const BuildInfoCard({
    super.key,
    required this.width,
    required this.title,
    required this.isSelected,
    required this.hasInfo,
    required this.icon,
    required this.color,
    required this.infoList,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Column(
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
                    //add icon for when info is not available
                    if (!hasInfo)
                      const Icon(
                        Icons.barcode_reader,
                        color: Colors.red,
                        size: 38,
                      ),
                    if (hasInfo)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 38,
                      ),
                  ],
                ),
                verticalSpaceSmall,
                ...infoList,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
