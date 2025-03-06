import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointmobile_scanner/pointmobile_scanner.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/enums/barcode_scan_type.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/rsa_scan.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_drivers_license.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_license_disk.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Returns values from the environment read from the .env file
@LazySingleton()
class ScanningService {
  final log = getLogger('ScanningService');

  StreamController<RsaDriversLicense> barcodeChangeController = StreamController<RsaDriversLicense>.broadcast();
  Stream<RsaDriversLicense> get licenseStream => barcodeChangeController.stream;

  StreamController<String> barcodeScanChangeController = StreamController<String>.broadcast();
  Stream<String> get rawStringStream => barcodeScanChangeController.stream;

  StreamController<LicenseDiskData> barcodeScanLicenseDiskDataChangeController = StreamController<LicenseDiskData>.broadcast();
  Stream<LicenseDiskData> get licenseDiskDataStream => barcodeScanLicenseDiskDataChangeController.stream;

  RsaDriversLicense? _rsaDriversLicense;
  RsaDriversLicense? get rsaDriversLicense => _rsaDriversLicense;

  String _barcode = '';
  String? get barcode => _barcode;

  bool _initScanner = false;
  bool? get initScanner => _initScanner;

  BarcodeScanType _barcodeScanType = BarcodeScanType.loadConQrCode;
  BarcodeScanType get barcodeScanType => _barcodeScanType;

  void setBarcodeScanType(BarcodeScanType barcodeScanType) {
    _barcodeScanType = barcodeScanType;
  }

  void initialise({BarcodeScanType barcodeScanType = BarcodeScanType.loadConQrCode}) {
    setBarcodeScanType(barcodeScanType);

    if (_initScanner) {
      return;
    }

    PointmobileScanner.channel.setMethodCallHandler(_onBarcodeScannerHandler);
    PointmobileScanner.initScanner();
    PointmobileScanner.enableScanner();
    PointmobileScanner.enableBeep();
    //from config later on?
    //PointmobileScanner.enableSymbology(PointmobileScanner.SYM_CODE128);
    //PointmobileScanner.enableSymbology(PointmobileScanner.SYM_EAN13);
    PointmobileScanner.enableSymbology(PointmobileScanner.SYM_QR);
    PointmobileScanner.enableSymbology(PointmobileScanner.SYM_PDF417);
    _initScanner = true;
  }

  Future<void> _onBarcodeScannerHandler(MethodCall call) async {
    try {
      if (call.method == PointmobileScanner.ON_DECODE) {
        switch (barcodeScanType) {
          case BarcodeScanType.loadConQrCode:
          case BarcodeScanType.staffQrCode:
            onDecodeQrCode(call);
            break;
          case BarcodeScanType.driversCard:
            //onDecode(call);
            onDecodeDebug(call);
            break;
          case BarcodeScanType.vehicleDisc:
            onDecodeVehicleDisc(call);
            break;
          default:
        }
      } else if (call.method == PointmobileScanner.ON_ERROR) {
        onError(call.arguments);
      } else {
        log.i(call.arguments);
      }
    } catch (e) {
      log.i(e);
    }
  }

  void onDecodeDebug(MethodCall call) {
    try {
      if (call.arguments != null) {
        var scanData = Uint8List.fromList(call.arguments);

        var rsaDriversLicense = RsaDriversLicense.fromBarcodeBytes(scanData);
        if (rsaDriversLicense != null) {
          _rsaDriversLicense = rsaDriversLicense;
          barcodeChangeController.add(_rsaDriversLicense!);
        }
      } else {
        Fluttertoast.showToast(msg: "Barcode READ FAIL!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM_RIGHT, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
      }
    } catch (e) {
      if (e is FormatException) {
        log.i("Invalid South African driver's license barcode data length: ${call.arguments.length}.");
        Fluttertoast.showToast(msg: "Barcode READ FAIL!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM_RIGHT, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
      }
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
    PointmobileScanner.disableScanner();
    _rsaDriversLicense = null;
  }

  void onError(Exception error) {
    log.i(error);
    _rsaDriversLicense = null;
    //return error.toString();
  }

  void onDecodeQrCode(MethodCall call) {
    var scanData = Uint8List.fromList(call.arguments);
    var textScanData = utf8.decode(scanData);
    if (textScanData != "READ_FAIL") {
      log.i("Scan Complete $textScanData");
      if (textScanData.isNotEmpty) {
        barcodeScanChangeController.add(textScanData.trim());
      }
    } else {
      Fluttertoast.showToast(msg: "Barcode READ FAIL!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
    }
  }

  void onDecodeVehicleDisc(MethodCall call) {
    //final List lDecodeResult = call.arguments;
    //var as = call.arguments as Object?;
    var scanData = Uint8List.fromList(call.arguments);
    var textScanData = utf8.decode(scanData);
    if (textScanData != "READ_FAIL") {
      log.i("Scan Complete $textScanData");
      if (textScanData.isNotEmpty) {
        //convert to license disk data
        var licenseDiskData = LicenseDiskData.fromString(textScanData);
        barcodeScanLicenseDiskDataChangeController.add(licenseDiskData);
      }
    } else {
      Fluttertoast.showToast(msg: "Barcode READ FAIL!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.CENTER, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
    }
  }
}
