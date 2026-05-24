import 'package:xstream_gate_pass_app/core/enums/cms_survey_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_photo.dart';

enum CmsMediaUploadOwnerType {
  inspectionLine,
  survey;

  static CmsMediaUploadOwnerType fromValue(dynamic value) {
    final raw = cmsParseString(value)?.trim().toLowerCase();
    return CmsMediaUploadOwnerType.values.firstWhere(
      (item) => item.name.toLowerCase() == raw,
      orElse: () => CmsMediaUploadOwnerType.inspectionLine,
    );
  }
}

enum CmsMediaUploadState {
  awaitingSave,
  local,
  queued,
  uploading,
  uploaded,
  failed;

  static CmsMediaUploadState fromValue(dynamic value) {
    final raw = cmsParseString(value)?.trim().toLowerCase();
    return CmsMediaUploadState.values.firstWhere(
      (state) => state.name.toLowerCase() == raw,
      orElse: () => CmsMediaUploadState.local,
    );
  }
}

class CmsMediaUploadItem {
  static const int imageUploadType = 1;
  static const int documentUploadType = 2;

  const CmsMediaUploadItem({
    required this.ownerType,
    required this.clientUploadId,
    required this.state,
    this.rootId,
    this.referenceId,
    this.clientKey,
    this.documentId,
    this.name,
    this.documentFileName,
    this.documentFileSize,
    this.documentFileType,
    this.externalPath,
    this.localPath,
    this.capturedAtUtc,
    this.errorMessage,
    this.surveyType,
    this.uploadType,
    this.uploadMethod,
    this.attempts = 0,
    this.createdAtUtc,
  });

  factory CmsMediaUploadItem.fromJson(Map<String, dynamic> json) {
    final ownerType = CmsMediaUploadOwnerType.fromValue(json['ownerType']);
    return CmsMediaUploadItem(
      ownerType: ownerType,
      clientUploadId: cmsParseString(json['clientUploadId']) ?? '',
      state: CmsMediaUploadState.fromValue(json['state']),
      rootId: cmsParseInt(json['rootId']) ?? cmsParseInt(json['inspectionId']) ?? cmsParseInt(json['surveyId']),
      referenceId: cmsParseInt(json['referenceId']) ??
          cmsParseInt(json['inspectionLineId']) ??
          cmsParseInt(json['referanceID']) ??
          cmsParseInt(json['referanceId']),
      clientKey: cmsParseString(json['clientKey']),
      documentId: cmsParseInt(json['documentId']),
      name: cmsParseString(json['name']),
      documentFileName: cmsParseString(json['documentFileName']),
      documentFileSize: cmsParseString(json['documentFileSize']),
      documentFileType: cmsParseString(json['documentFileType']),
      externalPath: cmsParseString(json['externalPath']),
      localPath: cmsParseString(json['localPath']),
      capturedAtUtc: cmsParseDateTime(json['capturedAtUtc'])?.toUtc(),
      errorMessage: cmsParseString(json['errorMessage']),
      surveyType: json['surveyType'] == null ? null : CmsSurveyType.fromValue(json['surveyType']),
      uploadType: _detectUploadType(
        explicitValue: cmsParseInt(json['uploadType']),
        documentFileType: cmsParseString(json['documentFileType']),
        documentFileName: cmsParseString(json['documentFileName']) ?? cmsParseString(json['name']),
      ),
      uploadMethod: cmsParseInt(json['uploadMethod']),
      attempts: cmsParseInt(json['attempts']) ?? 0,
      createdAtUtc: cmsParseDateTime(json['createdAtUtc'])?.toUtc(),
    );
  }

