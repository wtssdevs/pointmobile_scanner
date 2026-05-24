import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_survey_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/survey/cms_mobile_survey_list_input.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_survey_service.dart';

import '../../helpers/test_helpers.mocks.dart';

void main() {
  group('CmsMobileSurveyService -', () {
    late MockCmsApiManager cmsApiManager;
    late CmsMobileSurveyService service;

    setUp(() {
      cmsApiManager = MockCmsApiManager();
      service = CmsMobileSurveyService(cmsApiManager);
    });

    test('parses ABP-wrapped paged survey list response', () async {
      when(cmsApiManager.post(
        AppConst.CmsMobileSurveyGetList,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => {
            'result': {
              'totalCount': 2,
              'items': [
                {
                  'id': 10,
                  'surveyType': 0,
                  'containerNo': 'MSCU1234567',
                  'clientName': 'ACME',
                  'conductedBy': 'Inspector One',
                  'description': 'Container clean.',
                },
                {
                  'id': 11,
                  'surveyType': 1,
                  'containerNo': 'OOLU1234567',
                  'shippingLineName': 'Ocean Line',
                },
              ],
            },
          });

      final page = await service.getList(
        const CmsMobileSurveyListInput(pageSize: 25),
      );

      expect(page.totalCount, 2);
      expect(page.items.length, 2);
      expect(page.items.first.surveyType, CmsSurveyType.container);
      expect(page.items.first.title, 'MSCU1234567');
      expect(page.items.last.surveyType, CmsSurveyType.gatePass);
    });

    test('posts skip/take filters to survey list endpoint', () async {
      when(cmsApiManager.post(
        AppConst.CmsMobileSurveyGetList,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => {
            'result': {'totalCount': 0, 'items': []},
          });

      await service.getList(
        const CmsMobileSurveyListInput(
          pageNumber: 3,
          pageSize: 25,
          searchText: 'MSCU',
          surveyType: CmsSurveyType.gatePass,
        ),
      );

      final captured = verify(cmsApiManager.post(
        AppConst.CmsMobileSurveyGetList,
        data: captureAnyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).captured.single as Map<String, dynamic>;

      expect(captured['skipCount'], 50);
      expect(captured['maxResultCount'], 25);
      expect(captured['searchText'], 'MSCU');
      expect(captured['surveyType'], CmsSurveyType.gatePass.value);
    });

    test('maps getById and addUpdate payloads', () async {
      when(cmsApiManager.post(
        AppConst.CmsMobileSurveyGetById,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => {
            'result': {
              'id': 77,
              'surveyType': 1,
              'conductedBy': 'Inspector Two',
              'description': 'Gate pass survey.',
              'gatePassId': 5,
              'gatePassContainerId': 8,
              'containerNo': 'TGHU7654321',
            },
          });

      when(cmsApiManager.post(
        AppConst.CmsMobileSurveyAddUpdate,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => {
            'result': {
              'id': 78,
              'surveyType': 1,
              'conductedBy': 'Inspector Two',
              'description': 'Saved gate pass survey.',
              'containerNo': 'TGHU7654321',
            },
          });

      final edit = await service.getById(77);
      final saved = await service.addUpdate(edit.copyWith(description: 'Saved gate pass survey.'));

      expect(edit.surveyType, CmsSurveyType.gatePass);
      expect(edit.gatePassContainerId, 8);
      expect(saved.id, 78);
      expect(saved.description, 'Saved gate pass survey.');
    });

    test('unwraps ListResultDto email addresses', () async {
      when(cmsApiManager.post(
        AppConst.CmsMobileSurveyGetEmailAddresses,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => {
            'result': {
              'items': ['ops@example.com', 'surveys@example.com'],
            },
          });

      final emails = await service.getEmailAddresses(9);

      expect(emails, ['ops@example.com', 'surveys@example.com']);
    });

    test('downloads survey reports to a local pdf file', () async {
      final tempDirectory = await Directory.systemTemp.createTemp('cms-survey-report-test');
      addTearDown(() async {
        if (await tempDirectory.exists()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      when(cmsApiManager.getBytes(
        AppConst.cmsGatePassSurveyReport(99),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => <int>[1, 2, 3, 4]);

      final reportPath = await service.downloadReport(
        surveyId: 12,
        surveyType: CmsSurveyType.gatePass,
        referenceId: 99,
        targetDirectory: tempDirectory,
      );

      final file = File(reportPath);
      expect(await file.exists(), isTrue);
      expect(await file.readAsBytes(), <int>[1, 2, 3, 4]);
      expect(file.path, endsWith('survey-12-gatePass.pdf'));
      verify(cmsApiManager.getBytes(
        AppConst.cmsGatePassSurveyReport(99),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).called(1);
    });
  });
}
