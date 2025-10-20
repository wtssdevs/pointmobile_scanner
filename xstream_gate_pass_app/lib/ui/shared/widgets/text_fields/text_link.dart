import 'package:flutter/material.dart';

class TextLink extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final Function? onPressed;
  const TextLink(this.text, this.textStyle, {this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed as void Function()?,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: textStyle,
      ),
    );
  }
}
