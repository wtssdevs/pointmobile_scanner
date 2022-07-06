import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:xstream_gate_pass_app/app_config/app.locator.dart';
import 'package:xstream_gate_pass_app/app_config/app.logger.dart';
import 'package:xstream_gate_pass_app/app_config/app.router.dart';
import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

class StartUpViewModel extends BaseViewModel {
  final log = getLogger('StartUpViewModel');
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final ApiManager _apiManager = locator<ApiManager>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  //final _authenticationService = locator<AuthenticationService>();

  final _connectionService = locator<ConnectionService>();
  bool get hasConnection => _connectionService.hasConnection;

  Future<void> runStartupLogic() async {
    var useIsLoggedIn = _localStorageService.isLoggedIn;
    FlutterNativeSplash.remove();
    _navigationService.clearStackAndShow(Routes.homeView);
  }
}
