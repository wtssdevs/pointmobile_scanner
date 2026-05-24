import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspectable_container.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_filter.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_start_inspection_input.dart';
import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_inspections_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/list/cms_container_inspections_list_viewmodel.dart';

import '../helpers/cms_test_data.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('CmsContainerInspectionsListViewModel -', () {
    late MockCmsSessionService cmsSessionService;
    late MockCmsMobileInspectionsService cmsMobileInspectionsService;
    late MockLocalStorageService localStorageService;
    late MockNavigationService navigationService;
    late MockBottomSheetService bottomSheetService;

    setUp(() {
      registerServices();
      cmsSessionService = locator<CmsSessionService>() as MockCmsSessionService;
      cmsMobileInspectionsService = locator<CmsMobileInspectionsService>()
          as MockCmsMobileInspectionsService;
      localStorageService =
          locator<LocalStorageService>() as MockLocalStorageService;
      navigationService = locator<NavigationService>() as MockNavigationService;
      bottomSheetService =
          locator<BottomSheetService>() as MockBottomSheetService;

      when(cmsSessionService.getCached()).thenReturn(buildCmsSessionModel());
      when(localStorageService.getCmsDefaultInspectionDepotId())
          .thenReturn(null);
      when(cmsMobileInspectionsService.getInspectableContainers(any))
          .thenAnswer(
        (_) async => PagedList<CmsInspectableContainer>(
          totalCount: 1,
          items: const [
            CmsInspectableContainer(
              containerId: 501,
              containerNo: 'MSCU1234567',
              transactionNo: 'EMP-001',
              inspectionId: 88,
              inspectionType: CmsInspectionType.structural,
              inspectionTypeName: 'Structural',
              canResumeInspection: true,
              cardStatus: 'InProgress',
            ),
          ],
          pageNumber: 1,
          pageSize: 20,
          totalPages: 1,
        ),
      );
    });

    tearDown(() => locator.reset());

    test('loads first depot and fetches the first page on startup', () async {
      final model = CmsContainerInspectionsListViewModel();

      await model.runStartupLogic();

      expect(model.selectedDepotId, 101);
      final verification = verify(
          cmsMobileInspectionsService.getInspectableContainers(captureAny));
      verification.called(1);
      final captured = verification.captured.single as CmsInspectionFilter;
      expect(captured.depotId, 101);
      expect(captured.pageNumber, 1);
      expect(model.selectedDepotDisplay, 'Main Depot');
      expect(model.statusFilterLabel, 'All statuses');
      expect(model.actionLabelFor(model.pagingController.itemList!.single),
          'Resume Structural');
      expect(model.pagingController.itemList?.single.containerId, 501);
    });

    test('applies status filters through staged drawer state', () async {
      final model = CmsContainerInspectionsListViewModel();
      await model.runStartupLogic();
      clearInteractions(cmsMobileInspectionsService);

      model.beginFilterEditing();
      model.selectStagedStatus(CmsInspectableStatusFilter.inProgress);
      model.applyFilters();
      await model.fetchPage(1);

      expect(model.activeFilterCount, 1);
      final verification = verify(
          cmsMobileInspectionsService.getInspectableContainers(captureAny));
      verification.called(1);
      final captured = verification.captured.single as CmsInspectionFilter;
      expect(captured.statusFilter, CmsInspectableStatusFilter.inProgress);
    });

    test('navigates to detail when detail returns true', () async {
      final model = CmsContainerInspectionsListViewModel();
      await model.runStartupLogic();
      final item = model.pagingController.itemList!.single;

      when(navigationService.navigateTo<dynamic>(
        Routes.cmsInspectionDetailView,
        arguments: anyNamed('arguments'),
        id: anyNamed('id'),
        preventDuplicates: anyNamed('preventDuplicates'),
        parameters: anyNamed('parameters'),
        transition: anyNamed('transition'),
      )).thenAnswer((_) async => true);

      await model.openInspection(item);

      final navigationVerification = verify(
        navigationService.navigateTo<dynamic>(
          Routes.cmsInspectionDetailView,
          arguments: captureAnyNamed('arguments'),
          id: anyNamed('id'),
          preventDuplicates: true,
          parameters: anyNamed('parameters'),
          transition: anyNamed('transition'),
        ),
      );
      navigationVerification.called(1);
      final arguments = navigationVerification.captured.single
          as CmsInspectionDetailViewArguments;
      expect(arguments.inspectionId, 88);
      expect(arguments.containerId, isNull);
    });

    test('opens the start sheet, posts typed start payload, and navigates',
        () async {
      when(cmsMobileInspectionsService.getInspectableContainers(any))
          .thenAnswer(
        (_) async => PagedList<CmsInspectableContainer>(
          totalCount: 1,
          items: const [
            CmsInspectableContainer(
              containerId: 601,
              containerNo: 'OOLU1234567',
              transactionNo: 'EMP-601',
              inspectionType: CmsInspectionType.mechanical,
              inspectionTypeName: 'Mechanical',
              canStartInspection: true,
              cardStatus: 'Ready',
            ),
          ],
          pageNumber: 1,
          pageSize: 20,
          totalPages: 1,
        ),
      );

      final model = CmsContainerInspectionsListViewModel();
      await model.runStartupLogic();
      clearInteractions(cmsMobileInspectionsService);

      final item = model.pagingController.itemList!.single;
      when(bottomSheetService
          .showCustomSheet<CmsStartInspectionInput, CmsInspectableContainer>(
        variant: anyNamed('variant'),
        title: anyNamed('title'),
        description: anyNamed('description'),
        barrierDismissible: anyNamed('barrierDismissible'),
        isScrollControlled: anyNamed('isScrollControlled'),
        data: anyNamed('data'),
      )).thenAnswer(
        (_) async => SheetResponse<CmsStartInspectionInput>(
          confirmed: true,
          data: const CmsStartInspectionInput(
            id: 601,
            inspectionType: CmsInspectionType.mechanical,
            conditionTypeId: 12,
            conditionName: 'AVWASH',
            conditionDisplayName: 'Available Wash',
          ),
        ),
      );
      when(cmsMobileInspectionsService.startInspection(any)).thenAnswer(
        (_) async => CmsInspectionEdit(
          id: 901,
          containerId: 601,
          containerNo: 'OOLU1234567',
          conditionTypeId: 12,
          conditionName: 'AVWASH',
          conditionDisplayName: 'Available Wash',
          inspectionType: CmsInspectionType.mechanical,
          inspectionTypeName: 'Mechanical',
        ),
      );
      when(navigationService.navigateTo<dynamic>(
        Routes.cmsInspectionDetailView,
        arguments: anyNamed('arguments'),
        id: anyNamed('id'),
        preventDuplicates: anyNamed('preventDuplicates'),
        parameters: anyNamed('parameters'),
        transition: anyNamed('transition'),
      )).thenAnswer((_) async => false);

      await model.openInspection(item);

      final bottomSheetVerification = verify(bottomSheetService
          .showCustomSheet<CmsStartInspectionInput, CmsInspectableContainer>(
        variant: captureAnyNamed('variant'),
        title: captureAnyNamed('title'),
        description: captureAnyNamed('description'),
        barrierDismissible: captureAnyNamed('barrierDismissible'),
        isScrollControlled: captureAnyNamed('isScrollControlled'),
        data: captureAnyNamed('data'),
      ));
      bottomSheetVerification.called(1);
      final sheetCaptured = bottomSheetVerification.captured;
      expect(sheetCaptured[0], isNotNull);
      expect(sheetCaptured[1], 'Start Mechanical inspection');
      expect(sheetCaptured[5], item);

      final startVerification =
          verify(cmsMobileInspectionsService.startInspection(captureAny));
      startVerification.called(1);
      final startInput =
          startVerification.captured.single as CmsStartInspectionInput;
      expect(startInput.id, 601);
      expect(startInput.inspectionType, CmsInspectionType.mechanical);
      expect(startInput.conditionTypeId, 12);

      final navigationVerification = verify(
        navigationService.navigateTo<dynamic>(
          Routes.cmsInspectionDetailView,
          arguments: captureAnyNamed('arguments'),
          id: anyNamed('id'),
          preventDuplicates: true,
          parameters: anyNamed('parameters'),
          transition: anyNamed('transition'),
        ),
      );
      navigationVerification.called(1);
      final arguments = navigationVerification.captured.single
          as CmsInspectionDetailViewArguments;
      expect(arguments.inspectionId, 901);
      expect(arguments.containerId, isNull);
      expect(model.actionLabelFor(item), 'Start Mechanical');
    });
  });
}
