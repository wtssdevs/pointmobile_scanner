import 'package:intl/intl.dart';

class DriversLicence {
  /// Surname
  String? surname;

  /// Initials
  String? initials;

  /// Identity number
  String? identityNumber;

  /// Date of birth
  DateTime? dateOfBirth;

  /// Gender
  /// 01 = male, 02 = female
  String? gender;

  /// Licence codes
  List<String>? licenceCodes;

  /// Licence number
  String? licenceNumber;

  /// Identity country of issue
  String? identityCountryOfIssue;

  /// Licence country of issue
  String? licenceCountryOfIssue;

  /// Vehicle restrictions
  /// Up to 4 restrictions
  List<String>? vehicleRestrictions;

  /// Identity number type
  /// 02 = South African
  String? identityNumberType;

  /// Licence code issue dates
  /// Up to 4 dates
  List<DateTime>? licenceCodeIssueDates;

  /// Driver restriction codes, formatted as XX
  /// 0 = none, 1 = glasses, 2 = artificial limb
  String? driverRestrictionCodes;

  /// Professional driving permit expiry date
  DateTime? professionalDrivingPermitExpiryDate;

  /// Licence issue number
  String? licenceIssueNumber;

  /// Drivers licence image
  DriversLicenceImage? driversLicenceImage;

  /// Licence issue date
  DateTime? licenceIssueDate;

  /// Licence expiry date
  DateTime? licenceExpiryDate;

  DriversLicence({
    this.surname,
    this.initials,
    this.identityNumber,
    this.dateOfBirth,
    this.gender,
    this.licenceCodes,
    this.licenceNumber,
    this.identityCountryOfIssue,
    this.licenceCountryOfIssue,
    this.vehicleRestrictions,
    this.identityNumberType,
    this.licenceCodeIssueDates,
    this.driverRestrictionCodes,
    this.professionalDrivingPermitExpiryDate,
    this.licenceIssueNumber,
    this.driversLicenceImage,
    this.licenceIssueDate,
    this.licenceExpiryDate,
  });
}

/// Image processing is not implemented
/// Licence uses some form of wavelet encoding created in the 90s by a company called summus
class DriversLicenceImage {
  /// Width
  int? width;

  /// Height
  int? height;

  DriversLicenceImage({
    this.width,
    this.height,
  });
}
