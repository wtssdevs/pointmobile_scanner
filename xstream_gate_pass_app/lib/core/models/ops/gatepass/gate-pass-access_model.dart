import 'dart:convert';

import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';
import 'package:xstream_gate_pass_app/core/models/ops/gatepass/containers/gate_pass_access_container_model.dart';
import 'package:xstream_gate_pass_app/core/models/ops/gatepass/gate_pass_access_visitor_model.dart';

import '../../../utils/helper.dart';

class GatePassAccess {
  String id;
  DateTime? creationTime;
  int? creatorUserId;
  DateTime? lastModificationTime;
  int? lastModifierUserId;
  bool isDeleted = false;
  int? deleterUserId;
  int? serviceTypeId;
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
  String? trailerRegNumberOneValidation;
  String? trailerRegNumberTwo;
  String? trailerRegNumberTwoValidation;

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
  String? driverIdNoValidation;
  bool driverHasForeignID = false;
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
  bool isManualInput = false;
  bool isOverride = false;
  bool? isVehicleManualInput = false;
  bool? isTrailerOneManualInput = false;
  bool? isTrailerTwoManualInput = false;
  bool? isTrailerOneOverride = false;
  bool? isTrailerTwoOverride = false;

//CONTAINERS INFO , NEED TO BE LIST ??

  String? containerId;
  String? containerNumber;
  String? containerSize;
  int? containerSizeId;
  int? containerTypeId;
  String? containerType;
  String? containerCustomer;
  String? containerShippingLine;
  String? containerDepot;
  DeliveryType? containerDeliveryType;
  GatePassContainerType? gatePassContainerType;
  int? containerShippingLineId;
  int? containerCustomerId;
  int? containerDepotId;

