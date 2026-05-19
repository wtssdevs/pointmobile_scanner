import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';

class CmsInspectionLineEdit {
  static const String _panelMetadataPrefix = 'PANEL:';

  CmsInspectionLineEdit({
    this.id = 0,
    this.clientKey,
    this.containerNo,
    this.descriptionOne,
    this.descriptionTwo,
    this.descriptionThree,
    this.qty,
    this.cost,
    this.vatAmount,
    this.total,
    this.labourQty,
    this.labourRate,
    this.isVat = false,
    this.quotationId,
    this.quoteAuthorizationId,
    this.inspectionLocationId,
    this.inspectionItemId,
    this.inspectionActionId,
    this.inspectionDamageId,
    this.inspectionContainerName,
    this.inspectionLocationName,
    this.inspectionItemName,
    this.inspectionActionName,
    this.inspectionDamageName,
    this.discountAmount,
    this.discount,
    this.vatPercentage,
    this.subTotal,
    this.inspectionId,
    this.inspectionTransactionNo,
    this.inspectionItemCode,
    this.inspectionLocationCode,
    this.inspectionDamageCode,
    this.inspectionActionCode,
    this.partNumber,
    this.repairsStarted = false,
    this.repairsCompleted = false,
    this.hasTax = false,
  });

  factory CmsInspectionLineEdit.fromJson(Map<String, dynamic> json) {
    return CmsInspectionLineEdit(
      id: cmsParseInt(json['id']) ?? 0,
      clientKey: cmsParseString(json['clientKey']),
      containerNo: cmsParseString(json['containerNo']),
      descriptionOne: cmsParseString(json['descriptionOne']),
      descriptionTwo: cmsParseString(json['descriptionTwo']),
      descriptionThree: cmsParseString(json['descriptionThree']),
      qty: cmsParseDouble(json['qty']),
      cost: cmsParseDouble(json['cost']),
      vatAmount: cmsParseDouble(json['vatAmount']),
      total: cmsParseDouble(json['total']),
      labourQty: cmsParseDouble(json['labourQty']),
      labourRate: cmsParseDouble(json['labourRate']),
      isVat: cmsParseBool(json['isvat']) ?? cmsParseBool(json['isVat']) ?? false,
      quotationId: cmsParseInt(json['quotationId']),
      quoteAuthorizationId: cmsParseInt(json['quoteAuthorizationId']),
      inspectionLocationId: cmsParseInt(json['inspectionLocationId']),
      inspectionItemId: cmsParseInt(json['inspectionItemId']),
      inspectionActionId: cmsParseInt(json['inspectionActionId']),
      inspectionDamageId: cmsParseInt(json['inspectionDamageId']),
      inspectionContainerName: cmsParseString(json['inspectionContainerName']),
      inspectionLocationName: cmsParseString(json['inspectionLocationName']),
      inspectionItemName: cmsParseString(json['inspectionItemName']),
      inspectionActionName: cmsParseString(json['inspectionActionName']),
      inspectionDamageName: cmsParseString(json['inspectionDamageName']),
      discountAmount: cmsParseDouble(json['discountAmount']),
      discount: cmsParseDouble(json['discount']),
      vatPercentage: cmsParseDouble(json['vatPercentage']),
      subTotal: cmsParseDouble(json['subTotal']),
      inspectionId: cmsParseInt(json['inspectionId']),
      inspectionTransactionNo: cmsParseString(json['inspectionTransactionNo']),
      inspectionItemCode: cmsParseString(json['inspectionItemCode']),
      inspectionLocationCode: cmsParseString(json['inspectionLocationCode']),
      inspectionDamageCode: cmsParseString(json['inspectionDamageCode']),
      inspectionActionCode: cmsParseString(json['inspectionActionCode']),
      partNumber: cmsParseString(json['partNumber']),
      repairsStarted: cmsParseBool(json['repairsStarted']) ?? false,
      repairsCompleted: cmsParseBool(json['repairsCompleted']) ?? false,
      hasTax: cmsParseBool(json['hasTax']) ?? false,
    );
  }

