import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_panel_code.dart';

enum CmsPanelSeverity {
  pending,
  clean,
  minor,
  major,
}

class CmsPanelCoverage {
  const CmsPanelCoverage({
    required this.lineCount,
    required this.severity,
    this.unclassifiedLineCount = 0,
  });

  const CmsPanelCoverage.pending()
      : lineCount = 0,
        unclassifiedLineCount = 0,
        severity = CmsPanelSeverity.pending;

  final int lineCount;
  final int unclassifiedLineCount;
  final CmsPanelSeverity severity;

  bool get hasLines => lineCount > 0;
  bool get hasUnclassifiedLines => unclassifiedLineCount > 0;
}

class CmsInspectionSubRegion {
  const CmsInspectionSubRegion({
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

  double get area => width * height;

  bool contains(double x, double y) {
    return x >= left && x <= left + width && y >= top && y <= top + height;
  }
}

class CmsInspectionPanelDefinition {
  const CmsInspectionPanelDefinition({
    required this.code,
    required this.label,
    required this.cedexPrefix,
    required this.svgElementId,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.matchTerms,
    this.subtitle,
    this.subRegions = const <CmsInspectionSubRegion>[],
    this.isPrimary = true,
  });

  final String code;
  final String label;
  final String cedexPrefix;
  final String svgElementId;
  final double left;
  final double top;
  final double width;
  final double height;
  final List<String> matchTerms;
  final String? subtitle;
  final List<CmsInspectionSubRegion> subRegions;
  final bool isPrimary;

  double get centerX => left + (width / 2);
  double get centerY => top + (height / 2);
  double get right => left + width;
  double get bottom => top + height;

  CmsInspectionSubRegion? subRegionAt(double localX, double localY) {
    CmsInspectionSubRegion? bestMatch;

    for (final subRegion in subRegions) {
      if (!subRegion.contains(localX, localY)) {
        continue;
      }

      if (bestMatch == null || subRegion.area < bestMatch.area) {
        bestMatch = subRegion;
      }
    }

    return bestMatch;
  }
}

class CmsInspectionPanelTapDetails {
  const CmsInspectionPanelTapDetails({
    required this.panel,
    required this.x,
    required this.y,
    this.localX,
    this.localY,
    this.subRegion,
  });

  factory CmsInspectionPanelTapDetails.center(
    CmsInspectionPanelDefinition panel,
  ) {
    return CmsInspectionPanelTapDetails(
      panel: panel,
      x: panel.centerX,
      y: panel.centerY,
      localX: 0.5,
      localY: 0.5,
    );
  }

  final CmsInspectionPanelDefinition panel;
  final double x;
  final double y;
  final double? localX;
  final double? localY;
  final CmsInspectionSubRegion? subRegion;

  String get code => panel.code;
  String? get subRegionCode => subRegion?.code;
  String get label => subRegion?.label ?? panel.label;
  String get panelLabel => panel.label;
  String get fullLabel =>
      subRegion == null ? panel.label : '${panel.label} • ${subRegion!.label}';
  List<String> get locationMatchTerms =>
      subRegion?.matchTerms ?? panel.matchTerms;
}

abstract final class CmsInspectionPanels {
  static const double viewBoxWidth = 380;
  static const double viewBoxHeight = 252;

  static final CmsInspectionPanelDefinition roof = _primaryPanel(
    CmsInspectionPanelCode.roofTop,
    label: 'Roof',
    subtitle: 'Top exterior · corrugated roof bows',
    x: 92,
    y: 10,
    width: 196,
    height: 40,
  );

  static final CmsInspectionPanelDefinition front = _primaryPanel(
    CmsInspectionPanelCode.frontNose,
    label: 'Front end',
    subtitle: 'Forklift pocket end (FPE)',
    x: 35,
    y: 50,
    width: 57,
    height: 75,
    extraMatchTerms: const ['FPE', 'FORKLIFT POCKET END', 'NOSE'],
  );

  static final CmsInspectionPanelDefinition leftSide = _primaryPanel(
    CmsInspectionPanelCode.leftSide,
    label: 'Left side',
    subtitle: 'Door side (DS) · 4 corrugated panels',
    x: 92,
    y: 50,
    width: 196,
    height: 75,
    extraMatchTerms: const ['DS', 'DOOR SIDE', 'UPPER PANEL', 'LOWER PANEL'],
  );

  static final CmsInspectionPanelDefinition rear = _primaryPanel(
    CmsInspectionPanelCode.doorRear,
    label: 'Rear doors',
    subtitle: 'Door end (DDE) · 2 leaves · 3 hinges each',
    x: 288,
    y: 50,
    width: 57,
    height: 75,
    extraMatchTerms: const ['DDE', 'REAR', 'DOOR END'],
    subRegions: const <CmsInspectionSubRegion>[
      CmsInspectionSubRegion(
        code: 'DHB',
        label: 'Door header bar',
        left: 0,
        top: 0,
        width: 1,
        height: 0.12,
        matchTerms: ['HEADER', 'TOP RAIL', 'DOOR HEADER', 'DHB'],
      ),
      CmsInspectionSubRegion(
        code: 'DSL',
        label: 'Door sill',
        left: 0,
        top: 0.88,
        width: 1,
        height: 0.12,
        matchTerms: ['SILL', 'BOTTOM RAIL', 'DOOR SILL', 'DSL'],
      ),
      CmsInspectionSubRegion(
        code: 'DLR',
        label: 'Door lock rod',
        left: 0.42,
        top: 0.12,
        width: 0.07,
        height: 0.76,
        matchTerms: ['LOCK', 'LOCK ROD', 'ROD', 'DOOR LOCK ROD', 'DLR'],
      ),
      CmsInspectionSubRegion(
        code: 'DLR',
        label: 'Door lock rod',
        left: 0.51,
        top: 0.12,
        width: 0.07,
        height: 0.76,
        matchTerms: ['LOCK', 'LOCK ROD', 'ROD', 'DOOR LOCK ROD', 'DLR'],
      ),
      CmsInspectionSubRegion(
        code: 'DHN',
        label: 'Door hinges',
        left: 0,
        top: 0.12,
        width: 0.18,
        height: 0.76,
        matchTerms: ['HINGE', 'HINGES', 'DOOR HINGE', 'DHN'],
      ),
      CmsInspectionSubRegion(
        code: 'DHN',
        label: 'Door hinges',
        left: 0.82,
        top: 0.12,
        width: 0.18,
        height: 0.76,
        matchTerms: ['HINGE', 'HINGES', 'DOOR HINGE', 'DHN'],
      ),
      CmsInspectionSubRegion(
        code: 'DLF',
        label: 'Door left leaf',
        left: 0.18,
        top: 0.12,
        width: 0.24,
        height: 0.76,
        matchTerms: ['LEFT LEAF', 'LEFT DOOR', 'DOOR LEFT', 'DLF'],
      ),
      CmsInspectionSubRegion(
        code: 'DRD',
        label: 'Door right leaf',
        left: 0.58,
        top: 0.12,
        width: 0.24,
        height: 0.76,
        matchTerms: ['RIGHT LEAF', 'RIGHT DOOR', 'DOOR RIGHT', 'DRD'],
      ),
    ],
  );

  static final CmsInspectionPanelDefinition floor = _primaryPanel(
    CmsInspectionPanelCode.bottomFloor,
    label: 'Floor',
    subtitle: 'Hardwood T-1 · 7 cross-bearers',
    x: 92,
    y: 125,
    width: 196,
    height: 38,
    extraMatchTerms: const ['HARDWOOD', 'CROSS BEARER', 'CB'],
  );

  static final CmsInspectionPanelDefinition rightSide = _primaryPanel(
    CmsInspectionPanelCode.rightSide,
    label: 'Right side',
    subtitle: 'Curb side (CS) · 4 corrugated panels',
    x: 92,
    y: 163,
    width: 196,
    height: 75,
    extraMatchTerms: const ['CS', 'CURB SIDE', 'UPPER PANEL', 'LOWER PANEL'],
  );

  static final CmsInspectionPanelDefinition interior = _fallbackPanel(
    CmsInspectionPanelCode.interior,
    label: 'Interior',
    subtitle: 'Interior fallback location',
  );

  static final CmsInspectionPanelDefinition exteriorShell = _fallbackPanel(
    CmsInspectionPanelCode.exteriorShell,
    label: 'Exterior shell',
    subtitle: 'Exterior fallback location',
  );

  static final CmsInspectionPanelDefinition underStructure = _fallbackPanel(
    CmsInspectionPanelCode.underStructure,
    label: 'Under-structure',
    subtitle: 'Under-structure fallback location',
  );

  static final CmsInspectionPanelDefinition wholeContainer = _fallbackPanel(
    CmsInspectionPanelCode.wholeContainer,
    label: 'Whole container',
    subtitle: 'Whole-container fallback location',
  );

  static final List<CmsInspectionPanelDefinition> values = [
    roof,
    front,
    leftSide,
    rear,
    floor,
    rightSide,
  ];

  static final List<CmsInspectionPanelDefinition> allValues = [
    ...values,
    interior,
    exteriorShell,
    underStructure,
    wholeContainer,
  ];

  static CmsInspectionPanelDefinition? byCode(String? code) {
    final normalizedCode = _normalizeCode(code);
    if (normalizedCode == null) {
      return null;
    }

    for (final panel in allValues) {
      if (panel.code == normalizedCode || panel.cedexPrefix == normalizedCode) {
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
    final exactPanel = byCode(code) ?? byCode(altCode);
    if (exactPanel != null) {
      return exactPanel;
    }

    for (final panel in allValues) {
      final panelCode = CmsInspectionPanelCode.fromCode(panel.code);
      if (panelCode == null) {
        continue;
      }

      if (panelCode.matchesLocation(code: code, name: name) ||
          panelCode.matchesLocation(code: altCode, name: name)) {
        return panel;
      }
    }

    final normalizedValues = [code, altCode, name]
        .map(_normalizeSearch)
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    if (normalizedValues.isEmpty) {
      return null;
    }

    for (final panel in allValues) {
      final panelTerms = [panel.code, ...panel.matchTerms]
          .map(_normalizeSearch)
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
      for (final candidate in normalizedValues) {
        if (panelTerms.any(
          (term) => candidate == term || candidate.contains(term),
        )) {
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

  static CmsInspectionPanelDefinition _primaryPanel(
    CmsInspectionPanelCode panelCode, {
    required String label,
    required String subtitle,
    required double x,
    required double y,
    required double width,
    required double height,
    List<String> extraMatchTerms = const <String>[],
    List<CmsInspectionSubRegion> subRegions = const <CmsInspectionSubRegion>[],
  }) {
    return CmsInspectionPanelDefinition(
      code: panelCode.code,
      label: label,
      cedexPrefix: panelCode.cedexPrefix,
      svgElementId: panelCode.svgElementId,
      left: x / viewBoxWidth,
      top: y / viewBoxHeight,
      width: width / viewBoxWidth,
      height: height / viewBoxHeight,
      matchTerms: [
        ...panelCode.fallbackLocationNames,
        panelCode.cedexPrefix,
        ...extraMatchTerms,
      ],
      subtitle: subtitle,
      subRegions: subRegions,
    );
  }

  static CmsInspectionPanelDefinition _fallbackPanel(
    CmsInspectionPanelCode panelCode, {
    required String label,
    required String subtitle,
  }) {
    return CmsInspectionPanelDefinition(
      code: panelCode.code,
      label: label,
      cedexPrefix: panelCode.cedexPrefix,
      svgElementId: panelCode.svgElementId,
      left: 0.45,
      top: 0.42,
      width: 0.10,
      height: 0.10,
      matchTerms: panelCode.fallbackLocationNames,
      subtitle: subtitle,
      isPrimary: false,
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
    return (value ?? '')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }
}
