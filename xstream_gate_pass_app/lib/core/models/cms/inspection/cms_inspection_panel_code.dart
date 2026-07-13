enum CmsInspectionPanelCode {
  rightSide('RSD', 'Right side', 'R', 'panel_RSD', ['RIGHT', 'RIGHT SIDE']),
  leftSide('LSD', 'Left side', 'L', 'panel_LSD', ['LEFT', 'LEFT SIDE']),
  roofTop('RFT', 'Roof / top', 'T', 'panel_RFT', ['TOP', 'ROOF']),
  bottomFloor('FLR', 'Bottom / floor', 'B', 'panel_FLR', ['BOTTOM', 'FLOOR']),
  frontNose('FNT', 'Front / nose', 'F', 'panel_FNT', ['FRONT', 'FRONT PANEL']),
  doorRear('DOR', 'Door / rear', 'D', 'panel_DOR', ['DOOR', 'DOOR PANEL', 'DOOR (BOTTOM)', 'DOOR (TOP)']),
  interior('INT', 'Interior', 'I', 'panel_INT', ['INTERIOR']),
  exteriorShell('EXT', 'Exterior shell', 'E', 'panel_EXT', ['EXTERIOR']),
  underStructure('UND', 'Under-structure', 'U', 'panel_UND', ['UNDER-STRUCTURE', 'UNDERSTRUCTURE', 'GROSSMEMBER']),
  wholeContainer('WHL', 'Whole container', 'X', 'panel_WHL', ['OTHER']);

  const CmsInspectionPanelCode(
    this.code,
    this.label,
    this.cedexPrefix,
    this.svgElementId,
    this.fallbackLocationNames,
  );

  final String code;
  final String label;
  final String cedexPrefix;
  final String svgElementId;
  final List<String> fallbackLocationNames;

  static CmsInspectionPanelCode? fromCode(String? code) {
    final normalized = code?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    for (final value in CmsInspectionPanelCode.values) {
      if (value.code == normalized) {
        return value;
      }
    }

    return null;
  }

  bool matchesLocation({String? code, String? name}) {
    final normalizedCode = code?.trim().toUpperCase() ?? '';
    final normalizedName = name?.trim().toUpperCase() ?? '';

    return normalizedCode.startsWith(cedexPrefix) || fallbackLocationNames.any((fallback) => normalizedName.contains(fallback));
  }
}
