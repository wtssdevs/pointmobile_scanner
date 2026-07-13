import 'package:xstream_gate_pass_app/core/models/account/GetCurrentLoginInformation.dart';
import 'package:xstream_gate_pass_app/core/models/account/TenantLoginInfo.dart';
import 'package:xstream_gate_pass_app/core/models/account/UserLoginInfo.dart';
import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';

class CmsCurrentLoginInformation {
  CmsCurrentLoginInformation({
    this.user,
    this.tenant,
    this.userDepots = const [],
    this.userYards = const [],
  });

  factory CmsCurrentLoginInformation.fromJson(Map<String, dynamic> json) {
    return CmsCurrentLoginInformation(
      user: cmsParseMap(json['user']) == null ? null : CmsUserLoginInfo.fromJson(cmsParseMap(json['user'])!),
      tenant: cmsParseMap(json['tenant']) == null ? null : CmsTenantLoginInfo.fromJson(cmsParseMap(json['tenant'])!),
      userDepots: cmsParseMapList(json['userDepots']).map(CmsUserDepot.fromJson).toList(growable: false),
      userYards: cmsParseMapList(json['userYards']).map(CmsYard.fromJson).toList(growable: false),
    );
  }

  final CmsUserLoginInfo? user;
  final CmsTenantLoginInfo? tenant;
  final List<CmsUserDepot> userDepots;
  final List<CmsYard> userYards;

  int get depotCount => userDepots.length;
  int get yardCount => userYards.length;

  CurrentLoginInformation toLegacyCurrentLoginInformation() {
    return CurrentLoginInformation(
      user: UserLoginInfo(
        id: user?.id,
        name: user?.name,
        surname: user?.surname,
        fullName: user?.fullName,
        emailAddress: user?.emailAddress,
      ),
      tenant: TenantLoginInfo(
        id: tenant?.id ?? 0,
        name: tenant?.name ?? '',
        tenancyName: tenant?.tenancyName ?? '',
        code: '',
        taxFactor: tenant?.taxFactor ?? 0,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user?.toJson(),
      'tenant': tenant?.toJson(),
      'userDepots': userDepots.map((item) => item.toJson()).toList(),
      'userYards': userYards.map((item) => item.toJson()).toList(),
    };
  }
}

class CmsUserLoginInfo {
  CmsUserLoginInfo({
    this.id,
    this.name,
    this.surname,
    this.userName,
    this.fullName,
    this.emailAddress,
    this.userAccountTypes,
    this.userTypeRefId,
    this.lastPasswordUpdateTime,
    this.resetPassword,
  });

  factory CmsUserLoginInfo.fromJson(Map<String, dynamic> json) {
    return CmsUserLoginInfo(
      id: cmsParseInt(json['id']),
      name: cmsParseString(json['name']),
      surname: cmsParseString(json['surname']),
      userName: cmsParseString(json['userName']),
      fullName: cmsParseString(json['fullName']),
      emailAddress: cmsParseString(json['emailAddress']),
      userAccountTypes: cmsParseInt(json['userAccountTypes']),
      userTypeRefId: cmsParseInt(json['userTypeRefId']),
      lastPasswordUpdateTime: cmsParseDateTime(json['lastPasswordUpdateTime']),
      resetPassword: cmsParseBool(json['resetPassword']),
    );
  }

  final int? id;
  final String? name;
  final String? surname;
  final String? userName;
  final String? fullName;
  final String? emailAddress;
  final int? userAccountTypes;
  final int? userTypeRefId;
  final DateTime? lastPasswordUpdateTime;
  final bool? resetPassword;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'surname': surname,
      'userName': userName,
      'fullName': fullName,
      'emailAddress': emailAddress,
      'userAccountTypes': userAccountTypes,
      'userTypeRefId': userTypeRefId,
      'lastPasswordUpdateTime': lastPasswordUpdateTime?.toIso8601String(),
      'resetPassword': resetPassword,
    };
  }
}

class CmsTenantLoginInfo {
  CmsTenantLoginInfo({
    this.id,
    this.tenancyName,
    this.name,
    this.strictContainerNumber,
    this.countryId,
    this.currencyId,
    this.taxFactor,
    this.image,
  });

  factory CmsTenantLoginInfo.fromJson(Map<String, dynamic> json) {
    return CmsTenantLoginInfo(
      id: cmsParseInt(json['id']),
      tenancyName: cmsParseString(json['tenancyName']),
      name: cmsParseString(json['name']),
      strictContainerNumber: cmsParseBool(json['strictContainerNumber']),
      countryId: cmsParseInt(json['countryID']),
      currencyId: cmsParseInt(json['currencyID']),
      taxFactor: cmsParseDouble(json['taxFactor']),
      image: cmsParseBase64Bytes(json['image']),
    );
  }

  final int? id;
  final String? tenancyName;
  final String? name;
  final bool? strictContainerNumber;
  final int? countryId;
  final int? currencyId;
  final double? taxFactor;
  final String? image;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenancyName': tenancyName,
      'name': name,
      'strictContainerNumber': strictContainerNumber,
      'countryID': countryId,
      'currencyID': currencyId,
      'taxFactor': taxFactor,
      'image': image,
    };
  }
}

class CmsUserDepot {
  CmsUserDepot({
    this.id,
    this.displayName,
    this.depotCode,
    this.depoType,
    this.yardType,
    this.yard,
  });

  factory CmsUserDepot.fromJson(Map<String, dynamic> json) {
    return CmsUserDepot(
      id: cmsParseInt(json['id']),
      displayName: cmsParseString(json['displayName']),
      depotCode: cmsParseString(json['depotCode']),
      depoType: cmsParseInt(json['depoType']),
      yardType: cmsParseInt(json['yardType']),
      yard: cmsParseMap(json['yard']) == null ? null : CmsYard.fromJson(cmsParseMap(json['yard'])!),
    );
  }

  final int? id;
  final String? displayName;
  final String? depotCode;
  final int? depoType;
  final int? yardType;
  final CmsYard? yard;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'depotCode': depotCode,
      'depoType': depoType,
      'yardType': yardType,
      'yard': yard?.toJson(),
    };
  }
}

class CmsYard {
  CmsYard({
    this.id,
    this.tenantId,
    this.yardCode,
    this.yardName,
    this.columns,
    this.rows,
    this.levels,
    this.gatePassTargetMin,
    this.gatePassTargetHours,
    this.yardType,
  });

  factory CmsYard.fromJson(Map<String, dynamic> json) {
    return CmsYard(
      id: cmsParseInt(json['id']),
      tenantId: cmsParseInt(json['tenantId']),
      yardCode: cmsParseString(json['yardCode']),
      yardName: cmsParseString(json['yardName']),
      columns: cmsParseInt(json['columns']),
      rows: cmsParseInt(json['rows']),
      levels: cmsParseInt(json['levels']),
      gatePassTargetMin: cmsParseInt(json['gatePassTargetMin']),
      gatePassTargetHours: cmsParseInt(json['gatePassTargetHours']),
      yardType: cmsParseInt(json['yardType']),
    );
  }

  final int? id;
  final int? tenantId;
  final String? yardCode;
  final String? yardName;
  final int? columns;
  final int? rows;
  final int? levels;
  final int? gatePassTargetMin;
  final int? gatePassTargetHours;
  final int? yardType;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'yardCode': yardCode,
      'yardName': yardName,
      'columns': columns,
      'rows': rows,
      'levels': levels,
      'gatePassTargetMin': gatePassTargetMin,
      'gatePassTargetHours': gatePassTargetHours,
      'yardType': yardType,
    };
  }
}
