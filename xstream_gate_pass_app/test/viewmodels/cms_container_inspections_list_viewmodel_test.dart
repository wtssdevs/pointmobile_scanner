import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspectable_container.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_filter.dart';
import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_inspections_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
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
    late MockConnectionService connectionService;

    void stubContainerNavigation(Future<dynamic> Function() answer) {
      when(navigationService.navigateTo<dynamic>(
        Routes.cmsContainerDetailView,
        arguments: anyNamed('arguments'),
        id: anyNamed('id'),
        preventDuplicates: anyNamed('preventDuplicates'),
        parameters: anyNamed('parameters'),
        transition: anyNamed('transition'),
      )).thenAnswer((_) => answer());
    }

    setUp(() {
      registerServices();
      cmsSessionService = locator<CmsSessionService>() as MockCmsSessionService;
      cmsMobileInspectionsService = locator<CmsMobileInspectionsService>()
          as MockCmsMobileInspectionsService;
      localStorageService =
          locator<LocalStorageService>() as MockLocalStorageService;
      navigationService = locator<NavigationService>() as MockNavigationService;
      connectionService = locator<ConnectionService>() as MockConnectionService;

      when(cmsSessionService.getCached()).thenReturn(buildCmsSessionModel());
      when(localStorageService.getCmsDefaultInspectionDepotId())
          .thenReturn(null);
      when(connectionService.hasConnection).thenReturn(true);
      when(connectionService.connectionChange)
          .thenAnswer((_) => const Stream<dynamic>.empty());
      when(cmsMobileInspectionsService.getInspectableContainers(any))
          .thenAnswer(
        (_) async => PagedList<CmsInspectableContainer>(
          totalCount: 1,
          items: const [
            CmsInspectableContainer(
              containerId: 501,
              containerNo: 'MSCU1234567',
              transactionNo: 'EMP-001',
              resumeInspectionId: 88,
              resumeInspectionTypeName: 'Structural',
              canResumeInspection: true,
              lastInspectionId: 88,
              lastInspectionTypeName: 'Structural',
              lastInspectionCompleted: false,
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
      expect(model.actionLabelFor(model.pagingController.itemList!.single),
          'Resume Structural');
      expect(model.pagingController.itemList?.single.containerId, 501);
    });

    test(
        'openContainer navigates to the detail view with the container id and refreshes on true',
        () async {
      final model = CmsContainerInspectionsListViewModel();
      await model.runStartupLogic();
      final item = model.pagingController.itemList!.single;
      stubContainerNavigation(() async => true);

      await model.openContainer(item);

      final verification = verify(navigationService.navigateTo<dynamic>(
        Routes.cmsContainerDetailView,
        arguments: captureAnyNamed('arguments'),
        id: anyNamed('id'),
        preventDuplicates: anyNamed('preventDuplicates'),
        parameters: anyNamed('parameters'),
        transition: anyNamed('transition'),
      ));
      verification.called(1);
      final arguments =
          verification.captured.single as CmsContainerDetailViewArguments;
      expect(arguments.containerId, 501);
    });

    test('concurrent openContainer calls navigate only once', () async {
      final model = CmsContainerInspectionsListViewModel();
      await model.runStartupLogic();
      final item = model.pagingController.itemList!.single;

      final completer = Completer<dynamic>();
      stubContainerNavigation(() => completer.future);

      final first = model.openContainer(item);
      final second = model.openContainer(item);
      completer.complete(false);
      await Future.wait([first, second]);

      verify(navigationService.navigateTo<dynamic>(
        Routes.cmsContainerDetailView,
        arguments: anyNamed('arguments'),
        id: anyNamed('id'),
        preventDuplicates: anyNamed('preventDuplicates'),
        parameters: anyNamed('parameters'),
        transition: anyNamed('transition'),
      )).called(1);
    });

    test(
        'offline fetchPage sets the offline message without calling the service',
        () async {
      when(connectionService.hasConnection).thenReturn(false);

      final model = CmsContainerInspectionsListViewModel();
      await model.runStartupLogic();

      expect(model.isOffline, isTrue);
      expect(
          model.loadError, 'No connection. Check your network and try again.');
      verifyNever(cmsMobileInspectionsService.getInspectableContainers(any));
    });

    test('depot change refreshes the list and persists the selection',
        () async {
      final model = CmsContainerInspectionsListViewModel();
      await model.runStartupLogic();
      clearInteractions(cmsMobileInspectionsService);

      model.changeDepot(102);
      await model.fetchPage(1);

      verify(localStorageService.setCmsDefaultInspectionDepotId(102)).called(1);
      final verification = verify(
          cmsMobileInspectionsService.getInspectableContainers(captureAny));
      verification.called(1);
      expect(
          (verification.captured.single as CmsInspectionFilter).depotId, 102);
    });
  });
}
