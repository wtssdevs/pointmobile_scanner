import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';

import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/basic_dialog_status.dart';
import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';

import 'package:xstream_gate_pass_app/core/models/basefiles/filestore/filestore.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/access_token_repo.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';

import 'package:xstream_gate_pass_app/core/utils/dio_error_util.dart';
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
      baseUrl: _environmentService.getValue(AppConst.API_Base_Url),
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
        maxWidth: 160,
        enabled: true,
        request: true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        //*****onError****** */

        onError: (DioException error, ErrorInterceptorHandler handler) async {
          if (error.response?.statusCode == HttpStatus.forbidden ||
              error.response?.statusCode == HttpStatus.unauthorized) {
            log.i('AuthInterceptor - Error 401');
            final accessToken =
                await _accessTokenRepo.getAccessTokenFromStorageOrRefresh();

            //Happens on first request if badly handled
            //Or if the user cleaned his local storage at Runtime
            if (accessToken == null || accessToken.isEmpty) {
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

            newOptions.headers["authorization"] = "Bearer $accessToken";

            try {
              // Retry the request with the new token

              final response = await retryInternal(newOptions);

              return handler.resolve(response);
            } on DioException catch (e) {
              //DioErrorUtil.handleError(e);
              handelError(error);
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
          // //Getting cached Access Token, or getting it from storage and caching it

          //TODO add ignor type to request to skip it
          var pathLowerCase = options.path.toLowerCase();

          if (pathLowerCase == "/api/TokenAuth/Authenticate".toLowerCase()) {
            return handler.next(options);
          }
          if (pathLowerCase == AppConst.authentication.toLowerCase()) {
            return handler.next(options);
          }
          if (pathLowerCase ==
              "/api/services/app/Account/register".toLowerCase()) {
            return handler.next(options);
          }
          if (pathLowerCase ==
              "/api/services/app/Account/ForgotPassword".toLowerCase()) {
            return handler.next(options);
          }
          if (pathLowerCase ==
              "/api/services/app/Account/ResetForgotPassword".toLowerCase()) {
            return handler.next(options);
          }

          var token =
              await _accessTokenRepo.getAccessTokenFromStorageOrRefresh();

          var authHeader = options.headers["authorization"];
          if (authHeader == null && token != null) {
            options.headers["authorization"] = "Bearer $token";
          }
          options.headers["Accept"] = "application/json";

          if (options.headers['requires-token'] == 'false') {
            // if the request doesn't need token, then just continue to the next
            // interceptor
            options.headers
                .remove('requiresToken'); //remove the auxiliary header
            return handler.next(options);
          }

          options.headers.addAll({'authorization': 'Bearer ${token!}'});
          return handler.next(options);
        },
      ),
    );

    log.d('Initialized');
  }

  handelError(DioException dioError) {
    if (dioError.error is SocketException) {
      return;
      //TODO handel state check and route to error page
    }

    // if (dioError.requestOptions.disableRetry == false) {
    //   return;
    //   //silent failure
    // }

    if (dioError.response == null || dioError.response?.statusCode == null) {
      _dialogService.showDialog(
        title: "Error",
        description: "Internal error,Please try again later",
        buttonTitle: "OK",
      );
    }

    var listOrfCodesToAllow = [
      HttpStatus.internalServerError,
      HttpStatus.badRequest,
      HttpStatus.forbidden,
      HttpStatus.notFound
    ];

    //check if it is a general HTTP error or if it is a custom Server API error
    //if it is a custom Server API error, then we need to show the error message
    if ((listOrfCodesToAllow.contains(dioError.response!.statusCode)) &&
        dioError.response?.data != null) {
      //if it is a custom Server API error, then we need to show the error message

      //check if the error can be parsed as a Server API error
      try {
        var errorResponse = DioErrorUtil.handleAbpError(dioError);
        if (errorResponse.success != null && errorResponse.error != null) {
          //VALIDATION ERRORS

          if (errorResponse.error != null &&
              errorResponse.error?.details != null) {
            if (dioError.requestOptions.path.isNotEmpty &&
                dioError.requestOptions.path == "/api/Account/ExternalAuth" &&
                errorResponse.error?.details ==
                    "Invalid user name or password") {
              _accessTokenRepo.logOutCurrentUser();
            }
          }

          if (errorResponse.error!.validationErrors != null &&
              errorResponse.error!.message!.isNotEmpty) {
            var title = errorResponse.error!
                .message!; // + " " + errorResponse.error?.details! ?? "";
            var description = errorResponse.error!.details;

            if (description == null || description.isEmpty) {
              description = errorResponse.error!.validationErrors!.join(",\n");
            }
            _dialogService.showCustomDialog(
              variant: DialogType.basic,
              data: BasicDialogStatus.error,
              title: title,
              description: description,
              mainButtonTitle: "Ok",
            );

            return;
          }

          if (errorResponse.error!.validationErrors == null &&
              errorResponse.error!.message != null) {
            var description = errorResponse.error!.details;
            var title = errorResponse.error!.message;
            if (title == null || title.isEmpty) {
              title = "Error";
            }

            _dialogService.showCustomDialog(
              variant: DialogType.basic,
              data: BasicDialogStatus.error,
              title: title,
              description: description,
              mainButtonTitle: "Ok",
            );

            return;
          }

          if (errorResponse.error!.validationErrors!.isNotEmpty ||
              errorResponse.error!.message!.isNotEmpty) {
            _dialogService.showDialog(
              title: errorResponse.error!.message,
              description: errorResponse.error!.details,
            );
            return;
          }
        }
      } catch (e) {
        log.e(e);
      }

      if (dioError.response!.statusCode == 400 ||
          dioError.response!.statusCode == 401 ||
          dioError.response!.statusCode == 403 ||
          dioError.response!.statusCode == 404 ||
          dioError.response!.statusCode == 405 ||
          dioError.response!.statusCode == 500) {
        var errorResponseToShow = DioErrorUtil.handleError(dioError);
        if (errorResponseToShow.isNotEmpty) {
          _dialogService.showDialog(
            title: "Error",
            description: errorResponseToShow,
            buttonTitle: "OK",
          );
          return;
        }
      }
    }
    //else we need to show the general error message

    var err = DioErrorUtil.handleError(dioError);

    _dialogService.showDialog(
      title: "Error",
      description: err,
      buttonTitle: "OK",
    );
  }

  Future<Response<dynamic>> retryInternal(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    final baseOptions = BaseOptions(
      baseUrl: _environmentService.getValue(AppConst.API_Base_Url),
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

    return dioRetryClient.request<dynamic>(requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options);
  }

  // injecting dio instance

  // Get:-----------------------------------------------------------------------

  Future<dynamic> get(String uri,
      {Map<String, dynamic>? queryParameters,
      DioClient.Options? options,
      DioClient.CancelToken? cancelToken,
      DioClient.ProgressCallback? onReceiveProgress,
      bool showLoader = false}) async {
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
      var documentTypeID = 7; //default

      //[5] SEND TO SERVER
      final DioClient.Response response = await _dio.post(
        AppConst.FileUploading_Images,
        data: formData,
        options: DioClient.Options(
          headers: {
            "uploadType": "2", //TMSConsts.UploadType.Files:
            "uploadMethod":
                "0", //TMSConsts.UploadMethod.LoadAssignmentDocuments:
            //FileStoreType
            "fileStoreTypeId": "15", //    GatePassDocuments = 15,
            "referenceId": "${fileStore.refId}",
            "documentFileName": "${fileStore.fileName}",
            "documentTypeID":
                documentTypeID, //7 = PICTURES ,6 = PROOF OF DELIVERY
            "name": "${fileStore.fileName}",
            "antiForgeryToken": "",
          },
        ),
      );

      return response.data;
    } catch (err) {
      log.e(err);
      rethrow;
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

      formData = DioClient.FormData.fromMap({
        ...modelData,
        "file":
            await DioClient.MultipartFile.fromFile(filePath, filename: fileName)
      });

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
    }
  }

  // Put:----------------------------------------------------------------------
  Future<dynamic> put(String uri,
      {data,
      Map<String, dynamic>? queryParameters,
      DioClient.Options? options,
      DioClient.CancelToken? cancelToken,
      DioClient.ProgressCallback? onSendProgress,
      DioClient.ProgressCallback? onReceiveProgress,
      bool showLoader = true}) async {
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
    }
  }
}
