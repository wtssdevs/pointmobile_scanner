import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sembast/timestamp.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/enums/basic_dialog_status.dart';
import 'package:xstream_gate_pass_app/core/enums/bckground_job_type.dart';
import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/core/enums/filestore_type.dart';
import 'package:xstream_gate_pass_app/core/models/background_job_que/background_job_Info.dart';
import 'package:xstream_gate_pass_app/core/models/basefiles/filestore/filestore.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate-pass-access_model.dart';
import 'package:xstream_gate_pass_app/core/models/shared/base_lookup.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/filestore/filestore_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/masterfiles/masterfiles_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/gatepass/gatepass_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/scan_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_drivers_license.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/media_service.dart';

import 'package:xstream_gate_pass_app/ui/views/shared/base_form_view_model.dart';
import 'package:xstream_gate_pass_app/ui/views/shared/localization/app_view_base_helper.dart';

class GatePassEditViewModel extends BaseFormViewModel with AppViewBaseHelper {
  GatePassEditViewModel(this._gatePass);
  GatePassAccess _gatePass;
  GatePassAccess get gatePass => _gatePass;
  Function? _onModelSet;

  final log = getLogger('GatePassEditViewModel');
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();
  final GatePassService _gatePassService = locator<GatePassService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _scanningService = locator<ScanningService>();
  final _fileStoreRepository = locator<FileStoreRepository>();
  final _mediaService = locator<MediaService>();
  final _workerQueManager = locator<WorkerQueManager>();

  final _masterFilesService = locator<MasterFilesService>();
  StreamSubscription<RsaDriversLicense>? streamSubscription;
  List<FileStore> _fileStoreItems = <FileStore>[];
  List<FileStore> get fileStoreItems => _fileStoreItems;
  final _connectionService = locator<ConnectionService>();
  bool get hasConnection => _connectionService.hasConnection;

  RsaDriversLicense? _rsaDriversLicense;
  RsaDriversLicense? get rsaDriversLicense => _rsaDriversLicense;

  List<BaseLookup> _customers = <BaseLookup>[];
  List<BaseLookup> get customers => _customers;

  void startconnectionListen() {
    streamSubscription =
        _scanningService.licenseStream.asBroadcastStream().listen((data) {
      // log.i('Barcode Model Recieved? $data');
      _rsaDriversLicense = data;
      gatePass.driverName =
          "${_rsaDriversLicense?.firstNames} ${_rsaDriversLicense?.surname}";
      gatePass.driverIdNo = _rsaDriversLicense?.idNumber;
      gatePass.driverLicenceNo =
          "${_rsaDriversLicense?.licenseNumber} (${_rsaDriversLicense?.vehicleCodes.join(",")})";
      //gatePass.driv = _rsaDriversLicense?.gender;

      setModelUpdate(_gatePass);
      notifyListeners();
    });
  }

  Future<void> runStartupLogic() async {
    _scanningService.initialise();
    startconnectionListen();

    setModelUpdate(_gatePass);
    await loadFileStoreImages();
    _customers = await _masterFilesService.getAllLocalDetainOptions("");

    setCustomValidations();
    notifyListeners();
  }

  handleBackButton() async {
    _navigationService.back();
  }

  setCustomValidations() {
    var valMsg = "Customer is required!";
    if (gatePass.customerId == null || gatePass.customerId == 0) {
      setValidationMessage(valMsg);
    } else {
      clearValidationMessage(valMsg);
    }
  }

  listenToModelSet(Function onModelSet) {
    _onModelSet = onModelSet;
  }

  setModelUpdate(GatePassAccess entity) {
    _onModelSet?.call(entity);
    notifyListeners();
  }

  void setModeldata(GatePassAccess updatedData) {
    _gatePass = updatedData;

    //updateHasEdit(true);
    notifyListeners();
  }

  Future<void> onDispose() async {
    if (streamSubscription != null) {
      await streamSubscription?.cancel();
    }

    _scanningService.onExit();
  }

