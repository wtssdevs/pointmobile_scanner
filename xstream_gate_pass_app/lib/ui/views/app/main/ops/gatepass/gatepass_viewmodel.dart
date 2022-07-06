import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app_config/app.locator.dart';
import 'package:xstream_gate_pass_app/app_config/app.logger.dart';
import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/scan_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_drivers_license.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

class GatePassViewModel extends BaseViewModel {
  final log = getLogger('StartUpViewModel');
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final ApiManager _apiManager = locator<ApiManager>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _scanningService = locator<ScanningService>();
  final TextEditingController filterController = TextEditingController();

  final _connectionService = locator<ConnectionService>();
  bool get hasConnection => _connectionService.hasConnection;

  RsaDriversLicense? _rsaDriversLicense;
  RsaDriversLicense? get rsaDriversLicense => _scanningService.rsaDriversLicense;

  Future<void> runStartupLogic() async {
    _scanningService.initialise();
  }

  void onDispose() {
    _scanningService.onExit();
  }

  void onFilterValueChanged(String value) {}
}
