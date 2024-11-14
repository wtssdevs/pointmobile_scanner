import 'dart:convert';

import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class BaseLookup {
  BaseLookup(
      {this.name,
      this.code,
      this.isActive,
      this.displayName,
      this.id,
      this.type});
  factory BaseLookup.fromJsonManualMap(Map<String, dynamic> jsonRes,
          {required String nameMap,
          required String displayNameMap,
          required String codeMap}) =>
      BaseLookup(
        name: asT<String>(jsonRes[nameMap]) ?? "",
        displayName: asT<String>(jsonRes[displayNameMap]) ?? "",
        id: asT<int>(jsonRes['id']) ?? 0,
        isActive: asT<bool?>(jsonRes['isActive']),
        code: asT<String?>(jsonRes[codeMap]),
      );
  factory BaseLookup.fromJson(Map<String, dynamic> jsonRes) => BaseLookup(
        name: asT<String?>(jsonRes['name']),
        isActive: asT<bool?>(jsonRes['isActive']),
        displayName: asT<String?>(jsonRes['displayName']),
        id: asT<int?>(jsonRes['id']),
        type: asT<int?>(jsonRes['type']),
      );

  String? name;
  String? code;
  bool? isActive;
  String? displayName;
  int? id;
  int? type;

  @override
  String toString() {
    return jsonEncode(this);
  }

  bool isEqualToServer(BaseLookup l) {
    return id == l.id &&
        name == l.name &&
        code == l.code &&
        displayName == l.displayName &&
        type == l.type;
  }

  void mergeUpdate(BaseLookup server) {
    if (id == server.id) {
      name = server.name;
      isActive = server.isActive;
      displayName = server.displayName;
      type = server.type;
      code = server.code;
    }
  }

  List<BaseLookup> listFromJson(Map<String, dynamic> jsonRes) {
    final List<BaseLookup> newStopTypes = <BaseLookup>[];
    if (jsonRes is List) {
      for (final dynamic item in jsonRes.entries) {
        if (item != null) {
          newStopTypes
              .add(BaseLookup.fromJson(asT<Map<String, dynamic>>(item)!));
        }
      }
    }

    return newStopTypes;
  }

  Map<String, dynamic> toJsonFromServerAPI() => <String, dynamic>{
        'name': name,
        'isActive': isActive,
        'displayName': displayName,
        'id': id,
        'type': type,
        'code': code,
      };
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'isActive': isActive,
        'displayName': displayName,
        'id': id,
        'type': type,
        'code': code,
      };
}
