import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
//import 'package:pointmobile_scanner/pointmobile_scanner.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app_config/app.logger.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_drivers_license.dart';

/// Returns values from the environment read from the .env file
@LazySingleton()
class ScanningService {
  final log = getLogger('ScanningService');
  StreamController<RsaDriversLicense> barcodeChangeController = StreamController<RsaDriversLicense>.broadcast();
  Stream<RsaDriversLicense> get licenseStream => barcodeChangeController.stream;

  RsaDriversLicense? _rsaDriversLicense;
  RsaDriversLicense? get rsaDriversLicense => _rsaDriversLicense;

  void initialise() {
    // PointmobileScanner.channel.setMethodCallHandler(_onBarcodeScannerHandler);
    // PointmobileScanner.initScanner();
    // PointmobileScanner.enableScanner();
    // PointmobileScanner.enableBeep();
    // PointmobileScanner.enableSymbology(PointmobileScanner.SYM_CODE128);
    // PointmobileScanner.enableSymbology(PointmobileScanner.SYM_EAN13);
    // PointmobileScanner.enableSymbology(PointmobileScanner.SYM_QR);
    // PointmobileScanner.enableSymbology(PointmobileScanner.SYM_PDF417);
  }

  Future<void> _onBarcodeScannerHandler(MethodCall call) async {
    try {
      // if (call.method == PointmobileScanner.ON_DECODE) {
      //   onDecode(call);
      // } else if (call.method == PointmobileScanner.ON_ERROR) {
      //   onError(call.arguments);
      // } else {
      //   log.i(call.arguments);
      // }
    } catch (e) {
      log.i(e);
    }
  }

  RsaDriversLicense? onDecode(MethodCall call) {
    final List lDecodeResult = call.arguments;
    //var _decodeResult = "Symbology: ${lDecodeResult[0]}\n Base64Value: ${lDecodeResult[1]}";
    if (lDecodeResult[1] != null && lDecodeResult[0] != null && lDecodeResult[0] != "READ_FAIL") {
      var base64String = lDecodeResult[1] as String;
      var withOutNewlines = base64String.replaceAll("\n", "");
      var normalBase64 = base64.normalize(withOutNewlines);

      var bytes = base64.decode(normalBase64);

      _rsaDriversLicense = RsaDriversLicense.fromBarcodeBytes(bytes);

      log.i("Scan Complete");
      if (_rsaDriversLicense != null) {
        barcodeChangeController.add(_rsaDriversLicense!);
      } else {
        barcodeChangeController.add(_rsaDriversLicense!);
      }

      return _rsaDriversLicense;
    }
    _rsaDriversLicense = null;
    return null;
  }

  void onExit() {
    //PointmobileScanner.disableScanner();
    _rsaDriversLicense = null;
  }

  void onError(Exception error) {
    log.i(error);
    _rsaDriversLicense = null;
    //return error.toString();
  }
}
