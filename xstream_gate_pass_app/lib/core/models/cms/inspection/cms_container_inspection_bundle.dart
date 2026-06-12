import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_type.dart';

class CmsContainerInspectionBundle {
  const CmsContainerInspectionBundle({
    required this.containerId,
    required this.containerNo,
    required this.transactionNo,
    this.depotArrivalDateTime,
    this.statusId,
    this.statusName,
    this.statusDisplayName,
    this.conditionTypeId,
    this.conditionTypeName,
    this.shippingLineId,
    this.shippingLineCode,
    this.shippingLineName,
    this.containerSize,
    this.containerType,
    this.containerIsoType,
    this.depotId,
    this.isReefer = false,
    this.canStartInspection = false,
    this.canResumeInspection = false,
    this.resumeInspectionId,
    this.resumeInspectionTypeName,
    this.inspections = const <CmsContainerInspectionRow>[],
  });

  factory CmsContainerInspectionBundle.fromJson(Map<String, dynamic> json) {
    return CmsContainerInspectionBundle(
      containerId: cmsParseInt(json['containerId']) ?? 0,
      containerNo: cmsParseString(json['containerNo']) ?? '',
      transactionNo: cmsParseString(json['transactionNo']) ?? '',
      depotArrivalDateTime: cmsParseDateTime(json['depotArrivalDateTime']),
      statusId: cmsParseInt(json['statusId']),
      statusName: cmsParseString(json['statusName']),
      statusDisplayName: cmsParseString(json['statusDisplayName']),
      conditionTypeId: cmsParseInt(json['conditionTypeId']),
      conditionTypeName: cmsParseString(json['conditionTypeName']),
      shippingLineId: cmsParseInt(json['shippingLineId']),
      shippingLineCode: cmsParseString(json['shippingLineCode']),
      shippingLineName: cmsParseString(json['shippingLineName']),
      containerSize: cmsParseString(json['containerSize']),
      containerType: cmsParseString(json['containerType']),
      containerIsoType: cmsParseString(json['containerIsoType']),
      depotId: cmsParseInt(json['depotId']),
      isReefer: cmsParseBool(json['isReefer']) ?? false,
      canStartInspection: cmsParseBool(json['canStartInspection']) ?? false,
      canResumeInspection: cmsParseBool(json['canResumeInspection']) ?? false,
      resumeInspectionId: cmsParseInt(json['resumeInspectionId']),
      resumeInspectionTypeName: cmsParseString(json['resumeInspectionTypeName']),
      inspections: cmsParseMapList(json['inspections']).map(CmsContainerInspectionRow.fromJson).toList(growable: false),
    );
  }

  final int containerId;
  final String containerNo;
  final String transactionNo;
  final DateTime? depotArrivalDateTime;
  final int? statusId;
  final String? statusName;
  final String? statusDisplayName;
  final int? conditionTypeId;
  final String? conditionTypeName;
  final int? shippingLineId;
  final String? shippingLineCode;
  final String? shippingLineName;
  final String? containerSize;
  final String? containerType;
  final String? containerIsoType;
  final int? depotId;
  final bool isReefer;
  final bool canStartInspection;
  final bool canResumeInspection;
  final int? resumeInspectionId;
  final String? resumeInspectionTypeName;
  final List<CmsContainerInspectionRow> inspections;

  List<CmsContainerInspectionRow> get visibleInspections =>
      inspections.where((inspection) => !inspection.isPlaceholderStructural).toList(growable: false);

  bool get hasExistingInspections => visibleInspections.isNotEmpty;

  String get statusLabel {
    final display = statusDisplayName?.trim();
    if (display != null && display.isNotEmpty) {
      return display;
    }

    final name = statusName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    return 'Empty';
  }

  String? get shippingLineLabel {
    for (final value in [shippingLineCode, shippingLineName]) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return null;
  }

  String get containerTypeLine {
    return [containerSize, containerType, containerIsoType]
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .join(' • ');
  }

  CmsInspectionType? get resumeInspectionType => CmsInspectionType.fromName(resumeInspectionTypeName);

  String get resumeInspectionTypeLabel =>
      resumeInspectionTypeName?.trim().isNotEmpty == true ? resumeInspectionTypeName!.trim() : (resumeInspectionType?.label ?? 'Inspection');
}

class CmsContainerInspectionRow {
  const CmsContainerInspectionRow({
    required this.id,
    this.parentId,
    this.transactionNo,
    this.inspectionType,
    this.inspectionTypeName,
    this.inspectionCompleted = false,
    this.conditionTypeId,
    this.conditionTypeName,
    this.creationTime,
    this.isPlaceholderStructural = false,
  });

  factory CmsContainerInspectionRow.fromJson(Map<String, dynamic> json) {
    return CmsContainerInspectionRow(
      id: cmsParseInt(json['id']) ?? 0,
      parentId: cmsParseInt(json['parentId']),
      transactionNo: cmsParseString(json['transactionNo']),
      inspectionType: CmsInspectionType.fromValue(json['inspectionType']) ?? CmsInspectionType.fromName(json['inspectionTypeName']),
      inspectionTypeName: cmsParseString(json['inspectionTypeName']),
      inspectionCompleted: cmsParseBool(json['inspectionCompleted']) ?? false,
      conditionTypeId: cmsParseInt(json['conditionTypeId']),
      conditionTypeName: cmsParseString(json['conditionTypeName']),
      creationTime: cmsParseDateTime(json['creationTime']),
      isPlaceholderStructural: cmsParseBool(json['isPlaceholderStructural']) ?? false,
    );
  }

  final int id;
  final int? parentId;
  final String? transactionNo;
  final CmsInspectionType? inspectionType;
  final String? inspectionTypeName;
  final bool inspectionCompleted;
  final int? conditionTypeId;
  final String? conditionTypeName;
  final DateTime? creationTime;
  final bool isPlaceholderStructural;

  String get inspectionTypeLabel {
    final trimmed = inspectionTypeName?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }

    return inspectionType?.label ?? 'Inspection';
  }

  String get statusLabel => inspectionCompleted ? 'Completed' : 'In progress';
}
