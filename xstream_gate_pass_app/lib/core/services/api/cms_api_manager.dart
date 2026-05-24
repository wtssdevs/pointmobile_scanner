import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/services/api/abp_error_handler.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/cms_access_token_repo.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';
import 'package:dio/dio.dart' as dio_client;
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

@InitializableSingleton()
class CmsApiManager {
  final DialogService _dialogService = locator<DialogService>();
  final _environmentService = locator<EnvironmentService>();
  final CmsAccessTokenRepo _accessTokenRepo = locator<CmsAccessTokenRepo>();
  final log = getLogger('CmsApiManager');

  late Dio _dio;

  Future<void> init() async {
    final baseUrl = _environmentService.getBaseUrl(AuthPortal.cms);
    final options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: kDebugMode ? 800 : 60),
      receiveTimeout: const Duration(seconds: kDebugMode ? 800 : 60),
    );
    _dio = dio_client.Dio()..options = options;

    _configureHttpClientAdapter(_dio, baseUrl);

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        logPrint: log.d,
        maxWidth: 10060,
        enabled: false,
        request: true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == HttpStatus.forbidden || error.response?.statusCode == HttpStatus.unauthorized) {
            log.i('CMS AuthInterceptor - Error 401');
            final accessToken = await _accessTokenRepo.getAccessTokenFromStorageOrRefresh();

            if (accessToken == null || accessToken.accessToken == null) {
              log.i('CMS AuthInterceptor - No Local AccessToken');
              _accessTokenRepo.logOutCurrentUser();
              return handler.reject(error);
            }

            final options = error.requestOptions;
            final data = options.data;
            final newOptions = options.copyWith(
              data: data is FormData ? data.clone() : data,
            );

            newOptions.headers["authorization"] = "Bearer ${accessToken.accessToken}";
            if (accessToken.tenantId != null) {
              newOptions.headers["Abp-TenantId"] = accessToken.tenantId;
            }

            try {
              final response = await retryInternal(newOptions);

              return handler.resolve(response);
            } on DioException catch (e) {
              handelError(e);
              return handler.next(e);
            }
          }
          handelError(error);
          return handler.next(error);
        },
        onRequest: (
          RequestOptions options,
          RequestInterceptorHandler handler,
        ) async {
          final requiresAuth = options.extra[AppConst.requiresAuthExtraKey] != false && options.headers['requires-token'] != 'false';

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
        },
      ),
    );

    log.d('Initialized');
  }

  handelError(DioException dioError) {
    AbpErrorHandler.handle(
      dioError: dioError,
      dialogService: _dialogService,
      logError: log.e,
      onExternalAuthInvalid: _accessTokenRepo.logOutCurrentUser,
    );
  }

  void _configureHttpClientAdapter(Dio client, String baseUrl) {
    final scheme = Uri.tryParse(baseUrl)?.scheme.toLowerCase();
    if (scheme == 'https') {
      client.httpClientAdapter = Http2Adapter(
        ConnectionManager(
          idleTimeout: const Duration(seconds: 15),
          onClientCreate: (_, config) => config.onBadCertificate = (_) => true,
        ),
      );
      return;
    }

    log.i('CMS using default Dio adapter for base URL: $baseUrl');
  }

  Future<Response<dynamic>> retryInternal(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    final baseUrl = _environmentService.getBaseUrl(AuthPortal.cms);
    final baseOptions = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: kDebugMode ? 800 : 60),
      receiveTimeout: const Duration(seconds: kDebugMode ? 800 : 60),
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    var dioRetryClient = Dio()..options = baseOptions;

    _configureHttpClientAdapter(dioRetryClient, baseUrl);

    return dioRetryClient.request<dynamic>(requestOptions.path,
        data: requestOptions.data, queryParameters: requestOptions.queryParameters, options: options);
  }

  Future<dynamic> get(String uri,
      {Map<String, dynamic>? queryParameters,
      dio_client.Options? options,
      dio_client.CancelToken? cancelToken,
      dio_client.ProgressCallback? onReceiveProgress,
      bool showLoader = false}) async {
    try {
      if (showLoader) {
        EasyLoading.show();
      }

      final dio_client.Response response = await _dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      EasyLoading.dismiss();
      return response.data;
    } catch (e) {
      log.d(e.toString());
      EasyLoading.dismiss();
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<List<int>> getBytes(String uri,
      {Map<String, dynamic>? queryParameters,
      dio_client.Options? options,
      dio_client.CancelToken? cancelToken,
      dio_client.ProgressCallback? onReceiveProgress,
      bool showLoader = false}) async {
    try {
      if (showLoader) {
        EasyLoading.show();
      }

      final requestOptions = (options ?? dio_client.Options()).copyWith(
        responseType: ResponseType.bytes,
      );
      final dio_client.Response<List<int>> response = await _dio.get<List<int>>(
        uri,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      EasyLoading.dismiss();
      return response.data ?? const <int>[];
    } catch (e) {
      log.d(e.toString());
      EasyLoading.dismiss();
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<dynamic> post(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    dio_client.Options? options,
    dio_client.CancelToken? cancelToken,
    dio_client.ProgressCallback? onSendProgress,
    dio_client.ProgressCallback? onReceiveProgress,
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        EasyLoading.show();
      }
      log.d(
          "POST Request - URI: ${_dio.options.baseUrl}$uri, Data: $data, QueryParameters: $queryParameters, Options: ${options?.toString()}, CancelToken: ${cancelToken?.toString()}");
      final dio_client.Response response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      EasyLoading.dismiss();
      return response.data;
    } catch (e) {
      EasyLoading.dismiss();
      //log.d(e.toString());
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<dynamic> delete(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    dio_client.Options? options,
    dio_client.CancelToken? cancelToken,
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        EasyLoading.show();
      }

      final dio_client.Response response = await _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      EasyLoading.dismiss();
      return response.data;
    } catch (e) {
      EasyLoading.dismiss();
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }
}
