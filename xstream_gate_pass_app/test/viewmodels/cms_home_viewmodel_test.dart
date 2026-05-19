import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_sync_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/main/cms_home_viewmodel.dart';

import '../helpers/cms_test_data.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('CmsHomeViewModel -', () {
    late MockCmsSessionService cmsSessionService;
    late MockCmsMasterFilesSyncService cmsMasterFilesSyncService;
    late MockEnvironmentService environmentService;
    late StreamController<CmsSyncProgress> progressController;

    setUp(() {
      registerServices();
      cmsSessionService = locator<CmsSessionService>() as MockCmsSessionService;
      cmsMasterFilesSyncService = locator<CmsMasterFilesSyncService>() as MockCmsMasterFilesSyncService;
      environmentService = locator<EnvironmentService>() as MockEnvironmentService;
      progressController = StreamController<CmsSyncProgress>.broadcast();

      when(environmentService.getHostName(AuthPortal.cms)).thenReturn('cms.example.com');
      when(cmsSessionService.getCached()).thenReturn(buildCmsSessionModel());
      when(cmsSessionService.refreshFromServer(showLoader: anyNamed('showLoader'))).thenAnswer((_) async => buildCmsSessionModel());
      when(cmsMasterFilesSyncService.getSyncSummary()).thenAnswer(
        (_) async => {
          CmsMasterFileStores.locations.storeBase: CmsStoreSyncMeta(
            storeBase: CmsMasterFileStores.locations.storeBase,
            storeLabel: CmsMasterFileStores.locations.displayName,
            tenantId: 7,
            userId: 42,
            itemCount: 3,
          ),
        },
      );
      when(cmsMasterFilesSyncService.shouldRunInitialSync()).thenAnswer((_) async => true);
      when(cmsMasterFilesSyncService.syncAll(
        force: anyNamed('force'),
        reason: anyNamed('reason'),
      )).thenAnswer((_) async => CmsSyncResult.success());
      when(cmsMasterFilesSyncService.progressStream).thenAnswer((_) => progressController.stream);
    });

    tearDown(() async {
      await progressController.close();
      await locator.reset();
    });

    test('loads CMS session summary and kicks off initial sync when needed', () async {
      final model = CmsHomeViewModel();

      await model.handleStartUpLogic();
      await Future<void>.delayed(Duration.zero);

      expect(model.tenantDisplay, 'tenant-a');
      expect(model.depotCount, 1);
      expect(model.baseUrl, 'cms.example.com');
      verify(cmsMasterFilesSyncService.syncAll(
        force: false,
        reason: 'initial-login',
      )).called(1);
    });

    test('updates sync card text when progress stream emits', () async {
      final model = CmsHomeViewModel();
      await model.handleStartUpLogic();

      progressController.add(
        const CmsSyncProgress(
          storeBase: 'cms_inspection_locations',
          storeLabel: 'Locations',
          inProgress: true,
          message: 'Syncing Locations page 1 of 3',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(model.syncCardTitle, 'Syncing inspection master files');
      expect(model.syncCardSubtitle, contains('Syncing Locations page 1 of 3'));
    });
  });
}
