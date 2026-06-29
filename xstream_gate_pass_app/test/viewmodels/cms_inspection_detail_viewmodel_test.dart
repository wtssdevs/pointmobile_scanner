import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/enums/basic_dialog_status.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_inspection_state.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_photo.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_panel_definition.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_inspection_line_photo_queue_service.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_condition_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_type.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_inspections_service.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/detail/cms_inspection_detail_viewmodel.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('CmsInspectionDetailViewModel -', () {
    late MockCmsMobileInspectionsService cmsMobileInspectionsService;
    late MockCmsMasterFilesRepository masterFilesRepository;
    late MockNavigationService navigationService;
    late MockBottomSheetService bottomSheetService;
    late MockCmsInspectionLinePhotoQueueService linePhotoQueueService;
    late MockWorkerQueManager workerQueManager;
    late MockDialogService dialogService;

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
      dialogService = locator<DialogService>() as MockDialogService;
      masterFilesRepository = locator<CmsMasterFilesRepository>()
          as MockCmsMasterFilesRepository;
      _stubConditionLookup(masterFilesRepository, _conditionLookup());
      when(linePhotoQueueService.getForLine(any)).thenAnswer((_) async => []);
      when(linePhotoQueueService.getForInspection(any))
          .thenAnswer((_) async => []);
      when(linePhotoQueueService.remapSavedLines(any)).thenAnswer((_) async {});
      when(linePhotoQueueService.removeLocalOnly(any)).thenAnswer((_) async {});
      when(linePhotoQueueService.deletePhoto(any)).thenAnswer((_) async {});
      when(linePhotoQueueService.uploadPendingForInspection(any))
          .thenAnswer((_) async => 0);
      when(workerQueManager.enqueSingle(any, any)).thenAnswer((_) async {});
    });

    tearDown(() => locator.reset());

    test('loads an inspection by id and exposes the header facts', () async {
      final edit = _buildInspection();
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      expect(model.inspection?.id, 88);
      expect(model.headerTitle(), 'MSCU1234567');
      expect(model.inspectionStatusLabel, 'In progress');
      expect(
        model.containerHeaderFacts.map((fact) => '${fact.label}:${fact.value}'),
        containsAll(['Size:40', 'Type:HC', 'ISO:45G1']),
      );
      verify(cmsMobileInspectionsService.getInspectionForEdit(88)).called(1);
    });

    test('defaults active inspection timing to now when the server omits it',
        () async {
      final edit = _buildInspection()..inspectionDateTime = null;
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);

      final beforeLoad = DateTime.now();
      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);
      final afterLoad = DateTime.now();

      final inspectionDateTime = model.inspection?.inspectionDateTime;
      expect(inspectionDateTime, isNotNull);
      expect(inspectionDateTime!.isBefore(beforeLoad), isFalse);
      expect(inspectionDateTime.isAfter(afterLoad), isFalse);
      expect(model.hasUnsavedChanges, isFalse);
      expect(model.inspectionTimingTitle, 'Inspection in progress since');
    });

    test('saveDraft keeps unsaved client keys when the server omits them',
        () async {
      final edit = _buildInspection()
        ..items.add(
          _buildInspectionLine(
            id: 0,
            clientKey: 'line-new-1',
            panelCode: 'LSD',
            x: 0.33,
            y: 0.27,
          ),
        );
      final saved = edit.clone();
      saved.items.last
        ..id = 2
        ..clientKey = null;
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);
      when(cmsMobileInspectionsService.saveInspection(any))
          .thenAnswer((_) async => saved);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);
      model.commentsController.text = 'Updated from test';

      await model.saveDraft();

      final savedPayload =
          verify(cmsMobileInspectionsService.saveInspection(captureAny))
              .captured
              .single as CmsInspectionEdit;
      expect(savedPayload.comments, 'Updated from test');

      final remapped = verify(linePhotoQueueService.remapSavedLines(captureAny))
          .captured
          .single as CmsInspectionEdit;
      expect(
        remapped.items.any(
          (line) => line.id == 2 && line.clientKey == 'line-new-1',
        ),
        isTrue,
      );
      verifyNever(workerQueManager.enqueSingle(any, any));
      verifyNever(linePhotoQueueService.uploadPendingForInspection(any));
    });

    test(
        'completeInspection confirms, saves a completed edit, and navigates back',
        () async {
      final edit = _buildInspection();
      final completed = edit.clone()..inspectionCompleted = true;
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);
      when(cmsMobileInspectionsService.saveInspection(any))
          .thenAnswer((_) async => completed);
      _stubCompletionConfirm(dialogService, confirmed: true);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);
      model.setInspectionDateTime(DateTime(2026, 5, 18, 8, 30));
      model.commentsController.text = 'Ready to complete';

      await model.completeInspection();

      final completionPayload =
          verify(cmsMobileInspectionsService.saveInspection(captureAny))
              .captured
              .single as CmsInspectionEdit;
      expect(completionPayload.id, 88);
      expect(completionPayload.inspectionCompleted, isTrue);
      expect(completionPayload.comments, 'Ready to complete');
      expect(
          completionPayload.inspectionDateTime, DateTime(2026, 5, 18, 8, 30));
      verify(navigationService.back(result: true)).called(1);
    });

    test('completeInspection does nothing when the confirm dialog is declined',
        () async {
      final edit = _buildInspection();
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);
      _stubCompletionConfirm(dialogService, confirmed: false);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      await model.completeInspection();

      verifyNever(cmsMobileInspectionsService.saveInspection(any));
      verifyNever(navigationService.back(result: anyNamed('result')));
    });

    test('deleteLine removes queued photos for an unsaved line', () async {
      final edit = _buildInspection()
        ..items.add(_buildInspectionLine(
            id: 0, clientKey: 'line-x', panelCode: 'LSD', x: 0.3, y: 0.3));
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);
      when(linePhotoQueueService.getForLine(argThat(
              predicate<dynamic>((line) => line.clientKey == 'line-x'))))
          .thenAnswer((_) async => const [
                CmsInspectionLinePhoto(
                    clientUploadId: 'a',
                    state: CmsInspectionLinePhotoState.queued),
                CmsInspectionLinePhoto(
                    clientUploadId: 'b',
                    state: CmsInspectionLinePhotoState.awaitingSave),
              ]);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);
      await model.deleteLine(1);

      verify(linePhotoQueueService.deletePhoto(any)).called(2);
      verifyNever(linePhotoQueueService.removeLocalOnly(any));
      expect(model.inspection!.items, hasLength(1));
    });

    test('deleteLine removes an uploaded photo locally without a server delete',
        () async {
      final edit = _buildInspection();
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);
      when(linePhotoQueueService.getForLine(any))
          .thenAnswer((_) async => const [
                CmsInspectionLinePhoto(
                    clientUploadId: 'u',
                    documentId: 555,
                    state: CmsInspectionLinePhotoState.uploaded),
              ]);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);
      await model.deleteLine(0);

      verify(linePhotoQueueService.removeLocalOnly('u')).called(1);
      verifyNever(linePhotoQueueService.deletePhoto(any));
    });

    test('enqueues the photo upload job only when pending uploads exist',
        () async {
      final edit = _buildInspection();
      final saved = edit.clone();
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);
      when(cmsMobileInspectionsService.saveInspection(any))
          .thenAnswer((_) async => saved);
      when(linePhotoQueueService.getForInspection(any))
          .thenAnswer((_) async => const [
                CmsInspectionLinePhoto(
                    clientUploadId: 'p',
                    state: CmsInspectionLinePhotoState.queued),
              ]);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);
      await model.saveDraft();

      verify(workerQueManager.enqueSingle(any, any)).called(1);
    });

    test('hasUnsavedChanges does not mutate the inspection comments', () async {
      final edit = _buildInspection()..comments = 'Original';
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);
      model.commentsController.text = 'Typed but not saved';

      final before = model.inspection!.comments;
      final dirty = model.hasUnsavedChanges;
      final after = model.inspection!.comments;

      expect(dirty, isTrue);
      expect(after, before);
    });

    test('cancelled inspections are read-only and prefer the state label',
        () async {
      final edit = _buildInspection()..state = CmsInspectionState.cancelled;
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      expect(model.isCancelled, isTrue);
      expect(model.canEdit, isFalse);
      expect(model.inspectionStatusLabel, 'Cancelled');
    });

    test('blocks save when required start metadata is missing', () async {
      final edit = _buildInspection()
        ..inspectionType = null
        ..inspectionTypeName = null
        ..conditionTypeId = null;
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      await model.saveDraft();

      expect(
        model.errorMessage,
        contains('missing its inspection type or condition'),
      );
      verifyNever(cmsMobileInspectionsService.saveInspection(any));
    });

    test('stamps the parent inspection id on in-session lines before saving',
        () async {
      final edit = _buildInspection();
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);
      when(cmsMobileInspectionsService.saveInspection(any)).thenAnswer(
          (invocation) async =>
              (invocation.positionalArguments.single as CmsInspectionEdit)
                  .clone());

      final newLine = CmsInspectionLineEdit(
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
      )..applyPanelMetadata(panelCode: 'LSD', x: 0.33, y: 0.27);
      expect(newLine.inspectionId, isNull);

      _stubLineEditorResponse(
        bottomSheetService,
        response: SheetResponse<CmsInspectionLineEdit?>(
          confirmed: true,
          data: newLine,
        ),
      );

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);
      await model.addLineFromPanel(
        CmsInspectionPanelTapDetails(
          panel: CmsInspectionPanels.leftSide,
          x: 0.33,
          y: 0.27,
        ),
      );
      await model.saveDraft();

      final payload =
          verify(cmsMobileInspectionsService.saveInspection(captureAny))
              .captured
              .single as CmsInspectionEdit;
      expect(payload.items, isNotEmpty);
      expect(payload.items.every((line) => line.inspectionId == 88), isTrue);
    });

    test('handles repeated back requests once while navigator pop is pending',
        () async {
      final edit = _buildInspection();
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      final firstBack = model.onWillPop();
      final secondBack = model.onWillPop();
      await Future.wait([firstBack, secondBack]);

      verify(navigationService.back(result: false)).called(1);
    });

    test(
        'adds a line from a tapped panel and seeds the editor with panel metadata',
        () async {
      final edit = _buildInspection();
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
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
      await model.runStartupLogic(inspectionId: 88);
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
      expect(capturedData?['initialLocationMatchTerms'], contains('LEFT'));
      expect(model.inspection!.items.last.panelCode, 'LSD');
      expect(model.coveredPanelCount, 2);
    });

    test('creates an unclassified quick-photo line from a schematic panel',
        () async {
      final edit = _buildInspection();
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);
      when(linePhotoQueueService.capturePhotoForLine(
        inspectionId: anyNamed('inspectionId'),
        line: anyNamed('line'),
        fromGallery: anyNamed('fromGallery'),
      )).thenAnswer((invocation) async {
        final line = invocation.namedArguments[#line] as CmsInspectionLineEdit;
        return CmsInspectionLinePhoto(
          inspectionId: 88,
          clientKey: line.clientKey,
          clientUploadId: '22222222-2222-2222-2222-222222222222',
          state: CmsInspectionLinePhotoState.awaitingSave,
        );
      });

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      await model.captureLineFromPanel(
        CmsInspectionPanelTapDetails(
          panel: CmsInspectionPanels.rear,
          x: CmsInspectionPanels.rear.centerX,
          y: CmsInspectionPanels.rear.centerY,
        ),
      );

      final draftLine = model.inspection!.items.last;
      expect(model.inspection!.items, hasLength(2));
      expect(draftLine.id, 0);
      expect(draftLine.clientKey, isNotNull);
      expect(draftLine.panelCode, 'DOR');
      expect(model.lineNeedsClassification(draftLine), isTrue);
      expect(model.unclassifiedLineCount, 1);

      await model.saveDraft();

      expect(model.errorMessage, contains('needs classification'));
      verifyNever(cmsMobileInspectionsService.saveInspection(any));
    });

    test('canCancel is true for an open, persisted, idle inspection', () async {
      final edit = _buildInspection();
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      expect(model.canCancel, isTrue);
    });

    test('canCancel is false for a completed inspection', () async {
      final edit = _buildInspection()..inspectionCompleted = true;
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      expect(model.canCancel, isFalse);
    });

    test('canCancel is false for a cancelled inspection', () async {
      final edit = _buildInspection()..state = CmsInspectionState.cancelled;
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      expect(model.canCancel, isFalse);
    });

    test('canCancel is false for an unpersisted inspection (id == 0)',
        () async {
      final edit = _buildInspection()..id = 0;
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      expect(model.canCancel, isFalse);
    });

    test(
        'cancelInspection confirmed cancels via the service and navigates back',
        () async {
      final edit = _buildInspection();
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);
      when(cmsMobileInspectionsService.cancelInspection(88))
          .thenAnswer((_) async => CmsInspectionState.cancelled);
      _stubCompletionConfirm(dialogService, confirmed: true);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      await model.cancelInspection();

      verify(cmsMobileInspectionsService.cancelInspection(88)).called(1);
      verify(navigationService.back(result: true)).called(1);
    });

    test('cancelInspection declined does not call the service', () async {
      final edit = _buildInspection();
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);
      _stubCompletionConfirm(dialogService, confirmed: false);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      await model.cancelInspection();

      verifyNever(cmsMobileInspectionsService.cancelInspection(any));
      verifyNever(navigationService.back(result: anyNamed('result')));
    });

    test('loads condition types and resolves the AV condition by code',
        () async {
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => _buildInspection());

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      expect(model.hasConditionChoices, isTrue);
      expect(model.isAvConditionAvailable, isTrue);
      expect(model.avCondition?.id, 1);
    });

    test('isAvConditionAvailable is false when no AV code is synced', () async {
      _stubConditionLookup(masterFilesRepository, const [
        CmsConditionType(id: 10, code: 'UC', name: 'Under Control'),
      ]);
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => _buildInspection());

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      expect(model.isAvConditionAvailable, isFalse);
      expect(model.avCondition, isNull);
    });

    test('applyCondition updates the three fields and dirties the screen',
        () async {
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => _buildInspection());

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);
      expect(model.hasUnsavedChanges, isFalse);

      model.applyCondition(
        const CmsConditionType(id: 1, code: 'AV', name: 'Available'),
      );

      expect(model.inspection?.conditionTypeId, 1);
      expect(model.inspection?.conditionName, 'Available');
      expect(model.inspection?.conditionDisplayName, 'Available');
      expect(model.conditionLabel, 'Available');
      expect(model.hasUnsavedChanges, isTrue);
    });

    test('canCompleteAsAv is true only for an empty, editable, AV-synced inspection',
        () async {
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => _buildEmptyInspection());

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      expect(model.hasLineItems, isFalse);
      expect(model.canCompleteAsAv, isTrue);
    });

    test('canCompleteAsAv is false when line items exist', () async {
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => _buildInspection()); // has 1 line

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      expect(model.hasLineItems, isTrue);
      expect(model.canCompleteAsAv, isFalse);
    });

    test('canCompleteAsAv is false when AV is not synced', () async {
      _stubConditionLookup(masterFilesRepository, const [
        CmsConditionType(id: 10, code: 'UC', name: 'Under Control'),
      ]);
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => _buildEmptyInspection());

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      expect(model.canCompleteAsAv, isFalse);
    });

    test('completeAsAv sets AV, saves a completed edit, and navigates back',
        () async {
      final edit = _buildEmptyInspection();
      final completed = edit.clone()..inspectionCompleted = true;
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);
      when(cmsMobileInspectionsService.saveInspection(any))
          .thenAnswer((_) async => completed);
      _stubCompletionConfirm(dialogService, confirmed: true);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      await model.completeAsAv();

      final payload =
          verify(cmsMobileInspectionsService.saveInspection(captureAny))
              .captured
              .single as CmsInspectionEdit;
      expect(payload.inspectionCompleted, isTrue);
      expect(payload.conditionTypeId, 1); // AV id from lookup
      expect(payload.conditionName, 'Available');
      verify(navigationService.back(result: true)).called(1);
    });

    test('completeAsAv does nothing when the confirm dialog is declined',
        () async {
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => _buildEmptyInspection());
      _stubCompletionConfirm(dialogService, confirmed: false);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      await model.completeAsAv();

      verifyNever(cmsMobileInspectionsService.saveInspection(any));
      verifyNever(navigationService.back(result: anyNamed('result')));
    });

    test('changeCondition applies the condition chosen in the picker', () async {
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => _buildInspection());
      when(bottomSheetService
              .showCustomSheet<CmsConditionType?, Map<String, dynamic>>(
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
      )).thenAnswer((_) async => SheetResponse<CmsConditionType?>(
            confirmed: true,
            data: const CmsConditionType(id: 1, code: 'AV', name: 'Available'),
          ));

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      await model.changeCondition();

      expect(model.inspection?.conditionTypeId, 1);
      expect(model.conditionLabel, 'Available');
    });

    test('cancelInspection surfaces a friendly error and stays on the screen',
        () async {
      final edit = _buildInspection();
      when(cmsMobileInspectionsService.getInspectionForEdit(88))
          .thenAnswer((_) async => edit);
      when(cmsMobileInspectionsService.cancelInspection(88)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/cancel'),
          response: Response(
            requestOptions: RequestOptions(path: '/cancel'),
            statusCode: 409,
            data: const {
              'error': {'message': 'This inspection was already completed.'}
            },
          ),
        ),
      );
      _stubCompletionConfirm(dialogService, confirmed: true);

      final model = CmsInspectionDetailViewModel();
      await model.runStartupLogic(inspectionId: 88);

      await model.cancelInspection();

      expect(model.errorMessage, 'This inspection was already completed.');
      expect(model.isBusy, isFalse);
      verifyNever(navigationService.back(result: anyNamed('result')));
    });
  });
}

