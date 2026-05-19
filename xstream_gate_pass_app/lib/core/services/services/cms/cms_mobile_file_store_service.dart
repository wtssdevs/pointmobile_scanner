import 'dart:io';

import 'package:dio/dio.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';
import 'package:xstream_gate_pass_app/core/models/cms/cms_response_envelope.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_photo.dart';
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

    final data = root['data'];
    if (data is List) {
      return cmsParseMapList(data);
    }

    return cmsParseMapList(root['items']);
  }
}
