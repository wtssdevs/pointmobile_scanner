class LoadconQrCodeModel {
  String? transactionNo;
  String? referenceNo;
  String? customerRefNo;
  String? bookingOrderNumber;
  String? vehicleRegistrationNumber;
  int? branchId;

  LoadconQrCodeModel({this.transactionNo, this.referenceNo, this.customerRefNo, this.bookingOrderNumber, this.vehicleRegistrationNumber, this.branchId});
  bool isModelEmpty() {
    return transactionNo == null || referenceNo == null || customerRefNo == null || bookingOrderNumber == null || vehicleRegistrationNumber == null;
  }

  LoadconQrCodeModel.fromJson(Map<String, dynamic> json) {
    transactionNo = json['TransactionNo'];
    referenceNo = json['ReferenceNo'];
    customerRefNo = json['CustomerRefNo'];
    bookingOrderNumber = json['BookingOrderNumber'];
    vehicleRegistrationNumber = json['VehicleRegistrationNumber'];
    branchId = json['BranchId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TransactionNo'] = this.transactionNo;
    data['ReferenceNo'] = this.referenceNo;
    data['CustomerRefNo'] = this.customerRefNo;
    data['BookingOrderNumber'] = this.bookingOrderNumber;
    data['VehicleRegistrationNumber'] = this.vehicleRegistrationNumber;
    data['BranchId'] = this.branchId;
    return data;
  }
}
