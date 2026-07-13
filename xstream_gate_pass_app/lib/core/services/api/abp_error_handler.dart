import 'dart:io';

import 'package:dio/dio.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.dialogs.dart';
import 'package:xstream_gate_pass_app/core/enums/basic_dialog_status.dart';
import 'package:xstream_gate_pass_app/core/models/shared/api_response.dart';
import 'package:xstream_gate_pass_app/core/utils/dio_error_util.dart';

class AbpErrorHandler {
  static void handle({
    required DioException dioError,
    required DialogService dialogService,
    void Function(Object error)? logError,
    void Function()? onExternalAuthInvalid,
  }) {
    if (dioError.error is SocketException) {
      return;
    }

    if (dioError.response == null || dioError.response?.statusCode == null) {
      dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        data: BasicDialogStatus.warning,
        title: "Error",
        description: "Internal error,Please try again later",
        mainButtonTitle: "OK",
      );
      return;
    }

    var listOrfCodesToAllow = [
      HttpStatus.internalServerError,
      HttpStatus.badRequest,
      HttpStatus.forbidden,
      HttpStatus.notFound
    ];

    if ((listOrfCodesToAllow.contains(dioError.response!.statusCode)) &&
        dioError.response?.data != null) {
      try {
        var errorResponse = DioErrorUtil.handleAbpError(dioError);
        if (errorResponse.success != null && errorResponse.error != null) {
          if (errorResponse.error?.details != null &&
              dioError.requestOptions.path.isNotEmpty &&
              dioError.requestOptions.path == "/api/Account/ExternalAuth" &&
              errorResponse.error?.details == "Invalid user name or password") {
            onExternalAuthInvalid?.call();
          }

          final validationErrors = errorResponse.error!.validationErrors;
          final errorMessage = errorResponse.error!.message;
          final errorDetails = errorResponse.error!.details;

          if (validationErrors != null &&
              validationErrors.isNotEmpty &&
              errorMessage != null &&
              errorMessage.isNotEmpty) {
            var title = errorMessage;
            var description = errorDetails;

            if (description == null || description.isEmpty) {
              description = _validationErrorsToText(validationErrors);
            }
            dialogService.showCustomDialog(
              variant: DialogType.infoAlert,
              data: BasicDialogStatus.warning,
              mainButtonTitle: "Ok",
              title: title,
              description: description,
            );

            return;
          }

          if ((validationErrors == null || validationErrors.isEmpty) &&
              errorMessage != null) {
            var title = "Error";
            var desc = "";
            if (errorDetails != null) {
              desc = errorDetails;
            } else {
              desc = errorMessage;
            }

            title = errorMessage;

            dialogService.showCustomDialog(
              variant: DialogType.infoAlert,
              data: BasicDialogStatus.warning,
              mainButtonTitle: "Ok",
              title: title,
              description: desc,
            );

            return;
          }

          if ((validationErrors != null && validationErrors.isNotEmpty) ||
              (errorMessage != null && errorMessage.isNotEmpty)) {
            dialogService.showCustomDialog(
              variant: DialogType.infoAlert,
              data: BasicDialogStatus.warning,
              mainButtonTitle: "Ok",
              title: errorMessage,
              description: errorDetails ?? _validationErrorsToText(validationErrors),
            );
            return;
          }
        }
      } catch (e) {
        logError?.call(e);
      }

      if (dioError.response!.statusCode == 400 ||
          dioError.response!.statusCode == 401 ||
          dioError.response!.statusCode == 403 ||
          dioError.response!.statusCode == 404 ||
          dioError.response!.statusCode == 405 ||
          dioError.response!.statusCode == 500) {
        var errorResponseToShow = DioErrorUtil.handleError(dioError);
        if (errorResponseToShow.isNotEmpty) {
          dialogService.showCustomDialog(
            variant: DialogType.infoAlert,
            mainButtonTitle: "Ok",
            data: BasicDialogStatus.warning,
            title: "Error",
            description: errorResponseToShow,
          );
          return;
        }
      }
    }

    var err = DioErrorUtil.handleError(dioError);

    dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      data: BasicDialogStatus.warning,
      title: "Error",
      description: err,
      mainButtonTitle: "Ok",
    );
  }

  static String _validationErrorsToText(List<ValidationErrors>? errors) {
    if (errors == null || errors.isEmpty) {
      return '';
    }
    return errors
        .map((error) => error.message)
        .where((message) => message != null && message.isNotEmpty)
        .join(",\n");
  }
}