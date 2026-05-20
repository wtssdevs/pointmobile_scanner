import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_sync_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/settings/cms_settings_viewmodel.dart';

import '../helpers/cms_test_data.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('CmsSettingsViewModel -', () {
    late MockCmsSessionService cmsSessionService;
    late MockCmsMasterFilesSyncService cmsMasterFilesSyncService;
    late MockEnvironmentService environmentService;
    late MockLocalStorageService localStorageService;
    late StreamController<CmsSyncProgress> progressController;

    setUp(() {
      registerServices();
      cmsSessionService = locator<CmsSessionService>() as MockCmsSessionService;
      cmsMasterFilesSyncService =
          locator<CmsMasterFilesSyncService>() as MockCmsMasterFilesSyncService;
      environmentService =
          locator<EnvironmentService>() as MockEnvironmentService;
      localStorageService =
          locator<LocalStorageService>() as MockLocalStorageService;
      progressController = StreamController<CmsSyncProgress>.broadcast();

      when(environmentService.getHostName(AuthPortal.cms))
          .thenReturn('cms.example.com');
      when(localStorageService.isLoggedInForPortal(AuthPortal.cms))
          .thenReturn(true);
      when(cmsSessionService.getCached()).thenReturn(buildCmsSessionModel());
      when(cmsSessionService.refreshFromServer(
              showLoader: anyNamed('showLoader')))
          .thenAnswer((_) async => buildCmsSessionModel());
      when(cmsMasterFilesSyncService.progressStream)
          .thenAnswer((_) => progressController.stream);
      when(cmsMasterFilesSyncService.getSyncSummary()).thenAnswer(
        (_) async => {
          CmsMasterFileStores.locations.storeBase: CmsStoreSyncMeta(
            storeBase: CmsMasterFileStores.locations.storeBase,
            storeLabel: CmsMasterFileStores.locations.displayName,
            tenantId: 7,
            userId: 42,
            itemCount: 10,
            lastSuccessfulSyncAt: DateTime.utc(2026, 5, 18, 9),
          ),
        },
      );
      when(cmsMasterFilesSyncService.syncAll(
        force: anyNamed('force'),
        reason: anyNamed('reason'),
      )).thenAnswer((_) async => CmsSyncResult.success());
      when(cmsMasterFilesSyncService.syncStore(
        any,
        force: anyNamed('force'),
        reason: anyNamed('reason'),
      )).thenAnswer((_) async => CmsSyncResult.success());
    });

    tearDown(() async {
      await progressController.close();
      await locator.reset();
    });

    test('loads session summary and triggers sync actions', () async {
      final model = CmsSettingsViewModel();

      await model.initialise();
      await model.refreshSessionInfo();
      await model.syncAll();
      await model.syncStore(CmsMasterFileStores.locations.asBaseStore());

      expect(model.depotCount, 1);
      expect(model.yardCount, 1);
      expect(model.baseUrl, 'cms.example.com');
      expect(model.isCmsLoggedIn, isTrue);
      verify(cmsSessionService.refreshFromServer(showLoader: false)).called(1);
      verify(cmsMasterFilesSyncService.syncAll(force: true)).called(1);
      verify(cmsMasterFilesSyncService.syncStore(
        any,
        force: true,
      )).called(1);
    });

    test('reacts to sync progress and error events', () async {
      final model = CmsSettingsViewModel();
      await model.initialise();

      progressController.add(
        const CmsSyncProgress(
          storeBase: 'cms_inspection_locations',
          storeLabel: 'Locations',
          failed: true,
          error: 'offline',
          message: 'Failed to sync Locations',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(model.latestError, 'offline');
    });
  });
}
