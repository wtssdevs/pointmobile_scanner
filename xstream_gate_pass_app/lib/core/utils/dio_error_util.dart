import 'package:dio/dio.dart';
import 'package:xstream_gate_pass_app/core/models/shared/api_response.dart';

class DioErrorUtil {
  // general methods:------------------------------------------------------------
  static String handleError(DioError error) {
    String errorDescription = "";
    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.cancel:
          errorDescription = "Request to API server was cancelled";
          break;
        case DioErrorType.connectTimeout:
        case DioErrorType.receiveTimeout:
          errorDescription = "Connection timeout with TMS API server,please try again later.";
          break;
        case DioErrorType.other:
          errorDescription = "Connection to API server failed due to internet connection";
          break;

        case DioErrorType.response:
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
        case DioErrorType.sendTimeout:
          errorDescription = "Send timeout in connection with API server";
          break;
      }
    } else {
      errorDescription = "Unexpected error occured";
    }
    return errorDescription;
  }

  static ApiResponse handleAbpError(DioError error) {
    var apiResponse = ApiResponse();
    apiResponse.success = false;

    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.cancel:
          apiResponse.message = "Request to API server was cancelled";
          break;
        case DioErrorType.connectTimeout:
        case DioErrorType.receiveTimeout:
          apiResponse.message = "Connection timeout with TMS API server,please try again later.";
          break;
        case DioErrorType.other:
          apiResponse.message = "Connection to API server failed due to internet connection";
          break;
        case DioErrorType.response:
          apiResponse.message = "Received invalid status code: ${error.response!.statusCode}";
          switch (error.response!.statusCode) {
            case 400: //bad Request
              if (error.response != null && error.response!.data != null) {
                apiResponse = ApiResponse.fromJson(error.response!.data);
              } else {
                apiResponse.message = "Internal server error";
              }

              break;
            case 401: //bad Request

              break;
            case 500: //Internal server error
              apiResponse.message = "Bad Request";
              if (error.response != null && error.response!.data != null) {
                apiResponse = ApiResponse.fromJson(error.response!.data);
              } else {
                apiResponse.message = "Internal server error";
              }

              break;
          }
          break;
        case DioErrorType.sendTimeout:
          apiResponse.message = "Send timeout in connection with API server";
          break;
      }
    } else {
      apiResponse.message = "Unexpected error occured";
    }
    return apiResponse;
  }
}
