import 'dart:convert';

import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class BaselookupDto {
  BaselookupDto({required this.name, required this.id, required this.displayName, required this.isSelected});

  factory BaselookupDto.fromJson(Map<String, dynamic> jsonRes, {required String nameMap, required String displayNameMap}) => BaselookupDto(
        name: asT<String>(jsonRes[nameMap]) ?? "",
        displayName: asT<String>(jsonRes[displayNameMap]) ?? "",
        id: asT<int>(jsonRes['id']) ?? 0,
        isSelected: false,
      );

  String name;
  String displayName;
  int id;
  bool isSelected = false;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'id': id,
        'displayName': displayName,
      };
}
