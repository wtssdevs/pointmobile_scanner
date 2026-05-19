import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_repository.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

import '../../helpers/cms_test_data.dart';

void main() {
  group('CmsSessionRepository -', () {
    late LocalStorageService localStorageService;
    late CmsSessionRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await locator.reset();
      localStorageService = await LocalStorageService().init();
      locator.registerSingleton<LocalStorageService>(localStorageService);
      repository = CmsSessionRepository();
    });

    tearDown(() => locator.reset());

    test('saves rich session and legacy profile together', () async {
      final session = buildCmsSessionModel();

      await repository.save(session);

      final cached = repository.getCached();
      final legacy = repository.getCachedLegacyProfile();

      expect(cached?.depotCount, 1);
      expect(legacy?.tenant.tenancyName, 'tenant-a');
      expect(
        localStorageService.getStringByKey(AppConst.cms_currentLoginInformation),
        isNotEmpty,
      );
      expect(repository.getLastRefreshedAt(), isNotNull);
    });

    test('clear removes rich session payload', () async {
      await repository.save(buildCmsSessionModel());

      repository.clear();

      expect(repository.getCached(), isNull);
      expect(repository.getLastRefreshedAt(), isNull);
    });
  });
}
