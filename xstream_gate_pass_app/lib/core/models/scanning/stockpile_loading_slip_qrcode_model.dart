import 'dart:convert';

import 'package:xstream_gate_pass_app/core/enums/loading_stockpile_type.dart';
import 'package:xstream_gate_pass_app/core/enums/stockpile_actions.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class StockpileLoadingSlipQrCodeModel {
  String? voyageNo;
  String? customerRefNo;
  String? loadItemCode;
  int? cmsGatePassId;
  //
  int? branchId;
  StockpileActions stockpileAction;
  LoadingStockpileType loadingStockpileType;

  StockpileLoadingSlipQrCodeModel({
    this.voyageNo,
    this.customerRefNo,
    this.loadItemCode,
    this.cmsGatePassId,
//
    this.branchId,
    this.stockpileAction = StockpileActions.atStockPile,
    this.loadingStockpileType = LoadingStockpileType.loadingSlip,
  });
  bool hasAllInfo() {
    return voyageNo != null && customerRefNo != null && loadItemCode != null;
  }

  StockpileLoadingSlipQrCodeModel copyWith({
    String? voyageNo,
    String? customerRefNo,
    String? loadItemCode,
    int? cmsGatePassId,
  }) {
    return StockpileLoadingSlipQrCodeModel(
      voyageNo: voyageNo ?? this.voyageNo,
      customerRefNo: customerRefNo ?? this.customerRefNo,
      loadItemCode: loadItemCode ?? this.loadItemCode,
      cmsGatePassId: cmsGatePassId ?? this.cmsGatePassId,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['voyageNo'] = voyageNo;
    data['customerRefNo'] = customerRefNo;
    data['loadItemCode'] = loadItemCode;
    data['cmsGatePassId'] = cmsGatePassId;
//
    data['gatePassEventAction'] = stockpileAction.gatePassEventActionValue;
    data['gatePassEventActionText'] = stockpileAction.visitorName;
    data['branchId'] = branchId;

    return data;
    //return {
    //'VoyageNo': voyageNo,
    // 'CustomerRefNo': customerRefNo,
    // 'LoadItemCode': loadItemCode,
    // 'CmsGatePassId': cmsGatePassId,
    //};
  }

  factory StockpileLoadingSlipQrCodeModel.fromMap(Map<String, dynamic> map) {
    //map = {"VoyageNo":"PO416632","CustomerRefNo":"UG - 4502192786","LoadItemCode":"CHROME CONCENTRATE","CmsGatePassId":"276040","LoadingStockpileType":0}
    //why does this line (cmsGatePassId: asT<int?>(map['CmsGatePassId']),) fail to parse the cmsGatePassId from the map?
    return StockpileLoadingSlipQrCodeModel(
      voyageNo: map['VoyageNo'],
      customerRefNo: map['CustomerRefNo'],
      loadItemCode: map['LoadItemCode'],
      cmsGatePassId: map['CmsGatePassId'] != null
          ? int.tryParse(map['CmsGatePassId'].toString())
          : null,
      loadingStockpileType: LoadingStockpileType
          .values[asT<int?>(map['LoadingStockpileType']) ?? 0],
    );
  }

  //String toJson() => json.encode(toMap());

  factory StockpileLoadingSlipQrCodeModel.fromJson(String source) =>
      StockpileLoadingSlipQrCodeModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'StockpileLoadingSlipQrCodeModel(VoyageNo: $voyageNo, CustomerRefNo: $customerRefNo, LoadItemCode: $loadItemCode)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StockpileLoadingSlipQrCodeModel &&
        other.voyageNo == voyageNo &&
        other.customerRefNo == customerRefNo &&
        other.loadItemCode == loadItemCode;
  }

  @override
  int get hashCode =>
      voyageNo.hashCode ^ customerRefNo.hashCode ^ loadItemCode.hashCode;

  void clearInfo() {
    voyageNo = null;
    customerRefNo = null;
    loadItemCode = null;
  }
}
