import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate-pass-access_model.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class GatePassVisitorAccess {
  String? id;
  DateTime? creationTime;
  int? creatorUserId;
  DateTime? lastModificationTime;
  int? lastModifierUserId;
  String? gatePassAccessId;
  bool isActive;
  String? serviceType;
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
  String? rejectReason;
  int branchId;

  int? serviceTypeId;

  GatePassVisitorAccess({
    this.id,
    this.creationTime,
    this.creatorUserId,
    this.lastModificationTime,
    this.lastModifierUserId,
    this.gatePassAccessId,
    this.isActive = true,
    this.timeAtGate,
    this.serviceType,
    this.timeIn,
    this.timeOut,
    this.timeInYardDuration = 0,
    this.gatePassStatus = GatePassStatus.atGate,
    this.gatePassDeliveryType = DeliveryType.other,
    this.gatePassBookingType = GatePassBookingType.visitor,
    this.timeInYard = '',
    this.vehicleRegNumber,
    this.transactionNo,
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
    this.rejectReason,
    this.serviceTypeId,
    required this.branchId,
  });

  bool get hasDriverInfo =>
      driverName?.isNotEmpty == true && driverLicenceNo?.isNotEmpty == true;
  bool get hasVehicleInfo =>
      vehicleRegNumber?.isNotEmpty == true &&
      vehicleRegisterNumber?.isNotEmpty == true;

  factory GatePassVisitorAccess.fromJson(Map<String, dynamic> json) {
    return GatePassVisitorAccess(
      id: json['id'],
      creationTime: json['creationTime'] != null
          ? DateTime.parse(json['creationTime'])
          : null,
      creatorUserId: asT<int>(json['creatorUserId']),
      lastModificationTime: json['lastModificationTime'] != null
          ? DateTime.parse(json['lastModificationTime'])
          : null,
      lastModifierUserId: asT<int>(json['lastModifierUserId']),
      gatePassAccessId: json['gatePassAccessId'],
      isActive: json['isActive'] ?? false,
      timeAtGate: json["timeAtGate"] != null
          ? DateTime.parse(json["timeAtGate"])
          : null,
      timeIn: json["timeIn"] != null ? DateTime.parse(json["timeIn"]) : null,
      timeOut: json["timeOut"] != null ? DateTime.parse(json["timeOut"]) : null,
      timeInYardDuration: asT<int>(json['timeInYardDuration']) ?? 0,
      gatePassStatus:
          GatePassStatus.values[asT<int>(json['gatePassStatus']) ?? 0],
      gatePassDeliveryType:
          DeliveryType.values[asT<int>(json['gatePassDeliveryType']) ?? 0],
      gatePassBookingType: GatePassBookingType
          .values[asT<int>(json['gatePassBookingType']) ?? 0],
      timeInYard: json['timeInYard'] ?? '',
      vehicleRegNumber: json['vehicleRegNumber'],
      transactionNo: json['transactionNo'],
      driverName: json['driverName'] ?? '',
      driverIdNo: json['driverIdNo'],
      serviceType: json['serviceType'],
      driverLicenceNo: json['driverLicenceNo'],
      driversLicenceCodes: json['driversLicenceCodes'],
      professionalDrivingPermitExpiryDate:
          json['professionalDrivingPermitExpiryDate'] != null
              ? DateTime.parse(json['professionalDrivingPermitExpiryDate'])
              : null,
      driverLicenceIssueDate: json['driverLicenceIssueDate'] != null
          ? DateTime.parse(json['driverLicenceIssueDate'])
          : null,
      driverLicenceExpiryDate: json['driverLicenceExpiryDate'] != null
          ? DateTime.parse(json['driverLicenceExpiryDate'])
          : null,
      vehicleRegisterNumber: json['vehicleRegisterNumber'],
      vehicleVinNumber: json['vehicleVinNumber'],
      vehicleEngineNumber: json['vehicleEngineNumber'],
      vehicleMake: json['vehicleMake'],
      rejectReason: json['rejectReason'],
      serviceTypeId: asT<int>(json['serviceTypeId']),
      branchId: asT<int>(json['branchId']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creationTime': creationTime?.toIso8601String(),
      'creatorUserId': creatorUserId,
      'lastModificationTime': lastModificationTime?.toIso8601String(),
      'lastModifierUserId': lastModifierUserId,
      'gatePassAccessId': gatePassAccessId,
      'isActive': isActive,
      'timeAtGate': timeAtGate?.toIso8601String(),
      'timeIn': timeIn?.toIso8601String(),
      'timeOut': timeOut?.toIso8601String(),
      'timeInYardDuration': timeInYardDuration,
      'gatePassStatus': gatePassStatus.index,
      'gatePassDeliveryType': gatePassDeliveryType.index,
      'gatePassBookingType': gatePassBookingType.index,
      'timeInYard': timeInYard,
      'vehicleRegNumber': vehicleRegNumber,
      'serviceType': serviceType,
      'transactionNo': transactionNo,
      'driverName': driverName,
      'driverIdNo': driverIdNo,
      'driverLicenceNo': driverLicenceNo,
      'driversLicenceCodes': driversLicenceCodes,
      'professionalDrivingPermitExpiryDate':
          professionalDrivingPermitExpiryDate?.toIso8601String(),
      'driverLicenceIssueDate': driverLicenceIssueDate?.toIso8601String(),
      'driverLicenceExpiryDate': driverLicenceExpiryDate?.toIso8601String(),
      'vehicleRegisterNumber': vehicleRegisterNumber,
      'vehicleVinNumber': vehicleVinNumber,
      'vehicleEngineNumber': vehicleEngineNumber,
      'vehicleMake': vehicleMake,
      'rejectReason': rejectReason,
      'branchId': branchId,
      'serviceTypeId': serviceTypeId,
    };
  }
}
