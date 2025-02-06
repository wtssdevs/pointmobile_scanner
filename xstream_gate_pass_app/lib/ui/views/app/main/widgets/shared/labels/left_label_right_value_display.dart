import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/box_text.dart';

class LeftLabelWithRightTextWidget extends StatelessWidget {
  final String label;
  final String value;
  const LeftLabelWithRightTextWidget({Key? key, required this.label, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    EdgeInsets paddingValues = const EdgeInsets.only(left: 1, top: 2);
    return Visibility(
      visible: value.isNotEmpty,
      child: Row(children: [
        Padding(
          padding: paddingValues,
          child: BoxText.body(
            label,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Padding(
          padding: paddingValues,
          child: BoxText.body(
            ":",
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Flexible(
          child: Padding(
            padding: paddingValues,
            child: BoxText.body(
              value,
              fontSize: 10,
              fontWeight: FontWeight.normal,
              color: Colors.black,
            ),
          ),
        ),
      ]),
    );
  }
}
