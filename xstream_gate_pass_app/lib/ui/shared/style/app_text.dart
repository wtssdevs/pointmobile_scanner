import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign alignment;

  const AppText.productName(this.text,
      {super.key, TextAlign align = TextAlign.start})
      : style = productsTitleStyle,
        alignment = align;

  const AppText.productsDesc(this.text,
      {super.key, TextAlign align = TextAlign.start})
      : style = productsDescTitleStyle,
        alignment = align;

  const AppText.appBarTitle(this.text,
      {super.key, TextAlign align = TextAlign.start})
      : style = appBarTitleStyle,
        alignment = align;

  const AppText.headingOne(this.text,
      {super.key, TextAlign align = TextAlign.start})
      : style = heading1Style,
        alignment = align;
  const AppText.headingTwo(this.text,
      {super.key, TextAlign align = TextAlign.start})
      : style = heading2Style,
        alignment = align;
  const AppText.headingThree(this.text,
      {super.key, TextAlign align = TextAlign.start})
      : style = heading3Style,
        alignment = align;
  const AppText.headline(this.text,
      {super.key, TextAlign align = TextAlign.start})
      : style = headlineStyle,
        alignment = align;
  const AppText.subheading(this.text,
      {super.key,
      TextStyle textStyle = subheadingStyle,
      TextAlign align = TextAlign.start})
      : style = textStyle,
        alignment = align;
  const AppText.caption(this.text,
      {super.key, TextAlign align = TextAlign.start})
      : style = captionStyle,
        alignment = align;
  const AppText.validationMessageList(this.text,
      {super.key, TextAlign align = TextAlign.start})
      : style = validationMessageStyle,
        alignment = align;
  const AppText.tileTitle(this.text,
      {super.key, TextAlign align = TextAlign.start})
      : style = bodyTileStyle,
        alignment = align;
  const AppText.subtitle(this.text,
      {super.key, TextAlign align = TextAlign.start})
      : style = bodySubtitleStyle,
        alignment = align;

  const AppText.bodyActionButton(this.text,
      {super.key, TextAlign align = TextAlign.start})
      : style = bodyActionButtonStyle,
        alignment = align;

  const AppText.bodyListheading(this.text,
      {Key? key, TextAlign align = TextAlign.start})
      : style = bodyHeadingStyle,
        alignment = align,
        super(key: key);

  AppText.body(this.text,
      {Key? key,
      Color color = kcPrimaryColorDark,
      double fontSize = 16,
      FontWeight fontWeight = FontWeight.w400,
      TextAlign align = TextAlign.start})
      : style = bodyStyle.copyWith(
            color: color, fontSize: fontSize, fontWeight: fontWeight),
        alignment = align,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    //final scaledFontSize = MediaQuery.textScalerOf(context).scale(style.fontSize ?? 12);
    var textScaler = MediaQuery.textScalerOf(context)
        .clamp(minScaleFactor: 1.0, maxScaleFactor: 1.2);
    return Text(
      text,
      textScaler: textScaler,
      style: style,
      textAlign: alignment,
    );
  }
}
