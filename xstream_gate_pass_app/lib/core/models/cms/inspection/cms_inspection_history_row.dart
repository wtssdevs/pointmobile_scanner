import 'package:intl/intl.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_inspection_state.dart';
import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_type.dart';

/// Mirrors the CMS backend `MobileInspectionHistoryRowDto` for the container
/// detail "Inspections" tab (all inspections, all visits).
class CmsInspectionHistoryRow {
  const CmsInspectionHistoryRow({
    required this.id,
    this.parentId,
    this.transactionNo,
    this.inspectionType,
    this.inspectionTypeName,
    this.inspectionCompleted = false,
    this.state,
    this.inspectionDateTime,
    this.startDateTime,
    this.endDateTime,
    this.inspectedBy,
    this.conditionTypeId,
    this.conditionTypeName,
    this.depotArrivalDateTime,
    this.isCurrentVisit = false,
    this.isPlaceholderStructural = false,
    this.creationTime,
    this.repairStartDate,
    this.repairCompletedDate,
  });

  factory CmsInspectionHistoryRow.fromJson(Map<String, dynamic> json) {
    return CmsInspectionHistoryRow(
      id: cmsParseInt(json['id']) ?? 0,
      parentId: cmsParseInt(json['parentId']),
      transactionNo: cmsParseString(json['transactionNo']),
      inspectionType: CmsInspectionType.fromValue(json['inspectionType']) ?? CmsInspectionType.fromName(json['inspectionTypeName']),
      inspectionTypeName: cmsParseString(json['inspectionTypeName']),
      inspectionCompleted: cmsParseBool(json['inspectionCompleted']) ?? false,
      state: CmsInspectionState.fromValue(json['state']),
      inspectionDateTime: cmsParseDateTime(json['inspectionDateTime']),
      startDateTime: cmsParseDateTime(json['startDateTime']),
      endDateTime: cmsParseDateTime(json['endDateTime']),
      inspectedBy: cmsParseString(json['inspectedBy']),
      conditionTypeId: cmsParseInt(json['conditionTypeId']),
      conditionTypeName: cmsParseString(json['conditionTypeName']),
      depotArrivalDateTime: cmsParseDateTime(json['depotArrivalDateTime']),
      isCurrentVisit: cmsParseBool(json['isCurrentVisit']) ?? false,
      isPlaceholderStructural: cmsParseBool(json['isPlaceholderStructural']) ?? false,
      creationTime: cmsParseDateTime(json['creationTime']),
      repairStartDate: cmsParseDateTime(json['repairStartDate']),
      repairCompletedDate: cmsParseDateTime(json['repairCompletedDate']),
    );
  }

  final int id;
  final int? parentId;
  final String? transactionNo;
  final CmsInspectionType? inspectionType;
  final String? inspectionTypeName;
  final bool inspectionCompleted;
  final CmsInspectionState? state;
  final DateTime? inspectionDateTime;
  final DateTime? startDateTime;
  final DateTime? endDateTime;
  final String? inspectedBy;
  final int? conditionTypeId;
  final String? conditionTypeName;
  final DateTime? depotArrivalDateTime;
  final bool isCurrentVisit;
  final bool isPlaceholderStructural;
  final DateTime? creationTime;
  final DateTime? repairStartDate;
  final DateTime? repairCompletedDate;

  /// True when the row is an open inspection that can be resumed/edited.
  bool get isOpen => !inspectionCompleted && state != CmsInspectionState.cancelled && !isPlaceholderStructural;

  String get typeLabel {
    final trimmed = inspectionTypeName?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      return trimmed;
    }

    return inspectionType?.label ?? 'Inspection';
  }

  String get statusLabel {
    if (state != null) {
      return state!.label;
    }

    return inspectionCompleted ? 'Completed' : 'In progress';
  }

  String get dateLine {
    final date = inspectionDateTime ?? startDateTime ?? endDateTime;
    if (date == null) {
      return '';
    }

    return DateFormat('dd MMM yyyy HH:mm').format(date);
  }

  String get byLine {
    final by = inspectedBy?.trim();
    if (by == null || by.isEmpty) {
      return '';
    }

    return 'By $by';
  }
}
