import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_type.dart';

class CmsInspectableContainer {
  const CmsInspectableContainer({
    required this.containerId,
    required this.containerNo,
    required this.transactionNo,
    this.statusId,
    this.statusName,
    this.statusDisplayName,
    this.conditionTypeId,
    this.conditionTypeName,
    this.conditionTypeDisplayName,
    this.depotId,
    this.depotName,
    this.shippingLineId,
    this.shippingLineCode,
    this.shippingLineName,
    this.containerSize,
    this.containerType,
    this.containerIsoType,
    this.depotArrivalDateTime,
    this.inspectionId,
    this.inspectionTransactionNo,
    this.parentInspectionId,
    this.inspectionType,
    this.inspectionTypeName,
    this.inspectionCompleted = false,
    this.canStartInspection = false,
    this.canResumeInspection = false,
    this.cardStatus = 'Ready',
  });

  factory CmsInspectableContainer.fromJson(Map<String, dynamic> json) {
    return CmsInspectableContainer(
      containerId: cmsParseInt(json['containerId']) ?? 0,
      containerNo: cmsParseString(json['containerNo']) ?? '',
      transactionNo: cmsParseString(json['transactionNo']) ?? '',
      statusId: cmsParseInt(json['statusId']),
      statusName: cmsParseString(json['statusName']),
      statusDisplayName: cmsParseString(json['statusDisplayName']),
      conditionTypeId: cmsParseInt(json['conditionTypeId']),
      conditionTypeName: cmsParseString(json['conditionTypeName']),
      conditionTypeDisplayName:
          cmsParseString(json['conditionTypeDisplayName']),
      depotId: cmsParseInt(json['depotId']),
      depotName: cmsParseString(json['depotName']),
      shippingLineId: cmsParseInt(json['shippingLineId']),
      shippingLineCode: cmsParseString(json['shippingLineCode']),
      shippingLineName: cmsParseString(json['shippingLineName']),
      containerSize: cmsParseString(json['containerSize']),
      containerType: cmsParseString(json['containerType']),
      containerIsoType: cmsParseString(json['containerIsoType']),
      depotArrivalDateTime: cmsParseDateTime(json['depotArrivalDateTime']),
      inspectionId: cmsParseInt(json['inspectionId']),
      inspectionTransactionNo: cmsParseString(json['inspectionTransactionNo']),
      parentInspectionId: cmsParseInt(json['parentInspectionId']),
      inspectionType: CmsInspectionType.fromValue(json['inspectionType']),
      inspectionTypeName: cmsParseString(json['inspectionTypeName']),
      inspectionCompleted: cmsParseBool(json['inspectionCompleted']) ?? false,
      canStartInspection: cmsParseBool(json['canStartInspection']) ?? false,
      canResumeInspection: cmsParseBool(json['canResumeInspection']) ?? false,
      cardStatus: cmsParseString(json['cardStatus']) ?? 'Ready',
    );
  }

  final int containerId;
  final String containerNo;
  final String transactionNo;
  final int? statusId;
  final String? statusName;
  final String? statusDisplayName;
  final int? conditionTypeId;
  final String? conditionTypeName;
  final String? conditionTypeDisplayName;
  final int? depotId;
  final String? depotName;
  final int? shippingLineId;
  final String? shippingLineCode;
  final String? shippingLineName;
  final String? containerSize;
  final String? containerType;
  final String? containerIsoType;
  final DateTime? depotArrivalDateTime;
  final int? inspectionId;
  final String? inspectionTransactionNo;
  final int? parentInspectionId;
  final CmsInspectionType? inspectionType;
  final String? inspectionTypeName;
  final bool inspectionCompleted;
  final bool canStartInspection;
  final bool canResumeInspection;
  final String cardStatus;

  bool get isReady => cardStatus.toLowerCase() == 'ready';
  bool get isInProgress => cardStatus.toLowerCase() == 'inprogress';
  bool get isCompleted => cardStatus.toLowerCase() == 'completed';
  bool get isBlocked => cardStatus.toLowerCase() == 'blocked';
  bool get isStructural => inspectionType?.isStructural ?? false;
  bool get isMechanical => inspectionType?.isMechanical ?? false;

  String get inspectionTypeLabel {
    final trimmedTypeName = inspectionTypeName?.trim();
    if (trimmedTypeName != null && trimmedTypeName.isNotEmpty) {
      return trimmedTypeName;
    }

    return inspectionType?.label ?? 'Inspection';
  }

  String get conditionLabel {
    final trimmedDisplayName = conditionTypeDisplayName?.trim();
    if (trimmedDisplayName != null && trimmedDisplayName.isNotEmpty) {
      return trimmedDisplayName;
    }

    final trimmedName = conditionTypeName?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      return trimmedName;
    }

    final trimmedStatusName = statusDisplayName?.trim();
    if (trimmedStatusName != null && trimmedStatusName.isNotEmpty) {
      return trimmedStatusName;
    }

    return 'Condition pending';
  }

  Map<String, dynamic> toJson() {
    return {
      'containerId': containerId,
      'containerNo': containerNo,
      'transactionNo': transactionNo,
      'statusId': statusId,
      'statusName': statusName,
      'statusDisplayName': statusDisplayName,
      'conditionTypeId': conditionTypeId,
      'conditionTypeName': conditionTypeName,
      'conditionTypeDisplayName': conditionTypeDisplayName,
      'depotId': depotId,
      'depotName': depotName,
      'shippingLineId': shippingLineId,
      'shippingLineCode': shippingLineCode,
      'shippingLineName': shippingLineName,
      'containerSize': containerSize,
      'containerType': containerType,
      'containerIsoType': containerIsoType,
      'depotArrivalDateTime': depotArrivalDateTime?.toIso8601String(),
      'inspectionId': inspectionId,
      'inspectionTransactionNo': inspectionTransactionNo,
      'parentInspectionId': parentInspectionId,
      'inspectionType': inspectionType?.value,
      'inspectionTypeName': inspectionTypeName,
      'inspectionCompleted': inspectionCompleted,
      'canStartInspection': canStartInspection,
      'canResumeInspection': canResumeInspection,
      'cardStatus': cardStatus,
    };
  }
}
