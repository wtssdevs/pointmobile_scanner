import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_survey_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';
import 'package:xstream_gate_pass_app/core/models/cms/cms_response_envelope.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_photo.dart';
import 'package:xstream_gate_pass_app/core/models/cms/media/cms_media_upload_item.dart';
import 'package:xstream_gate_pass_app/core/services/api/cms_api_manager.dart';

@LazySingleton()
class CmsMobileFileStoreService {
  CmsMobileFileStoreService([CmsApiManager? apiManager]) : _apiManager = apiManager ?? locator<CmsApiManager>();

  final CmsApiManager _apiManager;

  Future<CmsInspectionLinePhoto> uploadInspectionLinePhoto({
    required int inspectionId,
    required int inspectionLineId,
    required String filePath,
    required String documentFileName,
    required String contentType,
    required String clientUploadId,
    DateTime? capturedAtUtc,
    ProgressCallback? onSendProgress,
  }) async {
    final file = File(filePath);
    final length = await file.length();
    if (length > AppConst.CmsInspectionLinePhotoMaxBytes) {
      throw StateError('Inspection line photos must be 8 MB or smaller after compression.');
    }

    final formData = FormData.fromMap({
      'inspectionId': inspectionId,
      'inspectionLineId': inspectionLineId,
      'documentFileName': documentFileName,
      'contentType': contentType,
      'clientUploadId': clientUploadId,
      if (capturedAtUtc != null) 'capturedAtUtc': capturedAtUtc.toUtc().toIso8601String(),
      'file': await MultipartFile.fromFile(filePath, filename: documentFileName),
    });

    final response = await _apiManager.post(
      AppConst.CmsInspectionLinePhotoUpload,
      data: formData,
      showLoader: false,
      onSendProgress: onSendProgress,
    );

    return CmsInspectionLinePhoto.fromDocumentJson(CmsResponseEnvelope.unwrapMap(response));
  }

  Future<List<CmsInspectionLinePhoto>> listInspectionLinePhotos(int inspectionLineId) async {
    final response = await _apiManager.get(
      AppConst.cmsInspectionLinePhotosForLine(inspectionLineId),
      showLoader: false,
    );

    return _unwrapList(response).map(CmsInspectionLinePhoto.fromDocumentJson).toList(growable: false);
  }

  Future<void> deleteInspectionLinePhoto(int documentId) async {
    await _apiManager.delete(
      AppConst.cmsInspectionLinePhotoDelete(documentId),
      showLoader: false,
    );
  }

  Future<CmsMediaUploadItem> uploadSurveyPhoto({
    required int surveyId,
    required int referenceId,
    required CmsSurveyType surveyType,
    required String filePath,
    required String documentFileName,
    required String contentType,
    required String clientUploadId,
    ProgressCallback? onSendProgress,
  }) async {
    return uploadSurveyMedia(
      surveyId: surveyId,
      referenceId: referenceId,
      surveyType: surveyType,
      uploadType: CmsMediaUploadItem.imageUploadType,
      filePath: filePath,
      documentFileName: documentFileName,
      contentType: contentType,
      clientUploadId: clientUploadId,
      onSendProgress: onSendProgress,
    );
  }

  Future<CmsMediaUploadItem> uploadSurveyDocument({
    required int surveyId,
    required int referenceId,
    required CmsSurveyType surveyType,
    required String filePath,
    required String documentFileName,
    required String contentType,
    required String clientUploadId,
    ProgressCallback? onSendProgress,
  }) async {
    return uploadSurveyMedia(
      surveyId: surveyId,
      referenceId: referenceId,
      surveyType: surveyType,
      uploadType: CmsMediaUploadItem.documentUploadType,
      filePath: filePath,
      documentFileName: documentFileName,
      contentType: contentType,
      clientUploadId: clientUploadId,
      onSendProgress: onSendProgress,
    );
  }

