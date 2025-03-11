import 'dart:convert';
import 'dart:typed_data';
import 'package:asn1lib/asn1lib.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_id_doc.dart';

/// A South African Driver's License. Includes all the details of the license.
class RsaDriversLicense implements RsaIdDocument {
  /// The ID Number of the person to whom this document belongs.
  final String idNumber;

  /// The first names of the person to whom this document belongs.
  ///
  /// May only contain initials if first names are not available.
  final String firstNames;

  /// The last name of the person to whom this document belongs.
  final String surname;

  /// The text representing gender of the person to whom this document belongs.
  ///
  /// 'M' and 'F' represent Male and Female.
  final String gender;

  /// The birth date of the person to whom this document belongs.
  final DateTime birthDate;

  /// The license number of this license.
  final String licenseNumber;

  /// The list of vehicle codes appearing on the license.
  final List<String> vehicleCodes;

  /// The PrDP Code appearing on the license.
  final String prdpCode;

  /// The country code representing the country in which the ID of the person
  /// to whom this document belongs was issued.
  final String idCountryOfIssue;

  /// The country code representing the country in which this license was issued.
  final String licenseCountryOfIssue;

  /// The vehicle restrictions placed on this license
  final List<String> vehicleRestrictions;

  /// The type of the ID number. '02' represents a South African ID number.
  final String idNumberType;

  /// A string representing driver restriction codes placed on this license.
  ///
  /// '00' = none
  /// '10' = glasses
  /// '20' = artificial limb
  /// '12' = glasses and artificial limb
  final String driverRestrictions;

  /// The expiry date of the PrDP Permit.
  final DateTime? prdpExpiry;

  /// The issue number of this license.
  final String licenseIssueNumber;

  /// The date from which this license is valid.
  final DateTime validFrom;

  /// The date to which this license is valid.
  final DateTime validTo;

  /// The issue date for each license code. Normally contains a date for each
  /// vehicleCode in [vehicleCodes].
  final List<DateTime?>? issueDates;

  /// The image data of the photo on this license in bytes.
  ///
  /// TODO: Determine how this data can be decoded to provide an actual image.
  final Uint8List? imageData;

  const RsaDriversLicense({
    required this.idNumber,
    required this.firstNames,
    required this.surname,
    required this.gender,
    required this.birthDate,
    this.issueDates,
    required this.licenseNumber,
    required this.vehicleCodes,
    required this.prdpCode,
    required this.idCountryOfIssue,
    required this.licenseCountryOfIssue,
    required this.vehicleRestrictions,
    required this.idNumberType,
    required this.driverRestrictions,
    required this.prdpExpiry,
    required this.licenseIssueNumber,
    required this.validFrom,
    required this.validTo,
    required this.imageData,
  });

  Uint8List? extractImageData(Uint8List bytes) {
    // Replace the TODO and section3 variable with this code:

// Extract the length of Section 3 (image data)
// Using lower 12 bits from bytes 8-9 in the header
    int section3Length = ((bytes[8] & 0x0F) << 8) | bytes[9];

// Calculate start position of Section 3
    int section3Start = 10 + bytes[5] + bytes[7];

// Extract the image data
    Uint8List? section3 = section3Length > 0 ? bytes.sublist(section3Start, section3Start + section3Length) : null;

// Parse the image data if present
    Uint8List? imageData = null;
    if (section3 != null && section3.length >= 7) {
      // Check for 'WI' marker which indicates image data
      if (section3[0] == 0x57 && section3[1] == 0x49) {
        // Image format info is in the next few bytes
        // Height: bytes 3-4 (00 fa = 250 pixels)
        // Width: bytes 5-6 (00 c8 = 200 pixels)
        int height = (section3[3] << 8) | section3[4];
        int width = (section3[5] << 8) | section3[6];

        // The actual image data starts after byte 12
        if (section3.length > 12) {
          imageData = section3.sublist(12);
        }
      }
    }

    return imageData;
  }

// New cleaning function
  static Uint8List _cleanRawBytes(Uint8List bytes) {
    // Remove any BOM or control characters at the beginning
    int startIndex = 0;
    while (startIndex < bytes.length && (bytes[startIndex] < 32 || bytes[startIndex] > 126)) {
      startIndex++;
    }

    // Remove any trailing control characters
    int endIndex = bytes.length;
    while (endIndex > startIndex && (bytes[endIndex - 1] < 32 || bytes[endIndex - 1] > 126)) {
      endIndex--;
    }

    // If we removed anything, create a new sublist
    if (startIndex > 0 || endIndex < bytes.length) {
      return bytes.sublist(startIndex, endIndex);
    }

    return bytes;
  }

