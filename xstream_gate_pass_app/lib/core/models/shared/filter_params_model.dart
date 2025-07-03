import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';

class FilterParams {
  final String? searchQuery;
  final String? sortColumn;
  final String? sortDirection;
  int pageSize;
  int pageNumber;
  int? branchId;
  final String? transactionNo;
  final DateTime? startDate;
  final DateTime? endDate;
  String? voyageNo;
  String? vehicleRegNumber;
  String? containerNumber;

  //checklist

  String? gatePassAccessId;
  String? templateId;
  ChecklistType? checklistType;

  DeliveryType? gateAccessDeliveryType;
  GatePassBookingType? gateAccessBookingType;

  String? previousChecklistId;
  String? containerId;

  FilterParams({
    this.searchQuery,
    this.sortColumn,
    this.sortDirection,
    this.pageSize = 10,
    this.pageNumber = 1,
    this.transactionNo,
    this.startDate,
    this.endDate,
    this.voyageNo,
    this.branchId,
    this.vehicleRegNumber,
    this.containerNumber,
    this.gatePassAccessId,
    this.templateId,
    this.checklistType,
    this.gateAccessDeliveryType,
    this.gateAccessBookingType,
    this.previousChecklistId,
    this.containerId,
  });
  void clear() {
    voyageNo = null;
    vehicleRegNumber = null;
    containerNumber = null;
    gatePassAccessId = null;
    templateId = null;
    checklistType = null;
    gateAccessDeliveryType = null;
    gateAccessBookingType = null;
    previousChecklistId = null;
    containerId = null;
  }

  Map<String, dynamic> toJson() {
    return {
      'searchQuery': searchQuery,
      'sortColumn': sortColumn,
      'sortDirection': sortDirection,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
      'branchId': branchId,
      'transactionNo': transactionNo,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'voyageNo': voyageNo,
      'department': vehicleRegNumber,
      'requestedBy': containerNumber,
      'gatePassAccessId': gatePassAccessId,
      'templateId': templateId,
      'checklistType': checklistType?.value,
      'gateAccessDeliveryType': gateAccessDeliveryType?.value,
      'gateAccessBookingType': gateAccessBookingType?.value,
      'previousChecklistId': previousChecklistId,
      'containerId': containerId,
    }..removeWhere((key, value) => value == null);
  }
}
