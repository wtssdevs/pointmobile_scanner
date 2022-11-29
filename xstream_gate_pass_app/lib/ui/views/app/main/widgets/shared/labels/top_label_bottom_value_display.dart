import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/box_text.dart';

class TopLabelWithTextWidget extends StatelessWidget {
  final String label;
  final String value;
  final String hasTextBadge;
  final CrossAxisAlignment crossAxisAlignment;
  const TopLabelWithTextWidget({Key? key, required this.label, required this.value, this.hasTextBadge = "", this.crossAxisAlignment = CrossAxisAlignment.stretch})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          BoxText.body(
            label,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            align: TextAlign.left,
          ),
          hasTextBadge.isEmpty
              ? BoxText.body(
                  value,
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                  //align: TextAlign.left,
                )
              : Chip(
                  padding: const EdgeInsets.all(0),
                  backgroundColor: Color(hasTextBadge.getHexValue()),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: const VisualDensity(horizontal: 0.0, vertical: -4),
                  label: BoxText.body(
                    value,
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    //align: TextAlign.left,
                  ),
                ),
        ],
      ),
    );
  }
}
