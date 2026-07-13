import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_lookup_base.dart';

class CmsItemCode extends CmsInspectionLookupBase {
  const CmsItemCode({
    int? id,
    int? tenantId,
    String? code,
    this.description,
    this.quantity,
    this.unitPrice,
    this.labourRate,
    this.grossWeight,
  }) : super(
          id: id,
          tenantId: tenantId,
          code: code,
          name: description,
        );

  factory CmsItemCode.fromJson(Map<String, dynamic> json) {
    final description = cmsParseString(json['description']);
    return CmsItemCode(
      id: cmsParseInt(json['id']),
      tenantId: cmsParseInt(json['tenantId']),
      code: cmsParseString(json['code']),
      description: description,
      quantity: cmsParseDouble(json['quantity']),
      unitPrice: cmsParseDouble(json['unitPrice']),
      labourRate: cmsParseDouble(json['labourRate']),
      grossWeight: cmsParseDouble(json['grossWeight']),
    );
  }

  final String? description;
  final double? quantity;
  final double? unitPrice;
  final double? labourRate;
  final double? grossWeight;

  @override
  Map<String, dynamic> toJson() {
    final map = toJsonBase();
    map['description'] = description;
    map['quantity'] = quantity;
    map['unitPrice'] = unitPrice;
    map['labourRate'] = labourRate;
    map['grossWeight'] = grossWeight;
    return map;
  }
}
