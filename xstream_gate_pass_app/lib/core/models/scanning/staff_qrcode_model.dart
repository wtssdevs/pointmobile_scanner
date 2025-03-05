class StaffQrCodeModel {
  String? code;
  String? fullName;
  String? driverLicenceNo;
  String? vehicleRegNumber;
  int? branchId;

  StaffQrCodeModel(
      {this.code,
      this.fullName,
      this.driverLicenceNo,
      this.vehicleRegNumber,
      this.branchId});

  StaffQrCodeModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    fullName = json['fullName'];
    driverLicenceNo = json['driverLicenceNo'];
    vehicleRegNumber = json['vehicleRegNumber'];
    branchId = json['branchId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['fullName'] = this.fullName;
    data['driverLicenceNo'] = this.driverLicenceNo;
    data['vehicleRegNumber'] = this.vehicleRegNumber;
    data['branchId'] = this.branchId;
    return data;
  }
}
