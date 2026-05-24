import 'dart:async';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/models/account/GetCurrentLoginInformation.dart';
import 'package:xstream_gate_pass_app/core/models/cms/account/cms_current_login_information.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/cms_authentication_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_sync_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

class CmsHomeViewModel extends BaseViewModel {
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final CmsAuthenticationService _cmsAuthenticationService = locator<CmsAuthenticationService>();
  final CmsSessionService _cmsSessionService = locator<CmsSessionService>();
  final CmsMasterFilesSyncService _cmsMasterFilesSyncService = locator<CmsMasterFilesSyncService>();
  final NavigationService _navigationService = locator<NavigationService>();

  CurrentLoginInformation? _currentLoginInformation;
  CurrentLoginInformation? get currentLoginInformation => _currentLoginInformation;
  CmsCurrentLoginInformation? _cmsCurrentLoginInformation;
  CmsCurrentLoginInformation? get cmsCurrentLoginInformation => _cmsCurrentLoginInformation;

  bool _hasInitialised = false;

  String get tenantDisplay => _cmsCurrentLoginInformation?.tenant?.tenancyName ?? _currentLoginInformation?.tenant.tenancyName ?? 'CMS tenant';

  String get userDisplay => _cmsCurrentLoginInformation?.user?.fullName ?? _currentLoginInformation?.user.showFullName ?? 'CMS user';

  bool get isCmsLoggedIn => _localStorageService.isLoggedInForPortal(AuthPortal.cms);

  Future<void> handleStartUpLogic() async {
    if (_hasInitialised) {
      return;
    }
    _hasInitialised = true;
    _cmsCurrentLoginInformation = _cmsSessionService.getCached();
    _currentLoginInformation =
        _cmsCurrentLoginInformation?.toLegacyCurrentLoginInformation() ?? _localStorageService.getUserLoginInfoForPortal(AuthPortal.cms);

    _currentLoginInformation ??= await _cmsAuthenticationService.getUserLoginInfo(true);

    _cmsCurrentLoginInformation ??= await _cmsSessionService.refreshFromServer(showLoader: false);
    _currentLoginInformation ??= _cmsCurrentLoginInformation?.toLegacyCurrentLoginInformation();

    rebuildUi();

    if (await _cmsMasterFilesSyncService.shouldRunInitialSync()) {
      unawaited(_cmsMasterFilesSyncService.syncAll(force: false, reason: 'initial-login'));
    }
  }

  Future<void> openSettings() async {
    await _navigationService.navigateToCmsSettingsView();
  }

  Future<void> openContainerInspections() async {
    await _navigationService.navigateToCmsContainerInspectionsListView();
  }

  Future<void> openContainerSurveys() async {
    await _navigationService.navigateToCmsSurveysListView();
  }
}