  int id;
  String? clientKey;
  String? containerNo;
  String? descriptionOne;
  String? descriptionTwo;
  String? descriptionThree;
  double? qty;
  double? cost;
  double? vatAmount;
  double? total;
  double? labourQty;
  double? labourRate;
  bool isVat;
  int? quotationId;
  int? quoteAuthorizationId;
  int? inspectionLocationId;
  int? inspectionItemId;
  int? inspectionActionId;
  int? inspectionDamageId;
  String? inspectionContainerName;
  String? inspectionLocationName;
  String? inspectionItemName;
  String? inspectionActionName;
  String? inspectionDamageName;
  double? discountAmount;
  double? discount;
  double? vatPercentage;
  double? subTotal;
  int? inspectionId;
  String? inspectionTransactionNo;
  String? inspectionItemCode;
  String? inspectionLocationCode;
  String? inspectionDamageCode;
  String? inspectionActionCode;
  String? partNumber;
  bool repairsStarted;
  bool repairsCompleted;
  bool hasTax;

  CmsInspectionLineEdit clone() => CmsInspectionLineEdit.fromJson(toJson());

  double get estimatedSubtotal => ((qty ?? 0) * (cost ?? 0)) + ((labourQty ?? 0) * (labourRate ?? 0));

  String? get panelCode {
    final raw = _panelSegments();
    if (raw.isEmpty) {
      return null;
    }

    final code = raw.first.substring(_panelMetadataPrefix.length).trim().toUpperCase();
    return code.isEmpty ? null : code;
  }

  double? get panelX => _parsePanelCoordinate('X');

  double? get panelY => _parsePanelCoordinate('Y');

  void applyPanelMetadata({
    required String panelCode,
    double? x,
    double? y,
  }) {
    final normalizedPanelCode = panelCode.trim().toUpperCase();
    if (normalizedPanelCode.isEmpty) {
      clearPanelMetadata();
      return;
    }

    final segments = <String>[
      '$_panelMetadataPrefix$normalizedPanelCode',
      if (x != null) 'X:${_formatCoordinate(x)}',
      if (y != null) 'Y:${_formatCoordinate(y)}',
    ];

    descriptionThree = segments.join('|');
  }

  void clearPanelMetadata() {
    if ((_panelSegments()).isEmpty) {
      return;
    }

    descriptionThree = null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientKey': clientKey,
      'containerNo': containerNo,
      'descriptionOne': descriptionOne,
      'descriptionTwo': descriptionTwo,
      'descriptionThree': descriptionThree,
      'qty': qty,
      'cost': cost,
      'vatAmount': vatAmount,
      'total': total,
      'labourQty': labourQty,
      'labourRate': labourRate,
      'isvat': isVat,
      'quotationId': quotationId,
      'quoteAuthorizationId': quoteAuthorizationId,
      'inspectionLocationId': inspectionLocationId,
      'inspectionItemId': inspectionItemId,
      'inspectionActionId': inspectionActionId,
      'inspectionDamageId': inspectionDamageId,
      'inspectionContainerName': inspectionContainerName,
      'inspectionLocationName': inspectionLocationName,
      'inspectionItemName': inspectionItemName,
      'inspectionActionName': inspectionActionName,
      'inspectionDamageName': inspectionDamageName,
      'discountAmount': discountAmount,
      'discount': discount,
      'vatPercentage': vatPercentage,
      'subTotal': subTotal,
      'inspectionId': inspectionId,
      'inspectionTransactionNo': inspectionTransactionNo,
      'inspectionItemCode': inspectionItemCode,
      'inspectionLocationCode': inspectionLocationCode,
      'inspectionDamageCode': inspectionDamageCode,
      'inspectionActionCode': inspectionActionCode,
      'partNumber': partNumber,
      'repairsStarted': repairsStarted,
      'repairsCompleted': repairsCompleted,
      'hasTax': hasTax,
    };
  }

  List<String> _panelSegments() {
    final raw = descriptionThree?.trim();
    if (raw == null || raw.isEmpty || !raw.startsWith(_panelMetadataPrefix)) {
      return const <String>[];
    }

    return raw.split('|').map((segment) => segment.trim()).where((segment) => segment.isNotEmpty).toList(growable: false);
  }

  double? _parsePanelCoordinate(String key) {
    final segments = _panelSegments();
    if (segments.isEmpty) {
      return null;
    }

    for (final segment in segments.skip(1)) {
      final separatorIndex = segment.indexOf(':');
      if (separatorIndex <= 0) {
        continue;
      }

      final candidateKey = segment.substring(0, separatorIndex).trim().toUpperCase();
      if (candidateKey != key) {
        continue;
      }

      return double.tryParse(segment.substring(separatorIndex + 1).trim());
    }

    return null;
  }

  String _formatCoordinate(double value) {
    final boundedValue = value.clamp(0.0, 1.0);
    return boundedValue.toStringAsFixed(3);
  }
}
