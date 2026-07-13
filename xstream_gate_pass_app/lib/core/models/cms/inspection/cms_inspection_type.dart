import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';

enum CmsInspectionType {
  structural(0, 'Structural'),
  mechanical(1, 'Mechanical');

  const CmsInspectionType(this.value, this.label);

  final int value;
  final String label;

  bool get isStructural => this == CmsInspectionType.structural;
  bool get isMechanical => this == CmsInspectionType.mechanical;

  static CmsInspectionType? fromValue(dynamic value) {
    final parsedValue = cmsParseInt(value);
    if (parsedValue == null) {
      return null;
    }

    for (final inspectionType in CmsInspectionType.values) {
      if (inspectionType.value == parsedValue) {
        return inspectionType;
      }
    }

    return null;
  }

  static CmsInspectionType? fromName(dynamic value) {
    final parsedValue = cmsParseString(value)?.trim().toLowerCase().replaceAll(' ', '');
    switch (parsedValue) {
      case 'structural':
        return CmsInspectionType.structural;
      case 'mechanical':
        return CmsInspectionType.mechanical;
      default:
        return null;
    }
  }
}
