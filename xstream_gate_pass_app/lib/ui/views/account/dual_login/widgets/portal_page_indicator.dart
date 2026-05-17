import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';

class PortalPageIndicator extends StatelessWidget {
  const PortalPageIndicator({Key? key, required this.selectedIndex})
      : super(key: key);

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(2, (index) {
        final selected = selectedIndex == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: selected ? 22 : 8,
          decoration: BoxDecoration(
            color: selected ? kcPrimaryColor : Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}