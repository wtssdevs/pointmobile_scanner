import 'dart:io';

import 'package:add_to_gallery/add_to_gallery.dart';
import 'package:camera/camera.dart';
import 'package:camerawesome/picture_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sembast/timestamp.dart';
import 'package:stacked/stacked.dart';

import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app_config/app.locator.dart';
import 'package:xstream_gate_pass_app/app_config/app.logger.dart';
import 'package:xstream_gate_pass_app/app_config/app.router.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/basic_dialog_status.dart';
import 'package:xstream_gate_pass_app/core/enums/bckground_job_type.dart';
import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/core/enums/filestore_type.dart';
import 'package:xstream_gate_pass_app/core/models/background_job_que/background_job_Info.dart';
import 'package:xstream_gate_pass_app/core/models/basefiles/filestore/filestore.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/filestore/filestore_repository.dart';
import 'package:xstream_gate_pass_app/core/services/shared/media_service.dart';

class CameraViewModel extends BaseViewModel {
  final DialogService _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final _mediaService = locator<MediaService>();

  final FileStoreType fileStoreType;
  final int refId;
  final int referanceId;

  final TickerProvider vsync;
  CameraViewModel(this.refId, this.referanceId, this.fileStoreType, this.vsync);

  final log = getLogger('CameraCaptureViewModel');

  final _fileStoreRepository = locator<FileStoreRepository>();
  final _workerQueManager = locator<WorkerQueManager>();
  String lastPhotoPath = '';

  Future<void> runStartupLogic(
    int refId,
    FileStoreType fileStoreType,
  ) async {
    refId = refId;
    fileStoreType = fileStoreType;
  }

  Future<void> saveToLocalDb({required File galleryFile, required String tempFilePath, String? fileName}) async {
    // var newLocation = await _locationService.getLocation().timeout(const Duration(seconds: 12), onTimeout: () => null);
    // if (newLocation != null && newLocation.latitude == null) {
    //   newLocation = await _locationService.getLocation().timeout(const Duration(seconds: 10), onTimeout: () => null);
    // }

    // if (kDebugMode) {
    //   log.d("----------------------------------");
    //   log.d("==> saveToLocalDb newLocation : ${newLocation?.latitude}, ${newLocation?.longitude}");
    //   log.d("----------------------------------");
    // }
    var fileStoreId = await _fileStoreRepository.insert(
      FileStore(
          filestoreType: fileStoreType.index,
          path: galleryFile.path,
          desc: "",
          referanceId: referanceId, //stop
          tempPath: tempFilePath,
          // latitude: newLocation?.latitude,
          //longitude: newLocation?.longitude,
          fileName: fileName ?? galleryFile.path,
          createdDateTime: Timestamp.now(),
          refId: refId), //step
    );
    await _workerQueManager.enqueSingle(
        BackgroundJobInfo(
            jobType: BackgroundJobType.syncImages.index,
            jobArgs: fileStoreId,
            lastTryTime: Timestamp.now(),
            creationTime: Timestamp.now(),
            nextTryTime: Timestamp.now(),
            refTransactionId: referanceId,
            stopId: referanceId,
            id: "",
            isAbandoned: false),
        false);
  }

  takePhoto(XFile xFile) async {
    final Directory extDir = await getTemporaryDirectory();
    final testDir = await Directory('${extDir.path}/Images').create(recursive: true);
    var fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = '${testDir.path}/$fileName';
    var status = await Permission.storage.status;
    if (status.isGranted == false) {
      await Permission.storage.request();
    }
    if (kDebugMode) {
      log.i("takePhoto : $status");
    }

    // await pictureController.takePicture(filePath).timeout(const Duration(seconds: 4), onTimeout: () async {
    //   if (kDebugMode) {
    //     log.i("takePhoto timeout Error : $status");
    //   }

    //   await _dialogService.showCustomDialog(
    //     variant: DialogType.basic,
    //     data: BasicDialogStatus.error,
    //     title: "Capture Image Error.",
    //     description: 'Capture Image Error,Please try agian.',
    //     mainButtonTitle: "Ok",
    //   );
    //   return;
    // });

    // lets just make our phone vibrate
    HapticFeedback.mediumImpact();
    try {
      var file = File(xFile.path);

      if (fileStoreType == FileStoreType.documentScan) {
//send for edit,after edit we will move forward
        var croppedFilePath = await _navigationService.navigateTo(
          Routes.imageEditorView,
          arguments: ImageEditorViewArguments(filePath: xFile.path),
        );

        if (croppedFilePath != null) {
          file = File(croppedFilePath);
        } else {
          return;
        }
      }

      File addToGalleryFile = await AddToGallery.addToGallery(
        originalFile: file,
        albumName: AppConst.App_Gallery_Album,
        deleteOriginalFile: true,
      );

      lastPhotoPath = addToGalleryFile.path;
      //here we will
      await saveToLocalDb(galleryFile: addToGalleryFile, tempFilePath: filePath, fileName: fileName);

      notifyListeners();

      Fluttertoast.showToast(
          msg: "Image capture successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.green.withOpacity(0.8),
          textColor: Colors.black,
          fontSize: 14.0);
      // if (previewAnimationController?.status == AnimationStatus.completed) {
      //   previewAnimationController?.reset();
      // }

      // if (previewAnimationController != null) {
      //   previewAnimationController?.forward();
      // }

      if (kDebugMode) {
        log.d("----------------------------------");
        log.d("==> hastakePhoto : ${await file.exists()} | path : $filePath");
        log.d("----------------------------------");
      }
    } catch (e) {
      log.e(e);
      await _dialogService.showCustomDialog(
        variant: DialogType.basic,
        data: BasicDialogStatus.error,
        title: "Capture Image Error.",
        description: 'Capture Image Error,Please try agian.${e.toString()}',
        mainButtonTitle: "Ok",
      );
    }
  }

  void onDispose() {}
}
