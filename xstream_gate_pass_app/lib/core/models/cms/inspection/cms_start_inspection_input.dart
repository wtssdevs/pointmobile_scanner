import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_type.dart';

class CmsStartInspectionInput {
  const CmsStartInspectionInput({
    required this.id,
    required this.inspectionType,
    required this.conditionTypeId,
    this.conditionName,
    this.conditionDisplayName,
  });

  final int id;
  final CmsInspectionType inspectionType;
  final int conditionTypeId;
  final String? conditionName;
  final String? conditionDisplayName;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inspectionType': inspectionType.value,
      'conditionTypeId': conditionTypeId,
    };
  }
}
