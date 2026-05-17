import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.dialogs.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/enums/basic_dialog_status.dart';
import 'package:xstream_gate_pass_app/core/models/account/GetCurrentLoginInformation.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/auth_session_coordinator.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/cms_authentication_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

class CmsHomeViewModel extends BaseViewModel {
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();
  final CmsAuthenticationService _cmsAuthenticationService =
      locator<CmsAuthenticationService>();
  final AuthSessionCoordinator _authSessionCoordinator =
      locator<AuthSessionCoordinator>();
  final DialogService _dialogService = locator<DialogService>();
  final EnvironmentService _environmentService = locator<EnvironmentService>();

  CurrentLoginInformation? _currentLoginInformation;
  CurrentLoginInformation? get currentLoginInformation =>
      _currentLoginInformation;

  String baseUrl = '';

  String get tenantDisplay =>
      _currentLoginInformation?.tenant.tenancyName ?? 'CMS tenant';

  String get userDisplay =>
      _currentLoginInformation?.user.showFullName ?? 'CMS user';

  bool get isCmsLoggedIn =>
      _localStorageService.isLoggedInForPortal(AuthPortal.cms);

  Future<void> handleStartUpLogic() async {
    baseUrl = _environmentService.getHostName(AuthPortal.cms);
    _currentLoginInformation =
        _localStorageService.getUserLoginInfoForPortal(AuthPortal.cms);

    _currentLoginInformation ??=
      await _cmsAuthenticationService.getUserLoginInfo(true);

    rebuildUi();
  }

  Future<void> switchToXac() async {
    await _authSessionCoordinator.switchToPortal(AuthPortal.xac);
  }

  Future<void> logoutCms() async {
    final confirmed = await _confirmLogout();
    if (confirmed) {
      await _authSessionCoordinator.logoutPortal(AuthPortal.cms);
    }
  }

  Future<bool> _confirmLogout() async {
    var confirm = await _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        data: BasicDialogStatus.warning,
        title: 'Confirm CMS Logout.',
        description: 'Are you sure you want to logout of CMS?',
        mainButtonTitle: 'Accept',
        secondaryButtonTitle: 'Decline');

    if (confirm != null) {
      return confirm.confirmed;
    }

    return false;
  }
}