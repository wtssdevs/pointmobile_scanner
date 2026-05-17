import 'dart:io';

import 'package:dio/dio.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/access_token_repo.dart';

class AuthInterceptor extends InterceptorsWrapper {
  final log = getLogger('AuthInterceptor');
  final AccessTokenRepo _accessTokenRepo = locator<AccessTokenRepo>();

  @override
  // ignore: avoid_void_async
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    //On Unauthorized, the AccessToken or RefreshToken may be outdated
    if (err.response?.statusCode == HttpStatus.unauthorized) {
      log.i('AuthInterceptor - Error 401');
      final accessToken =
          await _accessTokenRepo.getAccessTokenFromStorageOrRefresh();

      //Happens on first request if badly handled
      //Or if the user cleaned his local storage at Runtime
      if (accessToken == null || accessToken.accessToken == null) {
        log.i('AuthInterceptor - No Local AccessToken');
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // //Getting cached Access Token, or getting it from storage and caching it

    final requiresAuth = options.extra[AppConst.requiresAuthExtraKey] != false &&
        options.headers['requires-token'] != 'false';

    options.headers.remove('requires-token');
    options.headers.remove('requiresToken');
    options.headers["Accept"] = "application/json";

    if (!requiresAuth) {
      return handler.next(options);
    }

    var token = await _accessTokenRepo.getAccessTokenFromStorageOrRefresh();

    var authHeader = options.headers["authorization"];
    if (authHeader == null && token != null && token.accessToken != null) {
      options.headers["authorization"] = "Bearer ${token.accessToken}";
      if (token.tenantId != null) {
        options.headers["Abp-TenantId"] = token.tenantId;
      }
    }
    return handler.next(options);
  }
}
