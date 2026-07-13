class CmsCompleteInspectionInput {
  const CmsCompleteInspectionInput({
    required this.inspectionId,
    this.comments,
    this.inspectionDateTime,
  });

  final int inspectionId;
  final String? comments;
  final DateTime? inspectionDateTime;

  Map<String, dynamic> toJson() {
    return {
      'inspectionId': inspectionId,
      'comments': comments,
      'inspectionDateTime': inspectionDateTime?.toIso8601String(),
    };
  }
}
