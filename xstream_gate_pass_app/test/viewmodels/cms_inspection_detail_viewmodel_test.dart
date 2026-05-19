import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_complete_inspection_input.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_photo.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_panel_definition.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_inspection_line_photo_queue_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_inspections_service.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/detail/cms_inspection_detail_viewmodel.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('CmsInspectionDetailViewModel -', () {
    late MockCmsMobileInspectionsService cmsMobileInspectionsService;
    late MockNavigationService navigationService;
    late MockBottomSheetService bottomSheetService;
    late MockCmsInspectionLinePhotoQueueService linePhotoQueueService;
    late MockWorkerQueManager workerQueManager;

    setUp(() {
      registerServices();
      cmsMobileInspectionsService = locator<CmsMobileInspectionsService>()
          as MockCmsMobileInspectionsService;
      navigationService = locator<NavigationService>() as MockNavigationService;
      bottomSheetService =
          locator<BottomSheetService>() as MockBottomSheetService;
      linePhotoQueueService = locator<CmsInspectionLinePhotoQueueService>()
          as MockCmsInspectionLinePhotoQueueService;
      workerQueManager = locator<WorkerQueManager>() as MockWorkerQueManager;
      when(linePhotoQueueService.getForLine(any)).thenAnswer((_) async => []);
      when(linePhotoQueueService.remapSavedLines(any)).thenAnswer((_) async {});
      when(linePhotoQueueService.uploadPendingForInspection(any))
          .thenAnswer((_) async => 0);
      when(workerQueManager.enqueSingle(any, any)).thenAnswer((_) async {});
    });

    tearDown(() => locator.reset());

    test('starts an inspection when launched with a container id', () async {
      final edit = _buildInspection();
      when(cmsMobileInspectionsService.startInspection(501))
          .thenAnswer((_) async => edit);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(containerId: 501);

      expect(model.inspection?.id, 88);
      expect(model.headerTitle(), 'MSCU1234567');
      verify(cmsMobileInspectionsService.startInspection(501)).called(1);
    });

    test('saves draft with updated comments', () async {
      final edit = _buildInspection();
      when(cmsMobileInspectionsService.startInspection(501))
          .thenAnswer((_) async => edit);
      when(cmsMobileInspectionsService.saveInspection(any))
          .thenAnswer((_) async => edit);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(containerId: 501);
      model.commentsController.text = 'Updated from test';

      await model.saveDraft();

      final captured =
          verify(cmsMobileInspectionsService.saveInspection(captureAny))
              .captured
              .single as CmsInspectionEdit;
      expect(captured.comments, 'Updated from test');
      verify(linePhotoQueueService.remapSavedLines(edit)).called(1);
      verify(workerQueManager.enqueSingle(any, any)).called(1);
      verifyNever(linePhotoQueueService.uploadPendingForInspection(any));
    });

    test('captures a line photo and queues background upload for saved lines',
        () async {
      final edit = _buildInspection();
      when(cmsMobileInspectionsService.startInspection(501))
          .thenAnswer((_) async => edit);
      when(linePhotoQueueService.capturePhotoForLine(
        inspectionId: anyNamed('inspectionId'),
        line: anyNamed('line'),
        fromGallery: anyNamed('fromGallery'),
      )).thenAnswer(
        (_) async => const CmsInspectionLinePhoto(
          inspectionId: 88,
          inspectionLineId: 1,
          clientUploadId: '11111111-1111-1111-1111-111111111111',
          state: CmsInspectionLinePhotoState.queued,
        ),
      );

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(containerId: 501);

      await model.captureLinePhoto(0);

      verify(linePhotoQueueService.capturePhotoForLine(
        inspectionId: 88,
        line: anyNamed('line'),
        fromGallery: false,
      )).called(1);
      verify(workerQueManager.enqueSingle(any, any)).called(1);
    });

    test('completes inspection and navigates back with refresh', () async {
      final edit = _buildInspection();
      when(cmsMobileInspectionsService.startInspection(501))
          .thenAnswer((_) async => edit);
      when(cmsMobileInspectionsService.completeInspection(any))
          .thenAnswer((_) async => edit);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(containerId: 501);
      model.setInspectionDateTime(DateTime(2026, 5, 18, 8, 30));
      model.commentsController.text = 'Ready to complete';

      await model.completeInspection();

      final captured =
          verify(cmsMobileInspectionsService.completeInspection(captureAny))
              .captured
              .single as CmsCompleteInspectionInput;
      expect(captured.inspectionId, 88);
      expect(captured.comments, 'Ready to complete');
      verify(workerQueManager.enqueSingle(any, any)).called(1);
      verifyNever(linePhotoQueueService.uploadPendingForInspection(any));
      verify(navigationService.back(result: true)).called(1);
    });

    test(
        'adds a line from a tapped panel and seeds the editor with panel metadata',
        () async {
      final edit = _buildInspection();
      when(cmsMobileInspectionsService.startInspection(501))
          .thenAnswer((_) async => edit);

      Map<String, dynamic>? capturedData;
      final returnedLine = CmsInspectionLineEdit(
        id: 0,
        inspectionLocationId: 7,
        inspectionLocationName: 'Left side',
        inspectionLocationCode: 'LSD',
        inspectionItemId: 4,
        inspectionItemName: 'Panel',
        inspectionActionId: 5,
        inspectionActionName: 'Repair',
        inspectionDamageId: 6,
        inspectionDamageName: 'Dent',
        qty: 1,
      )..applyPanelMetadata(panelCode: 'LSD', x: 0.330, y: 0.270);

      _stubLineEditorResponse(
        bottomSheetService,
        response: SheetResponse<CmsInspectionLineEdit?>(
          confirmed: true,
          data: returnedLine,
        ),
        onCapture: (data) => capturedData = data,
      );

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(containerId: 501);
      await model.addLineFromPanel(
        CmsInspectionPanelTapDetails(
          panel: CmsInspectionPanels.leftSide,
          x: 0.330,
          y: 0.270,
        ),
      );

      expect(capturedData?['initialPanelCode'], 'LSD');
      expect(capturedData?['initialPinX'], 0.330);
      expect(capturedData?['initialPinY'], 0.270);
      expect(model.inspection!.items.last.panelCode, 'LSD');
      expect(model.coveredPanelCount, 2);
    });

    test('duplicates a line through the editor and resets the line id',
        () async {
      final edit = _buildInspection();
      when(cmsMobileInspectionsService.startInspection(501))
          .thenAnswer((_) async => edit);

      Map<String, dynamic>? capturedData;
      final duplicatedLine = edit.items.first.clone()..id = 0;

      _stubLineEditorResponse(
        bottomSheetService,
        response: SheetResponse<CmsInspectionLineEdit?>(
          confirmed: true,
          data: duplicatedLine,
        ),
        onCapture: (data) => capturedData = data,
      );

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(containerId: 501);
      await model.duplicateLine(0);

      final draft = capturedData?['line'] as CmsInspectionLineEdit?;
      expect(draft?.id, 0);
      expect(model.inspection!.items, hasLength(2));
      expect(model.inspection!.items.last.id, 0);
    });
  });
}

