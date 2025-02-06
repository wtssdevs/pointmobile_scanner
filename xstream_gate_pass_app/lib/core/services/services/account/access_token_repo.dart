import 'dart:async';

import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/models/account/AuthenticateResultModel.dart';
import 'package:xstream_gate_pass_app/core/models/account/UserCredential.dart';
import 'package:xstream_gate_pass_app/core/models/shared/api_response.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';

@InitializableSingleton()
class AccessTokenRepo {
  final log = getLogger('AccessTokenRepo');
  final _environmentService = locator<EnvironmentService>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final NavigationService _navigationService = locator<NavigationService>();
  Future<void> init() async {
    log.d('Initialized');
  }

  Completer<String>? _refreshTokenCompleter;
  Future<AuthenticateResultModel?> getAccessTokenFromStorageOrRefresh() async {
    return await _refreshToken();

    // if (_refreshTokenCompleter != null) {
    //   return _refreshTokenCompleter!.future;
    // }

    // final completer = _refreshTokenCompleter = Completer();

    // try {
    //   final token = await _refreshToken();
    //   completer.complete(token ?? "");
    //   return token;
    // } catch (ex, stacktrace) {
    //   completer.completeError(ex, stacktrace);
    //   rethrow;
    // }
  }

  void logOutCurrentUser() {
    _localStorageService.logout();
    _navigationService.clearStackAndShow(Routes.loginView);
  }

  Future<AuthenticateResultModel?> processAuthenticateResult(AuthenticateResultModel authenticateResultModel, UserCredential userCredential) async {
    if (authenticateResultModel.accessToken!.isNotEmpty) {
      // Successfully logged in

      authenticateResultModel.userNameOrEmailAddress = userCredential.userNameOrEmailAddress;
      authenticateResultModel.password = userCredential.password;
      authenticateResultModel.setUserCredentials(tenancyName: userCredential.tenancyName ?? "", userNameOrEmailAddress: userCredential.userNameOrEmailAddress, password: userCredential.password, tenantId: userCredential.tenantId);

      _localStorageService.setAuthToken(authenticateResultModel);
      _localStorageService.saveIsLoggedIn(true);
      _localStorageService.clearForgotPassword();
    } else {
      logOutCurrentUser();
    }

    return authenticateResultModel;
  }

  Future<AuthenticateResultModel?> _refreshToken() async {
    try {
      // do actual refresh token logic here
      var token = _localStorageService.getAuthToken;
      //get user credentials from storage
      if (token == null || token.autTokenIsEmpty()) {
        logOutCurrentUser();
      }

      //check if token has not expired
      if (!tokenHasExpired(token!.accessToken)) {
        return token;
      }

      var userCredential = UserCredential(
        tenancyName: token.tenancyName!,
        userNameOrEmailAddress: token.userNameOrEmailAddress!,
        password: token.password!,
        rememberClient: true,
        tenantId: token.tenantId,
      );

      final options = BaseOptions(
        baseUrl: _environmentService.getValue(AppConst.API_Base_Url),
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      );

      var dioClient = Dio(options);

      //TODO add error handler here

      var response = await dioClient.post(AppConst.authentication, data: userCredential.toJson());

      var apiResponse = ApiResponse.fromJson(response.data);

      if (apiResponse.success != null && apiResponse.success == true) {
        var authenticateResultModel = AuthenticateResultModel.fromJson(apiResponse.result);

        return await processAuthenticateResult(authenticateResultModel, userCredential);
      } else {
        logOutCurrentUser();
      }

      return null;
    } catch (e) {
      log.i(e);
      logOutCurrentUser();
      rethrow;
    }
  }
}
