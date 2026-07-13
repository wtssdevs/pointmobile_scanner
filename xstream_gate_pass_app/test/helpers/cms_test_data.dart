import 'package:xstream_gate_pass_app/core/models/cms/account/cms_current_login_information.dart';

Map<String, dynamic> buildCmsSessionJson({
  int userId = 42,
  int tenantId = 7,
}) {
  return {
    'user': {
      'id': userId,
      'name': 'Jane',
      'surname': 'Doe',
      'userName': 'jane.doe',
      'fullName': 'Jane Doe',
      'emailAddress': 'jane@example.com',
      'userAccountTypes': 0,
      'userTypeRefId': 99,
      'lastPasswordUpdateTime': '2026-05-01T12:00:00Z',
      'resetPassword': false,
    },
    'tenant': {
      'id': tenantId,
      'tenancyName': 'tenant-a',
      'name': 'Tenant A',
      'strictContainerNumber': true,
      'countryID': 1,
      'currencyID': 2,
      'taxFactor': 15.5,
      'image': [1, 2, 3, 4],
    },
    'userDepots': [
      {
        'id': 101,
        'displayName': 'Main Depot',
        'depotCode': 'DPT1',
        'depoType': 1,
        'yardType': 2,
        'yard': {
          'id': 201,
          'tenantId': tenantId,
          'yardCode': 'Y1',
          'yardName': 'Primary Yard',
          'columns': 10,
          'rows': 20,
          'levels': 3,
          'gatePassTargetMin': 30,
          'gatePassTargetHours': 2,
          'yardType': 2,
        },
      }
    ],
    'userYards': [
      {
        'id': 201,
        'tenantId': tenantId,
        'yardCode': 'Y1',
        'yardName': 'Primary Yard',
        'columns': 10,
        'rows': 20,
        'levels': 3,
        'gatePassTargetMin': 30,
        'gatePassTargetHours': 2,
        'yardType': 2,
      }
    ],
  };
}

CmsCurrentLoginInformation buildCmsSessionModel({
  int userId = 42,
  int tenantId = 7,
}) {
  return CmsCurrentLoginInformation.fromJson(
    buildCmsSessionJson(userId: userId, tenantId: tenantId),
  );
}

Map<String, dynamic> buildInspectionLocationJson(
  int id, {
  int tenantId = 7,
  bool isActive = true,
  int? shippingLineId,
  String? code,
  String? name,
}) {
  return {
    'id': id,
    'tenantId': tenantId,
    'name': name ?? 'Location $id',
    'code': code ?? 'LOC$id',
    'altCode': 'ALT$id',
    'isActive': isActive,
    'postingCodeId': 100 + id,
    'postingCodeName': 'POST$id',
    'shippingLineID': shippingLineId,
    'shippingLineName': shippingLineId == null ? null : 'Line $shippingLineId',
    'creatorUserFullName': 'Creator $id',
    'lastModifiedUserFullName': 'Modifier $id',
    'creationTime': '2026-05-01T00:00:00Z',
    'lastModificationTime': '2026-05-02T00:00:00Z',
  };
}

Map<String, dynamic> buildInspectionActionJson(
  int id, {
  dynamic labourRate = 10.5,
  dynamic cost = 20,
  int? shippingLineId,
}) {
  final json = buildInspectionLocationJson(
    id,
    shippingLineId: shippingLineId,
    code: 'ACT$id',
    name: 'Action $id',
  );
  json['labourRate'] = labourRate;
  json['cost'] = cost;
  return json;
}

Map<String, dynamic> buildInspectionItemJson(
  int id, {
  int? shippingLineId,
}) {
  final json = buildInspectionLocationJson(
    id,
    shippingLineId: shippingLineId,
    code: 'ITM$id',
    name: 'Item $id',
  );
  json['itemCodeId'] = 500 + id;
  return json;
}

Map<String, dynamic> buildItemCodeJson(
  int id, {
  String? code,
  String? description,
  dynamic quantity = 1,
  dynamic unitPrice = 10,
  dynamic labourRate,
  dynamic grossWeight = 2.5,
}) {
  return {
    'id': id,
    'tenantId': 7,
    'code': code ?? 'PART$id',
    'description': description ?? 'Part $id',
    'quantity': quantity,
    'unitPrice': unitPrice,
    'labourRate': labourRate,
    'grossWeight': grossWeight,
  };
}

List<Map<String, dynamic>> buildInspectionLocationPage({
  required int skip,
  required int take,
  required int total,
}) {
  if (skip >= total) {
    return const [];
  }

  final endExclusive = (skip + take) > total ? total : (skip + take);
  return List.generate(
    endExclusive - skip,
    (index) => buildInspectionLocationJson(skip + index + 1),
    growable: false,
  );
}
