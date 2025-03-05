import 'package:xstream_gate_pass_app/core/models/shared/base_lookup.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class UserLoginInfo {
  String? name;
  String? surname;
  String? fullName;
  String? emailAddress;
  int? id;
  List<BaseLookup> userBranches;

  //settings for device per users

  String get showFullName => (name ?? "") + (' $surname' ?? "");

  UserLoginInfo({
    this.name,
    this.surname,
    this.fullName,
    this.emailAddress,
    this.id,
    this.userBranches = const [],
  });
  factory UserLoginInfo.fromJson(Map<String, dynamic> json) {
    var user = UserLoginInfo(
      name: asT<String?>(json['name']) ?? null,
      surname: asT<String?>(json['surname']) ?? null,
      fullName: asT<String?>(json['fullName']) ?? null,
      emailAddress: asT<String?>(json['emailAddress']) ?? null,
      id: asT<int?>(json['id']) ?? null,
    );
    if (json['userBranches'] != null) {
      var userBranches = <BaseLookup>[];
      for (final dynamic item in json['userBranches']) {
        if (item != null) {
          var newL = BaseLookup.fromJsonManualMap(item,
              idMap: "branchId",
              displayNameMap: "branchName",
              nameMap: "branchName",
              codeMap: "branchCode");
          if (newL.id != null &&
              newL.id != 0 &&
              newL.code != null &&
              newL.name != '') {
            //could map
            userBranches.add(newL);
          } else {
            var newL = BaseLookup.fromJsonManualMap(item,
                idMap: "id",
                displayNameMap: "name",
                nameMap: "name",
                codeMap: "code");
            if (newL.id != null &&
                newL.id != 0 &&
                newL.code != null &&
                newL.name != '') {
              userBranches.add(newL);
            }
          }
        }
      }
      user.userBranches = userBranches;
    }
    //IF LOCAL DECODE MAPPING CHNAGE HERE

    return user;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = name;
    data['surname'] = surname;
    data['fullName'] = fullName;
    data['emailAddress'] = emailAddress;
    data['id'] = id;
    data['userBranches'] = userBranches.map((e) => e.toJson()).toList();
    return data;
  }
}
