/// Scan identity documents such as South African ID Cards, ID Books and
/// Driver's Licenses.
library rsa_scan;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pointmobile_scanner_example/rsa_drivers_scanner.dart';
import 'package:pointmobile_scanner_example/zar_drivers_license.dart';
import 'package:pointmobile_scanner_example/zar_id_book.dart';
import 'package:pointmobile_scanner_example/zar_id_card.dart';


/// A function for scanning an ID Book.
///
/// Returns the scanned [RsaIdBook] or null if nothing was scanned.
Future<RsaIdBook> scanIdBook(BuildContext context) async {
  final scannedIdBook = await Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => RsaDriversScanner(),
  ));

  return scannedIdBook;
}

/// A function for scanning an ID Card.
///
/// Returns the scanned [RsaIdCard] or null if nothing was scanned.
Future<RsaIdCard> scanIdCard(BuildContext context) async {
  final scannedIdCard = await Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => RsaDriversScanner(),
  ));

  return scannedIdCard;
}

/// A function for scanning a South African Drivers License.
///
/// Returns the scanned [RsaDriversLicense] or null if nothing was scanned.
Future<RsaDriversLicense> scanDrivers(BuildContext context) async {
  final scannedDrivers = await Navigator.of(context).push(MaterialPageRoute(
    builder: (context) => RsaDriversScanner(),
  ));

  return scannedDrivers;
}
