//  {
//       "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
//       "tenantId": 0,
//       "externalContainerId": "string",
//       "containerNumber": "string",
//       "deliveryType": 0,
//       "containerSetNo": 0,
//       "gatePassContainerType": 0,
//       "goodsDeliveryNo": "string",
//       "sealNumberOne": "string",
//       "sealNumberTwo": "string",
//       "sealNumberThree": "string",
//       "sealNumberFour": "string",
//       "description": "string",
//       "weight": 0,
//       "isDisabled": true,
//       "shippingLineId": 0,
//       "customerId": 0,
//       "containerSizeId": 0,
//       "containerTypeId": 0,
//       "branchId": 0,
//       "depotId": 0,
//       "gatePassAccessId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
//     }

import 'dart:convert';
import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_type.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class GatePassAccessContainerModel {
  String? id;
  int? tenantId;
  String? externalContainerId;
  String? containerNumber;
  int? deliveryType;
  int? containerSetNo;
  String? goodsDeliveryNo;
  String? sealNumberOne;
  String? sealNumberTwo;
  String? sealNumberThree;
  String? sealNumberFour;
  String? description;
  double? weight;
  bool isDisabled;
  int? shippingLineId;
  int? customerId;
  int? containerSizeId;
  int? containerTypeId;
  int? branchId;
  int? depotId;
  String? gatePassAccessId;

  // Additional properties from the existing class that might be needed
  String? containerSize;
  String? containerType;
  String? containerIsoCode;
  String? containerCustomer;
  String? containerShippingLine;
  String? containerDepot;

  DeliveryType? containerDeliveryType;
  GatePassContainerType? gatePassContainerType;

  GatePassAccessContainerModel({
    this.id,
    this.tenantId,
    this.externalContainerId,
    this.containerNumber,
    this.deliveryType,
    this.containerSetNo,
    this.gatePassContainerType,
    this.goodsDeliveryNo,
    this.sealNumberOne,
    this.sealNumberTwo,
    this.sealNumberThree,
    this.sealNumberFour,
    this.description,
    this.weight = 0.0,
    this.isDisabled = false,
    this.shippingLineId,
    this.customerId,
    this.containerSizeId,
    this.containerTypeId,
    this.branchId,
    this.depotId,
    this.gatePassAccessId,
    this.containerSize,
    this.containerType,
    this.containerIsoCode,
    this.containerCustomer,
    this.containerShippingLine,
    this.containerDepot,
    this.containerDeliveryType,
  });

  @override
  String toString() =>
      'Container: ${containerNumber ?? "N/A"}, Description: ${description ?? "N/A"}';

  String toJson() => json.encode(toMap());

  factory GatePassAccessContainerModel.fromJson(Map<String, dynamic> json) {
    return GatePassAccessContainerModel(
      id: json["id"],
      tenantId: json["tenantId"],
      externalContainerId: json["externalContainerId"],
      containerNumber: json["containerNumber"],
      containerSetNo: json["containerSetNo"],
      goodsDeliveryNo: json["goodsDeliveryNo"],
      sealNumberOne: json["sealNumberOne"],
      sealNumberTwo: json["sealNumberTwo"],
      sealNumberThree: json["sealNumberThree"],
      sealNumberFour: json["sealNumberFour"],
      description: json["description"],
      weight: json["weight"]?.toDouble(),
      isDisabled: json["isDisabled"] ?? false,

      shippingLineId: json["shippingLineId"],

      customerId: json["customerId"],

      containerSizeId: json["containerSizeId"],

      containerTypeId: json["containerTypeId"],
      containerType: json["containerType"],
      containerIsoCode: json["containerIsoCode"] ?? json["containerType"],

      // this.containerSize,
      //this.containerType,
      //this.containerCustomer,
      //this.containerShippingLine,

      branchId: json["branchId"],
      depotId: json["depotId"],
      gatePassAccessId: json["gatePassAccessId"],
      containerDeliveryType: json['deliveryType'] != null
          ? DeliveryType.values[
              asT<int?>(json['deliveryType']) ?? DeliveryType.other.value]
          : (json['containerDeliveryType'] != null
              ? DeliveryType.values[asT<int?>(json['containerDeliveryType']) ??
                  DeliveryType.other.value]
              : null),

      gatePassContainerType: GatePassContainerType.values[
          asT<int?>(json['gatePassContainerType']) ??
              GatePassContainerType.none.value],
    );
  }

Map<String, dynamic> toMap() {
  final normalizedId = id?.trim();
  final hasId = normalizedId != null && normalizedId.isNotEmpty;
  final normalizedGatePassAccessId = gatePassAccessId?.trim();
  final hasGatePassAccessId = normalizedGatePassAccessId != null && normalizedGatePassAccessId.isNotEmpty;

  var output = {
    "tenantId": tenantId ?? 0,
    "externalContainerId": externalContainerId,
    "containerNumber": containerNumber,
    "deliveryType": deliveryType ?? containerDeliveryType?.value ?? 0,
    "containerSetNo": containerSetNo ?? 1,
    "gatePassContainerType": gatePassContainerType?.value ?? 0,
    "goodsDeliveryNo": goodsDeliveryNo,
    "sealNumberOne": sealNumberOne,
    "sealNumberTwo": sealNumberTwo,
    "sealNumberThree": sealNumberThree,
    "sealNumberFour": sealNumberFour,
    "description": description,
    "weight": weight ?? 0.0,  
    "isDisabled": isDisabled,
    "shippingLineId": shippingLineId,
    "customerId": customerId,
    "containerSizeId": containerSizeId,
    "containerTypeId": containerTypeId,
    "containerType": containerType ?? containerIsoCode,
    "containerIsoCode": containerIsoCode,
    "branchId": branchId ?? 0,
    "depotId": depotId,
  };

  if (hasId) {
    output["id"] = normalizedId;
  }
  if (hasGatePassAccessId) {
    output["gatePassAccessId"] = normalizedGatePassAccessId;
  }

  if (shippingLineId == null || shippingLineId == 0) output.remove("shippingLineId");
  if (customerId == null || customerId == 0) output.remove("customerId");
  if (containerSizeId == null || containerSizeId == 0) output.remove("containerSizeId");
  if (containerTypeId == null || containerTypeId == 0) output.remove("containerTypeId");
  if (depotId == null || depotId == 0) output.remove("depotId");

  return output;
}
}