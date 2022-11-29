import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';

class BoxText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign alignment;

  const BoxText.headingOne(this.text, {TextAlign align = TextAlign.start})
      : style = heading1Style,
        alignment = align;
  const BoxText.headingTwo(this.text, {TextAlign align = TextAlign.start})
      : style = heading2Style,
        alignment = align;
  const BoxText.headingThree(this.text, {TextAlign align = TextAlign.start})
      : style = heading3Style,
        alignment = align;
  const BoxText.headline(this.text, {TextAlign align = TextAlign.start})
      : style = headlineStyle,
        alignment = align;
  const BoxText.subheading(this.text, {TextStyle textStyle = subheadingStyle, TextAlign align = TextAlign.start})
      : style = textStyle,
        alignment = align;
  const BoxText.caption(this.text, {TextAlign align = TextAlign.start})
      : style = captionStyle,
        alignment = align;
  const BoxText.validationMessageList(this.text, {TextAlign align = TextAlign.start})
      : style = validationMessageStyle,
        alignment = align;
  const BoxText.tileTitle(this.text, {TextAlign align = TextAlign.start})
      : style = bodyTileStyle,
        alignment = align;
  const BoxText.subtitle(this.text, {TextAlign align = TextAlign.start})
      : style = bodySubtitleStyle,
        alignment = align;

  const BoxText.bodyActionButton(this.text, {TextAlign align = TextAlign.start})
      : style = bodyActionButtonStyle,
        alignment = align;

  const BoxText.bodyListheading(this.text, {TextAlign align = TextAlign.start})
      : style = bodyHeadingStyle,
        alignment = align;

  BoxText.body(this.text,
      {Color color = kcMediumGreyColor, double fontSize = 16, FontWeight fontWeight = FontWeight.w400, TextAlign align = TextAlign.start})
      : style = bodyStyle.copyWith(color: color, fontSize: fontSize, fontWeight: fontWeight),
        alignment = align;
  BoxText.label(this.text,
      {Color color = kcMediumGreyColor, double fontSize = 14, FontWeight fontWeight = FontWeight.w600, TextAlign align = TextAlign.start})
      : style = bodyStyle.copyWith(color: color, fontSize: fontSize, fontWeight: fontWeight),
        alignment = align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: alignment,
    );
  }
}
