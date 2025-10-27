import 'package:xstream_gate_pass_app/core/app_const.dart';

/// Validation Messages Helper Class
///
/// This class provides convenient static methods for generating common validation messages
/// using the centralized constants from AppConst. This eliminates magic strings throughout
/// the codebase and ensures consistency.
///
/// Usage:
/// - For basic required field: ValidationMessages.required("Driver Name")
/// - For photo validation: ValidationMessages.photoRequired("Foreign license")
/// - For custom validation: Use AppConst constants directly
class ValidationMessages {
  ValidationMessages._(); // Private constructor to prevent instantiation

  // Pre-defined validation messages

  static const String vehicleRegMismatch = AppConst.msgVehicleRegMismatch;
  static const String customerRequired = AppConst.msgCustomerRequired;

  // Required field messages
  static const String driverNameRequired = AppConst.msgDriverNameRequired;
  static const String driverIdRequired = AppConst.msgDriverIdRequired;
  static const String vehicleRegRequired = AppConst.msgVehicleRegRequired;
  static const String foreignLicensePhotoRequired = AppConst.msgForeignLicensePhotoRequired;

  // Dynamic validation message generators
  static String required(String fieldName) {
    return AppConst.getFieldRequiredMessage(fieldName);
  }

  static String photoRequired(String photoType) {
    return AppConst.getPhotoRequiredMessage(photoType);
  }

  static String regNoMismatch(String preFix, String? regNumber, String? mismatchRegNo) {
    return "$preFix $regNumber ${AppConst.msgRegMismatch} ${mismatchRegNo ?? '(Not Scanned)'}.";
  }

  static String scanProcessingFailed(String error) {
    return AppConst.getScanDataProcessingFailedMessage(error);
  }

  // Network and connection messages
  static const String internetConnectionLost = AppConst.msgInternetConnectionLost;

  static String getDriverIdMismatchMessage(String? driverIdNo, String? driverIdNoValidation) {
    return "Driver ID Number: $driverIdNo does not match the scanned drivers card ID number: ${driverIdNoValidation ?? '(Not Scanned)'}.";
  }

  static const String noSpacesAllowed = "No spaces allowed in registration number.";

  static String photoRequiredForManualInput(String fieldType) {
    return "Photo required for manually entered $fieldType registration.";
  }

  static String overrideConfirmation(String fieldType, String expected, String entered) {
    return "Override: $fieldType registration mismatch.Expected: $expected Entered: $entered Are you sure you want to proceed?";
  }
}
