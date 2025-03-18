import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';

import 'package:xstream_gate_pass_app/core/models/account/UserCredential.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/authentication_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/localization/localization_manager_service.dart';

class LoginViewModel extends FormViewModel {
  final log = getLogger('LoginViewModel');
  final AuthenticationService _authenticationService = locator<AuthenticationService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final _localizationManager = locator<LocalizationManagerService>();

  int? get tenantId => _localStorageService.getTenantId;
  bool get hasTenantId => tenantId != null;

  @override
  void setFormStatus() {
    // TODO: implement setFormStatus
  }

  void saveData() {
    log.d("Help error");
  }

  void navigateToCreateAccount() {}
  void validateModel(String? tenancyName, String? userNameOrEmailAddress, String? password) {
    String valiMsg = "";
    if (tenancyName == null || tenancyName == "") {
      valiMsg = "Client code is requried";
    }
    if (userNameOrEmailAddress == null || userNameOrEmailAddress == "") {
      valiMsg = "$valiMsg,Username is requried";
    }
    if (password == null || password == "") {
      valiMsg = "$valiMsg,Password is requried";
    }
    setValidationMessage(valiMsg);
    notifyListeners();
  }

  Future signInRequest({required String tenancyName, required String userNameOrEmailAddress, required String password}) async {
    validateModel(tenancyName, userNameOrEmailAddress, password);
    if (!showValidationMessage) {
      var authResult = await _authenticationService.login(
        userCredential: UserCredential(
          tenancyName: tenancyName,
          userNameOrEmailAddress: userNameOrEmailAddress,
          password: password,
          rememberClient: true,
          tenantId: hasTenantId ? tenantId : null,
        ),
      );

      if (authResult != null) {
        if (authResult.accessToken!.isNotEmpty) {
          await _localizationManager.getLocalizeValues();
          //get more loadin
          await _authenticationService.getUserLoginInfo(true);

          _navigationService.navigateTo(Routes.homeView);
        } else {
          await _dialogService.showDialog(
            title: 'Login Failure',
            description: 'General login failure. Please try again later',
            buttonTitle: "Ok",
            cancelTitleColor: Colors.black,
            buttonTitleColor: Colors.black,
          );
        }
      }
    }
  }

  Future<void> navigateToTermsView() async {
    await _navigationService.navigateTo(Routes.termsAndPrivacyView);
  }

  void clearTenantInfo() {
    _localStorageService.clearTenantId();
    
    rebuildUi();
  }

  Future<void> setTenantCode(String value) async {
    if (value.isNotEmpty && hasTenantId == false) {
      //we need to check tenenat availability
      var tenantAvailableModel = await _authenticationService.isTenantAvailable(tenantCode: value);
      _localStorageService.setTenantId(tenantAvailableModel!.tenantId!);
      rebuildUi();
    }
  }
}
