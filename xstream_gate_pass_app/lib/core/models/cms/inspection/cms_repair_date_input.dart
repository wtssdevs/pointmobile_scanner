class CmsRepairDateInput {
  const CmsRepairDateInput({
    required this.inspectionId,
    this.setStart = false,
    this.setComplete = false,
  });

  final int inspectionId;
  final bool setStart;
  final bool setComplete;

  Map<String, dynamic> toJson() {
    return {
      'inspectionId': inspectionId,
      'setStart': setStart,
      'setComplete': setComplete,
    };
  }
}
