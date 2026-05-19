import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';

class CmsInspectionLookupBase {
  const CmsInspectionLookupBase({
    this.id,
    this.tenantId,
    this.name,
    this.code,
    this.altCode,
    this.isActive = true,
    this.postingCodeId,
    this.postingCodeName,
    this.shippingLineId,
    this.shippingLineName,
    this.creatorUserFullName,
    this.lastModifiedUserFullName,
    this.creationTime,
    this.lastModificationTime,
  });

  final int? id;
  final int? tenantId;
  final String? name;
  final String? code;
  final String? altCode;
  final bool isActive;
  final int? postingCodeId;
  final String? postingCodeName;
  final int? shippingLineId;
  final String? shippingLineName;
  final String? creatorUserFullName;
  final String? lastModifiedUserFullName;
  final DateTime? creationTime;
  final DateTime? lastModificationTime;

  bool matchesShippingLine(int? value) {
    if (value == null) {
      return true;
    }
    return shippingLineId == null || shippingLineId == value;
  }

  String get sortCode => (code ?? '').toLowerCase();
  String get sortName => (name ?? '').toLowerCase();
  String get displayName => [code, name].whereType<String>().where((item) => item.isNotEmpty).join(' - ');

  Map<String, dynamic> toJsonBase() {
    return {
      'id': id,
      'tenantId': tenantId,
      'name': name,
      'code': code,
      'altCode': altCode,
      'isActive': isActive,
      'postingCodeId': postingCodeId,
      'postingCodeName': postingCodeName,
      'shippingLineID': shippingLineId,
      'shippingLineName': shippingLineName,
      'creatorUserFullName': creatorUserFullName,
      'lastModifiedUserFullName': lastModifiedUserFullName,
      'creationTime': creationTime?.toIso8601String(),
      'lastModificationTime': lastModificationTime?.toIso8601String(),
    };
  }

  Map<String, dynamic> toJson() => toJsonBase();

  static CmsInspectionLookupBaseFields parseBaseFields(Map<String, dynamic> json) {
    return CmsInspectionLookupBaseFields(
      id: cmsParseInt(json['id']),
      tenantId: cmsParseInt(json['tenantId']),
      name: cmsParseString(json['name']),
      code: cmsParseString(json['code']),
      altCode: cmsParseString(json['altCode']),
      isActive: cmsParseBool(json['isActive']) ?? true,
      postingCodeId: cmsParseInt(json['postingCodeId']),
      postingCodeName: cmsParseString(json['postingCodeName']),
      shippingLineId: cmsParseInt(json['shippingLineID']),
      shippingLineName: cmsParseString(json['shippingLineName']),
      creatorUserFullName: cmsParseString(json['creatorUserFullName']),
      lastModifiedUserFullName: cmsParseString(json['lastModifiedUserFullName']),
      creationTime: cmsParseDateTime(json['creationTime']),
      lastModificationTime: cmsParseDateTime(json['lastModificationTime']),
    );
  }
}

class CmsInspectionLookupBaseFields {
  const CmsInspectionLookupBaseFields({
    this.id,
    this.tenantId,
    this.name,
    this.code,
    this.altCode,
    this.isActive = true,
    this.postingCodeId,
    this.postingCodeName,
    this.shippingLineId,
    this.shippingLineName,
    this.creatorUserFullName,
    this.lastModifiedUserFullName,
    this.creationTime,
    this.lastModificationTime,
  });

  final int? id;
  final int? tenantId;
  final String? name;
  final String? code;
  final String? altCode;
  final bool isActive;
  final int? postingCodeId;
  final String? postingCodeName;
  final int? shippingLineId;
  final String? shippingLineName;
  final String? creatorUserFullName;
  final String? lastModifiedUserFullName;
  final DateTime? creationTime;
  final DateTime? lastModificationTime;
}
