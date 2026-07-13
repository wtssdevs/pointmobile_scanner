import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';

class CmsStartInspectionResult {
  const CmsStartInspectionResult({
    required this.entryInspectionId,
    required this.structuralInspectionId,
    this.mechanicalInspectionId,
    this.structuralTransactionNo,
    this.mechanicalTransactionNo,
    this.placeholderStructuralCreated = false,
  });

  factory CmsStartInspectionResult.fromJson(Map<String, dynamic> json) {
    return CmsStartInspectionResult(
      entryInspectionId: cmsParseInt(json['entryInspectionId']) ?? 0,
      structuralInspectionId: cmsParseInt(json['structuralInspectionId']) ?? 0,
      mechanicalInspectionId: cmsParseInt(json['mechanicalInspectionId']),
      structuralTransactionNo: cmsParseString(json['structuralTransactionNo']),
      mechanicalTransactionNo: cmsParseString(json['mechanicalTransactionNo']),
      placeholderStructuralCreated: cmsParseBool(json['placeholderStructuralCreated']) ?? false,
    );
  }

  final int entryInspectionId;
  final int structuralInspectionId;
  final int? mechanicalInspectionId;
  final String? structuralTransactionNo;
  final String? mechanicalTransactionNo;
  final bool placeholderStructuralCreated;
}
