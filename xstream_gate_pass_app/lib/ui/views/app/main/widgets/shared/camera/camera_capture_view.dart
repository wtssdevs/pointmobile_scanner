import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:stacked/stacked.dart';

import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/enums/filestore_type.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/camera_capture_view_model.dart';

class CameraCaptureView extends StatefulWidget {
  final FileStoreType fileStoreType;
  final String refId;
  final int referanceId;

  const CameraCaptureView(
      {Key? key,
      required this.refId,
      required this.referanceId,
      required this.fileStoreType})
      : super(key: key);

  @override
  State<CameraCaptureView> createState() => _CameraCaptureViewState();
}

class _CameraCaptureViewState extends State<CameraCaptureView>
    with TickerProviderStateMixin {
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
    return ViewModelBuilder<CameraCaptureViewModel>.reactive(
      viewModelBuilder: () => CameraCaptureViewModel(
          widget.refId, widget.referanceId, widget.fileStoreType, this),
      onViewModelReady: (model) =>
          SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        model.runStartupLogic(widget.refId, widget.fileStoreType);
      }),
      onDispose: (model) {
        model.onDispose();
      },
      builder: (context, model, child) => Scaffold(
        body: CameraAwesomeBuilder.awesome(
          onMediaTap: (mediaCapture) {
            //OpenFile.open(mediaCapture.filePath);
            // model.openEditAndCropView(mediaCapture.filePath);
          },
          previewDecoratorBuilder: (state, previewSize) {
            // You could save the current state in a variable, but don't forget to refresh it every time this method is called
            //model.currentState = state;
            model.setUpCaptureStateSubscription(state);
            // Return a widget, just return an empty SizedBox if you don't want to show anything
            return const SizedBox();
          },
          saveConfig: SaveConfig.photoAndVideo(
            initialCaptureMode: CaptureMode.photo,
            photoPathBuilder: (sensors) async {
              return await model.getFilePath(sensors);
            },
            //  videoPathBuilder: (sensors) async {
            //      // same logic as photoPathBuilder
            //  },
            videoOptions: VideoOptions(
              enableAudio: true,
              ios: CupertinoVideoOptions(
                fps: 10,
              ),
              android: AndroidVideoOptions(
                bitrate: 6000000,
                fallbackStrategy: QualityFallbackStrategy.lower,
              ),
            ),

            mirrorFrontCamera: false,
          ),
        ),
      ),
    );
  }
}
