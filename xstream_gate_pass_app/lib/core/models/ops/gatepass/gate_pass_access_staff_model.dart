import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class GatePassStaffAccess {
  String? gatePassAccessId;
  bool isActive;
  String staffCode;
  DateTime? timeAtGate;
  DateTime? timeIn;
  DateTime? timeOut;
  int timeInYardDuration;

  GatePassStatus gatePassStatus;
  DeliveryType gatePassDeliveryType;
  GatePassBookingType gatePassBookingType;
  String timeInYard;
  String? vehicleRegNumber;
  String? transactionNo;
  String driverName;
  int staffId;
  int branchId;

  GatePassStaffAccess({
    this.gatePassAccessId,
    required this.isActive,
    required this.staffCode,
    this.timeAtGate,
    this.timeIn,
    this.timeOut,
    required this.timeInYardDuration,
    required this.gatePassStatus,
    required this.gatePassDeliveryType,
    required this.gatePassBookingType,
    required this.timeInYard,
    required this.vehicleRegNumber,
    this.transactionNo,
    required this.driverName,
    required this.staffId,
    required this.branchId,
  });

  // factory GatePassStaffAccess.fromJsonBase(Map<String, dynamic> json) {
  //   var user = GatePassStaffAccess(
  //     name: asT<String?>(json['name']) ?? null,
  //     surname: asT<String?>(json['surname']) ?? null,
  //     fullName: asT<String?>(json['fullName']) ?? null,
  //     emailAddress: asT<String?>(json['emailAddress']) ?? null,
  //     id: asT<int?>(json['id']) ?? null,
  //   );

  //   return user;
  // }

  factory GatePassStaffAccess.fromJson(Map<String, dynamic> json) {
    return GatePassStaffAccess(
      gatePassAccessId: json['gatePassAccessId'] ?? '',
      isActive: json['isActive'] ?? false,
      staffCode: json['staffCode'] ?? '',
      timeAtGate: json["timeAtGate"] != null
          ? DateTime.parse(json["timeAtGate"])
          : null,
      timeIn: json["timeIn"] != null ? DateTime.parse(json["timeIn"]) : null,
      timeOut: json["timeOut"] != null ? DateTime.parse(json["timeOut"]) : null,
      timeInYardDuration: json['timeInYardDuration'],
      gatePassStatus:
          GatePassStatus.values[asT<int>(json['gatePassStatus']) ?? 0],
      gatePassDeliveryType:
          DeliveryType.values[asT<int>(json['gatePassDeliveryType']) ?? 0],
      gatePassBookingType: GatePassBookingType
          .values[asT<int>(json['gatePassBookingType']) ?? 0],
      timeInYard: json['timeInYard'] ?? '',
      vehicleRegNumber: json['vehicleRegNumber'] ?? '',
      transactionNo: json['transactionNo'] ?? '',
      driverName: json['driverName'] ?? '',
      staffId: json['staffId'] ?? 0,
      branchId: json['branchId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gatePassAccessId': gatePassAccessId,
      'isActive': isActive,
      'staffCode': staffCode,
      'timeAtGate': timeAtGate?.toIso8601String(),
      'timeIn': timeIn?.toIso8601String(),
      'timeOut': timeOut?.toIso8601String(),
      'timeInYardDuration': timeInYardDuration,
      'gatePassStatus': gatePassStatus,
      'gatePassDeliveryType': gatePassDeliveryType,
      'gatePassBookingType': gatePassBookingType,
      'timeInYard': timeInYard,
      'vehicleRegNumber': vehicleRegNumber,
      'transactionNo': transactionNo,
      'driverName': driverName,
      'staffId': staffId,
      'branchId': branchId,
    };
  }
}
