import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_type.dart';

class CmsInspectionEdit {
  CmsInspectionEdit({
    this.id = 0,
    this.inspectionDateTime,
    this.depotArrivalDateTime,
    this.manufacturedDate,
    this.refNo,
    this.transactionNo,
    this.inspectedBy,
    this.comments,
    this.containerNo,
    this.containerSize,
    this.containerIsoType,
    this.isRfContainer = false,
    this.containterType,
    this.inspectionCompleted = false,
    this.maxGrossWeight,
    this.shippingLineId,
    this.shippingLineName,
    this.transporterName,
    this.conditionTypeId,
    this.conditionName,
    this.conditionDisplayName,
    this.containerId,
    this.repairStartDate,
    this.repairCompletedDate,
    this.depotId,
    this.statusId,
    this.displayStatus,
    this.inspectionType,
    this.inspectionTypeName,
    List<CmsInspectionLineEdit>? items,
  }) : items = items ?? <CmsInspectionLineEdit>[];

  factory CmsInspectionEdit.fromJson(Map<String, dynamic> json) {
    return CmsInspectionEdit(
      id: cmsParseInt(json['id']) ?? 0,
      inspectionDateTime: cmsParseDateTime(json['inspectionDateTime']),
      depotArrivalDateTime: cmsParseDateTime(json['depotArrivalDateTime']),
      manufacturedDate: cmsParseDateTime(json['manufacturedDate']),
      refNo: cmsParseString(json['refNo']),
      transactionNo: cmsParseString(json['transactionNo']),
      inspectedBy: cmsParseString(json['inspectedBy']),
      comments: cmsParseString(json['comments']),
      containerNo: cmsParseString(json['containerNo']),
      containerSize: cmsParseString(json['containerSize']),
      containerIsoType: cmsParseString(json['containerIsoType']) ??
          cmsParseString(json['containerISOType']) ??
          cmsParseString(json['isoType']),
      isRfContainer: cmsParseBool(json['isRFContainer']) ?? false,
      containterType: cmsParseString(json['containterType']) ??
          cmsParseString(json['containerType']),
      inspectionCompleted: cmsParseBool(json['inspectionCompleted']) ?? false,
      maxGrossWeight: cmsParseDouble(json['maxGrossWeight']),
      shippingLineId: cmsParseInt(json['shippingLineID']),
      shippingLineName: cmsParseString(json['shippingLineName']),
      transporterName: cmsParseString(json['transporterName']),
      conditionTypeId: cmsParseInt(json['conditionTypeId']),
      conditionName: cmsParseString(json['conditionName']),
      conditionDisplayName: cmsParseString(json['conditionDisplayName']),
      containerId: cmsParseInt(json['containerId']),
      repairStartDate: cmsParseDateTime(json['repairStartDate']),
      repairCompletedDate: cmsParseDateTime(json['repairCompletedDate']),
      depotId: cmsParseInt(json['depotID']),
      statusId: cmsParseInt(json['statusID']),
      displayStatus: cmsParseString(json['displayStatus']),
      inspectionType: CmsInspectionType.fromValue(json['inspectionType']),
      inspectionTypeName: cmsParseString(json['inspectionTypeName']),
      items: cmsParseMapList(json['items'])
          .map(CmsInspectionLineEdit.fromJson)
          .toList(growable: true),
    );
  }

  int id;
  DateTime? inspectionDateTime;
  DateTime? depotArrivalDateTime;
  DateTime? manufacturedDate;
  String? refNo;
  String? transactionNo;
  String? inspectedBy;
  String? comments;
  String? containerNo;
  String? containerSize;
  String? containerIsoType;
  bool isRfContainer;
  String? containterType;
  bool inspectionCompleted;
  double? maxGrossWeight;
  int? shippingLineId;
  String? shippingLineName;
  String? transporterName;
  int? conditionTypeId;
  String? conditionName;
  String? conditionDisplayName;
  int? containerId;
  DateTime? repairStartDate;
  DateTime? repairCompletedDate;
  int? depotId;
  int? statusId;
  String? displayStatus;
  CmsInspectionType? inspectionType;
  String? inspectionTypeName;
  List<CmsInspectionLineEdit> items;

  String get inspectionTypeLabel {
    final trimmedTypeName = inspectionTypeName?.trim();
    if (trimmedTypeName != null && trimmedTypeName.isNotEmpty) {
      return trimmedTypeName;
    }

    return inspectionType?.label ?? 'Inspection';
  }

  String get conditionLabel {
    final trimmedDisplayName = conditionDisplayName?.trim();
    if (trimmedDisplayName != null && trimmedDisplayName.isNotEmpty) {
      return trimmedDisplayName;
    }

    final trimmedName = conditionName?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      return trimmedName;
    }

    return 'Not set';
  }

  CmsInspectionEdit clone() => CmsInspectionEdit.fromJson(toJson());

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inspectionDateTime': inspectionDateTime?.toIso8601String(),
      'depotArrivalDateTime': depotArrivalDateTime?.toIso8601String(),
      'manufacturedDate': manufacturedDate?.toIso8601String(),
      'refNo': refNo,
      'transactionNo': transactionNo,
      'inspectedBy': inspectedBy,
      'comments': comments,
      'containerNo': containerNo,
      'containerSize': containerSize,
      'containerIsoType': containerIsoType,
      'isRFContainer': isRfContainer,
      'containterType': containterType,
      'inspectionCompleted': inspectionCompleted,
      'maxGrossWeight': maxGrossWeight,
      'shippingLineID': shippingLineId,
      'shippingLineName': shippingLineName,
      'transporterName': transporterName,
      'conditionTypeId': conditionTypeId,
      'conditionName': conditionName,
      'conditionDisplayName': conditionDisplayName,
      'containerId': containerId,
      'repairStartDate': repairStartDate?.toIso8601String(),
      'repairCompletedDate': repairCompletedDate?.toIso8601String(),
      'depotID': depotId,
      'statusID': statusId,
      'displayStatus': displayStatus,
      'inspectionType': inspectionType?.value,
      'inspectionTypeName': inspectionTypeName,
      'items': items.map((item) => item.toJson()).toList(growable: false),
    };
  }
}
