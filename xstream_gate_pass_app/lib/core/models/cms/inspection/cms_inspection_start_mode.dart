enum CmsInspectionStartMode {
  defaultMode(
    0,
    'Default',
    'Use the depot\'s normal inspection creation rules.',
    'default inspection',
  ),
  structuralOnly(
    1,
    'Structural only',
    'Create only the structural inspection for this container.',
    'structural inspection',
  ),
  mechanicalOnly(
    2,
    'Mechanical only',
    'Open the mechanical inspection and auto-create its structural parent.',
    'mechanical inspection',
  );

  const CmsInspectionStartMode(
    this.value,
    this.label,
    this.description,
    this.ctaLabel,
  );

  final int value;
  final String label;
  final String description;
  final String ctaLabel;

  bool get isMechanicalOnly => this == CmsInspectionStartMode.mechanicalOnly;
}
