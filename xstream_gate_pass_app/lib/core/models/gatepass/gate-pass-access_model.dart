import 'dart:convert';

import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';

import '../../utils/helper.dart';

enum GatePassBookingType {
  none(0, "None"),
  breakBulk(1, "Break Bulk"),
  containers(2, "Containers"),
  other(3, "Other");

  final int value;
  final String text;
  const GatePassBookingType(this.value, this.text);
}

enum DeliveryType {
  receive(0, "Receive"),
  dispatch(1, "Dispatch"),
  other(2, "Other");

  final int value;
  final String text;
  const DeliveryType(this.value, this.text);
}

enum GatePassContainerType {
  none(0, "None"),
  empty(1, "Empty"),
  unpackFull(2, "Unpack Full"),
  storeFull(3, "Store Full");

  final int value;
  final String text;
  const GatePassContainerType(this.value, this.text);
}

class GatePassAccess {
  String id;
  DateTime? creationTime;
  int? creatorUserId;
  DateTime? lastModificationTime;
  int? lastModifierUserId;
  bool isDeleted = false;
  int? deleterUserId;
  DateTime? deletionTime;
  String? createdByUser;
  String? lastModifiedByUser;
  String? deletedByUser;
  String? externalKey;
  int tenantId;
  String? extensionData;
  String? concurrencyStamp;
  bool isActive = true;
  bool canRelease;
  DateTime? timeAtGate;
  DateTime? timeIn;
  DateTime? timeOut;
  int? timeInYardDuration;
  GatePassStatus gatePassStatus;
  DeliveryType gatePassDeliveryType;
  GatePassBookingType gatePassBookingType;
  String? vehicleRegNumber;
  String? vehicleRegNumberValidation;
  String? trailerRegNumberOne;
  String? trailerRegNumberTwo;
  String? logisticRefNumber;
  String? siNumber;
  String? customerRefNo;
  String? transactionNo;
  String? gatePassCode;
  String? voyageNo;
  String? ticketNo;
  String? refNo;
  bool isHazardous = false;
  String? driverName;
  String? driverIdNo;
  String? driverLicenceNo;
  String? driversLicenceCodes;
  DateTime? professionalDrivingPermitExpiryDate;
  DateTime? driverLicenceIssueDate;
  DateTime? driverLicenceExpiryDate;
  String? vehicleRegisterNumber;
  String? vehicleVinNumber;
  String? vehicleEngineNumber;
  String? vehicleMake;
  String? vehicleCategory;
  int? vehicleTare;
  String? warehouseCode;
  String? comments;
  String? rejectReason;
  bool hasBeenPrinted = false;
  String? externalId;
  double? grossWeightIn;
  double? grossWeightOut;
  double? tareWeightIn;
  double? tareWeightOut;
  double? netWeightIn;
  double? netWeightOut;
  double? varianceIn;
  double? varianceOut;
  double? productVariance;
  double? totalProductGrossWeight;
  int? transporterId;
  int? customerId;
  int branchId;
  String? branchName;
  String? customerName;
  String? transporterName;
  String? containerId;
  String? containerNumber;
  String? containerSize;
  String? containerType;
  String? containerCustomer;
  String? containerShippingLine;
  String? containerDepot;
  DeliveryType? containerDeliveryType;
  GatePassContainerType? gatePassContainerType;

  GatePassAccess({
    required this.id,
    this.creationTime,
    this.creatorUserId,
    this.lastModificationTime,
    this.lastModifierUserId,
    this.isDeleted = false,
    this.deleterUserId,
    this.deletionTime,
    this.createdByUser,
    this.lastModifiedByUser,
    this.deletedByUser,
    this.externalKey,
    this.tenantId = 0,
    this.extensionData,
    this.concurrencyStamp,
    this.isActive = true,
    this.canRelease = false,
    this.timeAtGate,
    this.timeIn,
    this.timeOut,
    this.timeInYardDuration,
    required this.gatePassStatus,
    required this.gatePassDeliveryType,
    required this.gatePassBookingType,
    this.vehicleRegNumber,
    this.vehicleRegNumberValidation,
    this.trailerRegNumberOne,
    this.trailerRegNumberTwo,
    this.logisticRefNumber,
    this.siNumber,
    this.customerRefNo,
    this.transactionNo,
    this.gatePassCode,
    this.voyageNo,
    this.ticketNo,
    this.refNo,
    this.isHazardous = false,
    this.driverName,
    this.driverIdNo,
    this.driverLicenceNo,
    this.driversLicenceCodes,
    this.professionalDrivingPermitExpiryDate,
    this.driverLicenceIssueDate,
    this.driverLicenceExpiryDate,
    this.vehicleRegisterNumber,
    this.vehicleVinNumber,
    this.vehicleEngineNumber,
    this.vehicleMake,
    this.vehicleCategory,
    this.vehicleTare,
    this.warehouseCode,
    this.comments,
    this.rejectReason,
    this.hasBeenPrinted = false,
    this.externalId,
    this.grossWeightIn,
    this.grossWeightOut,
    this.tareWeightIn,
    this.tareWeightOut,
    this.netWeightIn,
    this.netWeightOut,
    this.varianceIn,
    this.varianceOut,
    this.productVariance,
    this.totalProductGrossWeight,
    this.transporterId,
    this.customerId,
    required this.branchId,
    this.branchName,
    this.customerName,
    this.transporterName,
    this.containerId,
    this.containerNumber,
    this.containerSize,
    this.containerType,
    this.containerCustomer,
    this.containerShippingLine,
    this.containerDepot,
    this.containerDeliveryType,
    this.gatePassContainerType,
  });

