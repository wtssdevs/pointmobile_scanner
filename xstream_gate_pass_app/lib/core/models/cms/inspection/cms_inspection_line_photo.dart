import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';

enum CmsInspectionLinePhotoState {
  awaitingSave,
  local,
  queued,
  uploading,
  uploaded,
  failed,
}

class CmsInspectionLinePhoto {
  const CmsInspectionLinePhoto({
    required this.clientUploadId,
    required this.state,
    this.inspectionId,
    this.inspectionLineId,
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
  });

  factory CmsInspectionLinePhoto.fromDocumentJson(Map<String, dynamic> json) {
    return CmsInspectionLinePhoto(
      clientUploadId: cmsParseString(json['clientUploadId']) ?? '',
      state: CmsInspectionLinePhotoState.uploaded,
      inspectionLineId:
          cmsParseInt(json['referanceID']) ?? cmsParseInt(json['referanceId']),
      documentId: cmsParseInt(json['id']),
      name: cmsParseString(json['name']),
      documentFileName: cmsParseString(json['documentFileName']),
      documentFileSize: cmsParseString(json['documentFileSize']),
      documentFileType: cmsParseString(json['documentFileType']),
      externalPath: cmsParseString(json['externalPath']),
      capturedAtUtc: cmsParseDateTime(json['documentDateUploaded'])?.toUtc(),
    );
  }

  factory CmsInspectionLinePhoto.fromJson(Map<String, dynamic> json) {
    return CmsInspectionLinePhoto(
      clientUploadId: cmsParseString(json['clientUploadId']) ?? '',
      state: _parseState(json['state']),
      inspectionId: cmsParseInt(json['inspectionId']),
      inspectionLineId: cmsParseInt(json['inspectionLineId']),
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
    );
  }

  final int? inspectionId;
  final int? inspectionLineId;
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
  final CmsInspectionLinePhotoState state;
  final String? errorMessage;

  CmsInspectionLinePhoto copyWith({
    int? inspectionId,
    int? inspectionLineId,
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
    CmsInspectionLinePhotoState? state,
    String? errorMessage,
  }) {
    return CmsInspectionLinePhoto(
      inspectionId: inspectionId ?? this.inspectionId,
      inspectionLineId: inspectionLineId ?? this.inspectionLineId,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'inspectionId': inspectionId,
      'inspectionLineId': inspectionLineId,
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
    };
  }

  static CmsInspectionLinePhotoState _parseState(dynamic value) {
    final raw = cmsParseString(value)?.trim().toLowerCase();
    return CmsInspectionLinePhotoState.values.firstWhere(
      (state) => state.name.toLowerCase() == raw,
      orElse: () => CmsInspectionLinePhotoState.local,
    );
  }
}
