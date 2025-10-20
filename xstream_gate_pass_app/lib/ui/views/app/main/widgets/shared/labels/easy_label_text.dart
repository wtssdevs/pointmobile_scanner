import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/box_text.dart';

class EasyLabelText extends StatelessWidget {
  final String label;
  final String value;
  final double labelFontSize;
  final double textFontSize;
  const EasyLabelText(
      {Key? key,
      required this.label,
      required this.value,
      this.labelFontSize = 11,
      this.textFontSize = 10})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    //EdgeInsets paddingValues = const EdgeInsets.only(left: 1, top: 2);
    //return Visibility(visible: value.isNotEmpty, child: Text('$label: ${value}'));

    //create rich text widget

    return Visibility(
      visible: value.isNotEmpty,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            TextSpan(
              text: ": ",
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: textFontSize,
                fontWeight: FontWeight.normal,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
