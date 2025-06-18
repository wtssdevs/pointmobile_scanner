import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointmobile_scanner/pointmobile_scanner.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/enums/barcode_scan_type.dart';
import 'package:xstream_gate_pass_app/core/models/device/device_config.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/rsa_scan.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_driver_temp_license.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_drivers_license.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_license_disk.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

/// Returns values from the environment read from the .env file
@LazySingleton()
class ScanningService {
  final log = getLogger('ScanningService');
  final DialogService _dialogService = locator<DialogService>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();

//RsaDriversLicense
  StreamController<RsaDriversLicense> barcodeChangeController = StreamController<RsaDriversLicense>.broadcast();
  Stream<RsaDriversLicense> get licenseStream => barcodeChangeController.stream;

//DriverTempLicense
  StreamController<DriverTempLicense> barcodeDriverTempLicenseChangeController = StreamController<DriverTempLicense>.broadcast();
  Stream<DriverTempLicense> get driverTempLicenseStream => barcodeDriverTempLicenseChangeController.stream;

  StreamController<String> barcodeScanChangeController = StreamController<String>.broadcast();
  Stream<String> get rawStringStream => barcodeScanChangeController.stream;

  StreamController<LicenseDiskData> barcodeScanLicenseDiskDataChangeController = StreamController<LicenseDiskData>.broadcast();
  Stream<LicenseDiskData> get licenseDiskDataStream => barcodeScanLicenseDiskDataChangeController.stream;

  RsaDriversLicense? _rsaDriversLicense;
  RsaDriversLicense? get rsaDriversLicense => _rsaDriversLicense;

  DeviceConfig get deviceConfig => _localStorageService.getDeviceConfig;
  String _barcode = '';
  String? get barcode => _barcode;

  bool _initScanner = false;
  bool? get initScanner => _initScanner;

  BarcodeScanType _barcodeScanType = BarcodeScanType.loadConQrCode;
  BarcodeScanType get barcodeScanType => _barcodeScanType;

  void setBarcodeScanType(BarcodeScanType barcodeScanType) {
    _barcodeScanType = barcodeScanType;
  }

  Future<void> initialise({BarcodeScanType barcodeScanType = BarcodeScanType.loadConQrCode}) async {
    try {
      setBarcodeScanType(barcodeScanType);

      if (_initScanner) {
        return;
      }

      PointmobileScanner.channel.setMethodCallHandler(_onBarcodeScannerHandler);
      var caninit = await PointmobileScanner.initScanner(deviceConfig.deviceScanningMode.value);
      if (caninit) {
        PointmobileScanner.enableScanner();
        PointmobileScanner.enableBeep();
        //from config later on?
        //PointmobileScanner.enableSymbology(PointmobileScanner.SYM_CODE128);
        //PointmobileScanner.enableSymbology(PointmobileScanner.SYM_EAN13);
        PointmobileScanner.enableSymbology(PointmobileScanner.SYM_QR);
        PointmobileScanner.enableSymbology(PointmobileScanner.SYM_PDF417);
        _initScanner = true;
      } else {
        _dialogService.showDialog(
          title: "PointmobileScanner SDK initScanner",
          description: "Error initializing PointmobileScanner SDK<try chaning device configuration",
          buttonTitle: "OK",
        );
        _initScanner = false;
      }
    } catch (e) {
      log.i(e);
      _dialogService.showDialog(
        title: "PointmobileScanner SDK Error",
        description: e.toString(),
        buttonTitle: "OK",
      );
      _initScanner = false;
    }
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
            onDecodeDriversCard(call);

            break;
          case BarcodeScanType.vehicleDisc:
          case BarcodeScanType.trailerOneDisc:
          case BarcodeScanType.trailerTwoDisc:
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

  bool onDecodeDriversCard(MethodCall call) {
    try {
      if (call.arguments is Uint8List) {
        var scanData = Uint8List.fromList(call.arguments);

        if (scanData.length <= 9) {
          //reaf fail
          //if the scan data is less than 10 bytes, it is likely an error or invalid scan
          Fluttertoast.showToast(msg: "Barcode READ FAIL!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
          return false;
        }

        //scanData.length  == 720
        if (scanData.length == 720 || scanData.length == 721) {
          // Driver Card scan
          // Handle the specific case for 720 bytes
          var rsaDriversLicense = RsaDriversLicense.fromBarcodeBytes(scanData);
          if (rsaDriversLicense != null) {
            _rsaDriversLicense = rsaDriversLicense;
            barcodeChangeController.add(_rsaDriversLicense!);
            return true;
          }
        } else if (scanData.length < 720 && scanData.length > 10) {
          //This is Temp liscense scan
          // Handle the specific case for 640 bytes
          var textScanData = utf8.decode(scanData);
          if (textScanData == "READ_FAIL") {
            Fluttertoast.showToast(msg: "Barcode READ FAIL!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
            return false;
          }

          //convert to temp license data
          var licenseDiskData = RsaDriversLicense.fromString(textScanData);
          barcodeChangeController.add(licenseDiskData);
          return true;
        }

        // If we reach this point, the scan was successful
        return true;
      }

      return false;
    } catch (e) {
      if (e is FormatException) {
        log.i("Invalid South African driver's license barcode data length: ${call.arguments.length}.");
        Fluttertoast.showToast(msg: "Barcode READ FAIL!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
      }
      return false;
    }
  }

// Decode RSA Drivers License from the call arguments
  // Returns RsaDriversLicense object or null if decoding fails
  //Not used anymore, use onDecodeDriversCard instead
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
    String textScanData = "";
    if (call.arguments is Uint8List) {
      var scanData = Uint8List.fromList(call.arguments);
      textScanData = utf8.decode(scanData);
    } else if (call.arguments[0] != "READ_FAIL") {
      textScanData = call.arguments[1] as String;
    }

    if (textScanData.isNotEmpty && textScanData != "READ_FAIL") {
      log.i("Scan Complete $textScanData");
      if (textScanData.isNotEmpty) {
        barcodeScanChangeController.add(textScanData.trim());
      }
    } else {
      Fluttertoast.showToast(msg: "Barcode READ FAIL!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
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
      Fluttertoast.showToast(msg: "Barcode READ FAIL!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 16.0);
    }
  }
}