CmsInspectionEdit _buildEmptyInspection() {
  return CmsInspectionEdit(
    id: 88,
    containerId: 501,
    containerNo: 'MSCU1234567',
    transactionNo: 'EMP-001',
    shippingLineName: 'MSK',
    containerSize: '40',
    containterType: 'HC',
    containerIsoType: '45G1',
    conditionTypeId: 10,
    conditionName: 'UC',
    conditionDisplayName: 'Under Control',
    inspectionType: CmsInspectionType.structural,
    inspectionTypeName: 'Structural',
    inspectionDateTime: DateTime(2026, 5, 18, 8, 0),
    items: [],
  );
}

CmsInspectionEdit _buildInspection() {
  return CmsInspectionEdit(
    id: 88,
    containerId: 501,
    containerNo: 'MSCU1234567',
    transactionNo: 'EMP-001',
    shippingLineName: 'MSK',
    containerSize: '40',
    containterType: 'HC',
    containerIsoType: '45G1',
    conditionTypeId: 10,
    conditionName: 'UC',
    conditionDisplayName: 'Under Control',
    inspectionTypeName: 'Structural',
    inspectionDateTime: DateTime(2026, 5, 18, 8, 0),
    items: [
      _buildInspectionLine(
        id: 1,
        panelCode: 'RFT',
        x: 0.500,
        y: 0.120,
      ),
    ],
  );
}