  /// Returns a `DriversLicense` instance from the bytes read from the
  /// barcode of the DriversLicense.
  ///
  /// IMPORTANT: [bytes] is the RAW bytes from the barcode. Some barcode
  /// scanner plugins expose the String of the barcode which has been decoded using
  /// UTF encoding - this corrupts the raw bytes when encoding the string to bytes again.
  /// Try to use a barcode scanner which exposes the raw bytes directly (ie. before
  /// any encoding/decoding takes place).
  ///
  /// See:
  /// - https://mybroadband.co.za/forum/threads/decode-drivers-licence-barcode.382187/
  /// - https://github.com/ugommirikwe/sa-license-decoder/blob/master/SPEC.md
  /// - https://stackoverflow.com/questions/17549231/decode-south-african-za-drivers-license
  factory RsaDriversLicense.fromBarcodeBytes(Uint8List bytes) {
    try {
      // Clean the bytes before processing
      //bytes = _cleanRawBytes(bytes);
      // Check if we have 721 bytes (sometimes scanners add an extra byte)
      if (bytes.length == 721) {
        // Skip the last byte which is likely added by the scanner as a newline character or terminator
        bytes = bytes.sublist(0, 720);
      } else if (bytes.length != 720) {
        throw FormatException('Invalid South African driver\'s license barcode data length: ${bytes.length}.');
      }

      bytes = _decodeDriversAll(bytes);
      var section1 = bytes.sublist(10, 10 + bytes[5]);
      var section2 = bytes.sublist(10 + bytes[5], 10 + bytes[5] + bytes[7]);

      // TODO: Determine length of section 3 (Image Section) and extract image.
      var section3;

      var section1Values = _getSection1Values(section1);
      var section2Values = _getSection2Values(section2);

      var idNumber = section1Values[14];
      var firstNames = section1Values[5];
      var surname = section1Values[4];
      var gender;
      section2Values[11] == '01' ? gender = 'M' : gender = 'F';
      var birthDate = section2Values[8];
      var issueDates = List<DateTime?>.from(section2Values.sublist(1, 5));
      issueDates.removeWhere((date) => date == null);
      var licenseNumber = section1Values[13];
      var vehicleCodes = section1Values.sublist(0, 4);
      vehicleCodes.removeWhere((code) => code.isEmpty);
      var prdpCode = section1Values[6];
      var idCountryOfIssue = section1Values[7];
      var licenseCountryOfIssue = section1Values[8];
      var vehicleRestrictions = section1Values.sublist(9, 13);
      vehicleRestrictions.removeWhere((code) => code.isEmpty);
      var idNumberType = section2Values[0];
      var driverRestrictions = section2Values[5];
      var prdpExpiry = section2Values[6];
      var licenseIssueNumber = section2Values[7];
      var validFrom = section2Values[9];
      var validTo = section2Values[10];
      var imageData = section3;

      return RsaDriversLicense(
        idNumber: idNumber,
        firstNames: firstNames,
        surname: surname,
        gender: gender,
        birthDate: birthDate,
        issueDates: issueDates,
        licenseNumber: licenseNumber,
        vehicleCodes: vehicleCodes,
        prdpCode: prdpCode,
        idCountryOfIssue: idCountryOfIssue,
        licenseCountryOfIssue: licenseCountryOfIssue,
        vehicleRestrictions: vehicleRestrictions,
        idNumberType: idNumberType,
        driverRestrictions: driverRestrictions,
        prdpExpiry: prdpExpiry,
        licenseIssueNumber: licenseIssueNumber,
        validFrom: validFrom,
        validTo: validTo,
        imageData: imageData,
      );
    } catch (e) {
      throw FormatException('Could not instantiate Drivers License from bytes: $e');
    }
  }
// Replace direct String.fromCharCodes with a safer version
  static String safeFromCharCodes(List<int> bytes) {
    try {
      return String.fromCharCodes(bytes);
    } catch (e) {
      // Try UTF-8 decoding instead
      try {
        return utf8.decode(bytes, allowMalformed: true);
      } catch (_) {
        // Last resort - replace invalid bytes
        return String.fromCharCodes(bytes.map((b) => b >= 32 && b <= 126 ? b : 46) // Replace with '.'
            );
      }
    }
  }

