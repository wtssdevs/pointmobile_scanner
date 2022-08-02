import 'dart:convert';
import 'package:xstream_gate_pass_app/core/models/account/TenantLoginInfo.dart';
import 'package:xstream_gate_pass_app/core/models/account/UserLoginInfo.dart';


class CurrentLoginInformation {
  CurrentLoginInformation({
    required this.user,
    required this.tenant,
  });

  factory CurrentLoginInformation.fromJson(Map<String, dynamic> jsonRes) => CurrentLoginInformation(
        user: UserLoginInfo.fromJson((jsonRes['user']) ?? UserLoginInfo()),
        tenant: TenantLoginInfo.fromJson((jsonRes['tenant']) ?? TenantLoginInfo(code: "", id: 0, name: "", tenancyName: "", taxFactor: 0)),
      );

  UserLoginInfo user;
  TenantLoginInfo tenant;
  String get showFullName => (tenant.tenancyName) + "\\" + (user.showFullName);
  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'user': user,
        'tenant': tenant,
      };
}
