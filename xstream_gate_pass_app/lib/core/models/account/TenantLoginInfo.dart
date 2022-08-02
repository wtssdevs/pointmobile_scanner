import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class TenantLoginInfo {
  String name;
  String tenancyName;
  String code;
  double taxFactor;
  double pODAPP_GrossWeight_DefaultValue;
  int id;
  bool pODAPP_VerifyLoads_IsEnabled;
  bool pODAPP_Survey_IsEnabled;
  int mobileSurveyType;

  TenantLoginInfo({
    required this.name,
    required this.tenancyName,
    required this.code,
    required this.taxFactor,
    required this.id,
    this.mobileSurveyType = 0,
    this.pODAPP_GrossWeight_DefaultValue = 0,
    this.pODAPP_VerifyLoads_IsEnabled = false,
    this.pODAPP_Survey_IsEnabled = false,
  });

  factory TenantLoginInfo.fromJson(Map<String, dynamic> json) => TenantLoginInfo(
        name: asT<String>(json['name']) ?? "",
        tenancyName: asT<String>(json['tenancyName']) ?? "",
        code: asT<String?>(json['code']) ?? "",
        taxFactor: asT<double>(json['taxFactor']) ?? 0,
        id: asT<int>(json['id']) ?? 0,
        pODAPP_GrossWeight_DefaultValue: asT<double>(json['pODAPP_GrossWeight_DefaultValue']) ?? 0,
        pODAPP_VerifyLoads_IsEnabled: asT<bool>(json['pODAPP_VerifyLoads_IsEnabled']) ?? false,
        pODAPP_Survey_IsEnabled: asT<bool>(json['pODAPP_Survey_IsEnabled']) ?? false,
        mobileSurveyType: asT<int>(json['mobileSurveyType']) ?? 0,
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = name;
    data['tenancyName'] = tenancyName;
    data['code'] = code;
    data['taxFactor'] = taxFactor;
    data['id'] = id;
    data['mobileSurveyType'] = mobileSurveyType;

    data['pODAPP_GrossWeight_DefaultValue'] = pODAPP_GrossWeight_DefaultValue;
    data['pODAPP_VerifyLoads_IsEnabled'] = pODAPP_VerifyLoads_IsEnabled;
    data['pODAPP_Survey_IsEnabled'] = pODAPP_Survey_IsEnabled;

    return data;
  }
}
