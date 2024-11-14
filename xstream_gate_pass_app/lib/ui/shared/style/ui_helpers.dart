import 'dart:math';

import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';

enum DeviceScreenType { mobile, tablet, desktop }

DeviceScreenType getDeviceType(MediaQueryData? mediaQuery) {
  double deviceWidth = 0;
  if (mediaQuery != null) {
    deviceWidth = mediaQuery.size.shortestSide;
  } else {
    deviceWidth = WidgetsBinding
        .instance.platformDispatcher.views.first.physicalSize.shortestSide;
  }

  return deviceWidth < 550 ? DeviceScreenType.mobile : DeviceScreenType.tablet;

  // if (deviceWidth < 550) {
  //   return DeviceScreenType.Desktop;
  // }
  //
  //
  // if (deviceWidth > 950) {
  //   return DeviceScreenType.Desktop;
  // }
  //
  // if (deviceWidth > 600) {
  //   return DeviceScreenType.Tablet;
  // }
  //
  // return DeviceScreenType.Mobile;
}

const Widget listDivider = Divider(
  color: Colors.grey,
);

const double _tinySize = 4.0;
const double _smallSize = 10.0;
const double _mediumSize = 25.0;
const double _largeSize = 50.0;
const double _massiveSize = 120.0;

const Widget horizontalSpaceTiny = SizedBox(width: _tinySize);
const Widget horizontalSpaceSmall = SizedBox(width: _smallSize);
const Widget horizontalSpaceMedium = SizedBox(width: _mediumSize);
const Widget horizontalSpaceLarge = SizedBox(width: _largeSize);

const Widget verticalSpaceTiny = SizedBox(height: _tinySize);
const Widget verticalSpaceSmall = SizedBox(height: _smallSize);
const Widget verticalSpaceMedium = SizedBox(height: _mediumSize);
const Widget verticalSpaceLarge = SizedBox(height: _largeSize);
const Widget verticalSpaceMassive = SizedBox(height: _massiveSize);

Widget spacedDivider = const Column(
  children: <Widget>[
    verticalSpaceMedium,
    Divider(color: Colors.blueGrey, height: 5.0),
    verticalSpaceMedium,
  ],
);

Widget verticalSpace(double height) => SizedBox(height: height);

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

double screenHeightPercentage(BuildContext context, {double percentage = 1}) =>
    screenHeight(context) * percentage;

double screenWidthPercentage(BuildContext context, {double percentage = 1}) =>
    screenWidth(context) * percentage;
double screenHeightFraction(BuildContext context,
        {int dividedBy = 1, double offsetBy = 0, double max = 3000}) =>
    min((screenHeight(context) - offsetBy) / dividedBy, max);

double screenWidthFraction(BuildContext context,
        {int dividedBy = 1, double offsetBy = 0, double max = 3000}) =>
    min((screenWidth(context) - offsetBy) / dividedBy, max);

double halfScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 2);

double thirdScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 3);

double quarterScreenWidth(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 4);

double getResponsiveHorizontalSpaceMedium(BuildContext context) =>
    screenWidthFraction(context, dividedBy: 10);
double getResponsiveSmallFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 14, max: 15);

double getResponsiveMediumFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 16, max: 17);

double getResponsiveLargeFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 21, max: 31);

double getResponsiveExtraLargeFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 25);

double getResponsiveMassiveFontSize(BuildContext context) =>
    getResponsiveFontSize(context, fontSize: 30);

double getResponsiveFontSize(BuildContext context,
    {double? fontSize, double? max}) {
  max ??= 100;

  var responsiveSize = min(
      screenWidthFraction(context, dividedBy: 10) * ((fontSize ?? 100) / 100),
      max);

  return responsiveSize;
}

//CARDS -->> SP/Vendors
const kSPTimeCountDownTextStyleTitle =
    TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red);

const kSPCardTextStyleTitle =
    TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black);
const kSPCardTextStyleSubTitle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: Colors.black,
    fontStyle: FontStyle.italic);

// Text Styles
const kProdCardTextStyleDiscountPercBig =
    TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white);
// To make it clear which weight we are using, we'll define the weight even for regular
// fonts
const menuButtonHeaderTextStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black);
const TextStyle productsTitleStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kcPrimaryColor);
const TextStyle productsDescTitleStyle = TextStyle(
    fontSize: 12, fontWeight: FontWeight.normal, color: kcPrimaryColor);

const TextStyle appBarTitleStyle =
    TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kcPrimaryColor);

const TextStyle heading1Style = TextStyle(
  fontSize: 34,
  fontWeight: FontWeight.w400,
);

const TextStyle heading2Style = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w600,
);

const TextStyle heading3Style = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.w600,
);

const TextStyle headlineStyle = TextStyle(
  fontSize: 30,
  fontWeight: FontWeight.w700,
);
const TextStyle bodyHeadingStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w700,
);
const TextStyle bodyStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w400,
);

const TextStyle subheadingStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w400,
);

const TextStyle captionStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
);

const kFindFilterChipTextStyle =
    TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black);
const TextStyle validationMessageStyle =
    TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.red);

//Load Items Tables
const kloadItemTableCellStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black);
const kloadItemTableCellHeaderStyle =
    TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black);

const headerSubTextMed =
    TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white);
const headerSubText =
    TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white);

const TextStyle bodyTileStyle =
    TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey);
const TextStyle bodySubtitleStyle =
    TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black);
const TextStyle bodyTextStyle =
    TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black);

const TextStyle tabBarHeadingTextStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);
const TextStyle persistentFooterButtonsTextStyle =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white);

const TextStyle bodyActionButtonStyle =
    TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white);

BoxDecoration fieldDecortaion = BoxDecoration(
    borderRadius: BorderRadius.circular(5), color: Colors.grey[350]);

BoxDecoration disabledFieldDecortaion = BoxDecoration(
    borderRadius: BorderRadius.circular(5), color: Colors.grey[100]);

const double fieldHeight = 55;
const double smallFieldHeight = 40;
const double inputFieldBottomMargin = 30;
const double inputFieldSmallBottomMargin = 0;
const EdgeInsets fieldPadding = EdgeInsets.symmetric(horizontal: 15);
const EdgeInsets textFieldPadding = EdgeInsets.all(15);
const EdgeInsets largeFieldPadding =
    EdgeInsets.symmetric(horizontal: 15, vertical: 15);

const TextStyle buttonTitleTextStyleLrg =
    TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16);

const TextStyle buttonTitleTextStyleRegular =
    TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14);
// Text Variables
const TextStyle buttonTitleTextStyle =
    TextStyle(fontWeight: FontWeight.w700, color: Colors.white);