  Future<CmsMediaUploadItem> uploadSurveyMedia({
    required int surveyId,
    required int referenceId,
    required CmsSurveyType surveyType,
    required int uploadType,
    required String filePath,
    required String documentFileName,
    required String contentType,
    required String clientUploadId,
    ProgressCallback? onSendProgress,
  }) async {
    final file = File(filePath);
    final length = await file.length();
    final maxBytes = uploadType == CmsMediaUploadItem.documentUploadType ? AppConst.CmsMediaDocumentMaxBytes : AppConst.CmsMediaUploadMaxBytes;
    if (length > maxBytes) {
      throw StateError(uploadType == CmsMediaUploadItem.documentUploadType
          ? 'Survey documents must be 25 MB or smaller.'
          : 'Survey photos must be 8 MB or smaller after compression.');
    }

    final response = await _apiManager.post(
      AppConst.CmsLegacyFileUpload,
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: documentFileName),
      }),
      options: Options(headers: {
        'name': documentFileName,
        'uploadType': _surveyUploadTypeName(uploadType),
        'uploadMethod': _surveyUploadMethodName(surveyType),
        'referenceId': referenceId.toString(),
        'documentFileName': documentFileName,
        'documentFileType': contentType,
        'contentType': contentType,
        'clientUploadId': clientUploadId,
      }),
      showLoader: false,
      onSendProgress: onSendProgress,
    );

    final root = cmsParseMap(response);
    final documentId = cmsParseInt(response) ?? cmsParseInt(root?['result']) ?? cmsParseInt(root?['data']) ?? DateTime.now().millisecondsSinceEpoch;

    return CmsMediaUploadItem(
      ownerType: CmsMediaUploadOwnerType.survey,
      rootId: surveyId,
      referenceId: referenceId,
      clientUploadId: clientUploadId,
      documentId: documentId,
      name: documentFileName,
      documentFileName: documentFileName,
      documentFileSize: length.toString(),
      documentFileType: contentType,
      localPath: filePath,
      capturedAtUtc: DateTime.now().toUtc(),
      state: CmsMediaUploadState.uploaded,
      surveyType: surveyType,
      uploadType: uploadType,
      uploadMethod: _surveyUploadMethodValue(surveyType),
    );
  }

  Future<List<CmsMediaUploadItem>> listSurveyMedia({
    required int surveyId,
    required int referenceId,
    required CmsSurveyType surveyType,
  }) async {
    final uploadMethod = _surveyUploadMethodValue(surveyType);
    final response = await _apiManager.post(
      AppConst.CmsFileUploadGetAllDocsByRefId,
      data: {
        'id': referenceId,
        'uploadMethod': uploadMethod,
      },
      showLoader: false,
    );

    return _unwrapList(response)
        .map((json) => CmsMediaUploadItem.fromDocumentJson(
              ownerType: CmsMediaUploadOwnerType.survey,
              rootId: surveyId,
              referenceId: referenceId,
              surveyType: surveyType,
              uploadMethod: uploadMethod,
              json: json,
            ))
        .toList(growable: false);
  }

  Future<List<CmsMediaUploadItem>> listSurveyPhotos({
    required int surveyId,
    required int referenceId,
    required CmsSurveyType surveyType,
  }) async {
    final items = await listSurveyMedia(
      surveyId: surveyId,
      referenceId: referenceId,
      surveyType: surveyType,
    );

    return items.where((item) => item.isImage).toList(growable: false);
  }

  Future<List<CmsMediaUploadItem>> listSurveyAttachments({
    required int surveyId,
    required int referenceId,
    required CmsSurveyType surveyType,
  }) async {
    final items = await listSurveyMedia(
      surveyId: surveyId,
      referenceId: referenceId,
      surveyType: surveyType,
    );

    return items.where((item) => item.isDocument).toList(growable: false);
  }

  Future<void> deleteSurveyPhoto(int documentId) async {
    await deleteSurveyDocument(documentId);
  }

  Future<void> deleteSurveyDocument(int documentId) async {
    await _apiManager.post(
      AppConst.CmsFileUploadDeleteDocument,
      data: {'inputId': documentId},
      showLoader: false,
    );
  }

  Future<String> downloadDocument({
    required int documentId,
    required String fileName,
    Directory? targetDirectory,
  }) async {
    final bytes = await _apiManager.getBytes(
      AppConst.cmsFileUploadDownload(documentId),
      showLoader: false,
    );
    if (bytes.isEmpty) {
      throw StateError('Document download returned no data.');
    }

    final directory = targetDirectory ?? await getTemporaryDirectory();
    await directory.create(recursive: true);
    final safeFileName = fileName.trim().isEmpty ? 'cms-document-$documentId' : fileName.trim();
    final file = File(path.join(directory.path, safeFileName));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  List<Map<String, dynamic>> _unwrapList(dynamic response) {
    if (response is List) {
      return cmsParseMapList(response);
    }

    final root = cmsParseMap(response);
    if (root == null) {
      return const [];
    }

    final result = root['result'];
    if (result is List) {
      return cmsParseMapList(result);
    }

    final resultMap = cmsParseMap(result);
    if (resultMap != null) {
      final resultItems = resultMap['items'];
      if (resultItems is List) {
        return cmsParseMapList(resultItems);
      }
    }

    final data = root['data'];
    if (data is List) {
      return cmsParseMapList(data);
    }

    return cmsParseMapList(root['items']);
  }

  String _surveyUploadMethodName(CmsSurveyType surveyType) {
    return surveyType == CmsSurveyType.gatePass ? 'GatePass' : 'ContainerManagement';
  }

  String _surveyUploadTypeName(int uploadType) {
    return uploadType == CmsMediaUploadItem.documentUploadType ? 'Files' : 'Img';
  }

  int _surveyUploadMethodValue(CmsSurveyType surveyType) {
    return surveyType == CmsSurveyType.gatePass ? 2 : 3;
  }
}
