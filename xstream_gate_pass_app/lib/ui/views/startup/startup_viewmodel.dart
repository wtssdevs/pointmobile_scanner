import 'package:stacked/stacked.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';

import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/auth_session_coordinator.dart';
import 'package:xstream_gate_pass_app/core/services/services/filestore/filestore_isolate_initializer.dart';
import 'package:xstream_gate_pass_app/ui/views/shared/localization/app_view_base_helper.dart';

class StartUpViewModel extends BaseViewModel with AppViewBaseHelper {
  final log = getLogger('StartUpViewModel');
  final _authSessionCoordinator = locator<AuthSessionCoordinator>();
// Initialize FileStore isolate
  final _fileStoreIsolateInitializer = locator<FileStoreIsolateInitializer>();

  Future<void> runBaseStartup() async {
    // Initialize FileStore isolate for background uploads
    try {
      await _fileStoreIsolateInitializer.initializeFileStoreIsolate();
    } catch (e) {
      log.e('FileStore isolate initialization warning: $e');
      // App continues normally with fallback uploads
    }
  }

  Future<void> runStartupLogic() async {
    //FlutterNativeSplash.remove();
    //_navigationService.clearStackAndShow(Routes.gateAccessPreBookingFindView);

    try {
      await _authSessionCoordinator.routeAfterStartup();
    } catch (e) {
      log.e(e);
      // await FlutterLogs.logError(
      //   "StartUpViewModel",
      //   "runStartupLogic",
      //   e.toString(),
      // );

      FlutterNativeSplash.remove();
  await _authSessionCoordinator.routeToLogin(AuthPortal.xac);
    } finally {
      FlutterNativeSplash.remove();
      await runBaseStartup();
    }
  }
}
