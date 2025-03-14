import 'package:dio/dio.dart';
import 'package:xstream_gate_pass_app/core/models/shared/api_response.dart';

class DioErrorUtil {
  // general methods:------------------------------------------------------------
  static String handleError(DioException error) {
    String errorDescription = "Internal Server Error";
    switch (error.type) {
      case DioExceptionType.cancel:
        errorDescription = "Request to API server was cancelled";
        break;
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.receiveTimeout:
        errorDescription = "Connection timeout with API server,please try again later.";
        break;
      case DioExceptionType.unknown:
        errorDescription = "Received invalid status code: ${error.response!.statusCode}";
        switch (error.response!.statusCode) {
          case 404: //not found
            errorDescription = "";
            break;
          case 400: //bad Request
          case 500: //Internal server error
            errorDescription = "Bad Request";
            if (error.response != null && error.response!.data != null) {
            } else {
              errorDescription = "Internal server error";
            }
            break;
        }
        break;
      case DioExceptionType.sendTimeout:
        errorDescription = "Send timeout in connection with API server";
        break;
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
    }
    return errorDescription;
  }

  static ApiResponse handleAbpError(DioException error, [bool showMessage = true]) {
    var apiResponse = ApiResponse();
    apiResponse.success = null;
    apiResponse.showMessage = showMessage;

    //if (kDebugMode) {}

    switch (error.type) {
      case DioExceptionType.cancel:
        apiResponse.success = false;
        apiResponse.message = "Request to API server was cancelled";
        break;
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.receiveTimeout:
        apiResponse.success = false;
        apiResponse.message = "Connection timeout with API server,please try again later.";
        break;
      case DioExceptionType.unknown:
        apiResponse.success = false;
        apiResponse.message = "Connection to API server failed due to internet connection";

        apiResponse.error = Error(message: "Connection to API server failed due to internet connection");
        apiResponse.showMessage = false;
        break;

      case DioExceptionType.sendTimeout:
        apiResponse.success = false;
        apiResponse.message = "Send timeout in connection with API server";
        break;
      case DioExceptionType.badResponse:
        switch (error.response!.statusCode) {
          case 400: //bad Request
          case 401: //bad Request
          case 500: //Internal server error
          case 403: //Internal server error
            apiResponse.message = "Bad Request";
            if (error.response != null && error.response!.data != null && error.response!.data != "") {
              if (error.response!.data is String) {
                //may try parse json,if not parseable then use as is
                try {
                  apiResponse = ApiResponse.fromJson(error.response!.data);
                } catch (e) {
                  apiResponse.message = error.response!.data;
                }
              } else {
                apiResponse = ApiResponse.fromJson(error.response!.data);
              }
            } else {
              apiResponse.message = "Internal server error";
            }
            break;
        }

      case DioExceptionType.badCertificate:
        apiResponse.success = false;
        apiResponse.message = "Bad Certificate with API server";
        break;
    }
    return apiResponse;
  }
}
