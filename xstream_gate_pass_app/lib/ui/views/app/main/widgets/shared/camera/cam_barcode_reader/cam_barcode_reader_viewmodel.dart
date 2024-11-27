import 'package:camerawesome/src/orchestrator/models/analysis/analysis_image.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/utils/mlkit_utils.dart';

class CamBarcodeReaderViewModel extends BaseViewModel {
  final log = getLogger('CamBarcodeReaderViewModel');

  final _barcodeScanner = BarcodeScanner(
    formats: [
      BarcodeFormat.pdf417,
      //BarcodeFormat.qrCode,
      //BarcodeFormat.dataMatrix,
      //BarcodeFormat.code128,
      //BarcodeFormat.code39,
    ],
  );

  Future<String> processImageBarcode(AnalysisImage img) async {
    // 1.
    final inputImage = img.toInputImage();

    try {
      // 2.
      var recognizedBarCodes = await _barcodeScanner.processImage(inputImage);
      // 3.
      for (Barcode barcode in recognizedBarCodes) {
        log.d("Barcode: [${barcode.format}]: ${barcode.rawValue}");
        // 4.
        return ("[${barcode.format.name}]: ${barcode.rawValue}");
      }

      return "";
    } catch (error) {
      log.e("...sending image resulted error $error");
      return "";
    }
  }

  void runStartupLogic() {}
}
