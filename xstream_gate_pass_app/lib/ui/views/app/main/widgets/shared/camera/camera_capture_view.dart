import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:stacked/stacked.dart';

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/models/orientations.dart';

import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:xstream_gate_pass_app/app_config/app.logger.dart';
import 'package:xstream_gate_pass_app/core/enums/filestore_type.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/camera_capture_view_model.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/smart/camera/bottom_bar.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/smart/camera/camera_preview.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/smart/camera/top_bar.dart';

class CameraCaptureView extends StatefulWidget {
  final FileStoreType fileStoreType;
  final int refId;
  final int referanceId;

  const CameraCaptureView({Key? key, required this.refId, required this.referanceId, required this.fileStoreType}) : super(key: key);

  @override
  State<CameraCaptureView> createState() => _CameraCaptureViewState();
}

class _CameraCaptureViewState extends State<CameraCaptureView> with TickerProviderStateMixin {
  final log = getLogger('CameraCaptureView');

  String _lastVideoPath = '';
  bool _focus = false, _fullscreen = true, _isRecordingVideo = false;

  final ValueNotifier<CameraFlashes> _switchFlash = ValueNotifier(CameraFlashes.NONE);
  final ValueNotifier<double> _zoomNotifier = ValueNotifier(0);
  final ValueNotifier<Size> _photoSize = ValueNotifier(const Size(800, 600));
  final ValueNotifier<Sensors> _sensor = ValueNotifier(Sensors.BACK);
  final ValueNotifier<CaptureModes> _captureMode = ValueNotifier(CaptureModes.PHOTO);
  final ValueNotifier<bool> _enableAudio = ValueNotifier(true);
  final ValueNotifier<CameraOrientations> _orientation = ValueNotifier(CameraOrientations.PORTRAIT_UP);

  /// use this to call a take picture

  /// use this to record a video
  final VideoController _videoController = VideoController();

  /// list of available sizes
  List<Size> _availableSizes = [];

  AnimationController? _iconsAnimationController;

  Timer? _previewDismissTimer;
  StreamSubscription<Uint8List>? previewStreamSub;
  Stream<Uint8List>? previewStream;

