import 'package:xstream_gate_pass_app/core/enums/cms_survey_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';

class CmsMobileSurveyListDto {
  const CmsMobileSurveyListDto({
    required this.id,
    required this.surveyType,
    this.conductedBy,
    this.name,
    this.description,
    this.clientId,
    this.clientName,
    this.shippingLineId,
    this.shippingLineName,
    this.gatePassId,
    this.gatePassContainerId,
    this.containerNo,
    this.creationTime,
    this.lastModificationTime,
  });

  factory CmsMobileSurveyListDto.fromJson(Map<String, dynamic> json) {
    return CmsMobileSurveyListDto(
      id: cmsParseInt(json['id']) ?? 0,
      conductedBy: cmsParseString(json['conductedBy']),
      name: cmsParseString(json['name']),
      description: cmsParseString(json['description']),
      surveyType: CmsSurveyType.fromValue(json['surveyType']),
      clientId: cmsParseInt(json['clientID']) ?? cmsParseInt(json['clientId']),
      clientName: cmsParseString(json['clientName']),
      shippingLineId: cmsParseInt(json['shippingLineId']),
      shippingLineName: cmsParseString(json['shippingLineName']),
      gatePassId: cmsParseInt(json['gatePassID']) ?? cmsParseInt(json['gatePassId']),
      gatePassContainerId: cmsParseInt(json['gatePassContainerID']) ?? cmsParseInt(json['gatePassContainerId']),
      containerNo: cmsParseString(json['containerNo']),
      creationTime: cmsParseDateTime(json['creationTime'])?.toLocal(),
      lastModificationTime: cmsParseDateTime(json['lastModificationTime'])?.toLocal(),
    );
  }

  final int id;
  final String? conductedBy;
  final String? name;
  final String? description;
  final CmsSurveyType surveyType;
  final int? clientId;
  final String? clientName;
  final int? shippingLineId;
  final String? shippingLineName;
  final int? gatePassId;
  final int? gatePassContainerId;
  final String? containerNo;
  final DateTime? creationTime;
  final DateTime? lastModificationTime;

  DateTime? get displayDate => lastModificationTime ?? creationTime;

  String get title {
    final parts =
        <String?>[containerNo, clientName, name].where((item) => item != null && item.trim().isNotEmpty).cast<String>().toList(growable: false);
    return parts.isEmpty ? 'Survey #$id' : parts.first;
  }

  String get subtitle {
    final parts = <String>[
      surveyType.displayName,
      if (clientName != null && clientName!.trim().isNotEmpty) clientName!,
      if (conductedBy != null && conductedBy!.trim().isNotEmpty) 'By $conductedBy',
    ];
    return parts.join(' • ');
  }
}