CmsInspectionLineEdit _buildInspectionLine({
  required int id,
  String? clientKey,
  required String panelCode,
  required double x,
  required double y,
}) {
  return CmsInspectionLineEdit(
    id: id,
    clientKey: clientKey,
    inspectionId: 88,
    inspectionLocationId: 3,
    inspectionLocationName: panelCode == 'LSD' ? 'Left side' : 'Roof',
    inspectionLocationCode: panelCode,
    inspectionItemId: 4,
    inspectionItemName: 'Panel',
    inspectionActionId: 5,
    inspectionActionName: 'Repair',
    inspectionDamageId: 6,
    inspectionDamageName: 'Dent',
    qty: 1,
    cost: 10,
    labourQty: 1,
    labourRate: 20,
  )..applyPanelMetadata(panelCode: panelCode, x: x, y: y);
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

List<CmsConditionType> _conditionLookup() => const [
      CmsConditionType(id: 1, code: 'AV', name: 'Available'),
      CmsConditionType(id: 10, code: 'UC', name: 'Under Control'),
      CmsConditionType(id: 2, code: 'AV WASH', name: 'Available after wash'),
    ];

void _stubConditionLookup(
  MockCmsMasterFilesRepository repository,
  List<CmsConditionType> conditions,
) {
  when(repository.getAll<CmsConditionType>(
    any,
    any,
    activeOnly: anyNamed('activeOnly'),
    shippingLineId: anyNamed('shippingLineId'),
    filterByShippingLine: anyNamed('filterByShippingLine'),
  )).thenAnswer((_) async => conditions);
}

void _stubCompletionConfirm(
  MockDialogService dialogService, {
  required bool confirmed,
}) {
  when(dialogService.showCustomDialog<dynamic, BasicDialogStatus>(
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
    customData: anyNamed('customData'),
    data: anyNamed('data'),
  )).thenAnswer((_) async => DialogResponse<dynamic>(confirmed: confirmed));
}
