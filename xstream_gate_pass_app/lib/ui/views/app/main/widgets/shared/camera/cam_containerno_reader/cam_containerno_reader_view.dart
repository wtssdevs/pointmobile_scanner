import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/core/models/basefiles/containers/container_info_extratced_model.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/cam_barcode_reader/barcode_display_widget.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/cam_containerno_reader/cam_containerno_reader_viewmodel.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/cam_containerno_reader/widgets/container_display_widget.dart';

class CamContainernoReaderView extends StatefulWidget {
  const CamContainernoReaderView({super.key});

  @override
  State<CamContainernoReaderView> createState() => _CamContainernoReaderState();
}

class _CamContainernoReaderState extends State<CamContainernoReaderView> with TickerProviderStateMixin {
  final _buffer = <ContainerInfo>[];
  List<ContainerInfo> _containerInfos = [];
  AnalysisImage? _image;
  final _barcodesController = BehaviorSubject<List<ContainerInfo>>();
  late final Stream<List<ContainerInfo>> _barcodesStream = _barcodesController.stream;
  final _scrollController = ScrollController();

  // Add this to store the analysis controller
  AnalysisController? _analysisController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _barcodesController.close();
    super.dispose();
  }

  void _addContainerInfo(ContainerInfo value) {
    try {
      if (_buffer.length > 20) {
        _buffer.removeRange(_buffer.length - 20, _buffer.length);
      }
      if (_buffer.isEmpty || value != _buffer[0]) {
        _buffer.insert(0, value);
        _barcodesController.add(_buffer);
        // _scrollController.animateTo(
        //   0,
        //   duration: const Duration(milliseconds: 400),
        //   curve: Curves.fastLinearToSlowEaseIn,
        // );

        // Stop analysis if we have 10 or more container numbers
        if (_buffer.length >= 10 && _analysisController != null && _analysisController!.enabled) {
          _analysisController!.stop();
          print("Stopping analysis after detecting 10 containers");
          setState(() {});
        }
      }
    } catch (err) {
      print("...logging error $err");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CamContainernoReaderViewModel>.reactive(
      viewModelBuilder: () => CamContainernoReaderViewModel(),
      onViewModelReady: (model) => SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        model.runStartupLogic();
      }),
      onDispose: (model) {
        model.dispose();
      },
      builder: (context, model, child) => Scaffold(
          body: CameraAwesomeBuilder.previewOnly(
        imageAnalysisConfig: AnalysisConfig(
          androidOptions: const AndroidAnalysisOptions.nv21(
            width: 512,
          ),
          maxFramesPerSecond: 5,
          autoStart: true,
        ),
        onImageForAnalysis: (img) async {
          var result = await model.processImageForContainer(img);
          if (result != null) {
            if (result.containerNumber.isNotEmpty) {
              _addContainerInfo(result);
            }
          }
        },

        // 4.
        builder: (cameraModeState, preview) {
          // Store the analysis controller for later use
          _analysisController = cameraModeState.analysisController;
          return ContainerDisplayWidget(
            barcodesStream: _barcodesStream,
            scrollController: _scrollController,
            analysisController: cameraModeState.analysisController!,
          );
        },
      )),
    );
  }
}
