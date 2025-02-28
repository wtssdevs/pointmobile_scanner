import 'dart:async';
import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:gal/gal.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sembast/timestamp.dart';
import 'package:stacked/stacked.dart';

import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/basic_dialog_status.dart';
import 'package:xstream_gate_pass_app/core/enums/bckground_job_type.dart';
import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/core/enums/filestore_type.dart';
import 'package:xstream_gate_pass_app/core/models/background_job_que/background_job_Info.dart';
import 'package:xstream_gate_pass_app/core/models/basefiles/filestore/filestore.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/filestore/filestore_repository.dart';

class CameraCaptureViewModel extends BaseViewModel {
  final DialogService _dialogService = locator<DialogService>();
  final _navigationService = locator<NavigationService>();
  final FileStoreType fileStoreType;
  final int refId;
  final int referanceId;
  StreamSubscription<MediaCapture?>? listenEvent;
  final TickerProvider vsync;
  CameraCaptureViewModel(
      this.refId, this.referanceId, this.fileStoreType, this.vsync);

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

    var status = await Permission.storage.status;
    if (status.isGranted == false) {
      await Permission.storage.request();
    }

    // Check Permission

    var hasAccess = await Gal.hasAccess();
    if (hasAccess == false) {
      // Request Permission
      await Gal.requestAccess();
    }
  }

  Future<SingleCaptureRequest> getFilePath(sensors) async {
    final Directory extDir = await getTemporaryDirectory();
    final testDir =
        await Directory('${extDir.path}/Images').create(recursive: true);
    const String fileExtension = 'jpg';
    final String filePath =
        '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
    return SingleCaptureRequest(filePath, sensors.first);
  }

  Future<void> saveToLocalDb(
      {required File galleryFile,
      required String tempFilePath,
      String? fileName}) async {
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
          refId: refId.toString()), //step
    );
    await _workerQueManager.enqueSingle(
        BackgroundJobInfo(
            jobType: BackgroundJobType.syncImages.index,
            jobArgs: fileStoreId,
            lastTryTime: Timestamp.now(),
            creationTime: Timestamp.now(),
            nextTryTime: Timestamp.now(),
            refTransactionId: referanceId.toString(),
            stopId: referanceId,
            id: "",
            isAbandoned: false),
        false);
  }

  void setUpCaptureStateSubscription(CameraState state) {
    if (listenEvent != null) {
      if (kDebugMode) {
        log.d("Cancel existing Listener.");
      }
      listenEvent!.cancel();
    }
    listenEvent = state.captureState$.listen((event) async {
      if (event == null) return;

      if (event.captureRequest.path == null) {
        return;
      }

      if (event.isPicture && event.status == MediaCaptureStatus.success) {
        if (lastPhotoPath != event.captureRequest.path) {
          if (event.exception != null) {
            await _dialogService.showCustomDialog(
              variant: DialogType.basic,
              data: BasicDialogStatus.error,
              title: "Capture Image Error.",
              description: event.exception.toString(),
              mainButtonTitle: "Ok",
            );
          } else {
            await takePhoto(event.captureRequest.path!);
          }
        }

        lastPhotoPath = event.captureRequest.path!;
      }
    });
  }

  takePhoto(String filePath) async {
    // lets just make our phone vibrate
    HapticFeedback.mediumImpact();
    try {
      var file = File(filePath);

      if (fileStoreType == FileStoreType.documentScan) {
//send for edit,after edit we will move forward
        var croppedFilePath = await _navigationService.navigateTo(
          Routes.imageEditorView,
          arguments: ImageEditorViewArguments(filePath: filePath),
        );

        if (croppedFilePath != null) {
          file = File(croppedFilePath);
        } else {
          return;
        }
      }

      // Check Permission
      var hasAccess = await Gal.hasAccess();
      if (hasAccess == false) {
        // Request Permission
        await Gal.requestAccess();
      }

      await Gal.putImage(filePath, album: '$AppConst.App_Gallery_Album');

      lastPhotoPath = file.path;
      //here we will
      await saveToLocalDb(
          galleryFile: file, tempFilePath: filePath, fileName: null);

      notifyListeners();

      Fluttertoast.showToast(
        msg: "Image capture successful",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM_LEFT,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green.withOpacity(0.8),
        textColor: Colors.black,
        fontSize: 14.0,
      );

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
