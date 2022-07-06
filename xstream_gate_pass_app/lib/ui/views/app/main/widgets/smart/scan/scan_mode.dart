import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pointmobile_scanner/pointmobile_scanner.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_drivers_license.dart';

class Scanbox extends StatefulWidget {
  Scanbox({Key? key}) : super(key: key);

  @override
  State<Scanbox> createState() => _ScanboxState();
}

class _ScanboxState extends State<Scanbox> {
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

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container();
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
      var _decodeResult = "Symbology: ${lDecodeResult[0]}\n Base64Value: ${lDecodeResult[1]}";

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
  }

  void _onError(Exception error) {
    setState(() {});
  }
}
