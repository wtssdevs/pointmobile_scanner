import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/cam_barcode_reader/barcode_display_widget.dart';
import 'cam_barcode_reader_viewmodel.dart';
import 'package:rxdart/rxdart.dart';

class CamBarcodeReader extends StatefulWidget {
  const CamBarcodeReader({super.key, this.returnResult = false});
  final bool returnResult;

  @override
  State<CamBarcodeReader> createState() => _CamBarcodeReaderState();
}

class _CamBarcodeReaderState extends State<CamBarcodeReader>
    with TickerProviderStateMixin {
  bool _returned = false;
  final _buffer = <String>[];

  final _barcodesController = BehaviorSubject<List<String>>();
  late final Stream<List<String>> _barcodesStream = _barcodesController.stream;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _barcodesController.close();
    _scrollController.dispose();
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
          maxFramesPerSecond: 5,
          autoStart: widget.returnResult,
        ),
        // 3.
        //onImageForAnalysis: (img) => model.processImageBarcode(img),
        onImageForAnalysis: (img) async {
          var result = await model.processImageBarcode(img,
              returnRawValue: widget.returnResult);

          if (widget.returnResult &&
              result.isNotEmpty &&
              !_returned &&
              mounted) {
            _returned = true;
            model.close(result);
            return;
          }
          if (result.isNotEmpty && mounted && !_returned) {
            _addBarcode(result);
          }
        },

        // 4.
        builder: (cameraModeState, preview) {
          // return BarcodePreviewOverlay(
          //   state: cameraModeState,
          //   barcodes: _barcodes,
          //   analysisImage: _image,
          //   preview: preview,
          // );
          if (widget.returnResult) {
            return SafeArea(
                child: Stack(children: [
              Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton.filled(
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => model.close(),
                  )),
              const Align(
                  alignment: Alignment.bottomCenter,
                  child: Card(
                    child: Padding(
                        padding: EdgeInsets.all(16),
                        child:
                            Text('Point the camera at the activity QR code.')),
                  )),
            ]));
          }
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
