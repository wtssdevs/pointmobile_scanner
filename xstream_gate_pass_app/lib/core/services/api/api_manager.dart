import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:dio/dio.dart' as DioClient;
import 'package:xstream_gate_pass_app/app_config/app.locator.dart';
import 'package:xstream_gate_pass_app/app_config/app.logger.dart';
import 'package:xstream_gate_pass_app/app_config/app.router.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/filestore_type.dart';
import 'package:xstream_gate_pass_app/core/models/account/AuthenticateResultModel.dart';
import 'package:xstream_gate_pass_app/core/models/account/UserCredential.dart';
import 'package:xstream_gate_pass_app/core/models/basefiles/filestore/filestore.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/core/utils/dio_error_util.dart';

@LazySingleton()
class ApiManager {
  final DialogService? _dialogService = locator<DialogService>();
  final LocalStorageService? _localStorageService = locator<LocalStorageService>();
  final NavigationService? _navigationService = locator<NavigationService>();
  final _environmentService = locator<EnvironmentService>();

  final log = getLogger('ApiManager');
  // dio instance
  static DioClient.Dio? _dio;
  ApiManager() {
    if (_dio == null) {
      // or new Dio with a BaseOptions instance.
      DioClient.BaseOptions options = DioClient.BaseOptions(
        baseUrl: _environmentService.getValue(AppConst.API_Base_Url),
        connectTimeout: 60000,
        receiveTimeout: 60000,
        sendTimeout: 60000,
        contentType: "application/json",
      );

      _dio = DioClient.Dio(options);
    }
    _dio!.interceptors.add(DioClient.InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Do something before request is sent
        // return handler.next(options); //continue
        // If you want to resolve the request with some custom data，
        // you can resolve a `Response` object eg: return `dio.resolve(response)`.
        // If you want to reject the request with a error message,
        // you can reject a `DioError` object eg: return `dio.reject(dioError)`
        //
        //if auth ignor
        if (options.path == "/api/Account/ExternalAuth") {
          return handler.next(options);
        }
        // Do something before request is sent
        var token = _localStorageService!.getAuthToken;
        var authHeader = options.headers["authorization"];

        //options.headers.putIfAbsent('Authorization', () => token);

        if (authHeader == null && token != null && token.accessToken != null) {
          options.headers["authorization"] = "Bearer ${token.accessToken}";
        }
        options.headers["Accept"] = "application/json";
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Do something with response data
        return handler.next(response); // continue
        // If you want to reject the request with a error message,
        // you can reject a `DioError` object eg: return `dio.reject(dioError)`
      },
      onError: (error, handler) {
        // Assume 401 stands for token expired\
        //  if (error.response?.statusCode == 403 || error.response?.statusCode == 401) {
        if (error.response?.statusCode == 401) {
          var options = error.response!.requestOptions;
          // If the token has been updated, repeat directly.
          var token = _localStorageService!.getAuthToken;
          if (token != null && token.accessToken != options.headers['authorization']) {
            options.headers["authorization"] = "Bearer ${token.accessToken}";
            //repeat
            _dio!.fetch(options).then(
              (r) => handler.resolve(r),
              onError: (e) {
                handler.reject(e);
              },
            );
            return;
          } else {
            logOutCurrentUser();
          }
          // update token and repeat
          // Lock to block the incoming request until the token updated
          if (token == null || token.tenancyName == null) {
            // logOutCurrentUser();
            return;
          }
          _dio!.lock();
          _dio!.interceptors.responseLock.lock();
          _dio!.interceptors.errorLock.lock();
          var tokenDio = DioClient.Dio();
          tokenDio.options = _dio!.options.copyWith();

          var userCredential =
              UserCredential(tenancyName: token.tenancyName!, userNameOrEmailAddress: token.userNameOrEmailAddress!, password: token.password!, rememberClient: true);
          tokenDio
              .get(
            "/api/Account/ExternalAuth",
            queryParameters: userCredential.toJson(),
          )
              .then((authResult) {
            var authenticateResultModel = AuthenticateResultModel.fromJson(authResult.data);
            processAuthenticateResult(authenticateResultModel, userCredential);
          }).whenComplete(() {
            _dio!.unlock();
            _dio!.interceptors.responseLock.unlock();
            _dio!.interceptors.errorLock.unlock();
          }).then((e) {
            //repeat
            _dio!.fetch(options).then(
              (r) => handler.resolve(r),
              onError: (e) {
                handler.reject(e);
              },
            );
          });
          return;
        } else {
          handelError(error);
        }
        return handler.next(error);
      },
    ));
  }

  void logOutCurrentUser() {
    _localStorageService!.logout();
    _navigationService!.clearStackAndShow(Routes.loginView);
  }

  Future<bool> refreshToken() async {
    var token = _localStorageService!.getAuthToken;
    if (token != null) {
      if (token.autTokenIsEmpty()) {
        logOutCurrentUser();
      }

      var userCredential = UserCredential(tenancyName: token.tenancyName!, userNameOrEmailAddress: token.userNameOrEmailAddress!, password: token.password!, rememberClient: true);

      var authResult = await get("/api/Account/ExternalAuth", queryParameters: userCredential.toJson(), showLoader: false);

      var authenticateResultModel = AuthenticateResultModel.fromJson(authResult);

      await processAuthenticateResult(authenticateResultModel, userCredential);
      return true;
    } else {
      return false;
    }
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
    } else {
      logOutCurrentUser();
    }
  }

  handelError(DioClient.DioError dioError) {
    // log.d(dioError);
    // if (dioError.error is SocketException) {
    //   Fluttertoast.showToast(
    //       msg: "No active internet connection found!",
    //       toastLength: Toast.LENGTH_SHORT,
    //       gravity: ToastGravity.CENTER,
    //       timeInSecForIosWeb: 3,
    //       backgroundColor: Colors.red,
    //       textColor: Colors.white,
    //       fontSize: 18.0);
    //   return;
    // }

    var errorResponseToShow = DioErrorUtil.handleAbpError(dioError);

    if (errorResponseToShow.error == null) {
      return;
    }
    //this was from auto refresh.user creds have changed or removed via logout
    if (errorResponseToShow.error != null && errorResponseToShow.error?.details != null) {
      if (dioError.requestOptions.path.isNotEmpty &&
          dioError.requestOptions.path == "/api/Account/ExternalAuth" &&
          errorResponseToShow.error?.details == "Invalid user name or password") {
        logOutCurrentUser();
      }
    }

    if (errorResponseToShow.error!.validationErrors == null && errorResponseToShow.error!.message!.isNotEmpty) {
      _dialogService!.showDialog(
        title: errorResponseToShow.error!.message,
        description: errorResponseToShow.error!.details,
      );
      return;
    }

    if (errorResponseToShow.error!.validationErrors!.length > 0 || errorResponseToShow.error!.message!.isNotEmpty) {
      _dialogService!.showDialog(
        title: errorResponseToShow.error!.message,
        description: errorResponseToShow.error!.details,
      );
      return;
    }
    if (errorResponseToShow.message!.isNotEmpty) {
      Fluttertoast.showToast(
          msg: errorResponseToShow.message!,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
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

      final DioClient.Response response = await _dio!.get(
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
      final DioClient.Response response = await _dio!.post(
        AppConst.FileUploading_Images,
        data: formData,
        options: DioClient.Options(
          headers: {
            "uploadType": "2", //TMSConsts.UploadType.Files:
            "uploadMethod": "4", //TMSConsts.UploadMethod.LoadAssignmentDocuments:
            //FileStoreType
            "fileStoreTypeId": "4",
            "referenceId": "${fileStore.refId}",
            "documentFileName": "${fileStore.fileName}",
            "documentTypeID": documentTypeID, //7 = PICTURES ,6 = PROOF OF DELIVERY
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

  Future<dynamic> postWithFile({required String uri, required String filePath, required String fileName, required Map<String, dynamic> modelData}) async {
    try {
      DioClient.FormData formData = DioClient.FormData();

      formData = DioClient.FormData.fromMap({...modelData, "file": await DioClient.MultipartFile.fromFile(filePath, filename: fileName)});

      //[5] SEND TO SERVER
      final DioClient.Response response = await _dio!.post(
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
  Future<dynamic> post(String uri,
      {data,
      Map<String, dynamic>? queryParameters,
      DioClient.Options? options,
      DioClient.CancelToken? cancelToken,
      DioClient.ProgressCallback? onSendProgress,
      DioClient.ProgressCallback? onReceiveProgress,
      bool showLoader = true}) async {
    try {
      if (showLoader) {
        EasyLoading.show();
      }

      final DioClient.Response response = await _dio!.post(
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
      final DioClient.Response response = await _dio!.request(
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
