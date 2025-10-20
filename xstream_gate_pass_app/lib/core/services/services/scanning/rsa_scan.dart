import 'dart:convert';
import 'dart:typed_data';
import 'package:asn1lib/asn1lib.dart';
import 'package:intl/intl.dart';
import 'package:pointycastle/api.dart';

import 'package:pointycastle/asymmetric/api.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/drivers_card.dart';

class RSAScanner {
  static final List<int> v1 = [0x01, 0xe1, 0x02, 0x45];
  static final List<int> v2 = [0x01, 0x9b, 0x09, 0x45];

  static const String pkV1128 = '''-----BEGIN RSA PUBLIC KEY-----
MIGXAoGBAP7S4cJ+M2MxbncxenpSxUmBOVGGvkl0dgxyUY1j4FRKSNCIszLFsMNwx2XWXZg8H53gpCsxDMwHrncL0rYdak3M6sdXaJvcv2CEePrzEvYIfMSWw3Ys9cRlHK7No0mfrn7bfrQOPhjrMEFw6R7VsVaqzm9DLW7KbMNYUd6MZ49nAhEAu3l//ex/nkLJ1vebE3BZ2w==
-----END RSA PUBLIC KEY-----''';

  static const String pkV174 = '''-----BEGIN RSA PUBLIC KEY-----
MGACSwD/POxrX0Djw2YUUbn8+u866wbcIynA5vTczJJ5cmcWzhW74F7tLFcRvPj1tsj3J221xDv6owQNwBqxS5xNFvccDOXqlT8MdUxrFwIRANsFuoItmswz+rfY9Cf5zmU=
-----END RSA PUBLIC KEY-----''';

  static const String pkV2128 = '''-----BEGIN RSA PUBLIC KEY-----
MIGWAoGBAMqfGO9sPz+kxaRh/qVKsZQGul7NdG1gonSS3KPXTjtcHTFfexA4MkGAmwKeu9XeTRFgMMxX99WmyaFvNzuxSlCFI/foCkx0TZCFZjpKFHLXryxWrkG1Bl9++gKTvTJ4rWk1RvnxYhm3n/Rxo2NoJM/822Oo7YBZ5rmk8NuJU4HLAhAYcJLaZFTOsYU+aRX4RmoF
-----END RSA PUBLIC KEY-----''';

  static const String pkV274 = '''-----BEGIN RSA PUBLIC KEY-----
MF8CSwC0BKDfEdHKz/GhoEjU1XP5U6YsWD10klknVhpteh4rFAQlJq9wtVBUc5DqbsdI0w/bga20kODDahmGtASy9fae9dobZj5ZUJEw5wIQMJz+2XGf4qXiDJu0R2U4Kw==
-----END RSA PUBLIC KEY-----''';

  static Uint8List decryptData(Uint8List data) {
    final header = data.sublist(0, 6);
    String pk128 = pkV1128;
    String pk74 = pkV174;

    if (listEquals(header.sublist(0, 4), v1)) {
      pk128 = pkV1128;
      pk74 = pkV174;
    } else if (listEquals(header.sublist(0, 4), v2)) {
      pk128 = pkV2128;
      pk74 = pkV274;
    }

    final result = BytesBuilder();
    final parser = RSAKeyParser();

    final pubKey128 = parser.parse(pk128) as RSAPublicKey;
    var start = 6;

    for (var i = 0; i < 5; i++) {
      final block = data.sublist(start, start + 128);
      final input = _bytesToBigInt(block);
      final output = _modPow(input, pubKey128.exponent!, pubKey128.modulus!);
      result.add(_bigIntToBytes(output, 128));
      start += 128;
    }

    final pubKey74 = parser.parse(pk74) as RSAPublicKey;
    final block = data.sublist(start, start + 74);
    final input = _bytesToBigInt(block);
    final output = _modPow(input, pubKey74.exponent!, pubKey74.modulus!);
    result.add(_bigIntToBytes(output, 74));

    return result.toBytes();
  }

