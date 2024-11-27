import 'dart:convert';

import 'package:xstream_gate_pass_app/core/utils/helper.dart';

enum DeviceScanningMode {
  laser(0, "Laser"),
  keyboard(1, "Keyboard"),
  camera(2, "Camera");

  final int value;
  final String displayName;
  const DeviceScanningMode(this.value, this.displayName);
}

class DeviceConfig {
  DeviceScanningMode deviceScanningMode;

  DeviceConfig({
    required this.deviceScanningMode,
  });

  factory DeviceConfig.fromJson(Map<String, dynamic> jsonRes) => DeviceConfig(
        deviceScanningMode: DeviceScanningMode
            .values[asT<int>(jsonRes['deviceScanningMode']) ?? 0],
      );

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'deviceScanningMode': deviceScanningMode.value,
      };
}
