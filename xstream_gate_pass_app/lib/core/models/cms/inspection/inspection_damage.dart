import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_lookup_base.dart';

class InspectionDamage extends CmsInspectionLookupBase {
  const InspectionDamage({
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
  });

  factory InspectionDamage.fromJson(Map<String, dynamic> json) {
    final fields = CmsInspectionLookupBase.parseBaseFields(json);
    return InspectionDamage(
      id: fields.id,
      tenantId: fields.tenantId,
      name: fields.name,
      code: fields.code,
      altCode: fields.altCode,
      isActive: fields.isActive,
      postingCodeId: fields.postingCodeId,
      postingCodeName: fields.postingCodeName,
      shippingLineId: fields.shippingLineId,
      shippingLineName: fields.shippingLineName,
      creatorUserFullName: fields.creatorUserFullName,
      lastModifiedUserFullName: fields.lastModifiedUserFullName,
      creationTime: fields.creationTime,
      lastModificationTime: fields.lastModificationTime,
    );
  }

  Map<String, dynamic> toJson() => toJsonBase();
}
