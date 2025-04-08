import 'package:dart_helper_utils/dart_helper_utils.dart';

class LicenseDiskData {
  final String prefix; // e.g., MVL1CC20
  final int encoding; // 139
  final String data; // 4522A001 (Likely the vehicle or license number)
  final int version; // 1
  final String licenseNo; // 4046048SP9R2 (Potentially owner info, needs further analysis)
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

  String? validateSARegistrationNumber(String? regNumber) {
    if (regNumber == null || regNumber.isEmpty) {
      return 'Registration number cannot be empty.';
    }

    // Remove any spaces or hyphens for easier pattern matching
    final cleanedRegNumber = regNumber.toUpperCase().replaceAll(' ', '').replaceAll('-', '');

    // Define regular expressions for common South African plate formats
    // This list is not exhaustive and might need adjustments based on
    // newer or less common formats.

    // Provincial formats (examples - more can be added)
    final gautengRegex1 = r'^[A-Z]{3}\d{3}GP$'; // e.g., ABC 123 GP
    final gautengRegex2 = r'^\d{2}[A-Z]{2}\d{2}GP$'; // Older format e.g., 12 AB 34 GP
    final gautengRegex3 = r'^[A-Z]{2}\d{2}[A-Z]{2}GP$'; // Newer format e.g., AB 12 CD GP
    final westernCapeRegex1 = r'^[A-Z]{2}\d{3}-\d{3}$'; // e.g., CA 123-456
    final westernCapeRegex2 = r'^[A-Z]{3}\d{3}$'; // Older format e.g., CAA 123
    final kwazuluNatalRegex1 = r'^[A-Z]{2}\d{3}-\d{3}$'; // e.g., ND 123-456
    final kwazuluNatalRegex2 = r'^\d{4,5}ND$'; // Older format e.g., 12345 ND
    final kwazuluNatalRegex3 = r'^[A-Z]{2}\d{2}[A-Z]{2}ZN$'; // Newer format e.g., BB 00 AA ZN (as of Dec 2023)
    final easternCapeRegex = r'^[A-Z]{3}\d{3}EC$'; // e.g., BBB 123 EC
    final freeStateRegex = r'^[A-Z]{3}\d{3}FS$'; // e.g., CCC 123 FS
    final limpopoRegex = r'^[A-Z]{3}\d{3}L$'; // e.g., DDD 123 L
    final mpumalangaRegex = r'^[A-Z]{3}\d{3}MP$'; // e.g., EEE 123 MP
    final northWestRegex = r'^[A-Z]{3}\d{3}NW$'; // e.g., FFF 123 NW
    final northernCapeRegex = r'^[A-Z]{3}\d{3}NC$'; // e.g., GGG 123 NC

    // Personalized plates (can have various formats, this is a basic example)
    final personalizedRegex = r'^[A-Z0-9\s]{3,9}$'; // 3 to 9 alphanumeric characters and spaces

    // Check against the defined patterns
    if (gautengRegex1.hasMatch(cleanedRegNumber) ||
            gautengRegex2.hasMatch(cleanedRegNumber) ||
            gautengRegex3.hasMatch(cleanedRegNumber) ||
            westernCapeRegex1.hasMatch(cleanedRegNumber) ||
            westernCapeRegex2.hasMatch(cleanedRegNumber) ||
            kwazuluNatalRegex1.hasMatch(cleanedRegNumber) ||
            kwazuluNatalRegex2.hasMatch(cleanedRegNumber) ||
            kwazuluNatalRegex3.hasMatch(cleanedRegNumber) ||
            easternCapeRegex.hasMatch(cleanedRegNumber) ||
            freeStateRegex.hasMatch(cleanedRegNumber) ||
            limpopoRegex.hasMatch(cleanedRegNumber) ||
            mpumalangaRegex.hasMatch(cleanedRegNumber) ||
            northWestRegex.hasMatch(cleanedRegNumber) ||
            northernCapeRegex.hasMatch(cleanedRegNumber)
        //|| personalizedRegex.hasMatch(cleanedRegNumber)
        ) {
      return null; // Validation successful
    } else {
      return 'Invalid South African registration number format.';
    }
  }

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
      throw FormatException('Invalid license disk format: Data parsing failed: $e');
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

  factory LicenseDiskData.fromJson(Map<String, dynamic> json) => LicenseDiskData(
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
