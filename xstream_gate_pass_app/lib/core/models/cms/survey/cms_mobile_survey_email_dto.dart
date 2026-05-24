class CmsMobileSurveyEmailDto {
  const CmsMobileSurveyEmailDto({
    required this.id,
    this.containerNo,
    this.shippingLineId,
  });

  final int id;
  final String? containerNo;
  final int? shippingLineId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'containerNo': containerNo,
      'shippingLineId': shippingLineId,
    };
  }
}
