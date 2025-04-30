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
    this.weight,
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
    this.containerCustomer,
    this.containerShippingLine,
    this.containerDepot,
    this.containerDeliveryType,
  });

  @override
  String toString() => 'Container: ${containerNumber ?? "N/A"}, Description: ${description ?? "N/A"}';

  String toJson() => json.encode(toMap());

  factory GatePassAccessContainerModel.fromJson(Map<String, dynamic> json) {
    return GatePassAccessContainerModel(
      id: json["id"],
      tenantId: json["tenantId"],
      externalContainerId: json["externalContainerId"],
      containerNumber: json["containerNumber"],
      deliveryType: json["deliveryType"],
      containerSetNo: json["containerSetNo"],
      //gatePassContainerType: json["gatePassContainerType"],
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

      // this.containerSize,
    //this.containerType,
    //this.containerCustomer,
    //this.containerShippingLine,

      branchId: json["branchId"],
      depotId: json["depotId"],
      gatePassAccessId: json["gatePassAccessId"],   
      containerDeliveryType: DeliveryType.values[asT<int?>(json['containerDeliveryType']) ?? DeliveryType.other.value],
      gatePassContainerType: GatePassContainerType.values[asT<int?>(json['gatePassContainerType']) ?? GatePassContainerType.none.value],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "tenantId": tenantId,
      "externalContainerId": externalContainerId,
      "containerNumber": containerNumber,
      "deliveryType": deliveryType,
      "containerSetNo": containerSetNo,
      "gatePassContainerType": gatePassContainerType,
      "goodsDeliveryNo": goodsDeliveryNo,
      "sealNumberOne": sealNumberOne,
      "sealNumberTwo": sealNumberTwo,
      "sealNumberThree": sealNumberThree,
      "sealNumberFour": sealNumberFour,
      "description": description,
      "weight": weight,
      "isDisabled": isDisabled,
      "shippingLineId": shippingLineId,
      "customerId": customerId,
      "containerSizeId": containerSizeId,
      "containerTypeId": containerTypeId,
      "branchId": branchId,
      "depotId": depotId,
      "gatePassAccessId": gatePassAccessId,
    };
  }
}
