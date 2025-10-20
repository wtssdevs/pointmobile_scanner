import 'dart:convert';

import 'package:xstream_gate_pass_app/core/utils/helper.dart';

extension EnumFromJson on Object {
  /// Takes whatever chaotic JSON throws at us and returns a valid enum value
  /// Like turning water into wine, but for enums
  T toEnum<T extends Enum>(List<T> values, {required T defaultValue}) {
    // Handle madness like "80" or 80 or "MODE_80" with grace
    if (this is int) {
      final index = this as int;
      return index >= 0 && index < values.length ? values[index] : defaultValue;
    }

    // Try to parse string to int
    if (this is String) {
      final parsed = int.tryParse(this as String);
      if (parsed != null && parsed >= 0 && parsed < values.length) {
        return values[parsed];
      }
    }

    // When all hope is lost, return to default
    print('🛑 Failed to convert $this to enum type ${T.toString()}');
    return defaultValue;
  }
}

enum DeviceModelScanningMode {
  pm80(80, "PM80"),
  pm84(84, "PM84");

  final int value;
  final String displayName;
  const DeviceModelScanningMode(this.value, this.displayName);
}

class DeviceConfig {
  DeviceModelScanningMode deviceScanningMode;

  DeviceConfig({
    required this.deviceScanningMode,
  });

  factory DeviceConfig.fromJson(Map<String, dynamic> jsonRes) => DeviceConfig(
        deviceScanningMode:
            _getSafeDeviceScanningMode(jsonRes['DeviceModelScanningMode']),
      );
// Add this method to your DeviceConfig class
  static DeviceModelScanningMode _getSafeDeviceScanningMode(dynamic value) {
    final index = asT<int>(value) ?? 0;

    switch (index) {
      case 80:
        return DeviceModelScanningMode.pm80;
      case 84:
        return DeviceModelScanningMode.pm84;

      default:
        return DeviceModelScanningMode.pm84;
    }
  }

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'DeviceModelScanningMode': deviceScanningMode.value,
      };
}
