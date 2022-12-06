import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/box_text.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/editor/image_editor_view_model.dart';

class ImageEditorView extends StatelessWidget {
  const ImageEditorView({Key? key, required this.filePath}) : super(key: key);
  final String filePath;
  @override
  Widget build(BuildContext context) {
    var provider = ExtendedFileImageProvider(File(filePath), cacheRawData: true);
    return ViewModelBuilder<ImageEditorViewModel>.reactive(
      viewModelBuilder: () => ImageEditorViewModel(),
      onModelReady: (model) {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          model.handleStartUpLogic();
        });
      },
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          return model.canBack();
        },
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.white,
            child: const Icon(
              Icons.save,
              color: Colors.green,
            ),
            onPressed: () async {
              model.cropImage();
            },
          ),
          appBar: AppBar(
            title: const BoxText.headingThree("Crop Image"),
          ),
          body: SafeArea(
            child: ExtendedImage(
              image: provider,
              fit: BoxFit.contain,
              mode: ExtendedImageMode.editor,
              extendedImageEditorKey: model.editorKey,
              initEditorConfigHandler: (state) {
                return EditorConfig(maxScale: 8.0, cropRectPadding: const EdgeInsets.all(16.0), hitTestSize: 20.0, cropAspectRatio: CropAspectRatios.original);
                //_aspectRatio.aspectRatio);
              },
            ),
          ),
        ),
      ),
    );
  }
}
