import 'dart:convert';

import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class LocalizationValue {
  LocalizationValue({required this.key, required this.value});

  factory LocalizationValue.fromJson(Map<String, dynamic> jsonRes) =>
      LocalizationValue(
        key: asT<String>(jsonRes['key'] ?? "") ?? "",
        value: asT<String>(jsonRes['value'] ?? "") ?? "",
      );

  String key;
  String value;

  @override
  String toString() {
    return jsonEncode(this);
  }

  static LocalizationValue fromMap(Map<String, dynamic> map) {
    return LocalizationValue(
      key: map['key'],
      value: map['value'],
    );
  }

  Map<String, String> toJson() => <String, String>{
        'key': key,
        'value': value,
      };
}
