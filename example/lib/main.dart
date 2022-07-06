import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointmobile_scanner/pointmobile_scanner.dart';
import 'package:pointmobile_scanner_example/zar_drivers_license.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _decodeResult = "Unknown";

  RsaDriversLicense? rsaDriversLicense;

  @override
  void initState() {
    super.initState();

    PointmobileScanner.channel.setMethodCallHandler(_onBarcodeScannerHandler);
    PointmobileScanner.initScanner();
    PointmobileScanner.enableScanner();
    PointmobileScanner.enableBeep();
    PointmobileScanner.enableSymbology(PointmobileScanner.SYM_CODE128);
    PointmobileScanner.enableSymbology(PointmobileScanner.SYM_EAN13);
    PointmobileScanner.enableSymbology(PointmobileScanner.SYM_QR);
    PointmobileScanner.enableSymbology(PointmobileScanner.SYM_PDF417);

    setState(() {
      _decodeResult = "Ready to decode";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Scanner plugin example app'),
            actions: <Widget>[
              PopupMenuButton(
                icon: Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 1) _onExit();
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                  const PopupMenuItem(child: Text('Exit'), value: 1),
                ],
              ),
            ],
          ),
          body: Center(
            child: ListView(
              children: [
             
                ListTile(
                  title: Text('licenseNumber: ${rsaDriversLicense?.licenseNumber}'),
                ),

                ListTile(
                  title: Text('idNumber: ${rsaDriversLicense?.idNumber}'),
                ),

                ListTile(
                  title: Text('idNumberType: ${rsaDriversLicense?.idNumberType}'),
                ),

                ListTile(
                  title: Text('idCountryOfIssue: ${rsaDriversLicense?.idCountryOfIssue}'),
                ),

                ListTile(
                  title: Text('firstNames: ${rsaDriversLicense?.firstNames}'),
                ),

                ListTile(
                  title: Text('surname: ${rsaDriversLicense?.surname}'),
                ),

                ListTile(
                  title: Text('birthDate: ${rsaDriversLicense?.birthDate}'),
                ),

                ListTile(
                  title: Text('gender: ${rsaDriversLicense?.gender}'),
                ),

                ListTile(
                  title: Text('driverRestrictions: ${rsaDriversLicense?.driverRestrictions}'),
                ),

                // ListTile(
                //   title: Text('issueDates: ${rsaDriversLicense?.issueDates}'),
                // ),

                ListTile(
                  title: Text('licenseIssueNumber: ${rsaDriversLicense?.licenseIssueNumber}'),
                ),

                ListTile(
                  title: Text('licenseCountryOfIssue: ${rsaDriversLicense?.licenseCountryOfIssue}'),
                ),

                ListTile(
                  title: Text('prdpCode: ${rsaDriversLicense?.prdpCode}'),
                ),

                ListTile(
                  title: Text('prdpExpiry: ${rsaDriversLicense?.prdpExpiry}'),
                ),

                ListTile(
                  title: Text('validFrom: ${rsaDriversLicense?.validFrom}'),
                ),

                ListTile(
                  title: Text('validTo: ${rsaDriversLicense?.validTo}'),
                ),

                ListTile(
                  title: Text('vehicleCodes: ${rsaDriversLicense?.vehicleCodes}'),
                ),

                ListTile(
                  title: Text('vehicleRestrictions: ${rsaDriversLicense?.vehicleRestrictions}'),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              PointmobileScanner.triggerOn();
            },
            child: Icon(Icons.view_week_rounded),
          ),
        );
      }),
    );
  }

  Future<void> _onBarcodeScannerHandler(MethodCall call) async {
    try {
      if (call.method == PointmobileScanner.ON_DECODE) {
        _onDecode(call);
      } else if (call.method == PointmobileScanner.ON_ERROR) {
        _onError(call.arguments);
      } else {
        print(call.arguments);
      }
    } catch (e) {
      print(e);
    }
  }

  void _onDecode(MethodCall call) {
    setState(() {
//      print(call);
      final List lDecodeResult = call.arguments;
      _decodeResult = "Symbology: ${lDecodeResult[0]}\n Base64Value: ${lDecodeResult[1]}";

      if (_decodeResult != null && _decodeResult!.isNotEmpty && lDecodeResult[1] != null && lDecodeResult[0] != "READ_FAIL") {
        var base64String = lDecodeResult[1] as String;
        var withOutNewlines = base64String.replaceAll("\n", "");
        var normalBase64 = base64.normalize(withOutNewlines);

        var bytes = base64.decode(normalBase64);
        //Uint8List bytes = bts as Uint8List;
        //List<int> list = bts.codeUnits;
        //Uint8List bytes = Uint8List.fromList(list);

        rsaDriversLicense = RsaDriversLicense.fromBarcodeBytes(bytes);
        //_decodeResult = "Full Name" + rsaDriversLicense!.firstNames + " " + rsaDriversLicense!.surname + " ID:" + rsaDriversLicense!.idNumber;
        print("Scan Complete");
      }
    });
  }

  void _onExit() {
    PointmobileScanner.disableScanner();
    SystemNavigator.pop();
  }

  void _onError(Exception error) {
    setState(() {
      _decodeResult = error.toString();
    });
  }
}
