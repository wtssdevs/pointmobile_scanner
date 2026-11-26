import 'package:camerawesome/src/orchestrator/models/analysis/analysis_image.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/utils/mlkit_utils.dart';

class CamBarcodeReaderViewModel extends BaseViewModel {
  final log = getLogger('CamBarcodeReaderViewModel');
  final _navigationService = locator<NavigationService>();

  void close([String? result]) => _navigationService.back(result: result);

  final _barcodeScanner = BarcodeScanner(
    formats: [
      BarcodeFormat.pdf417,
      BarcodeFormat.qrCode,
      //BarcodeFormat.dataMatrix,
      //BarcodeFormat.code128,
      //BarcodeFormat.code39,
    ],
  );

  Future<String> processImageBarcode(AnalysisImage img,
      {bool returnRawValue = false}) async {
    // 1.
    final inputImage = img.toInputImage();

    try {
      // 2.
      var recognizedBarCodes = await _barcodeScanner.processImage(inputImage);
      // 3.
      for (Barcode barcode in recognizedBarCodes) {
        if (!(barcode.rawValue?.startsWith("yac1.") ?? false))
        log.d("Barcode: [${barcode.format}]: ${barcode.rawValue}");
        // 4.
        final value = barcode.rawValue;
        if (value == null || value.isEmpty) continue;
        return returnRawValue ? value : "[${barcode.format.name}]: $value";
      }

      return "";
    } catch (error) {
      log.e("...sending image resulted error $error");
      return "";
    }
  }

  @override
  void dispose() {
    _barcodeScanner.close();
    super.dispose();
  }

  void runStartupLogic() {}
}