  List<GatePassAccessContainerModel>? containers = [];

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
    this.trailerRegNumberOneValidation,
    this.trailerRegNumberTwo,
    this.trailerRegNumberTwoValidation,
    this.serviceTypeId,
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
    this.driverHasForeignID = false,
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
    this.containerSizeId,
    this.containerTypeId,
    this.containerCustomer,
    this.containerShippingLine,
    this.containerDepot,
    this.containerDeliveryType,
    this.gatePassContainerType,
    this.containers,
    this.isManualInput = false,
    this.isOverride = false,
    this.isVehicleManualInput = false,
    this.isTrailerOneManualInput = false,
    this.isTrailerTwoManualInput = false,
    this.isTrailerOneOverride = false,
    this.isTrailerTwoOverride = false,
    this.containerShippingLineId,
    this.containerCustomerId,
    this.containerDepotId,
  });

  bool get hasDriverInfo =>
      driverName != null && driverIdNo != null && driverLicenceNo != null;

  bool get hasVehicleInfo =>
      vehicleRegNumber != null &&
      vehicleMake != null &&
      vehicleVinNumber != null;
  bool get vehicleDiscExpired => hasVehicleInfo;

  bool get vehicleRegNoMatch =>
      vehicleRegNumber != null &&
      vehicleRegNumberValidation != null &&
      vehicleRegNumber?.trim() == vehicleRegNumberValidation?.trim();

  bool get trailerRegNumberOneMatch =>
      trailerRegNumberOne != null &&
      trailerRegNumberOneValidation != null &&
      trailerRegNumberOne?.trim() == trailerRegNumberOneValidation?.trim();
  bool get trailerRegNumberTwoMatch =>
      trailerRegNumberTwo != null &&
      trailerRegNumberTwoValidation != null &&
      trailerRegNumberTwo?.trim() == trailerRegNumberTwoValidation?.trim();

  bool get driverIdNoMatch =>
      driverIdNo != null &&
      driverIdNoValidation != null &&
      driverIdNo?.trim() == driverIdNoValidation?.trim();

  void handleContainers() {
    if (containerId != null) {
      containers = containers ?? [];

      // Find existing container index
      int existingIndex =
          containers!.indexWhere((element) => element.id == containerId);

      if (existingIndex == -1) {
        // Not found, add new container
        containers!.add(
          GatePassAccessContainerModel(
            id: containerId,
            containerNumber: containerNumber,
            containerSize: containerSize,
            containerSizeId: containerSizeId,
            containerType: containerType,
            containerTypeId: containerTypeId,
            containerCustomer: containerCustomer,
            containerShippingLine: containerShippingLine,
            containerDepot: containerDepot,
            containerDeliveryType: containerDeliveryType,
            deliveryType: containerDeliveryType?.value,
            gatePassContainerType: gatePassContainerType,
            gatePassAccessId: id,
            branchId: branchId,
            containerSetNo: 1,
            tenantId: tenantId,
            weight: 0.0,
            shippingLineId: containerShippingLineId,
            customerId: containerCustomerId,
            depotId: containerDepotId,
          ),
        );
      } else {
        // Found, update existing container
        containers![existingIndex] = GatePassAccessContainerModel(
          id: containerId,
          containerNumber: containerNumber,
          containerSize: containerSize,
          containerSizeId: containerSizeId,
          containerType: containerType,
          containerTypeId: containerTypeId,
          containerCustomer: containerCustomer,
          containerShippingLine: containerShippingLine,
          containerDepot: containerDepot,
          containerDeliveryType: containerDeliveryType,
          deliveryType: containerDeliveryType?.value,
          gatePassContainerType: gatePassContainerType,
          gatePassAccessId: id,
          branchId: branchId,
          containerSetNo: 1,
          tenantId: tenantId,
          weight: 0.0,
          shippingLineId: containerShippingLineId,
          customerId: containerCustomerId,
          depotId: containerDepotId,
        );
      }
    }
  }

  String toJson() {
    handleContainers();
    return json.encode(toMap());
  }

  factory GatePassAccess.fromJson(Map<String, dynamic> json) => GatePassAccess(
        id: json["id"],
        creationTime: json["creationTime"] != null
            ? DateTime.parse(json["creationTime"])
            : null,
        lastModificationTime: json["lastModificationTime"] != null
            ? DateTime.parse(json["lastModificationTime"])
            : null,
        creatorUserId: json["creatorUserId"],
        lastModifierUserId: json["lastModifierUserId"],
        isDeleted: json["isDeleted"] ?? false,
        deleterUserId: json["deleterUserId"],
        serviceTypeId: asT<int>(json['serviceTypeId']),
        deletionTime: json["deletionTime"] != null
            ? DateTime.parse(json["deletionTime"])
            : null,
        createdByUser: json["createdByUser"] ?? "",
        lastModifiedByUser: json["lastModifiedByUser"] ?? "",
        deletedByUser: json["deletedByUser"] ?? "",
        externalKey: json["externalKey"] ?? "",
        tenantId: json["tenantId"] ?? 0,
        extensionData: json["extensionData"],
        concurrencyStamp: json["concurrencyStamp"],
        isActive: json["isActive"] ?? false,
        canRelease: json["canRelease"] ?? false,
        timeAtGate: json["timeAtGate"] != null
            ? DateTime.parse(json["timeAtGate"])
            : null,
        timeIn: json["timeIn"] != null ? DateTime.parse(json["timeIn"]) : null,
        timeOut:
            json["timeOut"] != null ? DateTime.parse(json["timeOut"]) : null,
        timeInYardDuration: json["timeInYardDuration"],
        gatePassStatus:
            GatePassStatus.values[asT<int>(json['gatePassStatus']) ?? 0],
        gatePassDeliveryType:
            DeliveryType.values[asT<int>(json['gatePassDeliveryType']) ?? 0],
        gatePassBookingType: GatePassBookingType
            .values[asT<int>(json['gatePassBookingType']) ?? 0],
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
        isHazardous: json["isHazardous"] ?? false,
        driverHasForeignID: json["driverHasForeignID"] ?? false,
        driverName: json["driverName"],
        driverIdNo: json["driverIdNo"],
        driverLicenceNo: json["driverLicenceNo"],
        driversLicenceCodes: json["driversLicenceCodes"],
        professionalDrivingPermitExpiryDate:
            json["professionalDrivingPermitExpiryDate"] != null
                ? DateTime.parse(json["professionalDrivingPermitExpiryDate"])
                : null,
        driverLicenceIssueDate: json["driverLicenceIssueDate"] != null
            ? DateTime.parse(json["driverLicenceIssueDate"])
            : null,
        driverLicenceExpiryDate: json["driverLicenceExpiryDate"] != null
            ? DateTime.parse(json["driverLicenceExpiryDate"])
            : null,
        vehicleRegisterNumber: json["vehicleRegisterNumber"],
        vehicleVinNumber: json["vehicleVinNumber"],
        vehicleEngineNumber: json["vehicleEngineNumber"],
        vehicleMake: json["vehicleMake"],
        vehicleCategory: json["vehicleCategory"],
        vehicleTare: json["vehicleTare"] ?? 0,
        warehouseCode: json["warehouseCode"],
        comments: json["comments"],
        rejectReason: json["rejectReason"],
        hasBeenPrinted: json["hasBeenPrinted"] ?? false,
        isManualInput: json["isManualInput"] ?? false,
        isOverride: json["isOverride"] ?? false,

        externalId: json["externalId"],
        grossWeightIn: json["grossWeightIn"] != null
            ? (json["grossWeightIn"] as num).toDouble()
            : 0.0,
        grossWeightOut: json["grossWeightOut"] != null
            ? (json["grossWeightOut"] as num).toDouble()
            : 0.0,
        tareWeightIn: json["tareWeightIn"] != null
            ? (json["tareWeightIn"] as num).toDouble()
            : 0.0,
        tareWeightOut: json["tareWeightOut"] != null
            ? (json["tareWeightOut"] as num).toDouble()
            : 0.0,
        netWeightIn: json["netWeightIn"] != null
            ? (json["netWeightIn"] as num).toDouble()
            : 0.0,
        netWeightOut: json["netWeightOut"] != null
            ? (json["netWeightOut"] as num).toDouble()
            : 0.0,
        varianceIn: json["varianceIn"] != null
            ? (json["varianceIn"] as num).toDouble()
            : 0.0,
        varianceOut: json["varianceOut"] != null
            ? (json["varianceOut"] as num).toDouble()
            : 0.0,
        productVariance: json["productVariance"] != null
            ? (json["productVariance"] as num).toDouble()
            : 0.0,
        totalProductGrossWeight: json["totalProductGrassWeightIn"] != null
            ? (json["totalProductGrossWeight"] as num).toDouble()
            : 0.0,
        transporterId: json["transporterId"],
        customerId: json["customerId"],
        branchId: json["branchId"],
        branchName: json["branchName"],
        customerName: json["customerName"],
        transporterName: json["transporterName"],
        containerId: json["containerId"],
        containerNumber: json["containerNumber"],
        containerSize: json["containerSize"],
        containerSizeId: json["containerSizeId"],
        containerType: json["containerType"],
        containerTypeId: json["containerTypeId"],

        containerCustomer: json["containerCustomer"],
        containerShippingLine: json["containerShippingLine"],
        containerDepot: json["containerDepot"],
        containerDeliveryType:
            DeliveryType.fromValue(json['containerDeliveryType']),

        containerShippingLineId: json["containerShippingLineId"],
        containerCustomerId: json["containerCustomerId"],
        containerDepotId: json["containerDepotId"],

        containers: json["containers"] != null
            ? List<GatePassAccessContainerModel>.from(json["containers"]
                .map((x) => GatePassAccessContainerModel.fromJson(x)))
            : [],
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
        "serviceTypeId": serviceTypeId,
        "canRelease": canRelease,
        "timeAtGate": timeAtGate?.toIso8601String(),
        "timeIn": timeIn?.toIso8601String(),
        "timeOut": timeOut?.toIso8601String(),
        "timeInYardDuration": timeInYardDuration,
        "gatePassStatus": gatePassStatus.value,
        "gatePassDeliveryType": gatePassDeliveryType.value,
        "gatePassBookingType": gatePassBookingType.value,
        "vehicleRegNumber": vehicleRegNumber,
        "vehicleRegNumberValidation": vehicleRegNumberValidation,
        "trailerRegNumberOne": trailerRegNumberOne,
        "trailerRegNumberOneValidation": trailerRegNumberOneValidation,
        "trailerRegNumberTwo": trailerRegNumberTwo,
        "trailerRegNumberTwoValidation": trailerRegNumberTwoValidation,
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
        "driverHasForeignID": driverHasForeignID,
        "driverLicenceNo": driverLicenceNo,
        "driversLicenceCodes": driversLicenceCodes,
        "professionalDrivingPermitExpiryDate":
            professionalDrivingPermitExpiryDate?.toIso8601String(),
        "driverLicenceIssueDate": driverLicenceIssueDate?.toIso8601String(),
        "driverLicenceExpiryDate": driverLicenceExpiryDate?.toIso8601String(),
        "vehicleRegisterNumber": vehicleRegisterNumber,
        "vehicleVinNumber": vehicleVinNumber,
        "vehicleEngineNumber": vehicleEngineNumber,
        "vehicleMake": vehicleMake,
        "vehicleCategory": vehicleCategory,
        "vehicleTare": vehicleTare ?? 0,
        "warehouseCode": warehouseCode,
        "comments": comments,
        "rejectReason": rejectReason,
        "hasBeenPrinted": hasBeenPrinted,
        "isManualInput": isManualInput,
        "isOverride": isOverride,
        "externalId": externalId,
        "grossWeightIn": grossWeightIn ?? 0,
        "grossWeightOut": grossWeightOut ?? 0,
        "tareWeightIn": tareWeightIn ?? 0,
        "tareWeightOut": tareWeightOut ?? 0,
        "netWeightIn": netWeightIn ?? 0,
        "netWeightOut": netWeightOut ?? 0,
        "varianceIn": varianceIn ?? 0,
        "varianceOut": varianceOut ?? 0,
        "productVariance": productVariance ?? 0,
        "totalProductGrossWeight": totalProductGrossWeight ?? 0,
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
        "containerDeliveryType": containerDeliveryType?.value ?? 0,
        "gatePassContainerType": gatePassContainerType?.value ?? 0,
        "isVehicleManualInput": isVehicleManualInput,
        "isTrailerOneManualInput": isTrailerOneManualInput,
        "isTrailerTwoManualInput": isTrailerTwoManualInput,
        "isTrailerOneOverride": isTrailerOneOverride,
        "isTrailerTwoOverride": isTrailerTwoOverride,
        "containerShippingLineId": containerShippingLineId,
        "containerCustomerId": containerCustomerId,
        "containerDepotId": containerDepotId,
        "containers": containers?.map((e) => e.toMap()).toList(),
      };

  static fromGatePassVisitorAccess(
      GatePassVisitorAccess gatePassVisitorAccess) {
    return GatePassAccess(
      id: gatePassVisitorAccess.id!,
      creationTime: gatePassVisitorAccess.creationTime,
      creatorUserId: gatePassVisitorAccess.creatorUserId,
      lastModificationTime: gatePassVisitorAccess.lastModificationTime,
      lastModifierUserId: gatePassVisitorAccess.lastModifierUserId,
      branchId: gatePassVisitorAccess.branchId,
      isActive: gatePassVisitorAccess.isActive,
      timeAtGate: gatePassVisitorAccess.timeAtGate,
      timeIn: gatePassVisitorAccess.timeIn,
      timeOut: gatePassVisitorAccess.timeOut,
      timeInYardDuration: gatePassVisitorAccess.timeInYardDuration,
      gatePassStatus: gatePassVisitorAccess.gatePassStatus,
      gatePassDeliveryType: gatePassVisitorAccess.gatePassDeliveryType,
      gatePassBookingType: gatePassVisitorAccess.gatePassBookingType,
      vehicleRegNumber: gatePassVisitorAccess.vehicleRegNumber,
      transactionNo: gatePassVisitorAccess.transactionNo,
      driverIdNo: gatePassVisitorAccess.driverIdNo,
      driverName: gatePassVisitorAccess.driverName,
      driverLicenceNo: gatePassVisitorAccess.driverLicenceNo,
      driversLicenceCodes: gatePassVisitorAccess.driversLicenceCodes,
      professionalDrivingPermitExpiryDate:
          gatePassVisitorAccess.professionalDrivingPermitExpiryDate,
      driverLicenceIssueDate: gatePassVisitorAccess.driverLicenceIssueDate,
      driverLicenceExpiryDate: gatePassVisitorAccess.driverLicenceExpiryDate,
      vehicleRegisterNumber: gatePassVisitorAccess.vehicleRegisterNumber,
      trailerRegNumberOne: gatePassVisitorAccess.trailerRegNumberOne,
      trailerRegNumberTwo: gatePassVisitorAccess.trailerRegNumberTwo,
      vehicleVinNumber: gatePassVisitorAccess.vehicleVinNumber,
      vehicleEngineNumber: gatePassVisitorAccess.vehicleEngineNumber,
      vehicleMake: gatePassVisitorAccess.vehicleMake,
    );
  }
}
