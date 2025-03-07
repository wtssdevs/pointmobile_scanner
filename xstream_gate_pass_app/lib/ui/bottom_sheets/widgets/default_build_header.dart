import 'package:flutter/material.dart';

import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';

class BaseSheetHeader extends StatelessWidget {
  final Function onTap;
  final String title;
  const BaseSheetHeader({super.key, required this.onTap, required this.title});

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kcPrimaryColor),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => onTap(),
            ),
          ],
        ),
        const Divider(),
        verticalSpaceSmall,
      ],
    );
  }
}
