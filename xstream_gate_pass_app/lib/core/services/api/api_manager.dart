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

import 'package:xstream_gate_pass_app/core/models/basefiles/filestore/filestore.dart';
import 'package:xstream_gate_pass_app/core/services/api/abp_error_handler.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/access_token_repo.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';

import 'package:dio/dio.dart' as DioClient;
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

@InitializableSingleton()
class ApiManager {
  final DialogService _dialogService = locator<DialogService>();
  final _environmentService = locator<EnvironmentService>();
  final AccessTokenRepo _accessTokenRepo = locator<AccessTokenRepo>();
  final log = getLogger('ApiManager');

  //static DioClient.Dio? _dio;
  late Dio _dio;

  Future<void> init() async {
    // Or create `Dio` with a `BaseOptions` instance.
    final options = BaseOptions(
      baseUrl: _environmentService.getBaseUrl(AuthPortal.xac),
      connectTimeout: const Duration(seconds: kDebugMode ? 800 : 60),
      receiveTimeout: const Duration(seconds: kDebugMode ? 800 : 60),
    );
    _dio = DioClient.Dio()
      ..options = options
      ..httpClientAdapter = Http2Adapter(
        ConnectionManager(
          idleTimeout: const Duration(seconds: 15),
          onClientCreate: (_, config) => config.onBadCertificate = (_) => true,
        ),
      );

//RETRY
    //  _dio.interceptors.add(
    // RetryInterceptor(
    //   dio: _dio,
    //   logPrint: log.d, // specify log function (optional)
    //   retries: 3, // retry count (optional)
    //   retryDelays: const [
    //     // set delays between retries (optional)
    //     Duration(seconds: 1), // wait 1 sec before first retry
    //     Duration(seconds: 3), // wait 2 sec before second retry
    //     Duration(seconds: 5), // wait 3 sec before third retry
    //   ],
    // ),
    // );

    // Add interceptor for bearer token
    // AuthInterceptor
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
        //*****onError****** */

        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == HttpStatus.forbidden || error.response?.statusCode == HttpStatus.unauthorized) {
            log.i('AuthInterceptor - Error 401');
            final accessToken = await _accessTokenRepo.getAccessTokenFromStorageOrRefresh();

            //Happens on first request if badly handled
            //Or if the user cleaned his local storage at Runtime
            if (accessToken == null || accessToken.accessToken == null) {
              log.i('AuthInterceptor - No Local AccessToken');
              //log out the user
              _accessTokenRepo.logOutCurrentUser();
              return handler.reject(error);
            }

            // Create a new request options object with the updated token

            final options = error.requestOptions;
            final data = options.data;
            final newOptions = options.copyWith(
              data: data is FormData ? data.clone() : data,
            );

            newOptions.headers["authorization"] =
                "Bearer ${accessToken.accessToken}";
            if (accessToken.tenantId != null) {
              newOptions.headers["Abp-TenantId"] = accessToken.tenantId;
            }

            try {
              // Retry the request with the new token

              final response = await retryInternal(newOptions);

              return handler.resolve(response);
            } on DioException catch (e) {
              handelError(e);
              return handler.next(e);
            }
          }
          //DioErrorUtil.handleError(error);
          handelError(error);
          return handler.next(error);
        },
        //*****onRequest****** */
        onRequest: (
          RequestOptions options,
          RequestInterceptorHandler handler,
        ) async {
          final requiresAuth =
              options.extra[AppConst.requiresAuthExtraKey] != false &&
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

  Future<Response<dynamic>> retryInternal(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    final baseOptions = BaseOptions(
      baseUrl: _environmentService.getBaseUrl(AuthPortal.xac),
      connectTimeout: const Duration(seconds: kDebugMode ? 800 : 60),
      receiveTimeout: const Duration(seconds: kDebugMode ? 800 : 60),
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    //var dioRetryClient = Dio(baseOptions);

    var dioRetryClient = Dio()
      ..options = baseOptions
      ..httpClientAdapter = Http2Adapter(
        ConnectionManager(
          idleTimeout: const Duration(seconds: 15),
          onClientCreate: (_, config) => config.onBadCertificate = (_) => true,
        ),
      );

    return dioRetryClient.request<dynamic>(requestOptions.path, data: requestOptions.data, queryParameters: requestOptions.queryParameters, options: options);
  }

  // injecting dio instance

  // Get:-----------------------------------------------------------------------

  Future<dynamic> get(String uri, {Map<String, dynamic>? queryParameters, DioClient.Options? options, DioClient.CancelToken? cancelToken, DioClient.ProgressCallback? onReceiveProgress, bool showLoader = false}) async {
    try {
      if (showLoader) {
        EasyLoading.show();
      }

      final DioClient.Response response = await _dio.get(
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

  Future<dynamic> uploadLoadImages(FileStore fileStore) async {
    try {
      DioClient.FormData formData = DioClient.FormData();

      formData = DioClient.FormData.fromMap({
        "files": await DioClient.MultipartFile.fromFile(
          fileStore.path,
          filename: fileStore.fileName,
        )
      });

      //[5] SEND TO SERVER
      final DioClient.Response response = await _dio.post(
        AppConst.FileUploading_Images,
        data: formData,
        options: DioClient.Options(
          headers: {
            "fileStoreType": "${fileStore.filestoreType}",
            "fileStoreTypeId": "15", //    GatePassDocuments = 15,
            "transactionRefId": "${fileStore.refId}",
            "overrideExisting": "false",
            "name": "${fileStore.fileName}",
            "antiForgeryToken": "",
          },
        ),
      );

      return response.data;
    } catch (err) {
      log.e(err);
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<dynamic> postWithFile({
    required String uri,
    required String filePath,
    required String fileName,
    required Map<String, dynamic> modelData,
  }) async {
    try {
      DioClient.FormData formData = DioClient.FormData();

      formData = DioClient.FormData.fromMap({...modelData, "file": await DioClient.MultipartFile.fromFile(filePath, filename: fileName)});

      //[5] SEND TO SERVER
      final DioClient.Response response = await _dio.post(
        uri,
        data: formData,
        //  options: DioClient.Options(
        //       headers: {
        //         "uploadType": "2",
        //         "uploadMethod": "4",
        //         "referenceId": "$refId",
        //         "documentFileName": "$fileName",
        //         "documentTypeID": "7",
        //         "name": "$fileName",
        //         "antiForgeryToken": "",
        //       },
        //     )
      );

      return response.data;
    } catch (err) {
      log.d(err.toString());
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  // Post:----------------------------------------------------------------------
  Future<dynamic> post(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    DioClient.Options? options,
    DioClient.CancelToken? cancelToken,
    DioClient.ProgressCallback? onSendProgress,
    DioClient.ProgressCallback? onReceiveProgress,
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        EasyLoading.show();
      }

      final DioClient.Response response = await _dio.post(
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
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  // Put:----------------------------------------------------------------------
  Future<dynamic> put(String uri, {data, Map<String, dynamic>? queryParameters, DioClient.Options? options, DioClient.CancelToken? cancelToken, DioClient.ProgressCallback? onSendProgress, DioClient.ProgressCallback? onReceiveProgress, bool showLoader = true}) async {
    try {
      if (showLoader) {
        //  EasyLoading.show();
      }

      final DioClient.Response response = await _dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      // EasyLoading.dismiss();
      return response.data;
    } catch (e) {
      //EasyLoading.dismiss();
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<DioClient.Response> request(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    DioClient.Options? options,
    DioClient.CancelToken? cancelToken,
    DioClient.ProgressCallback? onSendProgress,
    DioClient.ProgressCallback? onReceiveProgress,
  }) async {
    try {
      EasyLoading.show();
      final DioClient.Response response = await _dio.request(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      EasyLoading.dismiss();
      return response;
    } catch (e) {
      EasyLoading.dismiss();
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }
}