  static BigInt _bytesToBigInt(Uint8List bytes) {
    BigInt result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  static Uint8List _bigIntToBytes(BigInt number, int length) {
    final result = Uint8List(length);
    for (var i = length - 1; i >= 0; i--) {
      result[i] = (number & BigInt.from(0xFF)).toInt();
      number = number >> 8;
    }
    return result;
  }

  static BigInt _modPow(BigInt base, BigInt exponent, BigInt modulus) {
    if (exponent == BigInt.zero) return BigInt.one;

    var result = BigInt.one;
    base = base % modulus;

    while (exponent > BigInt.zero) {
      if (exponent & BigInt.one == BigInt.one) {
        result = (result * base) % modulus;
      }
      base = (base * base) % modulus;
      exponent = exponent >> 1;
    }
    return result;
  }

  static bool listEquals(List<int> a, List<int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static DriversLicence parseDecryptedData(Uint8List data) {
    int index = 0;
    // Find start of data marker
    for (int i = 0; i < data.length; i++) {
      if (data[i] == 0x82) {
        index = i;
        break;
      }
    }

    // Parse vehicle codes
    final vehicleCodes = _readStrings(data, index + 2, 4);

    // Parse personal info
    final surname = _readString(data, index);
    index = surname.index;

    final initials = _readString(data, index);
    index = initials.index;

    // Parse dates using nibble format
    final nibbleQueue = _getNibbleQueue(data, index);
    final licenseCodeIssueDates = _readNibbleDateList(nibbleQueue, 4);

    final birthDate = _parseDate(_readNibbleDateString(nibbleQueue));
    final licenseIssueDate = _parseDate(_readNibbleDateString(nibbleQueue));
    final licenseExpiryDate = _parseDate(_readNibbleDateString(nibbleQueue));

    // Parse gender
    final genderCode = '${nibbleQueue[0]}${nibbleQueue[1]}';
    final gender = genderCode == '01' ? 'male' : 'female';

    return DriversLicence(
      surname: surname.value,
      initials: initials.value,
      licenceCodes: vehicleCodes,
      dateOfBirth: birthDate,
      licenceIssueDate: licenseIssueDate,
      licenceExpiryDate: licenseExpiryDate,
      gender: gender,
      // Add other fields as needed
    );
  }

  static List<int> _getNibbleQueue(Uint8List data, int startIndex) {
    List<int> nibbleQueue = [];
    int index = startIndex;

    while (true) {
      int currentByte = data[index++];
      if (currentByte == 0x57) break;

      // Split byte into two nibbles
      nibbleQueue.add(currentByte >> 4); // High nibble
      nibbleQueue.add(currentByte & 0x0f); // Low nibble
    }

    return nibbleQueue;
  }

  static String _readNibbleDateString(List<int> nibbleQueue) {
    if (nibbleQueue.isEmpty) return '';

    final m = nibbleQueue.removeAt(0);
    if (m == 10) return '';

    final c = nibbleQueue.removeAt(0);
    final d = nibbleQueue.removeAt(0);
    final y = nibbleQueue.removeAt(0);
    final m1 = nibbleQueue.removeAt(0);
    final m2 = nibbleQueue.removeAt(0);
    final d1 = nibbleQueue.removeAt(0);
    final d2 = nibbleQueue.removeAt(0);

    return '$m$c$d$y/$m1$m2/$d1$d2';
  }

  static List<String> _readNibbleDateList(List<int> nibbleQueue, int length) {
    List<String> dateList = [];

    for (int i = 0; i < length; i++) {
      String dateString = _readNibbleDateString(nibbleQueue);
      if (dateString.isNotEmpty) {
        dateList.add(dateString);
      }
    }

    return dateList;
  }

  static ParsedString _readString(Uint8List data, int startIndex) {
    String value = '';
    int index = startIndex;
    int delimiter = 0xe0;

    while (true) {
      int currentByte = data[index++];
      if (currentByte == 0xe0 || currentByte == 0xe1) {
        delimiter = currentByte;
        break;
      }
      value += String.fromCharCode(currentByte);
    }

    return ParsedString(value, index, delimiter);
  }

  static List<String> _readStrings(Uint8List data, int startIndex, int length) {
    List<String> strings = [];
    int i = 0;
    int index = startIndex;

    while (i < length) {
      final parsed = _readString(data, index);
      if (parsed.value.isNotEmpty) {
        strings.add(parsed.value);
      }
      index = parsed.index;
      i++;
    }

    return strings;
  }

  static DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      return DateFormat('yyyy/MM/dd').parse(dateStr);
    } catch (e) {
      return null;
    }
  }
}

class ParsedString {
  final String value;
  final int index;
  final int delimiter;

  ParsedString(this.value, this.index, this.delimiter);
}

class RSAKeyParser {
  RSAAsymmetricKey parse(String key) {
    final rows = key.split('\n');
    final header = rows.first;

    if (header != '-----BEGIN RSA PUBLIC KEY-----') {
      throw ArgumentError('Invalid key format');
    }

    final keyText = rows
        .sublist(1, rows.length - 1)
        .where((line) => line.trim().isNotEmpty)
        .join('');

    final keyBytes = base64.decode(keyText);
    final asn1Parser = ASN1Parser(keyBytes);
    final topLevelSeq = asn1Parser.nextObject() as ASN1Sequence;

    final modulus = (topLevelSeq.elements[0] as ASN1Integer).valueAsBigInteger;
    final exponent = (topLevelSeq.elements[1] as ASN1Integer).valueAsBigInteger;

    return RSAPublicKey(modulus!, exponent!);
  }
}
