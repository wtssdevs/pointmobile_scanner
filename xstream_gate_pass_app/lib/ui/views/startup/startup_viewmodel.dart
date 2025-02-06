import 'package:flutter_logs/flutter_logs.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';

import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/authentication_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

class StartUpViewModel extends BaseViewModel {
  final log = getLogger('StartUpViewModel');
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final ApiManager _apiManager = locator<ApiManager>();
  final _navigationService = locator<NavigationService>();
  final _workerQueManager = locator<WorkerQueManager>();
  final _authenticationService = locator<AuthenticationService>();

  final _connectionService = locator<ConnectionService>();
  bool get hasConnection => _connectionService.hasConnection;

  Future<void> runStartupLogic() async {
    try {
      var useIsLoggedIn = _localStorageService.isLoggedIn;

      if (useIsLoggedIn == false) {
        FlutterNativeSplash.remove();
        _authenticationService.logOutCurrentUser();
        _navigationService.clearStackAndShow(Routes.loginView);
      } else {
        if (hasConnection) {
          var canRefresh = await _authenticationService.refreshToken();
          if (canRefresh == false) {
            FlutterNativeSplash.remove();
            _navigationService.clearStackAndShow(Routes.loginView);
          }

          await _authenticationService.getUserLoginInfo(true);
          //_workerQueManager.enqueForStartUp();

          // await Future.delayed(const Duration(milliseconds: 100));
          // whenever your initialization is completed, remove the splash screen:
          FlutterNativeSplash.remove();
          _navigationService.clearStackAndShow(Routes.homeView);
        } else {
          var canRefresToken = await _authenticationService.refreshToken();
          if (canRefresToken) {
            await _authenticationService.getUserLoginInfo(true);
            //_workerQueManager.enqueForStartUp();
            //  await Future.delayed(const Duration(milliseconds: 200));
            // whenever your initialization is completed, remove the splash screen:
            FlutterNativeSplash.remove();
            _navigationService.clearStackAndShow(Routes.homeView);
          } else {
            FlutterNativeSplash.remove();
            _navigationService.clearStackAndShow(Routes.loginView);
          }
        }
      }
    } catch (e) {
      log.e(e);
      await FlutterLogs.logError(
        "StartUpViewModel",
        "runStartupLogic",
        e.toString(),
      );

      FlutterNativeSplash.remove();
      _navigationService.clearStackAndShow(Routes.loginView);
    }
  }
}