CmsInspectionEdit _buildInspection() {
  return CmsInspectionEdit(
    id: 88,
    containerId: 501,
    containerNo: 'MSCU1234567',
    transactionNo: 'EMP-001',
    shippingLineName: 'MSK',
    conditionTypeId: 10,
    conditionName: 'UC',
    inspectionDateTime: DateTime(2026, 5, 18, 8, 0),
    items: [
      CmsInspectionLineEdit(
        id: 1,
        inspectionId: 88,
        inspectionLocationId: 3,
        inspectionLocationName: 'Roof',
        inspectionLocationCode: 'RFT',
        inspectionItemId: 4,
        inspectionItemName: 'Panel',
        inspectionActionId: 5,
        inspectionActionName: 'Repair',
        inspectionDamageId: 6,
        inspectionDamageName: 'Dent',
        qty: 1,
        cost: 10,
      )..applyPanelMetadata(panelCode: 'RFT', x: 0.500, y: 0.120),
    ],
  );
}

void _stubLineEditorResponse(
  MockBottomSheetService bottomSheetService, {
  required SheetResponse<CmsInspectionLineEdit?> response,
  void Function(Map<String, dynamic> data)? onCapture,
}) {
  when(bottomSheetService
      .showCustomSheet<CmsInspectionLineEdit?, Map<String, dynamic>>(
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
