import 'dart:async';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';

import 'package:xstream_gate_pass_app/core/enums/basic_dialog_status.dart';
import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/core/models/account/GetCurrentLoginInformation.dart';
import 'package:xstream_gate_pass_app/core/models/device/device_config.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/authentication_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/background_job_info_repository.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

class AccountViewModel extends BaseViewModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();
  final _connectionService = locator<ConnectionService>();
  final _authenticationService = locator<AuthenticationService>();
  final _backgroundJobInfoRepository = locator<BackgroundJobInfoRepository>();
  final DialogService _dialogService = locator<DialogService>();

  String get connectivityResultDisplayName =>
      _connectionService.showConnectivityResultDisplayName;
  String get showConnectionStatus => _connectionService.showConnectionStatus;
  bool get hasConnection => _connectionService.hasConnection;

  int _syncCount = 0;
  int get syncCount => _syncCount;

  CurrentLoginInformation? _currentLoginInformation;
  CurrentLoginInformation? get currentLoginInformation =>
      _currentLoginInformation;

  DeviceConfig get deviceConfig => _localStorageService.getDeviceConfig;

  Future handleStartUpLogic() async {
    await loadTaskCount();
    notifyListeners();
    startconnectionListen();
    if (hasConnection) {
      await getCurrentUserInfo();
      notifyListeners();
    }
  }

  StreamSubscription? streamSubscription;
  void startconnectionListen() {
    streamSubscription =
        _connectionService.connectionChange.asBroadcastStream().listen((data) {
      //log.i('Start Connectivity Change Listener? $data');
      notifyListeners();
    });
  }

  Future getCurrentUserInfo() async {
    //_currentLoginInformation = _localStorageService.getUserLoginInfo;
    _currentLoginInformation =
        await _authenticationService.getUserLoginInfo(true);
  }

  Future loadTaskCount() async {
    var waitingJobs = await _backgroundJobInfoRepository.getAll("");
    _syncCount = waitingJobs.length;
  }

  void goback() {
    _navigationService.back();
  }

  void handelLogout() async {
    _localStorageService.logout();
    _navigationService.clearStackAndShow(Routes.loginView);
  }

  logout() async {
    var shouldLogout = await confirmLogout();
    if (shouldLogout) {
      handelLogout();
    }
  }

  Future<void> navigateToTermsView() async {
    await _navigationService.navigateTo(Routes.termsAndPrivacyView);
  }

  Future<bool> confirmLogout() async {
    var confirm = await _dialogService.showCustomDialog(
        variant: DialogType.basic,
        data: BasicDialogStatus.warning,
        title: "Confirm Logout.",
        description: 'Are you sure you want to exit the application',
        mainButtonTitle: "Accept",
        secondaryButtonTitle: "Decline");

    if (confirm != null) {
      return confirm.confirmed;
    }

    return false;
  }

  Future<void> onDispose() async {
    if (streamSubscription != null) {
      await streamSubscription?.cancel();
    }
  }

  Future<void> gotoSyncList() async {
    await _navigationService.navigateTo(
      Routes.dataSyncView,
    );
    await loadTaskCount();
    notifyListeners();
  }

  void gotoDeviceConfiguration() {}

  void updateDeviceConfig(DeviceScanningMode? value) {
    if (value != null) {
      deviceConfig.deviceScanningMode = value;
      _localStorageService.setDeviceConfig(deviceConfig);
      rebuildUi();
    }
  }
}
