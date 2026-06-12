import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_container_inspection_bundle.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_history_row.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_start_mode.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_start_inspection_input.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_start_inspection_result.dart';
import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_inspections_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/container_detail/cms_container_detail_viewmodel.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('CmsContainerDetailViewModel -', () {
    late MockCmsMobileInspectionsService cmsMobileInspectionsService;
    late MockNavigationService navigationService;
    late MockBottomSheetService bottomSheetService;
    late MockConnectionService connectionService;

    CmsContainerInspectionBundle buildBundle({
      bool canResume = false,
      int? resumeInspectionId,
      bool canStart = false,
    }) {
      return CmsContainerInspectionBundle(
        containerId: 501,
        containerNo: 'MSCU1234567',
        transactionNo: 'EMP-001',
        canResumeInspection: canResume,
        resumeInspectionId: resumeInspectionId,
        resumeInspectionTypeName: 'Structural',
        canStartInspection: canStart,
      );
    }

    void stubInspectionNavigation(Future<dynamic> Function() answer) {
      when(navigationService.navigateTo<dynamic>(
        Routes.cmsInspectionDetailView,
        arguments: anyNamed('arguments'),
        id: anyNamed('id'),
        preventDuplicates: anyNamed('preventDuplicates'),
        parameters: anyNamed('parameters'),
        transition: anyNamed('transition'),
      )).thenAnswer((_) => answer());
    }

    setUp(() {
      registerServices();
      cmsMobileInspectionsService = locator<CmsMobileInspectionsService>()
          as MockCmsMobileInspectionsService;
      navigationService = locator<NavigationService>() as MockNavigationService;
      bottomSheetService =
          locator<BottomSheetService>() as MockBottomSheetService;
      connectionService = locator<ConnectionService>() as MockConnectionService;
      when(connectionService.hasConnection).thenReturn(true);
      when(cmsMobileInspectionsService.getContainerInspectionHistory(
        containerId: anyNamed('containerId'),
        pageNumber: anyNamed('pageNumber'),
        pageSize: anyNamed('pageSize'),
      )).thenAnswer((_) async => PagedList<CmsInspectionHistoryRow>(
            totalCount: 0,
            items: const <CmsInspectionHistoryRow>[],
            pageNumber: 1,
            pageSize: 20,
            totalPages: 0,
          ));
    });

    tearDown(() => locator.reset());

    test('startup loads the container bundle', () async {
      when(cmsMobileInspectionsService.getContainerInspections(501))
          .thenAnswer((_) async => buildBundle(canStart: true));

      final model = CmsContainerDetailViewModel();
      await model.runStartupLogic(501);

      expect(model.hasBundle, isTrue);
      expect(model.bundle?.containerNo, 'MSCU1234567');
      expect(model.canStart, isTrue);
      expect(model.errorMessage, isNull);
    });

    test('startup surfaces a translated error message on failure', () async {
      when(cmsMobileInspectionsService.getContainerInspections(501))
          .thenThrow(Exception('boom'));

      final model = CmsContainerDetailViewModel();
      await model.runStartupLogic(501);

      expect(model.hasBundle, isFalse);
      expect(model.errorMessage, isNotNull);
    });

    test('offline startup does not call the service', () async {
      when(connectionService.hasConnection).thenReturn(false);

      final model = CmsContainerDetailViewModel();
      await model.runStartupLogic(501);

      expect(model.isOffline, isTrue);
      expect(model.errorMessage,
          'No connection. Check your network and try again.');
      verifyNever(cmsMobileInspectionsService.getContainerInspections(any));
    });

    test('resume navigates to the inspection detail view with the resume id',
        () async {
      when(cmsMobileInspectionsService.getContainerInspections(501)).thenAnswer(
          (_) async => buildBundle(canResume: true, resumeInspectionId: 88));
      stubInspectionNavigation(() async => false);

      final model = CmsContainerDetailViewModel();
      await model.runStartupLogic(501);
      await model.resumeInspection();

      final verification = verify(navigationService.navigateTo<dynamic>(
        Routes.cmsInspectionDetailView,
        arguments: captureAnyNamed('arguments'),
        id: anyNamed('id'),
        preventDuplicates: anyNamed('preventDuplicates'),
        parameters: anyNamed('parameters'),
        transition: anyNamed('transition'),
      ));
      verification.called(1);
      final arguments =
          verification.captured.single as CmsInspectionDetailViewArguments;
      expect(arguments.inspectionId, 88);
    });

    test('start happy path creates the inspection and opens it', () async {
      when(cmsMobileInspectionsService.getContainerInspections(501))
          .thenAnswer((_) async => buildBundle(canStart: true));
      const input = CmsStartInspectionInput(
          containerId: 501,
          mode: CmsInspectionStartMode.defaultMode,
          conditionTypeId: 1);
      _stubStartSheet(bottomSheetService,
          response: SheetResponse<CmsStartInspectionInput>(
              confirmed: true, data: input));
      when(cmsMobileInspectionsService.startInspection(input)).thenAnswer(
          (_) async => const CmsStartInspectionResult(
              entryInspectionId: 999, structuralInspectionId: 999));
      stubInspectionNavigation(() async => null);

      final model = CmsContainerDetailViewModel();
      await model.runStartupLogic(501);
      await model.startInspection();

      verify(cmsMobileInspectionsService.startInspection(input)).called(1);
      final verification = verify(navigationService.navigateTo<dynamic>(
        Routes.cmsInspectionDetailView,
        arguments: captureAnyNamed('arguments'),
        id: anyNamed('id'),
        preventDuplicates: anyNamed('preventDuplicates'),
        parameters: anyNamed('parameters'),
        transition: anyNamed('transition'),
      ));
      verification.called(1);
      expect(
          (verification.captured.single as CmsInspectionDetailViewArguments)
              .inspectionId,
          999);
    });

    test('start surfaces a translated error when the service throws', () async {
      when(cmsMobileInspectionsService.getContainerInspections(501))
          .thenAnswer((_) async => buildBundle(canStart: true));
      const input = CmsStartInspectionInput(
          containerId: 501,
          mode: CmsInspectionStartMode.defaultMode,
          conditionTypeId: 1);
      _stubStartSheet(bottomSheetService,
          response: SheetResponse<CmsStartInspectionInput>(
              confirmed: true, data: input));
      when(cmsMobileInspectionsService.startInspection(input))
          .thenThrow(Exception('start failed'));

      final model = CmsContainerDetailViewModel();
      await model.runStartupLogic(501);
      await model.startInspection();

      verify(cmsMobileInspectionsService.startInspection(input)).called(1);
      verifyNever(navigationService.navigateTo<dynamic>(
        Routes.cmsInspectionDetailView,
        arguments: anyNamed('arguments'),
        id: anyNamed('id'),
        preventDuplicates: anyNamed('preventDuplicates'),
        parameters: anyNamed('parameters'),
        transition: anyNamed('transition'),
      ));
    });

    test('autoStart locks the start sheet to the default mode', () async {
      when(cmsMobileInspectionsService.getContainerInspections(501))
          .thenAnswer((_) async => buildBundle(canStart: true));
      Map<String, dynamic>? capturedData;
      _stubStartSheet(
        bottomSheetService,
        response: SheetResponse<CmsStartInspectionInput>(confirmed: false),
        onCapture: (data) => capturedData = data,
      );

      final model = CmsContainerDetailViewModel();
      await model.runStartupLogic(501);
      await model.autoStartInspection();

      expect(capturedData?['lockedMode'], CmsInspectionStartMode.defaultMode);
      expect(capturedData?['bundle'], isA<CmsContainerInspectionBundle>());
    });

    test('history paging loads rows from the service', () async {
      when(cmsMobileInspectionsService.getContainerInspections(501))
          .thenAnswer((_) async => buildBundle(canStart: true));
      when(cmsMobileInspectionsService.getContainerInspectionHistory(
        containerId: anyNamed('containerId'),
        pageNumber: anyNamed('pageNumber'),
        pageSize: anyNamed('pageSize'),
      )).thenAnswer((_) async => PagedList<CmsInspectionHistoryRow>(
            totalCount: 1,
            items: [
              CmsInspectionHistoryRow.fromJson(const {
                'id': 910,
                'inspectionType': 0,
                'state': 1,
                'inspectionCompleted': false,
              }),
            ],
            pageNumber: 1,
            pageSize: 20,
            totalPages: 1,
          ));

      final model = CmsContainerDetailViewModel();
      await model.runStartupLogic(501);
      await model.fetchHistoryPage(1);

      expect(model.historyController.itemList, isNotNull);
      expect(model.historyController.itemList!.single.id, 910);
      expect(model.historyController.itemList!.single.isOpen, isTrue);
    });
  });
}

