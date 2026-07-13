import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_survey_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/media/cms_media_upload_item.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_file_store_service.dart';

import '../../helpers/test_helpers.mocks.dart';

void main() {
  group('CmsMobileFileStoreService -', () {
    late MockCmsApiManager cmsApiManager;
    late CmsMobileFileStoreService service;

    setUp(() {
      cmsApiManager = MockCmsApiManager();
      service = CmsMobileFileStoreService(cmsApiManager);
    });

    test('parses ABP-wrapped line photo metadata list', () async {
      when(cmsApiManager.get(
        AppConst.cmsInspectionLinePhotosForLine(9001),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => {
            'result': [
              {
                'id': 501,
                'referanceID': 9001,
                'name': 'door dent.jpg',
                'documentFileName': '9001_11111111-1111-1111-1111-111111111111.jpg',
                'documentFileType': 'jpg',
                'documentFileSize': '0.42 MB',
                'clientUploadId': '11111111-1111-1111-1111-111111111111',
                'externalPath': '/api/mobile/inspections/files/download/501',
              }
            ]
          });

      final photos = await service.listInspectionLinePhotos(9001);

      expect(photos, hasLength(1));
      expect(photos.single.documentId, 501);
      expect(photos.single.inspectionLineId, 9001);
      expect(photos.single.clientUploadId, '11111111-1111-1111-1111-111111111111');
      expect(photos.single.externalPath, '/api/mobile/inspections/files/download/501');
    });

    test('parses ABP-wrapped survey photo metadata list', () async {
      when(cmsApiManager.post(
        AppConst.CmsFileUploadGetAllDocsByRefId,
        data: {'id': 7001, 'uploadMethod': 3},
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => {
            'result': {
              'items': [
                {
                  'id': 601,
                  'referanceID': 7001,
                  'name': 'survey-door.jpg',
                  'documentFileName': '7001-survey-door.jpg',
                  'documentFileType': 'jpg',
                  'documentFileSize': '0.31 MB',
                  'externalPath': '/api/FileUpload/Download/601',
                }
              ]
            }
          });

      final photos = await service.listSurveyPhotos(
        surveyId: 88,
        referenceId: 7001,
        surveyType: CmsSurveyType.container,
      );

      expect(photos, hasLength(1));
      expect(photos.single.ownerType, CmsMediaUploadOwnerType.survey);
      expect(photos.single.rootId, 88);
      expect(photos.single.referenceId, 7001);
      expect(photos.single.documentId, 601);
      expect(photos.single.state, CmsMediaUploadState.uploaded);
      expect(photos.single.externalPath, '/api/FileUpload/Download/601');
    });

    test('filters survey attachments from the shared document list', () async {
      when(cmsApiManager.post(
        AppConst.CmsFileUploadGetAllDocsByRefId,
        data: {'id': 7001, 'uploadMethod': 3},
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => {
            'result': {
              'items': [
                {
                  'id': 601,
                  'referanceID': 7001,
                  'name': 'survey-door.jpg',
                  'documentFileName': '7001-survey-door.jpg',
                  'documentFileType': 'image/jpeg',
                  'documentFileSize': '0.31 MB',
                  'externalPath': '/api/FileUpload/Download/601',
                },
                {
                  'id': 602,
                  'referanceID': 7001,
                  'name': 'packing-list.pdf',
                  'documentFileName': 'packing-list.pdf',
                  'documentFileType': 'application/pdf',
                  'documentFileSize': '0.10 MB',
                  'externalPath': '/api/FileUpload/Download/602',
                }
              ]
            }
          });

      final attachments = await service.listSurveyAttachments(
        surveyId: 88,
        referenceId: 7001,
        surveyType: CmsSurveyType.container,
      );

      expect(attachments, hasLength(1));
      expect(attachments.single.documentId, 602);
      expect(attachments.single.isDocument, isTrue);
    });

    test('uploads survey documents with CMS legacy file headers', () async {
      final tempDirectory = await Directory.systemTemp.createTemp('cms-survey-document-test');
      addTearDown(() async {
        if (await tempDirectory.exists()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final file = File('${tempDirectory.path}/packing-list.pdf');
      await file.writeAsBytes(const [1, 2, 3, 4], flush: true);

      when(cmsApiManager.post(
        AppConst.CmsLegacyFileUpload,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => {'result': 777});

      final uploaded = await service.uploadSurveyDocument(
        surveyId: 88,
        referenceId: 7001,
        surveyType: CmsSurveyType.container,
        filePath: file.path,
        documentFileName: 'packing-list.pdf',
        contentType: 'application/pdf',
        clientUploadId: 'doc-1',
      );

      final captured = verify(cmsApiManager.post(
        AppConst.CmsLegacyFileUpload,
        data: captureAnyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: captureAnyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).captured;

      expect(captured.first, isA<FormData>());
      final options = captured.last as Options;
      expect(options.headers?['uploadType'], 'Files');
      expect(options.headers?['uploadMethod'], 'ContainerManagement');
      expect(options.headers?['referenceId'], '7001');
      expect(uploaded.documentId, 777);
      expect(uploaded.uploadType, CmsMediaUploadItem.documentUploadType);
    });
  });
}