  static List<String> _getSection1Values(Uint8List bytes) {
    try {
      var values = <String>[];
      var prevDeliminator;
      while (values.length < 14) {
        var index = bytes.indexWhere((i) => i == 224 || i == 225);

        if (prevDeliminator == 225) {
          values.add('');

          var value = safeFromCharCodes(bytes.sublist(0, index));
          if (value.isNotEmpty) {
            values.add(value);
          }
        } else {
          var value = safeFromCharCodes(bytes.sublist(0, index));
          values.add(value);
        }

        prevDeliminator = bytes[index];
        bytes = bytes.sublist(index + 1);
      }
      values.add(safeFromCharCodes(bytes));

      return values;
    } catch (e) {
      rethrow;
    }
  }

  /// A helper function for [DriversLicense..fromBarcodeBytes]. Returns a list of the
  /// values in section 1 of the bytes.
  ///
  /// See:
  /// - https://github.com/ugommirikwe/sa-license-decoder/blob/master/SPEC.md
  // static List<String> _getSection1Values(Uint8List bytes) {
  //   try {
  //         // Validate bytes before processing
  //   if (bytes.length < 10) {
  //     throw FormatException('Invalid byte length for section 1: ${bytes.length}');
  //   }

  //   // Check for common invalid patterns
  //   if (bytes[0] < 32 && bytes[1] < 32) {
  //     // Strip control characters at the beginning
  //     bytes = bytes.sublist(bytes.indexWhere((byte) => byte >= 32));
  //   }
  //     var values = <String>[];
  //     var prevDeliminator;
  //     while (values.length < 14) {
  //       var index = bytes.indexWhere((i) => i == 224 || i == 225);

  //       if (prevDeliminator == 225) {
  //         values.add('');

  //         var value = String.fromCharCodes(bytes.sublist(0, index));
  //         if (value.isNotEmpty) {
  //           values.add(value);
  //         }
  //       } else {
  //         var value = String.fromCharCodes(bytes.sublist(0, index));
  //         values.add(value);
  //       }

  //       prevDeliminator = bytes[index];
  //       bytes = bytes.sublist(index + 1);
  //     }
  //     values.add(String.fromCharCodes(bytes));

  //     return values;
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  /// A helper function for [DriversLicense..fromBarcodeBytes]. Returns a list of the
  /// values in section 2 of the bytes.
  ///
  /// See:
  /// - https://github.com/ugommirikwe/sa-license-decoder/blob/master/SPEC.md
  static List<dynamic> _getSection2Values(Uint8List bytes) {
    try {
      // Convert bytes to a hex string so that each letter represents a single nibble.
      var hexList = bytes.map((byte) {
        var hex = byte.toRadixString(16);
        if (hex.length == 1) {
          hex = '0' + hex;
        }
        return hex;
      }).toList();
      var nibbleString = '';
      hexList.forEach((hex) => nibbleString = nibbleString + hex);

      return _getSection2ValuesFromNibbles(nibbleString);
    } catch (e) {
      rethrow;
    }
  }

