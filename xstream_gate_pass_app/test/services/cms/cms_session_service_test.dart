import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/services/api/cms_api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

import '../../helpers/cms_test_data.dart';
import '../../helpers/test_helpers.mocks.dart';

void main() {
  group('CmsSessionService -', () {
    late LocalStorageService localStorageService;
    late MockCmsApiManager cmsApiManager;
    late CmsSessionService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await locator.reset();
      localStorageService = await LocalStorageService().init();
      cmsApiManager = MockCmsApiManager();
      locator.registerSingleton<LocalStorageService>(localStorageService);
      locator.registerSingleton<CmsApiManager>(cmsApiManager);
      locator.registerSingleton<CmsSessionRepository>(CmsSessionRepository());
      service = CmsSessionService();
    });

    tearDown(() => locator.reset());

    test('refreshes from ABP result and persists rich + legacy session', () async {
      when(cmsApiManager.post(
        AppConst.getCurrentLoginInformations,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => {'result': buildCmsSessionJson()});

      final session = await service.refreshFromServer();

      expect(session?.depotCount, 1);
      expect(service.getCached()?.tenant?.tenancyName, 'tenant-a');
      expect(service.getCachedLegacyProfile()?.tenant.tenancyName, 'tenant-a');
    });

    test('falls back to cache when refresh fails', () async {
      locator.unregister<CmsSessionRepository>();
      final repository = CmsSessionRepository();
      locator.registerSingleton<CmsSessionRepository>(repository);
      await repository.save(buildCmsSessionModel());
      service = CmsSessionService();

      when(cmsApiManager.post(
        AppConst.getCurrentLoginInformations,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenThrow(Exception('offline'));

      final session = await service.refreshFromServer();

      expect(session?.tenant?.tenancyName, 'tenant-a');
      expect(service.getCachedLegacyProfile()?.tenant.tenancyName, 'tenant-a');
    });

    test('uses POST for the CMS session refresh endpoint', () async {
      when(cmsApiManager.post(
        AppConst.getCurrentLoginInformations,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => {'result': buildCmsSessionJson()});

      await service.refreshFromServer(showLoader: true);

      verify(cmsApiManager.post(
        AppConst.getCurrentLoginInformations,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: true,
      )).called(1);
      verifyNever(cmsApiManager.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      ));
    });
  });
}
