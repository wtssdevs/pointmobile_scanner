import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class TenantLoginInfo {
  String name;
  String tenancyName;
  String code;
  double taxFactor;
  int id;

  TenantLoginInfo({
    required this.name,
    required this.tenancyName,
    required this.code,
    required this.taxFactor,
    required this.id,
  });

  factory TenantLoginInfo.fromJson(Map<String, dynamic> json) => TenantLoginInfo(
        name: asT<String>(json['name']) ?? "",
        tenancyName: asT<String>(json['tenancyName']) ?? "",
        code: asT<String?>(json['code']) ?? "",
        taxFactor: asT<double>(json['taxFactor']) ?? 0,
        id: asT<int>(json['id']) ?? 0,
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = name;
    data['tenancyName'] = tenancyName;
    data['code'] = code;
    data['taxFactor'] = taxFactor;
    data['id'] = id;

    return data;
  }
}