  /// A helper function for [_getSection2Values]. Returns a list of the
  /// values from [nibbleString], which is a string in which each letter
  /// represents a single nibble.
  ///
  /// See:
  /// - https://github.com/ugommirikwe/sa-license-decoder/blob/master/SPEC.md
  static List<dynamic> _getSection2ValuesFromNibbles(String nibbleString) {
    try {
      var values = [];

      while (values.length < 12) {
        // If values.length is 0, 5, 7, or 8 - the next values is 2 nibbles (letters) long
        if (values.isEmpty || values.length == 5 || values.length == 7 || values.length == 11) {
          //2 nibbles
          values.add(nibbleString.substring(0, 2));
          nibbleString = nibbleString.substring(2);
          continue;
        }

        // If values.length is 0, 5, 7, or 8 - the next values is a date, which can be
        // a single nibble or 8 nibbles long.
        if (values.length == 1 || values.length == 2 || values.length == 3 || values.length == 4 || values.length == 6 || values.length == 8 || values.length == 9 || values.length == 10) {
          if (nibbleString.substring(0, 1) == 'a') {
            // 1 nibble
            values.add(null);
            nibbleString = nibbleString.substring(1);
          } else {
            // 8 nibbles
            var year = int.parse(nibbleString.substring(0, 4));
            var month = int.parse(nibbleString.substring(4, 6));
            var day = int.parse(nibbleString.substring(6, 8));
            values.add(DateTime(year, month, day));
            nibbleString = nibbleString.substring(8);
          }
          continue;
        }
      }

      return values;
    } catch (e) {
      rethrow;
    }
  }

