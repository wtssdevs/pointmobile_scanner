import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:xstream_gate_pass_app/app_config/app.locator.dart';
import 'package:xstream_gate_pass_app/app_config/app.logger.dart';
import 'package:xstream_gate_pass_app/app_config/app.router.dart';
import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/authentication_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

class StartUpViewModel extends BaseViewModel {
  final log = getLogger('StartUpViewModel');
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final ApiManager _apiManager = locator<ApiManager>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();

  final _authenticationService = locator<AuthenticationService>();

  final _connectionService = locator<ConnectionService>();
  bool get hasConnection => _connectionService.hasConnection;

  Future<void> runStartupLogic() async {
    try {
      var useIsLoggedIn = _localStorageService.isLoggedIn;

      if (useIsLoggedIn == false) {
        // if (!_localStorageService.hasDisclosedBackgroundPermission) {
        //   FlutterNativeSplash.remove();
        //   //show the alert to user ,then update localstorage
        //   // await _dialogService.showDialog(
        //   //     title: 'Background Location Access',
        //   //     description:
        //   //         'Xstream Gatepass, collects location data to enable tracking your trip delivery/collections and calculate distance travelled even when the app is closed or not in use.This data will be uploaded to xstream-tms.com where you may view and/request your location history.',
        //   //     buttonTitle: "Close",
        //   //     barrierDismissible: true,
        //   //     cancelTitleColor: Colors.black,
        //   //     buttonTitleColor: Colors.blue);

        //   _localStorageService.saveHasDisclosedBackgroundPermission(true);
        // } else {
        //   FlutterNativeSplash.remove();
        // }
        // whenever your initialization is completed, remove the splash screen:
        FlutterNativeSplash.remove();
        _navigationService.clearStackAndShow(Routes.loginView);
      } else {
        if (hasConnection) {
          var canRefresh = await _apiManager.refreshToken();
          if (canRefresh == false) {
            FlutterNativeSplash.remove();
            _navigationService.clearStackAndShow(Routes.loginView);
          }

          await _authenticationService.getUserLoginInfo(true);

          // await Future.delayed(const Duration(milliseconds: 100));
          // whenever your initialization is completed, remove the splash screen:
          FlutterNativeSplash.remove();
          _navigationService.clearStackAndShow(Routes.homeView);
        } else {
          _apiManager.refreshToken();
          _authenticationService.getUserLoginInfo(true);
          // _workerQueManager.enqueForStartUp();
          //  await Future.delayed(const Duration(milliseconds: 200));
          // whenever your initialization is completed, remove the splash screen:
          FlutterNativeSplash.remove();
          _navigationService.clearStackAndShow(Routes.homeView);
        }
      }
    } catch (e) {
      log.e(e);
      FlutterNativeSplash.remove();
      _navigationService.clearStackAndShow(Routes.loginView);
    }
  }
}
