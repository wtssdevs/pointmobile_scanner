import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:pointmobile_scanner_example/rsa_scanner.dart';
import 'package:pointmobile_scanner_example/zar_drivers_license.dart';

class RsaDriversScanner extends RsaScanner {
  @override
  String title() {
    return 'Scan Driver\'s License';
  }

  @override
  String hint() {
    return 'Hold the barcode on the back of the driver\'s license in front of the camera.';
  }

  @override
  RsaDriversLicense documentFromBarcode(Barcode barcode) {
    return RsaDriversLicense.fromBarcodeBytes(barcode.rawBytes!);
  }
}
