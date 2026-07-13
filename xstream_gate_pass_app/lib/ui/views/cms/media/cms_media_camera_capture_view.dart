import 'dart:async';
import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CmsMediaCameraCaptureView extends StatefulWidget {
  const CmsMediaCameraCaptureView({super.key});

  @override
  State<CmsMediaCameraCaptureView> createState() => _CmsMediaCameraCaptureViewState();
}

class _CmsMediaCameraCaptureViewState extends State<CmsMediaCameraCaptureView> {
  StreamSubscription<MediaCapture?>? _captureSubscription;
  String? _lastCapturedPath;

  @override
  void dispose() {
    _captureSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraAwesomeBuilder.awesome(
            previewDecoratorBuilder: (state, previewSize) {
              _subscribeToCaptureState(state);
              return const SizedBox.shrink();
            },
            saveConfig: SaveConfig.photo(
              mirrorFrontCamera: false,
              pathBuilder: (sensors) async {
                final tempDir = await getTemporaryDirectory();
                final imagesDir = await Directory(
                  path.join(tempDir.path, 'CMSMediaCamera'),
                ).create(recursive: true);
                final filePath = path.join(
                  imagesDir.path,
                  '${DateTime.now().millisecondsSinceEpoch}.jpg',
                );
                return SingleCaptureRequest(filePath, sensors.first);
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.topLeft,
                child: CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.45),
                  child: IconButton(
                    color: Colors.white,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop<String>(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _subscribeToCaptureState(CameraState state) {
    _captureSubscription?.cancel();
    _captureSubscription = state.captureState$.listen((event) async {
      final capturedPath = event?.captureRequest.path;
      if (event == null || capturedPath == null) {
        return;
      }

      if (!event.isPicture || event.status != MediaCaptureStatus.success) {
        return;
      }

      if (_lastCapturedPath == capturedPath || !mounted) {
        return;
      }

      _lastCapturedPath = capturedPath;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop<String>(capturedPath);
    });
  }
}