  factory CmsMediaUploadItem.fromInspectionPhoto(CmsInspectionLinePhoto photo) {
    return CmsMediaUploadItem(
      ownerType: CmsMediaUploadOwnerType.inspectionLine,
      rootId: photo.inspectionId,
      referenceId: photo.inspectionLineId,
      clientKey: photo.clientKey,
      clientUploadId: photo.clientUploadId,
      documentId: photo.documentId,
      name: photo.name,
      documentFileName: photo.documentFileName,
      documentFileSize: photo.documentFileSize,
      documentFileType: photo.documentFileType,
      externalPath: photo.externalPath,
      localPath: photo.localPath,
      capturedAtUtc: photo.capturedAtUtc,
      state: _fromInspectionState(photo.state),
      errorMessage: photo.errorMessage,
      uploadType: imageUploadType,
      uploadMethod: 4,
      createdAtUtc: photo.capturedAtUtc,
    );
  }

  factory CmsMediaUploadItem.fromDocumentJson({
    required CmsMediaUploadOwnerType ownerType,
    required Map<String, dynamic> json,
    int? rootId,
    int? referenceId,
    String? clientKey,
    CmsSurveyType? surveyType,
    int? uploadMethod,
  }) {
    return CmsMediaUploadItem(
      ownerType: ownerType,
      rootId: rootId,
      referenceId: referenceId ?? cmsParseInt(json['referanceID']) ?? cmsParseInt(json['referanceId']),
      clientKey: clientKey,
      clientUploadId: cmsParseString(json['clientUploadId']) ?? 'remote-${cmsParseInt(json['id']) ?? DateTime.now().microsecondsSinceEpoch}',
      documentId: cmsParseInt(json['id']),
      name: cmsParseString(json['name']),
      documentFileName: cmsParseString(json['documentFileName']),
      documentFileSize: cmsParseString(json['documentFileSize']),
      documentFileType: cmsParseString(json['documentFileType']),
      externalPath: cmsParseString(json['externalPath']),
      capturedAtUtc: cmsParseDateTime(json['documentDateUploaded'])?.toUtc(),
      state: CmsMediaUploadState.uploaded,
      surveyType: surveyType,
      uploadType: _detectUploadType(
        explicitValue: cmsParseInt(json['uploadType']),
        documentFileType: cmsParseString(json['documentFileType']),
        documentFileName: cmsParseString(json['documentFileName']) ?? cmsParseString(json['name']),
      ),
      uploadMethod: uploadMethod,
      createdAtUtc: cmsParseDateTime(json['documentDateUploaded'])?.toUtc(),
    );
  }

  final CmsMediaUploadOwnerType ownerType;
  final int? rootId;
  final int? referenceId;
  final String? clientKey;
  final String clientUploadId;
  final int? documentId;
  final String? name;
  final String? documentFileName;
  final String? documentFileSize;
  final String? documentFileType;
  final String? externalPath;
  final String? localPath;
  final DateTime? capturedAtUtc;
  final CmsMediaUploadState state;
  final String? errorMessage;
  final CmsSurveyType? surveyType;
  final int? uploadType;
  final int? uploadMethod;
  final int attempts;
  final DateTime? createdAtUtc;

  bool get isPendingUpload => state == CmsMediaUploadState.queued || state == CmsMediaUploadState.failed;

  bool get isImage => (uploadType ?? imageUploadType) == imageUploadType || _looksLikeImage(documentFileType, documentFileName ?? name);

  bool get isDocument => !isImage;

  CmsInspectionLinePhoto toInspectionPhoto() {
    return CmsInspectionLinePhoto(
      inspectionId: rootId,
      inspectionLineId: referenceId,
      clientKey: clientKey,
      clientUploadId: clientUploadId,
      documentId: documentId,
      name: name,
      documentFileName: documentFileName,
      documentFileSize: documentFileSize,
      documentFileType: documentFileType,
      externalPath: externalPath,
      localPath: localPath,
      capturedAtUtc: capturedAtUtc,
      state: _toInspectionState(state),
      errorMessage: errorMessage,
    );
  }

