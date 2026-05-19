import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspectable_container.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_filter.dart';
import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_inspections_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/list/cms_container_inspections_list_viewmodel.dart';

import '../helpers/cms_test_data.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('CmsContainerInspectionsListViewModel -', () {
    late MockCmsSessionService cmsSessionService;
    late MockCmsMobileInspectionsService cmsMobileInspectionsService;
    late MockNavigationService navigationService;

    setUp(() {
      registerServices();
      cmsSessionService = locator<CmsSessionService>() as MockCmsSessionService;
      cmsMobileInspectionsService = locator<CmsMobileInspectionsService>() as MockCmsMobileInspectionsService;
      navigationService = locator<NavigationService>() as MockNavigationService;

      when(cmsSessionService.getCached()).thenReturn(buildCmsSessionModel());
      when(cmsMobileInspectionsService.getInspectableContainers(any)).thenAnswer(
        (_) async => PagedList<CmsInspectableContainer>(
          totalCount: 1,
          items: const [
            CmsInspectableContainer(
              containerId: 501,
              containerNo: 'MSCU1234567',
              transactionNo: 'EMP-001',
              inspectionId: 88,
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
      final verification = verify(cmsMobileInspectionsService.getInspectableContainers(captureAny));
      verification.called(1);
      final captured = verification.captured.single as CmsInspectionFilter;
      expect(captured.depotId, 101);
      expect(captured.pageNumber, 1);
      expect(model.pagingController.itemList?.single.containerId, 501);
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
      final arguments = navigationVerification.captured.single as CmsInspectionDetailViewArguments;
      expect(arguments.inspectionId, 88);
      expect(arguments.containerId, isNull);
    });
  });
}
