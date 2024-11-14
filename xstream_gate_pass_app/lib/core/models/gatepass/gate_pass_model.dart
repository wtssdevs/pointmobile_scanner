import 'dart:convert';

import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_question.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class GatePass {
  GatePass(
      {required this.vehicleRegNumber,
      this.timeAtGate,
      this.timeIn,
      this.extensionData,
      this.customerName,
      this.transporterName,
      this.timeOut,
      required this.gatePassStatus,
      this.branchId,
      this.statusDescription,
      this.trailerNumber1,
      this.trailerNumber2,
      this.refNo,
      this.isHazardous,
      this.driverName,
      this.driverIdNo,
      this.driverLicenseNo,
      this.driverLicenseCountryCode,
      this.driverGender,
      this.siNumber,
      this.customerCode,
      this.transporterCode,
      this.goodsDescription,
      this.gatePassType,
      this.warehouseCode,
      this.comments,
      this.rejReason,
      this.gatePassBookingType = 0,
      this.siteCardNumber,
      this.driverAssistantDetails1,
      this.driverAssistantDetails2,
      this.totClaimedWeightIn,
      this.totMeasuredWeightIn,
      this.totClaimedWeightOut,
      this.totMeasuredWeightOut,
      this.productId,
      this.noOfPcs,
      this.containerNumber,
      this.containerType,
      this.containerSealNumber,
      this.samplerSealNumber,
      this.customerId,
      this.transporterId,
      this.productCode,
      this.productDescription,
      this.productAltCode,
      this.hasBeenPrinted,
      this.gatePassQuestions,
      this.id,
      this.hasDeliveryDocuments = false});
  factory GatePass.fromJson(Map<String, dynamic> jsonRes) => GatePass(
        vehicleRegNumber: asT<String>(jsonRes['vehicleRegNumber']) ?? "",
        timeAtGate: jsonRes["timeAtGate"] != null
            ? DateTime.parse(jsonRes["timeAtGate"])
            : null,
        timeIn: jsonRes["timeIn"] != null
            ? DateTime.parse(jsonRes["timeIn"])
            : null,
        extensionData: asT<String>(jsonRes['extensionData']) ?? "",
        customerName: asT<String>(jsonRes['customerName']) ?? "",
        transporterName: asT<String>(jsonRes['transporterName']) ?? "",
        timeOut: jsonRes["timeOut"] != null
            ? DateTime.parse(jsonRes["timeOut"])
            : null,
        gatePassStatus: asT<int>(jsonRes['gatePassStatus']) ?? 0,
        branchId: asT<int?>(jsonRes['branchId']),
        statusDescription: asT<String>(jsonRes['statusDescription']) ?? "",
        trailerNumber1: asT<String>(jsonRes['trailerNumber1']) ?? "",
        trailerNumber2: asT<String>(jsonRes['trailerNumber2']) ?? "",
        refNo: asT<String>(jsonRes['refNo']) ?? "",
        isHazardous: asT<bool>(jsonRes['isHazardous']) ?? false,
        driverName: asT<String>(jsonRes['driverName']) ?? "",
        driverIdNo: asT<String>(jsonRes['driverIDNo']) ?? "",
        driverLicenseNo: asT<String>(jsonRes['driverLicenseNo']) ?? "",
        driverLicenseCountryCode:
            asT<String>(jsonRes['driverLicenseCountryCode']) ?? "",
        driverGender: asT<String>(jsonRes['driverGender']) ?? "",
        siNumber: asT<String>(jsonRes['siNumber']) ?? "",
        customerCode: asT<String>(jsonRes['customerCode']) ?? "",
        transporterCode: asT<String>(jsonRes['transporterCode']) ?? "",
        goodsDescription: asT<String>(jsonRes['goodsDescription']) ?? "",
        gatePassType: asT<int>(jsonRes['gatePassType']) ?? 0,
        warehouseCode: asT<String>(jsonRes['warehouseCode']) ?? "",
        comments: asT<String>(jsonRes['comments']) ?? "",
        rejReason: asT<String>(jsonRes['rejReason']) ?? "",
        gatePassBookingType: asT<int>(jsonRes['gatePassBookingType']) ?? 0,
        siteCardNumber: asT<String>(jsonRes['siteCardNumber']) ?? "",
        driverAssistantDetails1:
            asT<String>(jsonRes['driverAssistantDetails1']) ?? "",
        driverAssistantDetails2:
            asT<String>(jsonRes['driverAssistantDetails2']) ?? "",
        totClaimedWeightIn: asT<double>(jsonRes['totClaimedWeightIn']) ?? 0,
        totMeasuredWeightIn: asT<double>(jsonRes['totMeasuredWeightIn']) ?? 0,
        totClaimedWeightOut: asT<double>(jsonRes['totClaimedWeightOut']) ?? 0,
        totMeasuredWeightOut: asT<double>(jsonRes['totMeasuredWeightOut']) ?? 0,
        productId: asT<int>(jsonRes['productId']) ?? 0,
        noOfPcs: asT<int>(jsonRes['noOfPcs']) ?? 0,
        containerNumber: asT<String>(jsonRes['containerNumber']) ?? "",
        containerType: asT<String>(jsonRes['containerType']) ?? "",
        containerSealNumber: asT<String>(jsonRes['containerSealNumber']) ?? "",
        samplerSealNumber: asT<String>(jsonRes['samplerSealNumber']) ?? "",
        customerId: asT<int>(jsonRes['customerID']) ?? 0,
        transporterId: asT<int>(jsonRes['transporterId']) ?? 0,
        productCode: asT<String>(jsonRes['productCode']) ?? "",
        productDescription: asT<String>(jsonRes['productDescription']) ?? "",
        productAltCode: asT<String>(jsonRes['productAltCode']) ?? "",
        hasBeenPrinted: asT<bool>(jsonRes['hasBeenPrinted']) ?? false,
        gatePassQuestions: jsonRes['gatePassQuestions'] == null
            ? null
            : GatePassQuestions.fromJson(
                asT<Map<String, dynamic>>(jsonRes['gatePassQuestions'])!),
        id: asT<int>(jsonRes['id']) ?? 0,
      );

  bool hasDeliveryDocuments;
  String vehicleRegNumber;
  DateTime? timeAtGate;
  DateTime? timeIn;
  String? extensionData;
  String? customerName;
  String? transporterName;
  DateTime? timeOut;
  int gatePassStatus;
  int? branchId;
  String? statusDescription;
  String? trailerNumber1;
  String? trailerNumber2;
  String? refNo;
  bool? isHazardous;
  String? driverName;
  String? driverIdNo;
  String? driverLicenseNo;
  String? driverLicenseCountryCode;
  String? driverGender;
  String? siNumber;
  String? customerCode;
  String? transporterCode;
  String? goodsDescription;
  int? gatePassType;
  String? warehouseCode;
  String? comments;
  String? rejReason;
  int? gatePassBookingType;
  String? siteCardNumber;
  String? driverAssistantDetails1;
  String? driverAssistantDetails2;
  double? totClaimedWeightIn;
  double? totMeasuredWeightIn;
  double? totClaimedWeightOut;
  double? totMeasuredWeightOut;
  int? productId;
  int? noOfPcs;
  String? containerNumber;
  String? containerType;
  String? containerSealNumber;
  String? samplerSealNumber;
  int? customerId;
  int? transporterId;
  String? productCode;
  String? productDescription;
  String? productAltCode;
  bool? hasBeenPrinted;
  GatePassQuestions? gatePassQuestions;
  int? id;

  @override
  String toString() {
    return jsonEncode(this);
  }

  String getGatePassStatusText() {
    switch (gatePassStatus) {
      case 0:
        return "None";
      case 1:
        return "At Gate";
      case 2:
        return "In Yard";
      case 3:
        return "Left The Yard";
      case 4:
        return "Rejected Entry";
      default:
        return "";
    }
  }

  Map<String, dynamic> toJson() {
    final log = getLogger('GatePasstoJson');
    final Map<String, dynamic> data = <String, dynamic>{};

    data['hasDeliveryDocuments'] = hasDeliveryDocuments;
    data['vehicleRegNumber'] = vehicleRegNumber;
    data['timeAtGate'] = timeAtGate?.toIso8601String();
    data['timeIn'] = timeIn?.toIso8601String();
    data['extensionData'] = extensionData;

    data['transporterName'] = transporterName;
    data['timeOut'] = timeOut?.toIso8601String();
    data['gatePassStatus'] = gatePassStatus;
    // data['branchId'] = branchId ?? 0;
    // data['statusDescription'] = statusDescription;
    data['trailerNumber1'] = trailerNumber1;
    data['trailerNumber2'] = trailerNumber2;
    // data['refNo'] = refNo;
    // data['isHazardous'] = isHazardous ?? false;
    data['driverName'] = driverName;
    data['driverIDNo'] = driverIdNo;
    data['driverLicenseNo'] = driverLicenseNo;
    data['driverLicenseCountryCode'] = driverLicenseCountryCode;
    data['driverGender'] = driverGender;

    data['customerCode'] = customerCode;
    data['customerName'] = customerName;
    // data['siNumber'] = siNumber;
    data['customerID'] = customerId == 0 ? "" : customerId;
    // data['transporterCode'] = transporterCode;
    // data['goodsDescription'] = goodsDescription;
    data['gatePassType'] = gatePassType ?? 0;
    // data['warehouseCode'] = warehouseCode;
    // data['comments'] = comments;
    // data['rejReason'] = rejReason;
    // data['gatePassBookingType'] = gatePassBookingType;
    // data['siteCardNumber'] = siteCardNumber;
    // data['driverAssistantDetails1'] = driverAssistantDetails1;
    // data['driverAssistantDetails2'] = driverAssistantDetails2;
    // data['totClaimedWeightIn'] = totClaimedWeightIn ?? 0;
    // data['totMeasuredWeightIn'] = totMeasuredWeightIn ?? 0;
    // data['totClaimedWeightOut'] = totClaimedWeightOut ?? 0;
    // data['totMeasuredWeightOut'] = totMeasuredWeightOut ?? 0;
    // data['productId'] = productId;
    // data['noOfPcs'] = noOfPcs ?? 0;
    // data['containerNumber'] = containerNumber;
    // data['containerType'] = containerType;
    // data['containerSealNumber'] = containerSealNumber;
    // data['samplerSealNumber'] = samplerSealNumber;

    // data['transporterID'] = transporterId;
    // data['productCode'] = productCode;
    // data['productDescription'] = productDescription;
    // data['productAltCode'] = productAltCode;
    // data['hasBeenPrinted'] = hasBeenPrinted ?? false;
    if (gatePassQuestions != null) {
      data['gatePassQuestions'] = gatePassQuestions!.toJson();
    }
    data['id'] = id;

    return data;
  }
}
