import 'dart:async';

import 'package:dio/dio.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/models/account/AuthenticateResultModel.dart';
import 'package:xstream_gate_pass_app/core/models/account/UserCredential.dart';
import 'package:xstream_gate_pass_app/core/models/shared/api_response.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/auth_session_coordinator.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';

@InitializableSingleton()
class AccessTokenRepo {
  final log = getLogger('AccessTokenRepo');
  final _environmentService = locator<EnvironmentService>();
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();
  Future<void> init() async {
    log.d('Initialized');
  }

  Completer<AuthenticateResultModel?>? _refreshTokenCompleter;
  Future<AuthenticateResultModel?> getAccessTokenFromStorageOrRefresh() async {
    if (_refreshTokenCompleter != null) {
      return _refreshTokenCompleter!.future;
    }

    final completer = _refreshTokenCompleter = Completer();

    try {
      final token = await _refreshToken();
      completer.complete(token);
      return token;
    } catch (ex, stacktrace) {
      completer.completeError(ex, stacktrace);
      rethrow;
    } finally {
      _refreshTokenCompleter = null;
    }
  }

  void logOutCurrentUser() async {
    _localStorageService.logoutPortal(AuthPortal.xac);
    await locator<AuthSessionCoordinator>().routeAfterPortalLogout(AuthPortal.xac);
  }

  Future<AuthenticateResultModel?> processAuthenticateResult(
      AuthenticateResultModel authenticateResultModel,
      UserCredential userCredential) async {
    if (authenticateResultModel.accessToken!.isNotEmpty) {
      // Successfully logged in

      authenticateResultModel.userNameOrEmailAddress =
          userCredential.userNameOrEmailAddress;
      authenticateResultModel.password = userCredential.password;
      userCredential.tenantId ??= authenticateResultModel.tenantId;
      authenticateResultModel.setUserCredentials(
          tenancyName: userCredential.tenancyName,
          userNameOrEmailAddress: userCredential.userNameOrEmailAddress,
          password: userCredential.password,
          tenantId: userCredential.tenantId);

        _localStorageService.setAuthTokenForPortal(
          AuthPortal.xac, authenticateResultModel);
        _localStorageService.saveIsLoggedInForPortal(AuthPortal.xac, true);
        _localStorageService.setLastSessionPortal(AuthPortal.xac);
      _localStorageService.clearForgotPassword();
    } else {
      logOutCurrentUser();
    }

    return authenticateResultModel;
  }

  Future<AuthenticateResultModel?> _refreshToken() async {
    try {
      // do actual refresh token logic here
      var token = _localStorageService.getAuthTokenForPortal(AuthPortal.xac);
      //get user credentials from storage
      if (token == null ||
          token.accessToken == null ||
          token.autTokenIsEmpty()) {
        logOutCurrentUser();
        return null;
      }

      //check if token has not expired
      if (!tokenHasExpired(token.accessToken)) {
        return token;
      }

      if (token.tenancyName == null ||
          token.userNameOrEmailAddress == null ||
          token.password == null) {
        logOutCurrentUser();
        return null;
      }

      var userCredential = UserCredential(
        tenancyName: token.tenancyName!,
        userNameOrEmailAddress: token.userNameOrEmailAddress!,
        password: token.password!,
        rememberClient: true,
        tenantId: token.tenantId,
      );

      final options = BaseOptions(
        baseUrl: _environmentService.getBaseUrl(AuthPortal.xac),
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      );

      var dioClient = Dio(options);

      //TODO add error handler here

      var response = await dioClient.post(AppConst.authentication,
          data: userCredential.toJson());

      var apiResponse = ApiResponse.fromJson(response.data);

      if (apiResponse.success != null && apiResponse.success == true) {
        var authenticateResultModel =
            AuthenticateResultModel.fromJson(apiResponse.result);

        return await processAuthenticateResult(
            authenticateResultModel, userCredential);
      } else {
        logOutCurrentUser();
      }

      return null;
    } catch (e) {
      log.i(e);
      logOutCurrentUser();
      return null;
    }
  }
}
