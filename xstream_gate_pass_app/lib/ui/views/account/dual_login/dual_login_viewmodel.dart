import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/models/account/UserCredential.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/auth_session_coordinator.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/authentication_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/cms_authentication_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/localization/localization_manager_service.dart';

class DualLoginViewModel extends BaseViewModel {
  DualLoginViewModel({this.initialPortal = AuthPortal.xac}) {
    _selectedIndex = initialPortal == AuthPortal.cms ? 1 : 0;
    pageController = PageController(initialPage: _selectedIndex);
  }

  static const tenantCodeField = 'tenantCode';
  static const usernameField = 'username';
  static const passwordField = 'password';
  static const formField = 'form';

  final log = getLogger('DualLoginViewModel');
  final AuthPortal initialPortal;
  final AuthenticationService _authenticationService =
      locator<AuthenticationService>();
  final CmsAuthenticationService _cmsAuthenticationService =
      locator<CmsAuthenticationService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();
  final _localizationManager = locator<LocalizationManagerService>();
  final _workerQueManager = locator<WorkerQueManager>();
  final _authSessionCoordinator = locator<AuthSessionCoordinator>();

  late final PageController pageController;

  final xacTenantCodeController = TextEditingController();
  final xacUsernameController = TextEditingController();
  final xacPasswordController = TextEditingController();
  final cmsTenantCodeController = TextEditingController();
  final cmsUsernameController = TextEditingController();
  final cmsPasswordController = TextEditingController();

  final xacTenantFocusNode = FocusNode();
  final xacUsernameFocusNode = FocusNode();
  final xacPasswordFocusNode = FocusNode();
  final cmsTenantFocusNode = FocusNode();
  final cmsUsernameFocusNode = FocusNode();
  final cmsPasswordFocusNode = FocusNode();

  final Map<AuthPortal, Map<String, String>> _validationErrors = {
    AuthPortal.xac: {},
    AuthPortal.cms: {},
  };

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;
  AuthPortal get selectedPortal =>
      _selectedIndex == 0 ? AuthPortal.xac : AuthPortal.cms;

  bool _xacBusy = false;
  bool _cmsBusy = false;
  bool isBusyForPortal(AuthPortal portal) =>
      portal == AuthPortal.xac ? _xacBusy : _cmsBusy;

  void initialise() {
    xacTenantCodeController.text =
        _localStorageService.getTenantCodeForPortal(AuthPortal.xac);
    cmsTenantCodeController.text =
        _localStorageService.getTenantCodeForPortal(AuthPortal.cms);
  }

