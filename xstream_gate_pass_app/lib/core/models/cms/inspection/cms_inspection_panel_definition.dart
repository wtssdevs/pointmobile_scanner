import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_panel_code.dart';

class CmsInspectionPanelDefinition {
  const CmsInspectionPanelDefinition({
    required this.code,
    required this.label,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.matchTerms,
  });

  final String code;
  final String label;
  final double left;
  final double top;
  final double width;
  final double height;
  final List<String> matchTerms;

  double get centerX => left + (width / 2);
  double get centerY => top + (height / 2);
}

class CmsInspectionPanelTapDetails {
  const CmsInspectionPanelTapDetails({
    required this.panel,
    required this.x,
    required this.y,
  });

  final CmsInspectionPanelDefinition panel;
  final double x;
  final double y;

  String get code => panel.code;
  String get label => panel.label;
}

abstract final class CmsInspectionPanels {
  static final CmsInspectionPanelDefinition front = CmsInspectionPanelDefinition(
    code: CmsInspectionPanelCode.frontNose.code,
    label: CmsInspectionPanelCode.frontNose.label,
    left: 0.02,
    top: 0.24,
    width: 0.14,
    height: 0.34,
    matchTerms: CmsInspectionPanelCode.frontNose.fallbackLocationNames,
  );

  static final CmsInspectionPanelDefinition leftSide = CmsInspectionPanelDefinition(
    code: CmsInspectionPanelCode.leftSide.code,
    label: CmsInspectionPanelCode.leftSide.label,
    left: 0.18,
    top: 0.20,
    width: 0.21,
    height: 0.40,
    matchTerms: CmsInspectionPanelCode.leftSide.fallbackLocationNames,
  );

  static final CmsInspectionPanelDefinition interior = CmsInspectionPanelDefinition(
    code: CmsInspectionPanelCode.interior.code,
    label: CmsInspectionPanelCode.interior.label,
    left: 0.41,
    top: 0.24,
    width: 0.18,
    height: 0.32,
    matchTerms: CmsInspectionPanelCode.interior.fallbackLocationNames,
  );

  static final CmsInspectionPanelDefinition rightSide = CmsInspectionPanelDefinition(
    code: CmsInspectionPanelCode.rightSide.code,
    label: CmsInspectionPanelCode.rightSide.label,
    left: 0.61,
    top: 0.20,
    width: 0.21,
    height: 0.40,
    matchTerms: CmsInspectionPanelCode.rightSide.fallbackLocationNames,
  );

  static final CmsInspectionPanelDefinition rear = CmsInspectionPanelDefinition(
    code: CmsInspectionPanelCode.doorRear.code,
    label: CmsInspectionPanelCode.doorRear.label,
    left: 0.84,
    top: 0.24,
    width: 0.14,
    height: 0.34,
    matchTerms: CmsInspectionPanelCode.doorRear.fallbackLocationNames,
  );

  static final CmsInspectionPanelDefinition roof = CmsInspectionPanelDefinition(
    code: CmsInspectionPanelCode.roofTop.code,
    label: CmsInspectionPanelCode.roofTop.label,
    left: 0.28,
    top: 0.03,
    width: 0.44,
    height: 0.14,
    matchTerms: CmsInspectionPanelCode.roofTop.fallbackLocationNames,
  );

  static final CmsInspectionPanelDefinition floor = CmsInspectionPanelDefinition(
    code: CmsInspectionPanelCode.bottomFloor.code,
    label: CmsInspectionPanelCode.bottomFloor.label,
    left: 0.28,
    top: 0.68,
    width: 0.44,
    height: 0.14,
    matchTerms: CmsInspectionPanelCode.bottomFloor.fallbackLocationNames,
  );

  static final List<CmsInspectionPanelDefinition> values = [
    front,
    leftSide,
    interior,
    rightSide,
    rear,
    roof,
    floor,
  ];

  static CmsInspectionPanelDefinition? byCode(String? code) {
    final normalizedCode = _normalizeCode(code);
    if (normalizedCode == null) {
      return null;
    }

    for (final panel in values) {
      if (panel.code == normalizedCode) {
        return panel;
      }
    }

    return null;
  }

  static String? labelForCode(String? code) => byCode(code)?.label;

  static CmsInspectionPanelDefinition? matchLocation({
    String? code,
    String? altCode,
    String? name,
  }) {
    final normalizedValues = [code, altCode, name].map(_normalizeSearch).where((value) => value.isNotEmpty).toList(growable: false);

    if (normalizedValues.isEmpty) {
      return null;
    }

    for (final panel in values) {
      final panelTerms = [panel.code, ...panel.matchTerms].map(_normalizeSearch).where((value) => value.isNotEmpty).toList(growable: false);
      for (final candidate in normalizedValues) {
        if (panelTerms.any((term) => candidate == term || candidate.contains(term) || term.contains(candidate))) {
          return panel;
        }
      }
    }

    return null;
  }

  static CmsInspectionPanelDefinition? fromLine(CmsInspectionLineEdit line) {
    return byCode(line.panelCode) ??
        matchLocation(
          code: line.inspectionLocationCode,
          name: line.inspectionLocationName,
        );
  }

  static String? _normalizeCode(String? value) {
    final trimmed = value?.trim().toUpperCase();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    return trimmed;
  }

  static String _normalizeSearch(String? value) {
    return (value ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }
}
