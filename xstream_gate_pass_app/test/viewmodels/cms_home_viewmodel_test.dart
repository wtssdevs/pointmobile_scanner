import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_sync_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/main/cms_home_viewmodel.dart';

import '../helpers/cms_test_data.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('CmsHomeViewModel -', () {
    late MockCmsSessionService cmsSessionService;
    late MockCmsMasterFilesSyncService cmsMasterFilesSyncService;

    setUp(() {
      registerServices();
      cmsSessionService = locator<CmsSessionService>() as MockCmsSessionService;
      cmsMasterFilesSyncService =
          locator<CmsMasterFilesSyncService>() as MockCmsMasterFilesSyncService;

      when(cmsSessionService.getCached()).thenReturn(buildCmsSessionModel());
      when(cmsSessionService.refreshFromServer(
              showLoader: anyNamed('showLoader')))
          .thenAnswer((_) async => buildCmsSessionModel());
      when(cmsMasterFilesSyncService.shouldRunInitialSync())
          .thenAnswer((_) async => true);
      when(cmsMasterFilesSyncService.syncAll(
        force: anyNamed('force'),
        reason: anyNamed('reason'),
      )).thenAnswer((_) async => CmsSyncResult.success());
    });

    tearDown(() async {
      await locator.reset();
    });

    test('loads CMS session summary and kicks off initial sync when needed',
        () async {
      final model = CmsHomeViewModel();

      await model.handleStartUpLogic();
      await Future<void>.delayed(Duration.zero);

      expect(model.tenantDisplay, 'tenant-a');
      expect(model.userDisplay, 'Jane Doe');
      verify(cmsMasterFilesSyncService.syncAll(
        force: false,
        reason: 'initial-login',
      )).called(1);
    });
  });
}