void _stubStartSheet(
  MockBottomSheetService bottomSheetService, {
  required SheetResponse<CmsStartInspectionInput> response,
  void Function(Map<String, dynamic> data)? onCapture,
}) {
  when(bottomSheetService
      .showCustomSheet<CmsStartInspectionInput, Map<String, dynamic>>(
    enableDrag: anyNamed('enableDrag'),
    enterBottomSheetDuration: anyNamed('enterBottomSheetDuration'),
    exitBottomSheetDuration: anyNamed('exitBottomSheetDuration'),
    ignoreSafeArea: anyNamed('ignoreSafeArea'),
    isScrollControlled: anyNamed('isScrollControlled'),
    barrierDismissible: anyNamed('barrierDismissible'),
    additionalButtonTitle: anyNamed('additionalButtonTitle'),
    variant: anyNamed('variant'),
    title: anyNamed('title'),
    hasImage: anyNamed('hasImage'),
    imageUrl: anyNamed('imageUrl'),
    showIconInMainButton: anyNamed('showIconInMainButton'),
    mainButtonTitle: anyNamed('mainButtonTitle'),
    showIconInSecondaryButton: anyNamed('showIconInSecondaryButton'),
    secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
    showIconInAdditionalButton: anyNamed('showIconInAdditionalButton'),
    takesInput: anyNamed('takesInput'),
    barrierColor: anyNamed('barrierColor'),
    barrierLabel: anyNamed('barrierLabel'),
    customData: anyNamed('customData'),
    data: anyNamed('data'),
    description: anyNamed('description'),
  )).thenAnswer((invocation) async {
    final rawData = invocation.namedArguments[#data];
    if (rawData is Map) {
      onCapture?.call(Map<String, dynamic>.from(rawData));
    }

    return response;
  });
}
