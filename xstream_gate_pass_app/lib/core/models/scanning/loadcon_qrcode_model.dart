class LoadconQrCodeModel {
  String? voyageNo;
  String? containerNumber;
  String? transactionNo;
  String? vehicleRegNumber;

  LoadconQrCodeModel({
    this.voyageNo,
    this.containerNumber,
    this.transactionNo,
    this.vehicleRegNumber,
  });

  LoadconQrCodeModel.fromJson(Map<String, dynamic> json) {
    voyageNo = json['voyageNo'];
    containerNumber = json['containerNumber'];
    transactionNo = json['transactionNo'];
    vehicleRegNumber = json['vehicleRegNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['voyageNo'] = this.voyageNo;
    data['containerNumber'] = this.containerNumber;
    data['transactionNo'] = this.transactionNo;
    data['vehicleRegNumber'] = this.vehicleRegNumber;
    return data;
  }
}
