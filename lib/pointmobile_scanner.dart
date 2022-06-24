import 'dart:async';
import 'package:flutter/services.dart';

class PointmobileScanner {
  static const MethodChannel channel =
      const MethodChannel("pointmobile_scanner");

  static const String ON_DECODE = "onDecode";
  static const String ON_ERROR = "onError";

  static const int SYM_NIL = 0;
  static const int SYM_AIRLINE_2OF5_13_DIGIT = 1;
  static const int SYM_AIRLINE_2OF5_15_DIGIT = 2;
  static const int SYM_AZTEC = 3;
  static const int SYM_AUSTRALIAN_POSTAL = 4;
  static const int SYM_BOOKLAND_EAN = 5;
  static const int SYM_BPO = 6;
  static const int SYM_CANPOST = 7;
  static const int SYM_CHINAPOST = 8;
  static const int SYM_CHINESE_2OF5 = 9;
  static const int SYM_CODABAR = 10;
  static const int SYM_CODABLOCK = 11;
  static const int SYM_CODE11 = 12;
  static const int SYM_CODE128 = 13;
  static const int SYM_CODE16K = 14;
  static const int SYM_CODE32 = 15;
  static const int SYM_CODE39 = 16;
  static const int SYM_CODE49 = 17;
  static const int SYM_CODE93 = 18;
  static const int SYM_COMPOSITE = 19;
  static const int SYM_COUPON_CODE = 20;
  static const int SYM_DATAMATRIX = 21;
  static const int SYM_DISCRETE_2OF5 = 22;
  static const int SYM_DUTCH_POSTAL = 23;
  static const int SYM_EAN128 = 24;
  static const int SYM_EAN13 = 25;
  static const int SYM_EAN8 = 26;
  static const int SYM_GS1_DATABAR_14 = 27;
  static const int SYM_GS1_DATABAR_EXPANDED = 28;
  static const int SYM_GS1_DATABAR_LIMITED = 29;
  static const int SYM_HONGKONG_2OF5 = 30;
  static const int SYM_IATA_2OF5 = 31;
  static const int SYM_IDTAG = 32;
  static const int SYM_INTERLEAVED_2OF5 = 33;
  static const int SYM_ISBT128 = 34;
  static const int SYM_JAPANESE_POSTAL = 35;
  static const int SYM_KOREAN_POSTAL = 36;
  static const int SYM_MATRIX_2OF5 = 37;
  static const int SYM_MAXICODE = 38;
  static const int SYM_MESA = 39;
  static const int SYM_MICRO_PDF417 = 40;
  static const int SYM_MICRO_QR = 41;
  static const int SYM_MSI = 42;
  static const int SYM_NEC_2OF5 = 43;
  static const int SYM_OCR = 44;
  static const int SYM_PDF417 = 45;
  static const int SYM_PLESSEY = 46;
  static const int SYM_POSICODE = 47;
  static const int SYM_POST_US4 = 48;
  static const int SYM_QR = 49;
  static const int SYM_STRAIGHT_2OF5 = 50;
  static const int SYM_STANDARD_2OF5 = 51;
  static const int SYM_TELEPEN = 52;
  static const int SYM_TLCODE39 = 53;
  static const int SYM_TRIOPTIC = 54;
  static const int SYM_UK_POSTAL = 55;
  static const int SYM_UPCA = 56;
  static const int SYM_UPCE = 57;
  static const int SYM_UPCE1 = 58;
  static const int SYM_US_PLANET = 59;
  static const int SYM_US_POSTNET = 60;
  static const int SYM_USPS_4CB = 61;
  static const int SYM_RSS = 62;
  static const int SYM_LABEL = 63;
  static const int SYM_HANXIN = 64;
  static const int SYM_GRIDMATRIX = 65;
  static const int SYM_INFO_MAIL = 66;
  static const int SYM_INTELLIGENT_MAIL = 67;
  static const int SYM_SWEDENPOST = 68;
  static const int SYM_LAST = 69;

  static Future<bool> initScanner() async {
    return await channel.invokeMethod<bool>("initScanner") ?? false;
  }

  static void enableScanner() {
    channel.invokeMethod("enableScanner");
  }

  static void disableScanner() {
    channel.invokeMethod("disableScanner");
  }

  static void enableBeep() {
    channel.invokeMethod("enableBeep");
  }

  static void disableBeep() {
    channel.invokeMethod("disableBeep");
  }

  static void enableSymbology(int nSymId) {
    channel.invokeMethod("enableSymbology", nSymId.toString());
  }

  static void disableSymbology(int nSymId) {
    channel.invokeMethod("disableSymbology", nSymId.toString());
  }

  static void triggerOn() {
    channel.invokeMethod("triggerOn");
  }

  static void triggerOff() {
    channel.invokeMethod("triggerOff");
  }
}