  CmsMediaUploadItem copyWith({
    CmsMediaUploadOwnerType? ownerType,
    int? rootId,
    int? referenceId,
    String? clientKey,
    String? clientUploadId,
    int? documentId,
    String? name,
    String? documentFileName,
    String? documentFileSize,
    String? documentFileType,
    String? externalPath,
    String? localPath,
    DateTime? capturedAtUtc,
    CmsMediaUploadState? state,
    String? errorMessage,
    CmsSurveyType? surveyType,
    int? uploadType,
    int? uploadMethod,
    int? attempts,
    DateTime? createdAtUtc,
  }) {
    return CmsMediaUploadItem(
      ownerType: ownerType ?? this.ownerType,
      rootId: rootId ?? this.rootId,
      referenceId: referenceId ?? this.referenceId,
      clientKey: clientKey ?? this.clientKey,
      clientUploadId: clientUploadId ?? this.clientUploadId,
      documentId: documentId ?? this.documentId,
      name: name ?? this.name,
      documentFileName: documentFileName ?? this.documentFileName,
      documentFileSize: documentFileSize ?? this.documentFileSize,
      documentFileType: documentFileType ?? this.documentFileType,
      externalPath: externalPath ?? this.externalPath,
      localPath: localPath ?? this.localPath,
      capturedAtUtc: capturedAtUtc ?? this.capturedAtUtc,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      surveyType: surveyType ?? this.surveyType,
      uploadType: uploadType ?? this.uploadType,
      uploadMethod: uploadMethod ?? this.uploadMethod,
      attempts: attempts ?? this.attempts,
      createdAtUtc: createdAtUtc ?? this.createdAtUtc,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerType': ownerType.name,
      'rootId': rootId,
      'referenceId': referenceId,
      'clientKey': clientKey,
      'clientUploadId': clientUploadId,
      'documentId': documentId,
      'name': name,
      'documentFileName': documentFileName,
      'documentFileSize': documentFileSize,
      'documentFileType': documentFileType,
      'externalPath': externalPath,
      'localPath': localPath,
      'capturedAtUtc': capturedAtUtc?.toUtc().toIso8601String(),
      'state': state.name,
      'errorMessage': errorMessage,
      'surveyType': surveyType?.value,
      'uploadType': uploadType,
      'uploadMethod': uploadMethod,
      'attempts': attempts,
      'createdAtUtc': createdAtUtc?.toUtc().toIso8601String(),
      if (ownerType == CmsMediaUploadOwnerType.inspectionLine) ...{
        'inspectionId': rootId,
        'inspectionLineId': referenceId,
      },
      if (ownerType == CmsMediaUploadOwnerType.survey) ...{
        'surveyId': rootId,
      },
    };
  }

  static CmsMediaUploadState _fromInspectionState(CmsInspectionLinePhotoState state) {
    return CmsMediaUploadState.values.firstWhere(
      (item) => item.name == state.name,
      orElse: () => CmsMediaUploadState.local,
    );
  }

  static CmsInspectionLinePhotoState _toInspectionState(CmsMediaUploadState state) {
    return CmsInspectionLinePhotoState.values.firstWhere(
      (item) => item.name == state.name,
      orElse: () => CmsInspectionLinePhotoState.local,
    );
  }

  static int _detectUploadType({
    required int? explicitValue,
    required String? documentFileType,
    required String? documentFileName,
  }) {
    if (explicitValue != null && explicitValue > 0) {
      return explicitValue;
    }

    return _looksLikeImage(documentFileType, documentFileName) ? imageUploadType : documentUploadType;
  }

  static bool _looksLikeImage(String? documentFileType, String? documentFileName) {
    final normalizedType = documentFileType?.trim().toLowerCase();
    if (normalizedType != null && normalizedType.startsWith('image/')) {
      return true;
    }

    final lowerName = documentFileName?.trim().toLowerCase() ?? '';
    return lowerName.endsWith('.jpg') ||
        lowerName.endsWith('.jpeg') ||
        lowerName.endsWith('.png') ||
        lowerName.endsWith('.gif') ||
        lowerName.endsWith('.bmp') ||
        lowerName.endsWith('.webp');
  }
}
