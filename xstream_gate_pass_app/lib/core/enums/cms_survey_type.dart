enum CmsSurveyType {
  container(0, displayName: 'Container'),
  gatePass(1, displayName: 'Gate Pass');

  const CmsSurveyType(this.value, {required this.displayName});

  final int value;
  final String displayName;

  static CmsSurveyType fromValue(dynamic value) {
    final parsed = value is int ? value : int.tryParse(value?.toString() ?? '');
    return CmsSurveyType.values.firstWhere(
      (item) => item.value == parsed,
      orElse: () => CmsSurveyType.container,
    );
  }
}