  //factory GatePassAccess.fromJson(String str) => GatePassAccess.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GatePassAccess.fromJson(Map<String, dynamic> json) => GatePassAccess(
        id: json["id"],
        creationTime: json["creationTime"] != null ? DateTime.parse(json["creationTime"]) : null,
        lastModificationTime: json["lastModificationTime"] != null ? DateTime.parse(json["lastModificationTime"]) : null,
        creatorUserId: json["creatorUserId"],
        lastModifierUserId: json["lastModifierUserId"],
        isDeleted: json["isDeleted"],
        deleterUserId: json["deleterUserId"],
        deletionTime: json["deletionTime"] != null ? DateTime.parse(json["deletionTime"]) : null,
        createdByUser: json["createdByUser"] ?? "",
        lastModifiedByUser: json["lastModifiedByUser"] ?? "",
        deletedByUser: json["deletedByUser"] ?? "",
        externalKey: json["externalKey"] ?? "",
        tenantId: json["tenantId"] ?? 0,
        extensionData: json["extensionData"],
        concurrencyStamp: json["concurrencyStamp"],
        isActive: json["isActive"],
        canRelease: json["canRelease"],
        timeAtGate: json["timeAtGate"] != null ? DateTime.parse(json["timeAtGate"]) : null,
        timeIn: json["timeIn"] != null ? DateTime.parse(json["timeIn"]) : null,
        timeOut: json["timeOut"] != null ? DateTime.parse(json["timeOut"]) : null,
        timeInYardDuration: json["timeInYardDuration"],
        gatePassStatus: GatePassStatus.values[asT<int>(json['gatePassStatus']) ?? 0],
        gatePassDeliveryType: DeliveryType.values[asT<int>(json['gatePassDeliveryType']) ?? 0],
        gatePassBookingType: GatePassBookingType.values[asT<int>(json['gatePassBookingType']) ?? 0],
        vehicleRegNumber: json["vehicleRegNumber"],
        //vehicleRegNumberValidation
        trailerRegNumberOne: json["trailerRegNumberOne"],
        trailerRegNumberTwo: json["trailerRegNumberTwo"],
        logisticRefNumber: json["logisticRefNumber"],
        siNumber: json["siNumber"],
        customerRefNo: json["customerRefNo"],
        transactionNo: json["transactionNo"],
        gatePassCode: json["gatePassCode"],
        voyageNo: json["voyageNo"],
        ticketNo: json["ticketNo"],
        refNo: json["refNo"],
        isHazardous: json["isHazardous"],
        driverName: json["driverName"],
        driverIdNo: json["driverIdNo"],
        driverLicenceNo: json["driverLicenceNo"],
        driversLicenceCodes: json["driversLicenceCodes"],
        professionalDrivingPermitExpiryDate: json["professionalDrivingPermitExpiryDate"] != null ? DateTime.parse(json["professionalDrivingPermitExpiryDate"]) : null,
        driverLicenceIssueDate: json["driverLicenceIssueDate"] != null ? DateTime.parse(json["driverLicenceIssueDate"]) : null,
        driverLicenceExpiryDate: json["driverLicenceExpiryDate"] != null ? DateTime.parse(json["driverLicenceExpiryDate"]) : null,
        vehicleRegisterNumber: json["vehicleRegisterNumber"],
        vehicleVinNumber: json["vehicleVinNumber"],
        vehicleEngineNumber: json["vehicleEngineNumber"],
        vehicleMake: json["vehicleMake"],
        vehicleCategory: json["vehicleCategory"],
        vehicleTare: json["vehicleTare"],
        warehouseCode: json["warehouseCode"],
        comments: json["comments"],
        rejectReason: json["rejectReason"],
        hasBeenPrinted: json["hasBeenPrinted"],
        externalId: json["externalId"],
        grossWeightIn: json["grossWeightIn"] ?? 0,
        grossWeightOut: json["grossWeightOut"] ?? 0,
        tareWeightIn: json["tareWeightIn"] ?? 0,
        tareWeightOut: json["tareWeightOut"] ?? 0,
        netWeightIn: json["netWeightIn"] ?? 0,
        netWeightOut: json["netWeightOut"] ?? 0,
        varianceIn: json["varianceIn"] ?? 0,
        varianceOut: json["varianceOut"] ?? 0,
        productVariance: json["productVariance"] ?? 0,
        totalProductGrossWeight: json["totalProductGrossWeight"] ?? 0,
        transporterId: json["transporterId"],
        customerId: json["customerId"],
        branchId: json["branchId"],
        branchName: json["branchName"],
        customerName: json["customerName"],
        transporterName: json["transporterName"],
        containerId: json["containerId"],
        containerNumber: json["containerNumber"],
        containerSize: json["containerSize"],
        containerType: json["containerType"],
        containerCustomer: json["containerCustomer"],
        containerShippingLine: json["containerShippingLine"],
        containerDepot: json["containerDepot"],
        containerDeliveryType: DeliveryType.values[asT<int?>(json['containerDeliveryType']) ?? 0],
        gatePassContainerType: GatePassContainerType.values[asT<int?>(json['gatePassContainerType']) ?? 0],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "creationTime": creationTime?.toIso8601String(),
        "creatorUserId": creatorUserId,
        "lastModificationTime": lastModificationTime?.toIso8601String(),
        "lastModifierUserId": lastModifierUserId,
        "isDeleted": isDeleted,
        "deleterUserId": deleterUserId,
        "deletionTime": deletionTime?.toIso8601String(),
        "createdByUser": createdByUser,
        "lastModifiedByUser": lastModifiedByUser,
        "deletedByUser": deletedByUser,
        "externalKey": externalKey,
        "tenantId": tenantId,
        "extensionData": extensionData,
        "concurrencyStamp": concurrencyStamp,
        "isActive": isActive,
        "canRelease": canRelease,
        "timeAtGate": timeAtGate?.toIso8601String(),
        "timeIn": timeIn?.toIso8601String(),
        "timeOut": timeOut?.toIso8601String(),
        "timeInYardDuration": timeInYardDuration,
        "gatePassStatus": gatePassStatus,
        "gatePassDeliveryType": gatePassDeliveryType,
        "gatePassBookingType": gatePassBookingType,
        "vehicleRegNumber": vehicleRegNumber,
        "vehicleRegNumberValidation": vehicleRegNumberValidation,
        "trailerRegNumberOne": trailerRegNumberOne,
        "trailerRegNumberTwo": trailerRegNumberTwo,
        "logisticRefNumber": logisticRefNumber,
        "siNumber": siNumber,
        "customerRefNo": customerRefNo,
        "transactionNo": transactionNo,
        "gatePassCode": gatePassCode,
        "voyageNo": voyageNo,
        "ticketNo": ticketNo,
        "refNo": refNo,
        "isHazardous": isHazardous,
        "driverName": driverName,
        "driverIdNo": driverIdNo,
        "driverLicenceNo": driverLicenceNo,
        "driversLicenceCodes": driversLicenceCodes,
        "professionalDrivingPermitExpiryDate": professionalDrivingPermitExpiryDate?.toIso8601String(),
        "driverLicenceIssueDate": driverLicenceIssueDate?.toIso8601String(),
        "driverLicenceExpiryDate": driverLicenceExpiryDate?.toIso8601String(),
        "vehicleRegisterNumber": vehicleRegisterNumber,
        "vehicleVinNumber": vehicleVinNumber,
        "vehicleEngineNumber": vehicleEngineNumber,
        "vehicleMake": vehicleMake,
        "vehicleCategory": vehicleCategory,
        "vehicleTare": vehicleTare,
        "warehouseCode": warehouseCode,
        "comments": comments,
        "rejectReason": rejectReason,
        "hasBeenPrinted": hasBeenPrinted,
        "externalId": externalId,
        "grossWeightIn": grossWeightIn,
        "grossWeightOut": grossWeightOut,
        "tareWeightIn": tareWeightIn,
        "tareWeightOut": tareWeightOut,
        "netWeightIn": netWeightIn,
        "netWeightOut": netWeightOut,
        "varianceIn": varianceIn,
        "varianceOut": varianceOut,
        "productVariance": productVariance,
        "totalProductGrossWeight": totalProductGrossWeight,
        "transporterId": transporterId,
        "customerId": customerId,
        "branchId": branchId,
        "branchName": branchName,
        "customerName": customerName,
        "transporterName": transporterName,
        "containerId": containerId,
        "containerNumber": containerNumber,
        "containerSize": containerSize,
        "containerType": containerType,
        "containerCustomer": containerCustomer,
        "containerShippingLine": containerShippingLine,
        "containerDepot": containerDepot,
        "containerDeliveryType": containerDeliveryType,
        "gatePassContainerType": gatePassContainerType,
      };
}
