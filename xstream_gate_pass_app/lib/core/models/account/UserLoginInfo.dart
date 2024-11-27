import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class UserLoginInfo {
  String? name;
  String? surname;
  String? fullName;
  String? emailAddress;
  int? id;
  int? transporterId;
  bool podCanAddTrip;
  bool mustCompleteSurvey;
  bool podAccess_Signature_IsRequired;
  bool podAccess_Orders_IsVisible;
  bool podAccess_Parcels_IsVisible;
  bool podAccess_Device_Tracking_IsEnabled;

  //settings for device per users

  String get showFullName => (name ?? "") + (surname ?? "");

  UserLoginInfo(
      {this.name,
      this.surname,
      this.fullName,
      this.emailAddress,
      this.id,
      this.transporterId,
      this.podCanAddTrip = false,
      this.mustCompleteSurvey = false,
      this.podAccess_Orders_IsVisible = false,
      this.podAccess_Parcels_IsVisible = false,
      this.podAccess_Device_Tracking_IsEnabled = true,
      this.podAccess_Signature_IsRequired = false});

  factory UserLoginInfo.fromJson(Map<String, dynamic> json) => UserLoginInfo(
        name: asT<String?>(json['name']) ?? null,
        surname: asT<String?>(json['surname']) ?? null,
        fullName: asT<String?>(json['fullName']) ?? null,
        emailAddress: asT<String?>(json['emailAddress']) ?? null,
        id: asT<int?>(json['id']) ?? null,
        transporterId: asT<int?>(json['transporterID']) ?? null,
        podCanAddTrip: asT<bool>(json['podCanAddTrip']) ?? false,
        mustCompleteSurvey: asT<bool>(json['mustCompleteSurvey']) ?? false,
        podAccess_Orders_IsVisible:
            asT<bool>(json['podAccess_Orders_IsVisible']) ?? false,
        podAccess_Parcels_IsVisible:
            asT<bool>(json['podAccess_Parcels_IsVisible']) ?? false,
        podAccess_Signature_IsRequired:
            asT<bool>(json['podAccess_Signature_IsRequired']) ?? false,
        podAccess_Device_Tracking_IsEnabled:
            asT<bool>(json['podAccess_Device_Tracking_IsEnabled'] ?? true) ??
                true,
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['surname'] = this.surname;
    data['fullName'] = this.fullName;
    data['emailAddress'] = this.emailAddress;
    data['id'] = this.id;
    data['transporterID'] = this.transporterId;
    data['podCanAddTrip'] = this.podCanAddTrip;
    data['mustCompleteSurvey'] = this.mustCompleteSurvey;
    data['podAccess_Orders_IsVisible'] = this.podAccess_Orders_IsVisible;
    data['podAccess_Parcels_IsVisible'] = this.podAccess_Parcels_IsVisible;
    data['podAccess_Signature_IsRequired'] =
        this.podAccess_Signature_IsRequired;
    data['podAccess_Device_Tracking_IsEnabled'] =
        this.podAccess_Device_Tracking_IsEnabled;

    return data;
  }
}