  @override
  void initState() {
    super.initState();
    _iconsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _iconsAnimationController?.dispose();

    previewStreamSub?.cancel();
    _photoSize.dispose();
    _captureMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CameraCaptureViewModel>.reactive(
      viewModelBuilder: () => CameraCaptureViewModel(widget.refId, widget.referanceId, widget.fileStoreType, this),
      createNewModelOnInsert: true,
      onModelReady: (model) => SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        model.runStartupLogic(widget.refId, widget.fileStoreType);
      }),
      onDispose: (model) {
        model.onDispose();
      },
      builder: (context, model, child) => Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            _fullscreen ? buildFullscreenCamera() : buildSizedScreenCamera(),
            Stack(
              children: <Widget>[
                SafeArea(
                  bottom: false,
                  child: TopBarWidget(
                      isFullscreen: _fullscreen,
                      isRecording: _isRecordingVideo,
                      enableAudio: _enableAudio,
                      photoSize: _photoSize,
                      captureMode: _captureMode,
                      switchFlash: _switchFlash,
                      orientation: _orientation,
                      rotationController: _iconsAnimationController!,
                      onFlashTap: () {
                        switch (_switchFlash.value) {
                          case CameraFlashes.NONE:
                            _switchFlash.value = CameraFlashes.ON;
                            break;
                          case CameraFlashes.ON:
                            _switchFlash.value = CameraFlashes.AUTO;
                            break;
                          case CameraFlashes.AUTO:
                            _switchFlash.value = CameraFlashes.ALWAYS;
                            break;
                          case CameraFlashes.ALWAYS:
                            _switchFlash.value = CameraFlashes.NONE;
                            break;
                        }
                        setState(() {});
                      },
                      onAudioChange: () {
                        _enableAudio.value = !_enableAudio.value;
                        setState(() {});
                      },
                      onChangeSensorTap: () {
                        _focus = !_focus;
                        if (_sensor.value == Sensors.FRONT) {
                          _sensor.value = Sensors.BACK;
                        } else {
                          _sensor.value = Sensors.FRONT;
                        }
                      },
                      onResolutionTap: () => _buildChangeResolutionDialog(),
                      onFullscreenTap: () {
                        _fullscreen = !_fullscreen;
                        setState(() {});
                      }),
                ),
                BottomBarWidget(
                  onZoomInTap: () {
                    if (_zoomNotifier.value <= 0.9) {
                      _zoomNotifier.value += 0.1;
                    }
                    setState(() {});
                  },
                  onZoomOutTap: () {
                    if (_zoomNotifier.value >= 0.1) {
                      _zoomNotifier.value -= 0.1;
                    }
                    setState(() {});
                  },
                  onCaptureModeSwitchChange: () {
                    if (_captureMode.value == CaptureModes.PHOTO) {
                      _captureMode.value = CaptureModes.VIDEO;
                    } else {
                      _captureMode.value = CaptureModes.PHOTO;
                    }
                    setState(() {});
                  },
                  onCaptureTap: (_captureMode.value == CaptureModes.PHOTO) ? model.takePhoto : _recordVideo(),
                  rotationController: _iconsAnimationController!,
                  orientation: _orientation,
                  isRecording: _isRecordingVideo,
                  captureMode: _captureMode,
                ),
              ],
            ),
            // (!_isRecordingVideo && model.previewAnimation != null && model.lastPhotoPath.isNotEmpty)
            //     ? PreviewCardWidget(
            //         lastPhotoPath: model.lastPhotoPath,
            //         orientation: _orientation,
            //         previewAnimation: model.previewAnimation!,
            //       )
            //     : Container(),
          ],
        ),
      ),
    );
  }

  void onTimeOutError() {
    log.d("onTimeOutError__TAKE PHOTO CALLED");
  }

  _recordVideo() async {
    // lets just make our phone vibrate
    HapticFeedback.mediumImpact();

    if (_isRecordingVideo) {
      await _videoController.stopRecordingVideo();

      _isRecordingVideo = false;
      setState(() {});

      final file = File(_lastVideoPath);
      log.d("----------------------------------");
      log.d("VIDEO RECORDED");
      log.d("==> has been recorded : ${file.exists()} | path : $_lastVideoPath");
      log.d("----------------------------------");

      await Future.delayed(const Duration(milliseconds: 300));
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraPreview(
            videoPath: _lastVideoPath,
          ),
        ),
      );
    } else {
      final Directory extDir = await getTemporaryDirectory();
      final testDir = await Directory('${extDir.path}/test').create(recursive: true);
      final String filePath = '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
      await _videoController.recordVideo(filePath);
      _isRecordingVideo = true;
      _lastVideoPath = filePath;
      setState(() {});
    }
  }

  _buildChangeResolutionDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.separated(
        itemBuilder: (context, index) => ListTile(
          key: const ValueKey("resOption"),
          onTap: () {
            _photoSize.value = _availableSizes[index];
            setState(() {});
            Navigator.of(context).pop();
          },
          leading: const Icon(Icons.aspect_ratio),
          title: Text("${_availableSizes[index].width}/${_availableSizes[index].height}"),
        ),
        separatorBuilder: (context, index) => const Divider(),
        itemCount: _availableSizes.length,
      ),
    );
  }

  _onOrientationChange(CameraOrientations? newOrientation) {
    if (newOrientation != null) {
      _orientation.value = newOrientation;
      if (_previewDismissTimer != null) {
        _previewDismissTimer?.cancel();
      }
    }
  }

  _onPermissionsResult(bool? granted) {
    if (granted != null && !granted) {
      AlertDialog alert = AlertDialog(
        title: const Text('Error'),
        content: const Text('It seems you doesn\'t authorized some permissions. Please check on your settings and try again.'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    } else {
      setState(() {});
      log.d("granted");
    }
  }

  // /// this is just to preview images from stream
  // /// This use a bufferTime to take an image each 1500 ms
  // /// you cannot show every frame as flutter cannot draw them fast enough
  // /// [THIS IS JUST FOR DEMO PURPOSE]
  // Widget _buildPreviewStream() {
  //   if (previewStream == null) return Container();
  //   return Positioned(
  //     left: 32,
  //     bottom: 120,
  //     child: StreamBuilder(
  //       stream: previewStream.bufferTime(Duration(milliseconds: 1500)),
  //       builder: (context, snapshot) {
  //         log.d(snapshot);
  //         if (!snapshot.hasData || snapshot.data == null) return Container();
  //         List<Uint8List> data = snapshot.data;
  //         log.d(
  //             "...${DateTime.now()} new image received... ${data.last.lengthInBytes} bytes");
  //         return Image.memory(
  //           data.last,
  //           width: 120,
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget buildFullscreenCamera() {
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      right: 0,
      child: Center(
        child: CameraAwesome(
          onPermissionsResult: _onPermissionsResult,
          selectDefaultSize: (availableSizes) {
            _availableSizes = availableSizes;

            double defaultSizeIndex = 0;
            if (availableSizes.length > 2) {
              defaultSizeIndex = availableSizes.length / 2.0;
            }

            return availableSizes[defaultSizeIndex.floor()];
          },
          captureMode: _captureMode,
          photoSize: _photoSize,
          sensor: _sensor,
          enableAudio: _enableAudio,
          switchFlashMode: _switchFlash,

          zoom: _zoomNotifier,
          onOrientationChanged: _onOrientationChange,
          // imagesStreamBuilder: (imageStream) {
          //   /// listen for images preview stream
          //   /// you can use it to process AI recognition or anything else...
          //   log.d("-- init CamerAwesome images stream");
          //   setState(() {
          //     previewStream = imageStream;
          //   });

          //   imageStream.listen((Uint8List imageData) {
          //     log.d(
          //         "...${DateTime.now()} new image received... ${imageData.lengthInBytes} bytes");
          //   });
          // },
          onCameraStarted: () {
            // camera started here -- do your after start stuff
            _photoSize.value = const Size(800.0, 600.0);
          },
        ),
      ),
    );
  }

  Widget buildSizedScreenCamera() {
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      right: 0,
      child: Container(
        color: Colors.black,
        child: Center(
          child: SizedBox(
            height: 300,
            width: MediaQuery.of(context).size.width,
            child: CameraAwesome(
              onPermissionsResult: _onPermissionsResult,
              selectDefaultSize: (availableSizes) {
                _availableSizes = availableSizes;

                double defaultSizeIndex = 0;
                if (availableSizes.length > 2) {
                  defaultSizeIndex = availableSizes.length / 2.0;
                }

                return availableSizes[defaultSizeIndex.floor()];
              },
              captureMode: _captureMode,
              photoSize: _photoSize,
              sensor: _sensor,
              fitted: true,
              switchFlashMode: _switchFlash,
              zoom: _zoomNotifier,
              onOrientationChanged: _onOrientationChange,
            ),
          ),
        ),
      ),
    );
  }
}
