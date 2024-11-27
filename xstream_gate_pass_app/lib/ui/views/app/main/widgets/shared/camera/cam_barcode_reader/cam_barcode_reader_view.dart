import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/cam_barcode_reader/barcode_display_widget.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/cam_barcode_reader/barcode_preview_overlay.dart';
import 'cam_barcode_reader_viewmodel.dart';
import 'package:rxdart/rxdart.dart';

class CamBarcodeReader extends StatefulWidget {
  const CamBarcodeReader({super.key});

  @override
  State<CamBarcodeReader> createState() => _CamBarcodeReaderState();
}

class _CamBarcodeReaderState extends State<CamBarcodeReader>
    with TickerProviderStateMixin {
  final _buffer = <String>[];
  List<Barcode> _barcodes = [];
  AnalysisImage? _image;
  final _barcodesController = BehaviorSubject<List<String>>();
  late final Stream<List<String>> _barcodesStream = _barcodesController.stream;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void _addBarcode(String value) {
      try {
        if (_buffer.length > 300) {
          _buffer.removeRange(_buffer.length - 300, _buffer.length);
        }
        if (_buffer.isEmpty || value != _buffer[0]) {
          _buffer.insert(0, value);
          _barcodesController.add(_buffer);
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastLinearToSlowEaseIn,
          );
        }
      } catch (err) {
        print("...logging error $err");
      }
    }

    return ViewModelBuilder<CamBarcodeReaderViewModel>.reactive(
      viewModelBuilder: () => CamBarcodeReaderViewModel(),
      onViewModelReady: (model) =>
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        model.runStartupLogic();
      }),
      onDispose: (model) {},
      builder: (context, model, child) => Scaffold(
          body: CameraAwesomeBuilder.previewOnly(
        // 2.
        imageAnalysisConfig: AnalysisConfig(
          // androidOptions: const AndroidAnalysisOptions.yuv420(
          //   width: 512,
          // ),
          androidOptions: const AndroidAnalysisOptions.nv21(
            width: 512,
          ),
          maxFramesPerSecond: 3,
          autoStart: false,
        ),
        // 3.
        //onImageForAnalysis: (img) => model.processImageBarcode(img),
        onImageForAnalysis: (img) async {
          var result = await model.processImageBarcode(img);
          setState(() {
            _image = img;
          });
          if (result.isNotEmpty) {
            _addBarcode(result);
          }
        },

        // 4.
        builder: (cameraModeState, preview) {
          return BarcodePreviewOverlay(
            state: cameraModeState,
            barcodes: _barcodes,
            analysisImage: _image,
            preview: preview,
          );
          return BarcodeDisplayWidget(
            barcodesStream: _barcodesStream,
            scrollController: _scrollController,
            // 5.
            analysisController: cameraModeState.analysisController!,
          );
        },
      )),
    );
  }
}
