import 'package:dio/dio.dart';

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
}
