import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app_config/app.locator.dart';
import 'package:xstream_gate_pass_app/app_config/app.logger.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_model.dart';
import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/scan_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_drivers_license.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';
import 'package:xstream_gate_pass_app/ui/views/shared/base_form_view_model.dart';

class GatePassEditViewModel extends BaseFormViewModel {
  GatePassEditViewModel(this._gatePass);
  GatePass _gatePass;
  GatePass get gatePass => _gatePass;
  Function? _onModelSet;

  final log = getLogger('GatePassEditViewModel');
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final ApiManager _apiManager = locator<ApiManager>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _scanningService = locator<ScanningService>();

  StreamSubscription<RsaDriversLicense>? streamSubscription;

  final _connectionService = locator<ConnectionService>();
  bool get hasConnection => _connectionService.hasConnection;

  final formKey = GlobalKey<FormState>();

  RsaDriversLicense? _rsaDriversLicense;
  RsaDriversLicense? get rsaDriversLicense => _rsaDriversLicense;

  void startconnectionListen() {
    streamSubscription = _scanningService.licenseStream.asBroadcastStream().listen((data) {
      log.i('Barcode Model Recieved? $data');
      _rsaDriversLicense = data;
      notifyListeners();
    });
  }

  Future<void> runStartupLogic() async {
    _scanningService.initialise();
    startconnectionListen();
    setModelUpdate(_gatePass);
    //await loadFileStoreImages();

    notifyListeners();
  }

  handleBackButton() async {
    _navigationService.back();
  }

  listenToModelSet(Function onModelSet) {
    _onModelSet = onModelSet;
  }

  setModelUpdate(GatePass entity) {
    _onModelSet?.call(entity);
    notifyListeners();
  }

  void setModeldata(GatePass updatedData) {
    _gatePass = updatedData;

    //updateHasEdit(true);
    notifyListeners();
  }

  void onDispose() async {
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

    //filter for not uploaded yet
    // var filesToSave = fileStoreItems.where((element) => element.upLoaded == false).toList();

    // for (var item in filesToSave) {
    //   var fileAsBase64String = await convertFileStoreToBase64String(item);
    //   if (fileAsBase64String != null) {
    //     _gatePass.imagesAsBase64String!.add(fileAsBase64String);
    //   }
    // }

    // for (var item in filesToSave) {
    //   item.upLoaded = true;
    //   await _fileStoreRepository.update(item);
    // }
    notifyListeners();
  }

    Future<void> getStoragePermissions() async {
    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }
  }
}
