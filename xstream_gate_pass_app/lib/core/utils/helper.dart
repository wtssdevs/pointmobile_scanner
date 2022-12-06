import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:add_to_gallery/add_to_gallery.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xstream_gate_pass_app/core/models/shared/base_lookup.dart';
import 'package:xstream_gate_pass_app/core/models/shared/merge_delta_reponse%20copy.dart';

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

MergeDeltaResponse<T> getDeltaMerge<T>(List<T> local, List<T> server) {
  var delta = MergeDeltaResponse(added: <T>[], changed: <T>[], deleted: <T>[], same: <T>[], all: <T>[]);

  //map ids from array
  // old local
  var mapLocal = mapFromTArray(local);
  var mapServer = mapFromTArray(server);

  mapLocal.forEach((key, value) {
    //local
    if (!mapServer.containsKey(key)) {
      //was deleted  // Remove from local
      delta.deleted.add(value);
    } else {
      //com
      var iseq = isTEqual(mapServer[key], value);

      if (iseq == false) {
        //maybe save local here if we have status update or signature etc???
        if (value is BaseLookup) {
          value.mergeUpdate(mapServer[key]! as BaseLookup);
        }
        //delta.changed.add(mapServer[key]!); // update local from server "Server WINS Conflict"
        delta.changed.add(value); // update local from server "Local WINS Conflict"
      } else {
        delta.same.add(value);
      }
    }
  });

  mapServer.forEach((key, value) {
    if (!mapLocal.containsKey(key)) {
      delta.added.add(value);
    }
  });

  delta.all = [...delta.added, ...delta.changed, ...delta.same];

  return delta;
}

MergeDeltaResponse<T> getDeltaMergLocalWins<T>(List<T> local, List<T> server) {
  var delta = MergeDeltaResponse(added: <T>[], changed: <T>[], deleted: <T>[], same: <T>[], all: <T>[]);

  //map ids from array
  // old local
  var mapLocal = mapFromTArray(local);
  var mapServer = mapFromTArray(server);

  mapLocal.forEach((key, value) {
    //local
    if (!mapServer.containsKey(key)) {
      //was deleted  // Remove from local
      delta.deleted.add(value);
    } else {
      var iseq = isTEqual(mapServer[key], value);
      if (iseq == false) {
        if (value is BaseLookup) {
          value.mergeUpdate(mapServer[key]! as BaseLookup);
        } else {
          var serverMapFound = mapServer[key];
          if (serverMapFound != null) {
            value = serverMapFound; //overwrite local with server values here
          }
        }
        delta.changed.add(value); //maybe merge changes here based on rules set
      } else {
        delta.same.add(value);
      }
    }
  });

  mapServer.forEach((key, value) {
    if (!mapLocal.containsKey(key)) {
      delta.added.add(value);
    }
  });

  delta.all = [...delta.added, ...delta.changed, ...delta.same];

  return delta;
}

bool isTEqual<T>(T s, T l) {
  if (s is BaseLookup && l is BaseLookup) {
    return s.isEqualToServer(l);
  }

  return false;
}

Map<int, T> mapFromTArray<T>(List<T> list) {
  var map = Map<int, T>.fromIterable(list, key: (e) => e.id, value: (e) => e);
  return map;
}

List<T> flattenDeep<T>(Iterable<dynamic> list) => [
      for (var element in list)
        if (element is! Iterable) element else ...flattenDeep(element),
    ];

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

  double? initScale({
    required Size imageSize,
    required Size size,
    double? initialScale,
  }) {
    final double n1 = imageSize.height / imageSize.width;
    final double n2 = size.height / size.width;
    if (n1 > n2) {
      final FittedSizes fittedSizes = applyBoxFit(BoxFit.contain, imageSize, size);
      //final Size sourceSize = fittedSizes.source;
      final Size destinationSize = fittedSizes.destination;
      return size.width / destinationSize.width;
    } else if (n1 / n2 < 1 / 4) {
      final FittedSizes fittedSizes = applyBoxFit(BoxFit.contain, imageSize, size);
      //final Size sourceSize = fittedSizes.source;
      final Size destinationSize = fittedSizes.destination;
      return size.height / destinationSize.height;
    }

    return initialScale;
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
