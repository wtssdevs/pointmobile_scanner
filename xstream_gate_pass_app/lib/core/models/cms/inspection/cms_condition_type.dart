import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_lookup_base.dart';

class CmsConditionType extends CmsInspectionLookupBase {
  const CmsConditionType({
    super.id,
    super.tenantId,
    super.name,
    super.code,
    super.altCode,
    super.isActive,
    super.postingCodeId,
    super.postingCodeName,
    super.shippingLineId,
    super.shippingLineName,
    super.creatorUserFullName,
    super.lastModifiedUserFullName,
    super.creationTime,
    super.lastModificationTime,
    this.conditionDisplayName,
  });

  factory CmsConditionType.fromJson(Map<String, dynamic> json) {
    final baseFields = CmsInspectionLookupBase.parseBaseFields(json);
    return CmsConditionType(
      id: baseFields.id,
      tenantId: baseFields.tenantId,
      name: baseFields.name,
      code: baseFields.code,
      altCode: baseFields.altCode,
      isActive: baseFields.isActive,
      postingCodeId: baseFields.postingCodeId,
      postingCodeName: baseFields.postingCodeName,
      shippingLineId: baseFields.shippingLineId,
      shippingLineName: baseFields.shippingLineName,
      creatorUserFullName: baseFields.creatorUserFullName,
      lastModifiedUserFullName: baseFields.lastModifiedUserFullName,
      creationTime: baseFields.creationTime,
      lastModificationTime: baseFields.lastModificationTime,
      conditionDisplayName: cmsParseString(json['displayName']),
    );
  }

  final String? conditionDisplayName;

  @override
  String get displayName {
    final trimmedDisplayName = conditionDisplayName?.trim();
    if (trimmedDisplayName != null && trimmedDisplayName.isNotEmpty) {
      return trimmedDisplayName;
    }

    final trimmedName = name?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      return trimmedName;
    }

    return super.displayName;
  }

  @override
  String get sortName => displayName.toLowerCase();

  @override
  Map<String, dynamic> toJson() {
    return {
      ...toJsonBase(),
      'displayName': conditionDisplayName,
    };
  }
}
