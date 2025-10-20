import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/services/shared/media_service.dart';
import 'package:xstream_gate_pass_app/core/utils/crop_editor_helper.dart';

class ImageEditorViewModel extends BaseViewModel {
  final NavigationService _navigationService = locator<NavigationService>();

  final MediaService _mediaService = locator<MediaService>();
  final log = getLogger('ImageEditorViewModel');

  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();
  bool _cropping = false;
  bool get cropping => _cropping;
  Future handleStartUpLogic() async {}

  Future<bool> canBack() async {
    _navigationService.back();
    return true;
  }

  Future<void> cropImage() async {
    if (cropping) {
      return;
    }
    _cropping = true;
    try {
      final ExtendedImageEditorState? state = editorKey.currentState;
      if (state == null) {
        return;
      }

      // final Uint8List fileData =
      //     Uint8List.fromList((await cropImageDataWithNativeLibrary(state: editorKey.currentState!))!);
      final Uint8List fileData = state.rawImageData;
      final String? fileFath = await _mediaService.imageSave(fileData);
      if (fileFath != null) {
        Fluttertoast.showToast(
          msg: "Saveing image...",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        _navigationService.back<String?>(result: fileFath);
      } else {
        //error
        log.e("cropImage Error,file path empty,could not save file");
      }

      return;
    } finally {
      _cropping = false;
    }
  }
}
