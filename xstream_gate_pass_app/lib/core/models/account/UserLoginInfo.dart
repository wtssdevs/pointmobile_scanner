import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class UserLoginInfo {
  String? name;
  String? surname;
  String? fullName;
  String? emailAddress;
  int? id;

  //settings for device per users

  String get showFullName => (name ?? "") + (' $surname' ?? "");

  UserLoginInfo({
    this.name,
    this.surname,
    this.fullName,
    this.emailAddress,
    this.id,
  });

  factory UserLoginInfo.fromJson(Map<String, dynamic> json) => UserLoginInfo(
        name: asT<String?>(json['name']) ?? null,
        surname: asT<String?>(json['surname']) ?? null,
        fullName: asT<String?>(json['fullName']) ?? null,
        emailAddress: asT<String?>(json['emailAddress']) ?? null,
        id: asT<int?>(json['id']) ?? null,
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['surname'] = this.surname;
    data['fullName'] = this.fullName;
    data['emailAddress'] = this.emailAddress;
    data['id'] = this.id;

    return data;
  }
}
