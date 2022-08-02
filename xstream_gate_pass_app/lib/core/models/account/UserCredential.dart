import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class UserCredential {
  String tenancyName;
  String userNameOrEmailAddress;
  String password;
  bool rememberClient;

  UserCredential({required this.tenancyName, required this.userNameOrEmailAddress, required this.password, required this.rememberClient});

  factory UserCredential.fromJson(Map<String, dynamic> jsonRes) {
    return UserCredential(
      tenancyName: asT<String>(jsonRes['tenancyName']) ?? "",
      userNameOrEmailAddress: asT<String?>(jsonRes['userNameOrEmailAddress']) ?? "",
      password: asT<String>(jsonRes['password']) ?? "",
      rememberClient: asT<bool>(jsonRes['rememberClient']) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tenancyName'] = this.tenancyName;
    data['userNameOrEmailAddress'] = this.userNameOrEmailAddress;
    data['password'] = this.password;
    data['rememberClient'] = this.rememberClient;
    return data;
  }
}
