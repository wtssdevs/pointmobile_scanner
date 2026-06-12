import 'package:intl/intl.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_inspection_state.dart';
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
    this.isReefer = false,
    this.canStartInspection = false,
    this.canResumeInspection = false,
    this.resumeInspectionId,
    this.resumeInspectionTypeName,
    this.lastInspectionId,
    this.lastInspectionType,
    this.lastInspectionTypeName,
    this.lastInspectionCompleted,
    this.lastInspectionState,
    this.lastInspectionDateTime,
    this.lastInspectionEndDateTime,
    this.lastInspectionInspectedBy,
    this.lastInspectionConditionTypeName,
    this.lastInspectionTransactionNo,
    this.lastInspectionIsCurrentVisit = false,
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
      conditionTypeDisplayName: cmsParseString(json['conditionTypeDisplayName']),
      depotId: cmsParseInt(json['depotId']),
      depotName: cmsParseString(json['depotName']),
      shippingLineId: cmsParseInt(json['shippingLineId']),
      shippingLineCode: cmsParseString(json['shippingLineCode']),
      shippingLineName: cmsParseString(json['shippingLineName']),
      containerSize: cmsParseString(json['containerSize']),
      containerType: cmsParseString(json['containerType']),
      containerIsoType: cmsParseString(json['containerIsoType']),
      depotArrivalDateTime: cmsParseDateTime(json['depotArrivalDateTime']),
      isReefer: cmsParseBool(json['isReefer']) ?? false,
      canStartInspection: cmsParseBool(json['canStartInspection']) ?? false,
      canResumeInspection: cmsParseBool(json['canResumeInspection']) ?? false,
      resumeInspectionId: cmsParseInt(json['resumeInspectionId']),
      resumeInspectionTypeName: cmsParseString(json['resumeInspectionTypeName']),
      lastInspectionId: cmsParseInt(json['lastInspectionId']),
      lastInspectionType: CmsInspectionType.fromValue(json['lastInspectionType']),
      lastInspectionTypeName: cmsParseString(json['lastInspectionTypeName']),
      lastInspectionCompleted: cmsParseBool(json['lastInspectionCompleted']),
      lastInspectionState: CmsInspectionState.fromValue(json['lastInspectionState']),
      lastInspectionDateTime: cmsParseDateTime(json['lastInspectionDateTime']),
      lastInspectionEndDateTime: cmsParseDateTime(json['lastInspectionEndDateTime']),
      lastInspectionInspectedBy: cmsParseString(json['lastInspectionInspectedBy']),
      lastInspectionConditionTypeName: cmsParseString(json['lastInspectionConditionTypeName']),
      lastInspectionTransactionNo: cmsParseString(json['lastInspectionTransactionNo']),
      lastInspectionIsCurrentVisit: cmsParseBool(json['lastInspectionIsCurrentVisit']) ?? false,
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
  final bool isReefer;
  final bool canStartInspection;
  final bool canResumeInspection;
  final int? resumeInspectionId;
  final String? resumeInspectionTypeName;
  final int? lastInspectionId;
  final CmsInspectionType? lastInspectionType;
  final String? lastInspectionTypeName;
  final bool? lastInspectionCompleted;
  final CmsInspectionState? lastInspectionState;
  final DateTime? lastInspectionDateTime;
  final DateTime? lastInspectionEndDateTime;
  final String? lastInspectionInspectedBy;
  final String? lastInspectionConditionTypeName;
  final String? lastInspectionTransactionNo;
  final bool lastInspectionIsCurrentVisit;

  int? get inspectionId => resumeInspectionId;

  CmsInspectionType? get inspectionType => CmsInspectionType.fromName(resumeInspectionTypeName);

  String? get inspectionTypeName => resumeInspectionTypeName;

  String get resumeInspectionTypeLabel {
    final trimmedTypeName = resumeInspectionTypeName?.trim();
    if (trimmedTypeName != null && trimmedTypeName.isNotEmpty) {
      return trimmedTypeName;
    }

    return inspectionType?.label ?? 'Inspection';
  }

  String get inspectionTypeLabel {
    return resumeInspectionTypeLabel;
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

  bool get hasLastInspection => lastInspectionId != null;

  String get lastInspectionSummary {
    final parts = <String>[];

    final typeLabel = lastInspectionType?.label ?? lastInspectionTypeName?.trim();
    if (typeLabel != null && typeLabel.isNotEmpty) {
      parts.add(typeLabel);
    }

    final statusLabel = _lastInspectionStatusLabel;
    if (statusLabel != null && statusLabel.isNotEmpty) {
      parts.add(statusLabel);
    }

    final date = lastInspectionDateTime ?? lastInspectionEndDateTime;
    if (date != null) {
      parts.add(DateFormat('dd MMM yyyy HH:mm').format(date));
    }

    return parts.join(' • ');
  }

  String? get _lastInspectionStatusLabel {
    if (lastInspectionState != null) {
      return lastInspectionState!.label;
    }

    if (lastInspectionCompleted != null) {
      return lastInspectionCompleted! ? 'Completed' : 'In progress';
    }

    return null;
  }

  String get lastInspectionByLine {
    final by = lastInspectionInspectedBy?.trim();
    if (by == null || by.isEmpty) {
      return '';
    }

    return 'By $by';
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
      'isReefer': isReefer,
      'canStartInspection': canStartInspection,
      'canResumeInspection': canResumeInspection,
      'resumeInspectionId': resumeInspectionId,
      'resumeInspectionTypeName': resumeInspectionTypeName,
      'lastInspectionId': lastInspectionId,
      'lastInspectionType': lastInspectionType?.value,
      'lastInspectionTypeName': lastInspectionTypeName,
      'lastInspectionCompleted': lastInspectionCompleted,
      'lastInspectionState': lastInspectionState?.value,
      'lastInspectionDateTime': lastInspectionDateTime?.toIso8601String(),
      'lastInspectionEndDateTime': lastInspectionEndDateTime?.toIso8601String(),
      'lastInspectionInspectedBy': lastInspectionInspectedBy,
      'lastInspectionConditionTypeName': lastInspectionConditionTypeName,
      'lastInspectionTransactionNo': lastInspectionTransactionNo,
      'lastInspectionIsCurrentVisit': lastInspectionIsCurrentVisit,
    };
  }
}
