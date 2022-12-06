import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app_config/app.locator.dart';
import 'package:xstream_gate_pass_app/app_config/app.logger.dart';
import 'package:xstream_gate_pass_app/core/models/account/AuthenticateResultModel.dart';
import 'package:xstream_gate_pass_app/core/models/account/ForgotPassword.dart';
import 'package:xstream_gate_pass_app/core/models/account/GetCurrentLoginInformation.dart';
import 'package:xstream_gate_pass_app/core/models/account/RegisterUser.dart';
import 'package:xstream_gate_pass_app/core/models/account/ResetForgotPassword.dart';
import 'package:xstream_gate_pass_app/core/models/account/UserCredential.dart';
import 'package:xstream_gate_pass_app/core/models/shared/api_response.dart';
import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

@LazySingleton()
class AuthenticationService {
  final log = getLogger('AuthenticationService');
  UserCredential? _currentUser;
  UserCredential? get currentUser => _currentUser;
  final ApiManager? _apiManager = locator<ApiManager>();
  final LocalStorageService? _localStorageService = locator<LocalStorageService>();
  final _workerQueManager = locator<WorkerQueManager>();


  //**********LOGIN ********************************** */
  Future<AuthenticateResultModel?> login({
    required UserCredential userCredential,
  }) async {
    var authResult = await _apiManager!.get("/api/Account/ExternalAuth", queryParameters: userCredential.toJson(), showLoader: true);

    var authenticateResultModel = AuthenticateResultModel.fromJson(authResult);

    await processAuthenticateResult(authenticateResultModel, userCredential);
    return authenticateResultModel;
  }

  Future processAuthenticateResult(AuthenticateResultModel authenticateResultModel, UserCredential userCredential) async {
    if (authenticateResultModel.accessToken!.isNotEmpty) {
      // Successfully logged in
      authenticateResultModel.tenancyName = userCredential.tenancyName;
      authenticateResultModel.userNameOrEmailAddress = userCredential.userNameOrEmailAddress;
      authenticateResultModel.password = userCredential.password;

      authenticateResultModel.setUserCredentials(
          tenancyName: userCredential.tenancyName, userNameOrEmailAddress: userCredential.userNameOrEmailAddress, password: userCredential.password);

      _localStorageService!.setAuthToken(authenticateResultModel);
      _localStorageService!.saveIsLoggedIn(true);
      _localStorageService!.clearForgotPassword();

      //remove await here to allow background...run and move on to screen...
      //_baseFilesService.getAndsyncServerWithLocalBaseFiles();
      await _workerQueManager.enqueForStartUp();
    } else {
      // Unexpected result!

    }
  }

//**********Register ********************************** */

  ///Returns a bool indicating the users account was created sucesfully and should route user to home view flow.
  Future<bool?> register({
    required RegisterUser registerUser,
  }) async {
    try {
      var authResult = await _apiManager!.post("/api/services/app/session/getCurrentLoginInformations", data: registerUser.toJson());
      var apiResponse = ApiResponse.fromJson(authResult);
      return apiResponse.success;
    } catch (e) {
      return null;
    }
  }

  //**********Forgot Password ********************************** */

  Future<ForgotPassword?> forgotPassword({required String userNameOrEmailAddress}) async {
    try {
      var forgotPassword = ForgotPassword(emailAddress: userNameOrEmailAddress, userId: 0);
      var authResult = await _apiManager!.post("/api/services/app/User/ForgotPassword", data: forgotPassword.toJson());
      var apiResponse = ApiResponse.fromJson(authResult);

      if (apiResponse.success!) {
        var forgotPasswordReponse = ForgotPassword.fromJson(apiResponse.result);
        _localStorageService!.setForgotPassword(forgotPasswordReponse);

        return forgotPasswordReponse;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool?> resetForgotPassword({required ResetForgotPassword resetForgotPassword}) async {
    try {
      var authResult = await _apiManager!.post("/api/services/app/User/ResetForgotPassword", data: resetForgotPassword.toJson());
      var apiResponse = ApiResponse.fromJson(authResult);
      _localStorageService!.clearForgotPassword();
      return apiResponse.success;
    } catch (e) {
      return null;
    }
  }

  Future<CurrentLoginInformation?> getUserLoginInfo([bool forceUpdate = false]) async {
    try {
      if (forceUpdate == false) {
        var localprofile = _localStorageService!.getUserLoginInfo;
        if (localprofile != null) {
          return localprofile;
        }
      }

      var authResult = await _apiManager!.post("/api/services/app/Session/GetCurrentLoginInformations", showLoader: false);
      var apiResponse = ApiResponse.fromJson(authResult);
      if (apiResponse.success!) {
        var userLoginInfo = CurrentLoginInformation.fromJson(apiResponse.result);
        _localStorageService!.setUserLoginInfo(userLoginInfo);
        return userLoginInfo;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void setUserInfo() {
    var localprofile = _localStorageService!.getUserLoginInfo;
    if (localprofile != null) {
      _localStorageService!.setUserLoginInfo(localprofile);
    }
  }

  BaseResponse isPasswordCompliant(String password, String username, [int minLength = 6]) {
    var outPut = BaseResponse();
    outPut.messages = [];
    outPut.success = true;
    if (password.isEmpty) {
      outPut.success = false;
      outPut.messages!.add("Password is required!");
      return outPut;
    }
    if (username.isNotEmpty) {
      bool hasUsername = password.contains(username);
      if (hasUsername) {
        outPut.success = false;
        outPut.messages!.add("Password should not contain your email.");
      }
    }

    bool hasUppercase = password.contains(new RegExp(r'[A-Z]'));
    if (!hasUppercase) {
      outPut.success = false;
      outPut.messages!.add("One uppercase character is required!.");
    }
    bool hasDigits = password.contains(new RegExp(r'[0-9]'));
    if (!hasDigits) {
      outPut.success = false;
      outPut.messages!.add("One number is required!.");
    }

    bool hasLowercase = password.contains(new RegExp(r'[a-z]'));
    if (!hasLowercase) {
      outPut.success = false;
      outPut.messages!.add("One lowercase character is required!.");
    }
    bool hasSpecialCharacters = password.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    if (!hasSpecialCharacters) {
      outPut.success = false;
      outPut.messages!.add("One special character is required!.");
    }
    bool hasMinLength = password.length > minLength;
    if (!hasMinLength) {
      outPut.success = false;
      outPut.messages!.add("Minimum Password lenght is $minLength");
    }

    //return !hasUsername && hasDigits && hasUppercase && hasLowercase && hasSpecialCharacters && hasMinLength;

    return outPut;
  }
}
