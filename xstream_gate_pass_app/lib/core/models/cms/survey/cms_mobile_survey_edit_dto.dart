import 'package:xstream_gate_pass_app/core/enums/cms_survey_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';

class CmsMobileSurveyEditDto {
  const CmsMobileSurveyEditDto({
    this.id = 0,
    this.conductedBy,
    this.name,
    this.description,
    this.clientId,
    this.containerId,
    this.surveyType = CmsSurveyType.container,
    this.gatePassId,
    this.gatePassContainerId,
    this.shippingLineId,
    this.containerNo,
  });

  factory CmsMobileSurveyEditDto.empty({
    CmsSurveyType surveyType = CmsSurveyType.container,
    String? conductedBy,
    int? gatePassId,
    int? gatePassContainerId,
    String? containerNo,
    int? clientId,
    int? shippingLineId,
    int? containerId,
  }) {
    return CmsMobileSurveyEditDto(
      surveyType: surveyType,
      conductedBy: conductedBy,
      gatePassId: gatePassId,
      gatePassContainerId: gatePassContainerId,
      containerNo: containerNo,
      clientId: clientId,
      shippingLineId: shippingLineId,
      containerId: containerId,
    );
  }

  factory CmsMobileSurveyEditDto.fromJson(Map<String, dynamic> json) {
    return CmsMobileSurveyEditDto(
      id: cmsParseInt(json['id']) ?? 0,
      conductedBy: cmsParseString(json['conductedBy']),
      name: cmsParseString(json['name']),
      description: cmsParseString(json['description']),
      clientId: cmsParseInt(json['clientID']) ?? cmsParseInt(json['clientId']),
      containerId: cmsParseInt(json['containerId']),
      surveyType: CmsSurveyType.fromValue(json['surveyType']),
      gatePassId: cmsParseInt(json['gatePassId']) ?? cmsParseInt(json['gatePassID']),
      gatePassContainerId: cmsParseInt(json['gatePassContainerId']) ?? cmsParseInt(json['gatePassContainerID']),
      shippingLineId: cmsParseInt(json['shippingLineId']),
      containerNo: cmsParseString(json['containerNo']),
    );
  }

  final int id;
  final String? conductedBy;
  final String? name;
  final String? description;
  final int? clientId;
  final int? containerId;
  final CmsSurveyType surveyType;
  final int? gatePassId;
  final int? gatePassContainerId;
  final int? shippingLineId;
  final String? containerNo;

  bool get isSaved => id > 0;

  CmsMobileSurveyEditDto copyWith({
    int? id,
    String? conductedBy,
    String? name,
    String? description,
    int? clientId,
    int? containerId,
    CmsSurveyType? surveyType,
    int? gatePassId,
    int? gatePassContainerId,
    int? shippingLineId,
    String? containerNo,
  }) {
    return CmsMobileSurveyEditDto(
      id: id ?? this.id,
      conductedBy: conductedBy ?? this.conductedBy,
      name: name ?? this.name,
      description: description ?? this.description,
      clientId: clientId ?? this.clientId,
      containerId: containerId ?? this.containerId,
      surveyType: surveyType ?? this.surveyType,
      gatePassId: gatePassId ?? this.gatePassId,
      gatePassContainerId: gatePassContainerId ?? this.gatePassContainerId,
      shippingLineId: shippingLineId ?? this.shippingLineId,
      containerNo: containerNo ?? this.containerNo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conductedBy': conductedBy,
      'name': name,
      'description': description,
      'clientID': clientId,
      'containerId': containerId,
      'surveyType': surveyType.value,
      'gatePassId': gatePassId,
      'gatePassContainerId': gatePassContainerId,
      'shippingLineId': shippingLineId,
      'containerNo': containerNo,
    };
  }
}
