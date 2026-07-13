import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_start_mode.dart';

class CmsStartInspectionInput {
  const CmsStartInspectionInput({
    required this.containerId,
    required this.mode,
    required this.conditionTypeId,
    this.conditionName,
    this.conditionDisplayName,
  });

  final int containerId;
  final CmsInspectionStartMode mode;
  final int conditionTypeId;
  final String? conditionName;
  final String? conditionDisplayName;

  Map<String, dynamic> toJson() {
    return {
      'containerId': containerId,
      'mode': mode.value,
      'conditionTypeId': conditionTypeId,
    };
  }
}
