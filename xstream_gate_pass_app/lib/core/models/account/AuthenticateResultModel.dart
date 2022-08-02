import 'dart:convert';

import 'package:xstream_gate_pass_app/core/utils/helper.dart';



class AuthenticateResultModel {
  String? accessToken;
  String? encryptedAccessToken;
  String? userNameOrEmailAddress;
  String? password;
  String? tenancyName;
  int? expireInSeconds;
  DateTime? expiryDate;
  int? userId;
  int? tenantId;

  AuthenticateResultModel(
      {this.accessToken,
      this.encryptedAccessToken,
      this.password,
      this.userNameOrEmailAddress,
      this.expireInSeconds,
      this.expiryDate,
      this.userId,
      this.tenantId});

  AuthenticateResultModel.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'] as String?;
    encryptedAccessToken = json['encryptedAccessToken'] as String?;
    password = json['password'] as String?;
    tenancyName = json['tenancyName'] as String?;
    userNameOrEmailAddress = json['userNameOrEmailAddress'] as String?;
    expireInSeconds = json['expireInSeconds'] as int?;
    userId = json['userId'] as int?;
    tenantId = json['tenantId'] as int?;
    expiryDate = asT<DateTime?>(json['expiryDate']) ?? null;

    //fromBase64
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accessToken'] = accessToken;
    data['encryptedAccessToken'] = encryptedAccessToken;
    data['password'] = password;
    data['userNameOrEmailAddress'] = userNameOrEmailAddress;
    data['tenancyName'] = tenancyName;
    data['expireInSeconds'] = expireInSeconds;
    data['userId'] = userId;
    data['expiryDate'] = expiryDate;
    data['tenantId'] = tenantId;
    return data;
  }

  encodeUserNameOrEmailAddress(String userNameOrEmailAddressToEncode) {
    userNameOrEmailAddress = base64.encode(utf8.encode(userNameOrEmailAddressToEncode));
  }

  String decodeUserNameOrEmailAddress() {
    return utf8.decode(base64.decode(userNameOrEmailAddress!));
  }

  encodePassword(String passwordToEncode) {
    password = base64.encode(utf8.encode(passwordToEncode));
    //String encoded = base64.encode(utf8.encode(credentials)); // dXNlcm5hbWU6cGFzc3dvcmQ=
  }

  String decodePassword() {
    return utf8.decode(base64.decode(password!));
    //String decoded = utf8.decode(base64.decode(encoded));     // username:password
  }

  setUserCredentials({required String tenancyName, required String userNameOrEmailAddress, required String password}) {
    tenancyName = tenancyName;
    userNameOrEmailAddress = userNameOrEmailAddress;
    password = password;
    //encodeUserNameOrEmailAddress(userNameOrEmailAddress);
    //encodePassword(password);
  }

  bool autTokenIsEmpty() {
    return tenancyName == null || userNameOrEmailAddress == null || password == null;
  }
}
