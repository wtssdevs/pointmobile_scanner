import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class GatePassQuestions {
  GatePassQuestions({
    required this.hasDeliveryDocuments,
    required this.isContainerised,
    required this.hasDamagesDefects,
    required this.qtyMatchedDocs,
    required this.itemCodesMatchDocs,
    required this.expectedDelivery,
    required this.driverAgree,
  });

  bool hasDeliveryDocuments;
  bool isContainerised;
  bool hasDamagesDefects;
  bool qtyMatchedDocs;
  bool itemCodesMatchDocs;
  bool expectedDelivery;
  bool driverAgree;

  factory GatePassQuestions.fromJson(Map<String, dynamic> jsonRes) => GatePassQuestions(
        hasDeliveryDocuments: asT<bool>(jsonRes['hasDeliveryDocuments']) ?? false,
        isContainerised: asT<bool>(jsonRes['isContainerised']) ?? false,
        hasDamagesDefects: asT<bool>(jsonRes['hasDamagesDefects']) ?? false,
        qtyMatchedDocs: asT<bool>(jsonRes['qtyMatchedDocs']) ?? false,
        itemCodesMatchDocs: asT<bool>(jsonRes['itemCodesMatchDocs']) ?? false,
        expectedDelivery: asT<bool>(jsonRes['expectedDelivery']) ?? false,
        driverAgree: asT<bool>(jsonRes['driverAgree']) ?? false,
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hasDeliveryDocuments'] = hasDeliveryDocuments;
    data['isContainerised'] = isContainerised;
    data['hasDamagesDefects'] = hasDamagesDefects;
    data['qtyMatchedDocs'] = qtyMatchedDocs;
    data['itemCodesMatchDocs'] = itemCodesMatchDocs;
    data['expectedDelivery'] = expectedDelivery;
    data['driverAgree'] = driverAgree;
    return data;
  }
}
