import 'dart:async';

import 'package:dio/dio.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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
class CmsAccessTokenRepo {
  final log = getLogger('CmsAccessTokenRepo');
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
    _localStorageService.logoutPortal(AuthPortal.cms);
    await locator<AuthSessionCoordinator>().routeAfterPortalLogout(AuthPortal.cms);
  }

  Future<AuthenticateResultModel?> processAuthenticateResult(
      AuthenticateResultModel authenticateResultModel,
      UserCredential userCredential) async {
    if (authenticateResultModel.accessToken != null &&
        authenticateResultModel.accessToken!.isNotEmpty) {
      authenticateResultModel.userNameOrEmailAddress =
          userCredential.userNameOrEmailAddress;
      authenticateResultModel.password = userCredential.password;
      authenticateResultModel.tenancyName = userCredential.tenancyName;
      userCredential.tenantId ??= authenticateResultModel.tenantId;
      authenticateResultModel.setUserCredentials(
          tenancyName: userCredential.tenancyName,
          userNameOrEmailAddress: userCredential.userNameOrEmailAddress,
          password: userCredential.password,
          tenantId: userCredential.tenantId ?? authenticateResultModel.tenantId);

      _localStorageService.setAuthTokenForPortal(
          AuthPortal.cms, authenticateResultModel);
      _localStorageService.saveIsLoggedInForPortal(AuthPortal.cms, true);
      _localStorageService.setLastSessionPortal(AuthPortal.cms);
    } else {
      logOutCurrentUser();
    }

    return authenticateResultModel;
  }

  AuthenticateResultModel buildAuthenticateResultModel(
      dynamic result, UserCredential userCredential) {
    AuthenticateResultModel authenticateResultModel;

    if (result is String) {
      authenticateResultModel = AuthenticateResultModel(accessToken: result);
    } else if (result is Map<String, dynamic>) {
      authenticateResultModel = AuthenticateResultModel.fromJson(result);
    } else {
      authenticateResultModel = AuthenticateResultModel();
    }

    authenticateResultModel.tenantId ??=
        userCredential.tenantId ?? _readTenantIdFromToken(authenticateResultModel.accessToken);
    authenticateResultModel.userId ??=
        _readUserIdFromToken(authenticateResultModel.accessToken);

    return authenticateResultModel;
  }

  Future<AuthenticateResultModel?> _refreshToken() async {
    try {
      var token = _localStorageService.getAuthTokenForPortal(AuthPortal.cms);
      if (token == null ||
          token.accessToken == null ||
          token.autTokenIsEmpty()) {
        logOutCurrentUser();
        return null;
      }

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
        baseUrl: _environmentService.getBaseUrl(AuthPortal.cms),
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      );

      var dioClient = Dio(options);

      var response = await dioClient.post(AppConst.authentication,
          data: userCredential.toJson());

      var apiResponse = ApiResponse.fromJson(response.data);

      if (apiResponse.success != null && apiResponse.success == true) {
        var authenticateResultModel =
            buildAuthenticateResultModel(apiResponse.result, userCredential);

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

  int? _readTenantIdFromToken(String? accessToken) {
    return _readIntClaim(accessToken, [
      'tenantId',
      'TenantId',
      'http://www.aspnetboilerplate.com/identity/claims/tenantId',
    ]);
  }

  int? _readUserIdFromToken(String? accessToken) {
    return _readIntClaim(accessToken, [
      'userId',
      'UserId',
      'sub',
      'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
    ]);
  }

  int? _readIntClaim(String? accessToken, List<String> keys) {
    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    try {
      final claims = JwtDecoder.decode(accessToken);
      for (final key in keys) {
        final value = claims[key];
        if (value is int) {
          return value;
        }
        if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed != null) {
            return parsed;
          }
        }
      }
    } catch (e) {
      log.i(e);
    }

    return null;
  }
}