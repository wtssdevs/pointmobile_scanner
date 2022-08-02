import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app_config/app.locator.dart';
import 'package:xstream_gate_pass_app/app_config/app.logger.dart';
import 'package:xstream_gate_pass_app/app_config/app.router.dart';
import 'package:xstream_gate_pass_app/core/models/account/UserCredential.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/authentication_service.dart';

class LoginViewModel extends FormViewModel {
  final log = getLogger('LoginViewModel');
  final AuthenticationService _authenticationService = locator<AuthenticationService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final DialogService _dialogService = locator<DialogService>();

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
        userCredential:
            UserCredential(tenancyName: tenancyName, userNameOrEmailAddress: userNameOrEmailAddress, password: password, rememberClient: true),
      );

      if (authResult != null) {
        if (authResult.accessToken!.isNotEmpty) {
          //get more loadin
          await _authenticationService.getUserLoginInfo(true);

          _navigationService.navigateTo(Routes.homeView);
        } else {
          await _dialogService.showDialog(
              title: 'Login Failure',
              description: 'General login failure. Please try again later',
              buttonTitle: "Ok",
              cancelTitleColor: Colors.black,
              buttonTitleColor: Colors.black);
        }
      }
    }
  }

  Future<void> navigateToTermsView() async {
    await _navigationService.navigateTo(Routes.termsAndPrivacyView);
  }
}
