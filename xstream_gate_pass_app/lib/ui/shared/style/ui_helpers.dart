// Horizontal Spacing
import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/core/enums/device_screen_type.dart';

const Widget horizontalSpaceTiny = SizedBox(width: 5.0);
const Widget horizontalSpaceSmall = SizedBox(width: 10.0);
const Widget horizontalSpaceRegular = SizedBox(width: 18.0);
const Widget horizontalSpaceMedium = SizedBox(width: 25.0);
const Widget horizontalSpaceLarge = SizedBox(width: 50.0);

const Widget verticalSpaceTiny = SizedBox(height: 5.0);
const Widget verticalSpaceSmall = SizedBox(height: 10.0);
const Widget verticalSpaceRegular = SizedBox(height: 18.0);
const Widget verticalSpaceMedium = SizedBox(height: 25.0);
const Widget verticalSpaceLarge = SizedBox(height: 50.0);

// Screen Size helpers

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;

double screenHeightPercentage(BuildContext context, {double percentage = 1}) => screenHeight(context) * percentage;

double screenWidthPercentage(BuildContext context, {double percentage = 1}) => screenWidth(context) * percentage;

DeviceScreenType getDeviceType(MediaQueryData? mediaQuery) {
  double deviceWidth = 0;
  if (mediaQuery != null) {
    deviceWidth = mediaQuery.size.shortestSide;
  } else {
    if (WidgetsBinding.instance == null) {
      WidgetsFlutterBinding.ensureInitialized();
    }

    deviceWidth = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.shortestSide;
  }

  return deviceWidth < 550 ? DeviceScreenType.Mobile : DeviceScreenType.Tablet;
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

// Text Styles

// To make it clear which weight we are using, we'll define the weight even for regular
// fonts
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
const TextStyle validationMessageStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.red);

//Load Items Tables
const kloadItemTableCellStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.black);
const kloadItemTableCellHeaderStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black);

const TextStyle bodyTileStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey);
const TextStyle bodySubtitleStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black);
const TextStyle bodyTextStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black);

const TextStyle tabBarHeadingTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);
const TextStyle persistentFooterButtonsTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white);

const TextStyle bodyActionButtonStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.white);

BoxDecoration fieldDecortaion = BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.grey[200]);

BoxDecoration disabledFieldDecortaion = BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.grey[100]);

const double fieldHeight = 55;
const double smallFieldHeight = 40;
const double inputFieldBottomMargin = 30;
const double inputFieldSmallBottomMargin = 0;
const EdgeInsets fieldPadding = const EdgeInsets.symmetric(horizontal: 15);
const EdgeInsets textFieldPadding = const EdgeInsets.all(15);
const EdgeInsets largeFieldPadding = const EdgeInsets.symmetric(horizontal: 15, vertical: 15);

const TextStyle buttonTitleTextStyleLrg = const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 16);

const TextStyle buttonTitleTextStyleRegular = const TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 14);
// Text Variables
const TextStyle buttonTitleTextStyle = const TextStyle(fontWeight: FontWeight.w700, color: Colors.white);

Widget spacedDivider = Column(
  children: const <Widget>[
    verticalSpaceMedium,
    const Divider(color: Colors.blueGrey, height: 5.0),
    verticalSpaceMedium,
  ],
);

Widget verticalSpace(double height) => SizedBox(height: height);

double screenHeightFraction(BuildContext context, {int dividedBy = 1, double offsetBy = 0}) => (screenHeight(context) - offsetBy) / dividedBy;

double screenWidthFraction(BuildContext context, {int dividedBy = 1, double offsetBy = 0}) => (screenWidth(context) - offsetBy) / dividedBy;

double halfScreenWidth(BuildContext context) => screenWidthFraction(context, dividedBy: 2);

double thirdScreenWidth(BuildContext context) => screenWidthFraction(context, dividedBy: 3);