  Future<void> selectPortal(AuthPortal portal) async {
    _unfocusAllFields();
    final index = portal == AuthPortal.xac ? 0 : 1;
    if (pageController.hasClients) {
      await pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
    _setSelectedIndex(index);
  }

  void onPageChanged(int index) {
    _unfocusAllFields();
    _setSelectedIndex(index);
  }

  String? validationFor(AuthPortal portal, String key) {
    return _validationErrors[portal]?[key];
  }

  Future<void> signIn(AuthPortal portal) async {
    if (!_validatePortal(portal)) {
      return;
    }

    _setBusyForPortal(portal, true);
    try {
      switch (portal) {
        case AuthPortal.xac:
          await _signInXac();
          return;
        case AuthPortal.cms:
          await _signInCms();
          return;
      }
    } catch (e) {
      log.e(e);
      _setPortalError(
          portal, formField, 'Login failed. Please check your details.');
    } finally {
      _setBusyForPortal(portal, false);
    }
  }

  Future<void> navigateToTermsView() async {
    await _navigationService.navigateTo(Routes.termsAndPrivacyView);
  }

  Future<void> _signInXac() async {
    final tenancyName = xacTenantCodeController.text.trim();
    final userNameOrEmailAddress = xacUsernameController.text.trim();
    final password = xacPasswordController.text;

    final tenantAvailableModel =
        await _authenticationService.isTenantAvailable(tenantCode: tenancyName);
    if (tenantAvailableModel == null) {
      _setPortalError(AuthPortal.xac, formField,
          'Client code could not be verified.');
      return;
    }

    final authResult = await _authenticationService.login(
      userCredential: UserCredential(
        tenancyName: tenancyName,
        userNameOrEmailAddress: userNameOrEmailAddress,
        password: password,
        rememberClient: true,
        tenantId: tenantAvailableModel.tenantId,
      ),
    );

    if (authResult != null &&
        authResult.accessToken != null &&
        authResult.accessToken!.isNotEmpty) {
      await _localizationManager.getLocalizeValues();
      await _authenticationService.getUserLoginInfo(true);
      _workerQueManager.enqueForStartUp();
      _localStorageService.setTenantCodeForPortal(
          AuthPortal.xac, tenancyName);
      await _authSessionCoordinator.routeToPortalHome(AuthPortal.xac);
      return;
    }

    _setPortalError(AuthPortal.xac, formField,
        'General login failure. Please try again later.');
  }

  Future<void> _signInCms() async {
    final tenancyName = cmsTenantCodeController.text.trim();
    final userNameOrEmailAddress = cmsUsernameController.text.trim();
    final password = cmsPasswordController.text;

    final authResult = await _cmsAuthenticationService.login(
      userCredential: UserCredential(
        tenancyName: tenancyName,
        userNameOrEmailAddress: userNameOrEmailAddress,
        password: password,
        rememberClient: true,
      ),
    );

    if (authResult != null &&
        authResult.accessToken != null &&
        authResult.accessToken!.isNotEmpty) {
      await _cmsAuthenticationService.getUserLoginInfo(true);
      _localStorageService.setTenantCodeForPortal(
          AuthPortal.cms, tenancyName);
      await _authSessionCoordinator.routeToPortalHome(AuthPortal.cms);
      return;
    }

    _setPortalError(AuthPortal.cms, formField,
        'CMS login failed. Please check tenant, username, and password.');
  }

  bool _validatePortal(AuthPortal portal) {
    final errors = <String, String>{};
    final tenantCode = portal == AuthPortal.xac
        ? xacTenantCodeController.text.trim()
        : cmsTenantCodeController.text.trim();
    final username = portal == AuthPortal.xac
        ? xacUsernameController.text.trim()
        : cmsUsernameController.text.trim();
    final password = portal == AuthPortal.xac
        ? xacPasswordController.text
        : cmsPasswordController.text;

    if (tenantCode.isEmpty) {
      errors[tenantCodeField] = 'Client code is required!';
    }
    if (username.isEmpty) {
      errors[usernameField] = 'Username is required!';
    }
    if (password.isEmpty) {
      errors[passwordField] = 'Password is required!';
    }

    _validationErrors[portal] = errors;
    rebuildUi();
    return errors.isEmpty;
  }

  void _setSelectedIndex(int index) {
    if (_selectedIndex == index) {
      return;
    }
    _selectedIndex = index;
    rebuildUi();
  }

  void _setBusyForPortal(AuthPortal portal, bool value) {
    if (portal == AuthPortal.xac) {
      _xacBusy = value;
    } else {
      _cmsBusy = value;
    }
    rebuildUi();
  }

  void _setPortalError(AuthPortal portal, String key, String message) {
    _validationErrors[portal] = {
      ...?_validationErrors[portal],
      key: message,
    };
    rebuildUi();
  }

  void _unfocusAllFields() {
    xacTenantFocusNode.unfocus();
    xacUsernameFocusNode.unfocus();
    xacPasswordFocusNode.unfocus();
    cmsTenantFocusNode.unfocus();
    cmsUsernameFocusNode.unfocus();
    cmsPasswordFocusNode.unfocus();
  }

  void disposeControllers() {
    pageController.dispose();
    xacTenantCodeController.dispose();
    xacUsernameController.dispose();
    xacPasswordController.dispose();
    cmsTenantCodeController.dispose();
    cmsUsernameController.dispose();
    cmsPasswordController.dispose();
    xacTenantFocusNode.dispose();
    xacUsernameFocusNode.dispose();
    xacPasswordFocusNode.dispose();
    cmsTenantFocusNode.dispose();
    cmsUsernameFocusNode.dispose();
    cmsPasswordFocusNode.dispose();
  }
}