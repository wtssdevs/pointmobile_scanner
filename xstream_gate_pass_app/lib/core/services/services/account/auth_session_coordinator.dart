import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/authentication_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/cms_authentication_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/localization/localization_manager_service.dart';

@LazySingleton()
class AuthSessionCoordinator {
  final log = getLogger('AuthSessionCoordinator');
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final ConnectionService _connectionService = locator<ConnectionService>();
  final _localizationManager = locator<LocalizationManagerService>();
  final _workerQueManager = locator<WorkerQueManager>();
  final EnvironmentService _environmentService = locator<EnvironmentService>();

  Future<void> routeAfterStartup() async {
    final portal = await resolveStartupPortal();
    if (portal == null || !_environmentService.isPortalEnabled(portal)) {
      await routeToLogin(_environmentService.defaultPortal);
      return;
    }

    await _preparePortalSession(portal);
    await routeToPortalHome(portal);
  }

  Future<AuthPortal?> resolveStartupPortal() async {
    final hintedPortal = _localStorageService.getLastSessionPortal() ??
        (_localStorageService.isLoggedInForPortal(AuthPortal.xac)
            ? AuthPortal.xac
            : AuthPortal.cms);
    final fallbackPortal = _otherPortal(hintedPortal);

    if (await _portalHasValidOrRefreshableSession(hintedPortal)) {
      _localStorageService.setLastSessionPortal(hintedPortal);
      return hintedPortal;
    }

    if (await _portalHasValidOrRefreshableSession(fallbackPortal)) {
      _localStorageService.setLastSessionPortal(fallbackPortal);
      return fallbackPortal;
    }

    return null;
  }

  Future<void> switchToPortal(AuthPortal targetPortal) async {
    if (await _portalHasValidOrRefreshableSession(targetPortal)) {
      await _preparePortalSession(targetPortal);
      await routeToPortalHome(targetPortal);
      return;
    }

    _localStorageService.logoutPortal(targetPortal);
    await routeToLogin(targetPortal);
  }

  Future<void> logoutPortal(AuthPortal portal) async {
    _localStorageService.logoutPortal(portal);
    await routeAfterPortalLogout(portal);
  }

  Future<void> logoutAllPortals() async {
    _localStorageService.logoutAllPortals();
    await routeToLogin(_environmentService.defaultPortal);
  }

  Future<void> routeAfterPortalLogout(AuthPortal loggedOutPortal) async {
    final fallbackPortal = _otherPortal(loggedOutPortal);
    if (_environmentService.isPortalEnabled(fallbackPortal) &&
        await _portalHasValidOrRefreshableSession(fallbackPortal)) {
      await _preparePortalSession(fallbackPortal);
      await routeToPortalHome(fallbackPortal);
      return;
    }

    await routeToLogin(_environmentService.defaultPortal);
  }

  Future<void> routeToLogin(AuthPortal initialPortal) async {
    await _navigationService.clearStackAndShow(
      Routes.dualLoginView,
      arguments: DualLoginViewArguments(initialPortal: initialPortal),
    );
  }

  Future<void> routeToPortalHome(AuthPortal portal) async {
    _localStorageService.setLastSessionPortal(portal);
    switch (portal) {
      case AuthPortal.xac:
        await _navigationService.clearStackAndShow(Routes.homeView);
        return;
      case AuthPortal.cms:
        await _navigationService.clearStackAndShow(Routes.cmsHomeView);
        return;
    }
  }

  Future<bool> _portalHasValidOrRefreshableSession(AuthPortal portal) async {
    if (!_localStorageService.isLoggedInForPortal(portal)) {
      return false;
    }

    final token = _localStorageService.getAuthTokenForPortal(portal);
    if (token == null || token.autTokenIsEmpty()) {
      return false;
    }

    if (!_connectionService.hasConnection) {
      return true;
    }

    switch (portal) {
      case AuthPortal.xac:
        return locator<AuthenticationService>().refreshToken();
      case AuthPortal.cms:
        return locator<CmsAuthenticationService>().refreshToken();
    }
  }

  Future<void> _preparePortalSession(AuthPortal portal) async {
    switch (portal) {
      case AuthPortal.xac:
        await _localizationManager.getLocalizeValues();
        await locator<AuthenticationService>().getUserLoginInfo(true);
        _workerQueManager.enqueForStartUp();
        return;
      case AuthPortal.cms:
        await locator<CmsAuthenticationService>().getUserLoginInfo(true);
        return;
    }
  }

  AuthPortal _otherPortal(AuthPortal portal) {
    switch (portal) {
      case AuthPortal.xac:
        return AuthPortal.cms;
      case AuthPortal.cms:
        return AuthPortal.xac;
    }
  }
}