  static Uint8List _decodeDriversAll(Uint8List bytes) {
    var key128v1 = '''-----BEGIN RSA PUBLIC KEY-----
MIGXAoGBAP7S4cJ+M2MxbncxenpSxUmBOVGGvkl0dgxyUY1j4FRKSNCIszLFsMNwx2XWXZg8H53gpCsxDMwHrncL0rYdak3M6sdXaJvcv2CEePrzEvYIfMSWw3Ys9cRlHK7No0mfrn7bfrQOPhjrMEFw6R7VsVaqzm9DLW7KbMNYUd6MZ49nAhEAu3l//ex/nkLJ1vebE3BZ2w==
-----END RSA PUBLIC KEY-----''';

    var key74v2 = '''-----BEGIN RSA PUBLIC KEY-----
MGACSwD/POxrX0Djw2YUUbn8+u866wbcIynA5vTczJJ5cmcWzhW74F7tLFcRvPj1tsj3J221xDv6owQNwBqxS5xNFvccDOXqlT8MdUxrFwIRANsFuoItmswz+rfY9Cf5zmU=
-----END RSA PUBLIC KEY-----''';

    var key128v2 = '''-----BEGIN RSA PUBLIC KEY-----
MIGWAoGBAMqfGO9sPz+kxaRh/qVKsZQGul7NdG1gonSS3KPXTjtcHTFfexA4MkGAmwKeu9XeTRFgMMxX99WmyaFvNzuxSlCFI/foCkx0TZCFZjpKFHLXryxWrkG1Bl9++gKTvTJ4rWk1RvnxYhm3n/Rxo2NoJM/822Oo7YBZ5rmk8NuJU4HLAhAYcJLaZFTOsYU+aRX4RmoF
-----END RSA PUBLIC KEY-----''';

    var key74v1 = '''-----BEGIN RSA PUBLIC KEY-----
MF8CSwC0BKDfEdHKz/GhoEjU1XP5U6YsWD10klknVhpteh4rFAQlJq9wtVBUc5DqbsdI0w/bga20kODDahmGtASy9fae9dobZj5ZUJEw5wIQMJz+2XGf4qXiDJu0R2U4Kw==
-----END RSA PUBLIC KEY-----''';

    var decrypted = <int>[];
    try {
      // Check version from header bytes
      bool isVersion2 = bytes[0] == 0x01 && bytes[1] == 0x9b && bytes[2] == 0x09 && bytes[3] == 0x45;

      // Select appropriate keys based on version
      var key128 = isVersion2 ? key128v2 : key128v1;
      var key74 = isVersion2 ? key74v2 : key74v1;

      // 5 blocks of 128, 1 block of 74
      var block1 = bytes.sublist(6, 134);
      var block2 = bytes.sublist(134, 262);
      var block3 = bytes.sublist(262, 390);
      var block4 = bytes.sublist(390, 518);
      var block5 = bytes.sublist(518, 646);
      var block6 = bytes.sublist(646, 720);

      // decode first 5 blocks using 128-bit key
      var rows = key128.split(RegExp(r'\r\n?|\n'));
      var sequence = _parseSequence(rows);
      var modulus = (sequence.elements[0] as ASN1Integer).valueAsBigInteger!;
      var exponent = (sequence.elements[1] as ASN1Integer).valueAsBigInteger!;

      decrypted.addAll(_encryptValue(block1, exponent, modulus, 128).sublist(5));
      decrypted.addAll(_encryptValue(block2, exponent, modulus, 128).sublist(5));
      decrypted.addAll(_encryptValue(block3, exponent, modulus, 128).sublist(5));
      decrypted.addAll(_encryptValue(block4, exponent, modulus, 128).sublist(5));
      decrypted.addAll(_encryptValue(block5, exponent, modulus, 128).sublist(5));

      // decode last block using 74-bit key
      rows = key74.split(RegExp(r'\r\n?|\n'));
      sequence = _parseSequence(rows);
      modulus = (sequence.elements[0] as ASN1Integer).valueAsBigInteger!;
      exponent = (sequence.elements[1] as ASN1Integer).valueAsBigInteger!;
      decrypted.addAll(_encryptValue(block6, exponent, modulus, 74));

      return Uint8List.fromList(decrypted);
    } catch (e) {
      rethrow;
    }
  }

