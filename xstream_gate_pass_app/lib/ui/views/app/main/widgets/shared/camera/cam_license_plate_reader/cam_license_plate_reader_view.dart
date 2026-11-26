import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'cam_license_plate_reader_viewmodel.dart';

class CamLicensePlateReader extends StatefulWidget {
  const CamLicensePlateReader({super.key, this.returnResult = false});

  final bool returnResult;

  @override
  State<CamLicensePlateReader> createState() => _CamLicensePlateReaderState();
}

class _CamLicensePlateReaderState extends State<CamLicensePlateReader> {
  bool _returned = false;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CamLicensePlateReaderViewModel>.reactive(
      viewModelBuilder: CamLicensePlateReaderViewModel.new,
      builder: (context, model, child) => Scaffold(
        body: CameraAwesomeBuilder.previewOnly(
          imageAnalysisConfig: AnalysisConfig(
            androidOptions: const AndroidAnalysisOptions.nv21(width: 512),
            maxFramesPerSecond: 5,
            autoStart: true,
          ),
          onImageForAnalysis: (image) async {
            final result = await model.processImage(image);
            if (result == null ||
                !widget.returnResult ||
                _returned ||
                !mounted) {
              return;
            }
            _returned = true;
            model.close(result);
          },
          builder: (cameraModeState, preview) => SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton.filled(
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => model.close(),
                  ),
                ),
                const Center(
                  child: IgnorePointer(
                    child: SizedBox(
                      width: 300,
                      height: 100,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.fromBorderSide(
                            BorderSide(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Point the camera at the vehicle licence plate.',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
