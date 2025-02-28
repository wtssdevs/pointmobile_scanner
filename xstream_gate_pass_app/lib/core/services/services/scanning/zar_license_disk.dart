class LicenseDiskData {
  final String prefix; // e.g., MVL1CC20
  final int encoding; // 139
  final String data; // 4522A001 (Likely the vehicle or license number)
  final int version; // 1
  final String
      licenseNo; // 4046048SP9R2 (Potentially owner info, needs further analysis)
  final String licensePlateNo; // BS93TVGP (Unknown, needs further analysis)
  final String vehicleRegisterNo; // PWR418W (Unknown, needs further analysis)
  final String vehicleType; // Mcycle(no sidecar) / Mfiets(nie syspan)
  final String make; // HONDA
  final String model; // NC 700 X
  final String color; // White / Wit
  final String vin; // JH2RC63A5CK500130
  final String engineNumber; // RC61E5001427
  final DateTime expiryDate; // 2025-02-28

  LicenseDiskData({
    required this.prefix,
    required this.encoding,
    required this.data,
    required this.version,
    required this.licensePlateNo,
    required this.licenseNo,
    required this.vehicleRegisterNo,
    required this.vehicleType,
    required this.make,
    required this.model,
    required this.color,
    required this.vin,
    required this.engineNumber,
    required this.expiryDate,
  });

  factory LicenseDiskData.fromString(String qrCodeString) {
    List<String> parts = qrCodeString.split('%');

    if (parts.length < 15) {
      throw FormatException('Invalid license disk format: Not enough parts');
    }

    try {
      return LicenseDiskData(
        prefix: parts[1],
        encoding: int.parse(parts[2]),
        data: parts[3],
        version: int.parse(parts[4]),
        licenseNo: parts[5],
        licensePlateNo: parts[6],
        vehicleRegisterNo: parts[7],
        vehicleType: parts[8],
        make: parts[9],
        model: parts[10],
        color: parts[11],
        vin: parts[12],
        engineNumber: parts[13],
        expiryDate: DateTime.parse(parts[14]),
      );
    } catch (e) {
      throw FormatException(
          'Invalid license disk format: Data parsing failed: $e');
    }
  }

  Map<String, dynamic> toJson() => {
        'prefix': prefix,
        'encoding': encoding,
        'data': data,
        'version': version,
        'licensePlateNo': licensePlateNo,
        'licenseNo': licenseNo,
        'vehicleRegisterNo': vehicleRegisterNo,
        'vehicleType': vehicleType,
        'make': make,
        'model': model,
        'color': color,
        'vin': vin,
        'engineNumber': engineNumber,
        'expiryDate': expiryDate.toIso8601String(), // Store as ISO string
      };

  factory LicenseDiskData.fromJson(Map<String, dynamic> json) =>
      LicenseDiskData(
        prefix: json['prefix'],
        encoding: json['encoding'],
        data: json['data'],
        version: json['version'],
        licensePlateNo: json['licensePlateNo'],
        licenseNo: json['licenseNo'],
        vehicleRegisterNo: json['vehicleRegisterNo'],
        vehicleType: json['vehicleType'],
        make: json['make'],
        model: json['model'],
        color: json['color'],
        vin: json['vin'],
        engineNumber: json['engineNumber'],
        expiryDate: DateTime.parse(json['expiryDate']),
      );
}
