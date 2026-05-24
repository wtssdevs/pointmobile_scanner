import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_survey_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/media/cms_media_upload_item.dart';
import 'package:xstream_gate_pass_app/core/models/cms/survey/cms_mobile_survey_edit_dto.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_media_upload_queue_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_file_store_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_survey_service.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/surveys/detail/cms_survey_detail_viewmodel.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('CmsSurveyDetailViewModel -', () {
    late MockCmsMobileSurveyService cmsMobileSurveyService;
    late MockCmsMediaUploadQueueService mediaUploadQueueService;
    late MockCmsMobileFileStoreService fileStoreService;
    late MockWorkerQueManager workerQueManager;
    late MockNavigationService navigationService;
    late MockDialogService dialogService;

    setUp(() {
      registerServices();
      cmsMobileSurveyService = locator<CmsMobileSurveyService>() as MockCmsMobileSurveyService;
      mediaUploadQueueService = locator<CmsMediaUploadQueueService>() as MockCmsMediaUploadQueueService;
      fileStoreService = locator<CmsMobileFileStoreService>() as MockCmsMobileFileStoreService;
      workerQueManager = locator<WorkerQueManager>() as MockWorkerQueManager;
      navigationService = locator<NavigationService>() as MockNavigationService;
      dialogService = locator<DialogService>() as MockDialogService;

      when(cmsMobileSurveyService.getById(any)).thenAnswer((invocation) async {
        final surveyId = invocation.positionalArguments.single as int;
        return _buildSurvey(id: surveyId);
      });
      when(cmsMobileSurveyService.addUpdate(any)).thenAnswer((invocation) async {
        final input = invocation.positionalArguments.single as CmsMobileSurveyEditDto;
        return input.copyWith(id: input.id > 0 ? input.id : 88, containerId: input.containerId ?? 7001);
      });
      when(cmsMobileSurveyService.getEmailAddresses(any)).thenAnswer((_) async => ['ops@example.com']);
      when(cmsMobileSurveyService.downloadReport(
        surveyId: anyNamed('surveyId'),
        surveyType: anyNamed('surveyType'),
        referenceId: anyNamed('referenceId'),
        targetDirectory: anyNamed('targetDirectory'),
      )).thenAnswer((_) async => 'C:/temp/survey-report.pdf');
      when(mediaUploadQueueService.getForSurvey(any, uploadType: anyNamed('uploadType'))).thenAnswer((_) async => []);
      when(mediaUploadQueueService.surveyUploadReferenceId(any)).thenAnswer((invocation) {
        final survey = invocation.positionalArguments.single as CmsMobileSurveyEditDto;
        return survey.surveyType == CmsSurveyType.gatePass ? survey.gatePassId : survey.containerId;
      });
      when(mediaUploadQueueService.watch(
        ownerType: anyNamed('ownerType'),
        rootId: anyNamed('rootId'),
        uploadType: anyNamed('uploadType'),
      )).thenAnswer((_) => const Stream<List<CmsMediaUploadItem>>.empty());
      when(workerQueManager.enqueSingle(any, any)).thenAnswer((_) async {});
    });

    tearDown(() => locator.reset());

    test('downloads report using the saved survey reference', () async {
      final model = CmsSurveyDetailViewModel();
      await model.runStartupLogic(surveyId: 88, surveyType: CmsSurveyType.container);

      final reportPath = await model.downloadReport();

      expect(reportPath, 'C:/temp/survey-report.pdf');
      verify(cmsMobileSurveyService.downloadReport(
        surveyId: 88,
        surveyType: CmsSurveyType.container,
        referenceId: 7001,
        targetDirectory: anyNamed('targetDirectory'),
      )).called(1);
    });

    test('blocks email sending when the survey has no recipients', () async {
      when(cmsMobileSurveyService.getEmailAddresses(88)).thenAnswer((_) async => const []);

      final model = CmsSurveyDetailViewModel();
      await model.runStartupLogic(surveyId: 88, surveyType: CmsSurveyType.container);
      await model.sendEmail();

      expect(model.inlineMessage, 'No recipients on file for this survey.');
      verifyNever(cmsMobileSurveyService.sendEmail(any));
    });

    test('queues survey documents through the shared media worker', () async {
      when(mediaUploadQueueService.captureSurveyDocument(
        survey: anyNamed('survey'),
        sourcePath: anyNamed('sourcePath'),
        fileName: anyNamed('fileName'),
        mimeType: anyNamed('mimeType'),
      )).thenAnswer(
        (_) async => const CmsMediaUploadItem(
          ownerType: CmsMediaUploadOwnerType.survey,
          rootId: 88,
          referenceId: 7001,
          clientUploadId: 'doc-1',
          documentFileName: 'packing-list.pdf',
          documentFileType: 'application/pdf',
          state: CmsMediaUploadState.queued,
          surveyType: CmsSurveyType.container,
          uploadType: CmsMediaUploadItem.documentUploadType,
        ),
      );

      final model = CmsSurveyDetailViewModel();
      await model.runStartupLogic(surveyId: 88, surveyType: CmsSurveyType.container);
      await model.queueDocumentFromPath('C:/temp/packing-list.pdf', fileName: 'packing-list.pdf');

      verify(mediaUploadQueueService.captureSurveyDocument(
        survey: anyNamed('survey'),
        sourcePath: 'C:/temp/packing-list.pdf',
        fileName: 'packing-list.pdf',
        mimeType: anyNamed('mimeType'),
      )).called(1);
      verify(workerQueManager.enqueSingle(any, any)).called(1);
    });

    test('prompts for unsaved changes and saves before leaving', () async {
      when(dialogService.showCustomDialog(
        variant: anyNamed('variant'),
        title: anyNamed('title'),
        description: anyNamed('description'),
        hasImage: anyNamed('hasImage'),
        imageUrl: anyNamed('imageUrl'),
        showIconInMainButton: anyNamed('showIconInMainButton'),
        mainButtonTitle: anyNamed('mainButtonTitle'),
        showIconInSecondaryButton: anyNamed('showIconInSecondaryButton'),
        secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
        showIconInAdditionalButton: anyNamed('showIconInAdditionalButton'),
        additionalButtonTitle: anyNamed('additionalButtonTitle'),
        takesInput: anyNamed('takesInput'),
        barrierColor: anyNamed('barrierColor'),
        barrierDismissible: anyNamed('barrierDismissible'),
        barrierLabel: anyNamed('barrierLabel'),
        useSafeArea: anyNamed('useSafeArea'),
        routeSettings: anyNamed('routeSettings'),
        navigatorKey: anyNamed('navigatorKey'),
        transitionBuilder: anyNamed('transitionBuilder'),
        customData: anyNamed('customData'),
        data: anyNamed('data'),
      )).thenAnswer((_) async => DialogResponse(confirmed: true));

      final model = CmsSurveyDetailViewModel();
      await model.runStartupLogic(surveyId: 88, surveyType: CmsSurveyType.container);
      model.descriptionController.text = 'Updated from test';

      await model.onWillPop();

      verify(dialogService.showCustomDialog(
        variant: anyNamed('variant'),
        title: anyNamed('title'),
        description: anyNamed('description'),
        hasImage: anyNamed('hasImage'),
        imageUrl: anyNamed('imageUrl'),
        showIconInMainButton: anyNamed('showIconInMainButton'),
        mainButtonTitle: anyNamed('mainButtonTitle'),
        showIconInSecondaryButton: anyNamed('showIconInSecondaryButton'),
        secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
        showIconInAdditionalButton: anyNamed('showIconInAdditionalButton'),
        additionalButtonTitle: anyNamed('additionalButtonTitle'),
        takesInput: anyNamed('takesInput'),
        barrierColor: anyNamed('barrierColor'),
        barrierDismissible: anyNamed('barrierDismissible'),
        barrierLabel: anyNamed('barrierLabel'),
        useSafeArea: anyNamed('useSafeArea'),
        routeSettings: anyNamed('routeSettings'),
        navigatorKey: anyNamed('navigatorKey'),
        transitionBuilder: anyNamed('transitionBuilder'),
        customData: anyNamed('customData'),
        data: anyNamed('data'),
      )).called(1);
      verify(cmsMobileSurveyService.addUpdate(any)).called(1);
      verify(navigationService.back(result: true)).called(1);
    });

    test('downloads remote attachments through the file store service', () async {
      when(fileStoreService.downloadDocument(
        documentId: anyNamed('documentId'),
        fileName: anyNamed('fileName'),
        targetDirectory: anyNamed('targetDirectory'),
      )).thenAnswer((_) async => 'C:/temp/packing-list.pdf');

      final model = CmsSurveyDetailViewModel();
      await model.runStartupLogic(surveyId: 88, surveyType: CmsSurveyType.container);
      final path = await model.downloadAttachment(
        const CmsMediaUploadItem(
          ownerType: CmsMediaUploadOwnerType.survey,
          rootId: 88,
          referenceId: 7001,
          clientUploadId: 'doc-remote',
          documentId: 501,
          documentFileName: 'packing-list.pdf',
          documentFileType: 'application/pdf',
          state: CmsMediaUploadState.uploaded,
          surveyType: CmsSurveyType.container,
          uploadType: CmsMediaUploadItem.documentUploadType,
        ),
      );

      expect(path, 'C:/temp/packing-list.pdf');
      verify(fileStoreService.downloadDocument(
        documentId: 501,
        fileName: 'packing-list.pdf',
        targetDirectory: anyNamed('targetDirectory'),
      )).called(1);
    });
  });
}

CmsMobileSurveyEditDto _buildSurvey({
  required int id,
  CmsSurveyType surveyType = CmsSurveyType.container,
}) {
  return CmsMobileSurveyEditDto(
    id: id,
    surveyType: surveyType,
    conductedBy: 'Inspector One',
    name: 'Pre-trip survey',
    description: 'Container clean and ready.',
    containerId: surveyType == CmsSurveyType.container ? 7001 : null,
    gatePassId: surveyType == CmsSurveyType.gatePass ? 9001 : null,
    shippingLineId: 45,
    containerNo: 'MSCU1234567',
  );
}