  /// A helper function for [DriversLicense..fromBarcodeBytes]. The bytes scanned from
  /// a driver's license need to decoded using a RSA encryption.
  ///
  /// See the following links on how to decode the license:
  /// - https://mybroadband.co.za/forum/threads/decode-drivers-licence-barcode.382187/
  /// - https://stackoverflow.com/questions/17549231/decode-south-african-za-drivers-license
  static Uint8List _decodeDrivers(Uint8List bytes) {
    var key128 = '''-----BEGIN RSA PUBLIC KEY-----
MIGWAoGBAMqfGO9sPz+kxaRh/qVKsZQGul7NdG1gonSS3KPXTjtcHTFfexA4MkGA
mwKeu9XeTRFgMMxX99WmyaFvNzuxSlCFI/foCkx0TZCFZjpKFHLXryxWrkG1Bl9+
+gKTvTJ4rWk1RvnxYhm3n/Rxo2NoJM/822Oo7YBZ5rmk8NuJU4HLAhAYcJLaZFTO
sYU+aRX4RmoF
-----END RSA PUBLIC KEY-----''';
    var key74 = '''-----BEGIN RSA PUBLIC KEY-----
MF8CSwC0BKDfEdHKz/GhoEjU1XP5U6YsWD10klknVhpteh4rFAQlJq9wtVBUc5Dq
bsdI0w/bga20kODDahmGtASy9fae9dobZj5ZUJEw5wIQMJz+2XGf4qXiDJu0R2U4
Kw==
-----END RSA PUBLIC KEY-----''';

    var decrypted = <int>[];

    try {
      // 5 blocks of 128, 1 block of 74
      var block1 = bytes.sublist(6, 134);
      var block2 = bytes.sublist(134, 262);
      var block3 = bytes.sublist(262, 390);
      var block4 = bytes.sublist(390, 518);
      var block5 = bytes.sublist(518, 646);
      var block6 = bytes.sublist(646, 720);

      // decode first 5 blocks and add to decrypted.
      var rows = key128.split(RegExp(r'\r\n?|\n'));

      var sequence = _parseSequence(rows);
      var modulus = (sequence.elements[0] as ASN1Integer).valueAsBigInteger!;
      var exponent = (sequence.elements[1] as ASN1Integer).valueAsBigInteger!;
      decrypted.addAll(_encryptValue(block1, exponent, modulus, 128).sublist(5));
      decrypted.addAll(_encryptValue(block2, exponent, modulus, 128).sublist(5));
      decrypted.addAll(_encryptValue(block3, exponent, modulus, 128).sublist(5));
      decrypted.addAll(_encryptValue(block4, exponent, modulus, 128).sublist(5));
      decrypted.addAll(_encryptValue(block5, exponent, modulus, 128).sublist(5));

      // decode last block of 74 and add to decrypted.
      rows = key74.split(RegExp(r'\r\n?|\n'));

      sequence = _parseSequence(rows);
      modulus = (sequence.elements[0] as ASN1Integer).valueAsBigInteger!;
      exponent = (sequence.elements[1] as ASN1Integer).valueAsBigInteger!;
      decrypted.addAll(_encryptValue(block6, exponent, modulus, 74));

      return Uint8List.fromList(decrypted);
    } catch (e) {
      rethrow;
    }
  }

  /// A helper function for [_decodeDrivers]. Helps to implement RSA Encryption
  /// manually since encryption packages don't seem to be working.
  static Uint8List _encryptValue(Uint8List rgb, BigInt e, BigInt n, int size) {
    try {
      var input = _decodeBigInt(rgb);
      var output = input.modPow(e, n);
      return _encodeBigInt(output);
    } catch (e) {
      rethrow;
    }
  }

  /// A helper function for [_decodeDrivers]. Helps to implement RSA Encryption
  /// manually since encryption packages don't seem to be working.
  static ASN1Sequence _parseSequence(List<String> rows) {
    try {
      final keyText = rows.skipWhile((row) => row.startsWith('-----BEGIN')).takeWhile((row) => !row.startsWith('-----END')).map((row) => row.trim()).join('');

      final keyBytes = Uint8List.fromList(base64.decode(keyText));
      final asn1Parser = ASN1Parser(keyBytes);

      return asn1Parser.nextObject() as ASN1Sequence;
    } catch (e) {
      rethrow;
    }
  }

  /// A helper function for [_encryptValue]. Helps to implement RSA Encryption
  /// manually since encryption packages don't seem to be working.
  /// Decodes a BigInt from bytes in big-endian encoding.
  static BigInt _decodeBigInt(List<int> bytes) {
    try {
      var result = BigInt.from(0);
      for (var i = 0; i < bytes.length; i++) {
        result += BigInt.from(bytes[bytes.length - i - 1]) << (8 * i);
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// A helper function for [_encryptValue]. Helps to implement RSA Encryption
  /// manually since encryption packages don't seem to be working.
  /// Encode a BigInt into bytes using big-endian encoding.
  static Uint8List _encodeBigInt(BigInt number) {
    try {
      var _byteMask = BigInt.from(0xff);
      var size = (number.bitLength + 7) >> 3;
      var result = Uint8List(size);
      for (var i = 0; i < size; i++) {
        result[size - i - 1] = (number & _byteMask).toInt();
        number = number >> 8;
      }
      return result;
    } catch (e) {
      rethrow;
    }
  }
}
