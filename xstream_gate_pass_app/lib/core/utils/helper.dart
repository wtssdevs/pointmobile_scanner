import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:add_to_gallery/add_to_gallery.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

T? asT<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  return null;
}
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
extension HexString on String {
  int getHexValue() => int.parse(replaceAll('#', '0xff'));
}

List<T> flattenDeep<T>(Iterable<dynamic> list) => [
      for (var element in list)
        if (element is! Iterable) element else ...flattenDeep(element),
    ];

Map<int, T> mapFromTArray<T>(List<T> list) {
  var map = Map<int, T>.fromIterable(list, key: (e) => e.id, value: (e) => e);
  return map;
}

String convertToTitleCase(String text) {
  if (text.isEmpty) {
    return text;
  }

  if (text.length <= 1) {
    return text.toUpperCase();
  }

  // Split string into multiple words
  final List<String> words = text.split(' ');

  // Capitalize first letter of each words
  final capitalizedWords = words.map((word) {
    if (word.trim().isNotEmpty) {
      final String firstLetter = word.trim().substring(0, 1).toUpperCase();
      final String remainingLetters = word.trim().substring(1);

      return '$firstLetter$remainingLetters';
    }
    return '';
  });

  // Join/Merge all words back to one String
  return capitalizedWords.join(' ');
}

extension CapitalizedStringExtension on String {
  String toTitleCase() {
    return convertToTitleCase(this);
  }
}

extension StringExtensions on String {
  String removeWhitespace() {
    return this.replaceAll(' ', '');
  }
}

extension DoubleWhiteSpaceStringExtensions on String {
  String removeDoubleWhitespace() {
    return this.replaceAll('  ', ' ');
  }
}

Future<File?> saveSignatureImageWithRandomFileName(Uint8List imageAsBytes, [bool addToGallery = true]) async {
  try {
    final Directory extDir = await getTemporaryDirectory();
    final testDir = await Directory('${extDir.path}/TMS_Signatures').create(recursive: true);
    final String filePath = '${testDir.path}/Signature_${DateTime.now().millisecondsSinceEpoch}.png';
    File(filePath).writeAsBytesSync(imageAsBytes);

    final file = File(filePath);

    if (addToGallery) {
      File addToGalleryFile = await AddToGallery.addToGallery(
        originalFile: file,
        albumName: "Xstream_Gate_Pass",
        deleteOriginalFile: true,
      );

      return addToGalleryFile;
    }

    return file;
  } catch (e) {
    return null;
  }
}

Future<String?> convertFileStoreToBase64String(String localPath) async {
  try {
    final file = File(localPath);

    List<int> imageBytes = await file.readAsBytes(); // readAsBytesSync();
    String base64Image = "data:image/png;base64," + base64Encode(imageBytes);
    return base64Image;
  } catch (e) {
    return null;
  }
}

extension FormatDatedExtension on DateTime? {
  String toFormattedString() {
    try {
      if (this == null) {
        return "";
      }
      String formattedDate = DateFormat('yyyy/MM/dd HH:mm a').format(this!);
      return formattedDate;
    } catch (e) {
      return "";
    }
  }

  String getSocialDateFormat(DateTime tm) {
    DateTime today = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    Duration twoDay = new Duration(days: 2);
    Duration oneWeek = new Duration(days: 7);
    String month = "";
    switch (tm.month) {
      case 1:
        month = "January";
        break;
      case 2:
        month = "February";
        break;
      case 3:
        month = "March";
        break;
      case 4:
        month = "April";
        break;
      case 5:
        month = "May";
        break;
      case 6:
        month = "June";
        break;
      case 7:
        month = "July";
        break;
      case 8:
        month = "August";
        break;
      case 9:
        month = "September";
        break;
      case 10:
        month = "October";
        break;
      case 11:
        month = "November";
        break;
      case 12:
        month = "December";
        break;
    }

    Duration difference = today.difference(tm);

    if (difference.compareTo(oneDay) < 1) {
      return "Today";
    } else if (difference.compareTo(twoDay) < 1) {
      return "Yesterday";
    } else if (difference.compareTo(oneWeek) < 1) {
      switch (tm.weekday) {
        case 1:
          return "Monday";
        case 2:
          return "Tuesday";
        case 3:
          return "Wednesday";
        case 4:
          return "Thursday";
        case 5:
          return "Friday";
        case 6:
          return "Saturday";
        case 7:
          return "Sunday";
      }
    } else if (tm.year == today.year) {
      return '${tm.day} $month ${tm.year}';
      //return "${tm.day} $month";
    } else {
      return '${tm.day} $month ${tm.year}';
    }

    return "";
  }
}