  void onFilterValueChanged(String value) {}

  Future<void> save() async {
    if (!_connectionService.hasConnection) {
      //internet Message
      return;
    }

    notifyListeners();
  }

  Future<void> getStoragePermissions() async {
    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }
    var mediaLibraryStatus = await Permission.mediaLibrary.status;
    if (!mediaLibraryStatus.isGranted) {
      await Permission.mediaLibrary.request();
    }
    var camStatus = await Permission.camera.status;
    if (!camStatus.isGranted) {
      await Permission.camera.request();
    }
  }

  void setDocRecievedChange(bool? val) {
    if (val != null) {
      //gatePass.gatePassQuestions?.hasDeliveryDocuments = val;
      notifyListeners();
    }
  }

  void modelNotifyListeners() {
    notifyListeners();
  }

  Future<void> saveOnly() async {
    if (!_connectionService.hasConnection) {
      await _dialogService.showCustomDialog(
        variant: DialogType.basic,
        data: BasicDialogStatus.warning,
        title: "Internet Connection Failure",
        description:
            'Could not Save,Please check you internet connection and try again',
        mainButtonTitle: "Ok",
      );
    }
    //here we save back to server
    GatePassAccess? reponse;
    if (gatePass.id == 0) {
      reponse = await _gatePassService.create(gatePass);
    } else {
      reponse = await _gatePassService.update(gatePass);
    }

    if (reponse != null) {
      _gatePass = reponse;
      Fluttertoast.showToast(
          msg: "Save was successful! ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14.0);
    } else {
      //error could not save
      Fluttertoast.showToast(
          msg: "Save Failed!,Please try again or contact your system admin. ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0);
    }

    //update Screen UI state with model changes
    setModelUpdate(_gatePass);
    notifyListeners();
  }

  Future<void> authorizeEntry() async {
    if (!_connectionService.hasConnection) {
      await _dialogService.showCustomDialog(
        variant: DialogType.basic,
        data: BasicDialogStatus.warning,
        title: "Internet Connection Failure",
        description:
            'Could not authorize for entry,Please check you internet connection and try again',
        mainButtonTitle: "Ok",
      );
    }
    //here we save back to server
    var reponse = await _gatePassService.authorizeForEntry(gatePass);
    if (reponse != null) {
      _gatePass = reponse;
      Fluttertoast.showToast(
          msg: "Save was successful! ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14.0);
    } else {
      //error could not save
      Fluttertoast.showToast(
          msg: "Save Failed!,Please try again or contact your system admin. ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0);
    }

    //update Screen UI state with model changes
    setModelUpdate(_gatePass);
    notifyListeners();
  }

  Future<void> authorizeExit() async {
    if (!_connectionService.hasConnection) {
      await _dialogService.showCustomDialog(
        variant: DialogType.basic,
        data: BasicDialogStatus.warning,
        title: "Internet Connection Failure",
        description:
            'Could not authorize for entry,Please check you internet connection and try again',
        mainButtonTitle: "Ok",
      );
    }
    //here we save back to server
    var reponse = await _gatePassService.authorizeExit(gatePass);
    if (reponse != null) {
      _gatePass = reponse;
      Fluttertoast.showToast(
          msg: "Save was successful! ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14.0);
    } else {
      //error could not save
      Fluttertoast.showToast(
          msg: "Save Failed!,Please try again or contact your system admin. ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0);
    }

    //update Screen UI state with model changes
    setModelUpdate(_gatePass);
    notifyListeners();
  }

  Future<void> rejectEntry() async {
    if (!_connectionService.hasConnection) {
      await _dialogService.showCustomDialog(
        variant: DialogType.basic,
        data: BasicDialogStatus.warning,
        title: "Internet Connection Failure",
        description:
            'Could not authorize for entry,Please check you internet connection and try again',
        mainButtonTitle: "Ok",
      );
    }
    //here we save back to server
    var reponse = await _gatePassService.rejectForEntry(gatePass);
    if (reponse != null) {
      _gatePass = reponse;
      Fluttertoast.showToast(
          msg: "Save was successful! ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14.0);
    } else {
      //error could not save
      Fluttertoast.showToast(
          msg: "Save Failed!,Please try again or contact your system admin. ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0);
    }

    //update Screen UI state with model changes
    setModelUpdate(_gatePass);
    notifyListeners();
  }

  Future<void> onTabBarTap(int index) async {
    switch (index) {
      case 1:
        await loadFileStoreImages();
        notifyListeners();
        break;
      default:
    }
  }

  Future<void> loadFileStoreImages() async {
    if (gatePass.id != null && gatePass.id != 0) {
      // _fileStoreItems = await _fileStoreRepository.getAll(gatePass.id!, 100);
    }
  }

  Future<void> goToCamView(FileStoreType fileStoreType) async {
    await getStoragePermissions();
    if (gatePass.id != null && gatePass.id != 0) {
      // await _navigationService.navigateTo(
      //   Routes.cameraCaptureView,
      //   arguments: CameraCaptureViewArguments(refId: gatePass.id!, referanceId: 0, fileStoreType: fileStoreType),
      // );
      await _navigationService.navigateToCamBarcodeReader();

      await loadFileStoreImages();

      notifyListeners();
    }
  }

  Future<void> saveImageToLocalDb(
      {required File galleryFile, required String tempFilePath}) async {
    await _fileStoreRepository.insert(
      FileStore(
          desc: "",
          referanceId: 0,
          filestoreType: FileStoreType.image.index,
          path: galleryFile.path,
          tempPath: tempFilePath,
          fileName: galleryFile.path,
          createdDateTime: Timestamp.now(),
          refId: gatePass.id!),
    );
  }

  Future<void> deleteImage(FileStore fileItem) async {
    var confirm = await _dialogService.showCustomDialog(
        variant: DialogType.basic,
        data: BasicDialogStatus.warning,
        title: "Delete Image?.",
        description: 'Are you sure you want to Delete this image?',
        mainButtonTitle: "Confirm",
        takesInput: false,
        secondaryButtonTitle: "Cancel");

    if (confirm != null && confirm.confirmed) {
      await _fileStoreRepository.delete(fileItem);

      //server side delete of image
      await _workerQueManager.enqueSingle(BackgroundJobInfo(
          refTransactionId: gatePass.id,
          jobType: BackgroundJobType.syncImages.index,
          jobArgs: fileItem.fileName,
          lastTryTime: Timestamp.now(),
          creationTime: Timestamp.now(),
          nextTryTime: Timestamp.now(),
          id: "",
          isAbandoned: false));
    }
    await loadFileStoreImages();
    notifyListeners();
  }

  Future<void> openImagePicker() async {
    await getStoragePermissions();
    if (gatePass.id != null && gatePass.id != 0) {
      var selectedImages = await _mediaService.pickMultiImages();
      if (selectedImages != null) {
        for (var xfile in selectedImages) {
          final file = File(xfile.path);
          await saveImageToLocalDb(galleryFile: file, tempFilePath: xfile.path);
        }

        await loadFileStoreImages();
        //await save();
      }
    }

    notifyListeners();
  }

  BaseLookup? getCustomer() {
    if (gatePass.customerName != null && gatePass.customerName!.isNotEmpty) {
      return BaseLookup(
          // code: gatePass.customerCode,
          id: gatePass.customerId,
          name: gatePass.customerName,
          displayName: gatePass.customerName);
    }
    if (gatePass.customerId == null) {
      return null;
    }
    var found = customers.firstWhereOrNull((e) => e.id == gatePass.customerId);
    if (found != null) {
      return found;
    }

    return null;
  }

  void setCustomer(BaseLookup selectedItem) {
    gatePass.customerId = selectedItem.id;
    gatePass.customerName = selectedItem.name;
//    gatePass.cu = selectedItem.code;

    notifyListeners();
  }
}
