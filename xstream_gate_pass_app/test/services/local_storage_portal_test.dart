import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/models/account/AuthenticateResultModel.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

void main() {
  group('LocalStorageService portal storage -', () {
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = await LocalStorageService().init();
    });

    test('keeps XAC and CMS auth state isolated', () {
      storage.setAuthTokenForPortal(
        AuthPortal.xac,
        AuthenticateResultModel(accessToken: 'xac-token', tenantId: 1),
      );
      storage.saveIsLoggedInForPortal(AuthPortal.xac, true);

      storage.setAuthTokenForPortal(
        AuthPortal.cms,
        AuthenticateResultModel(accessToken: 'cms-token', tenantId: 2),
      );
      storage.saveIsLoggedInForPortal(AuthPortal.cms, true);

      expect(storage.getAuthTokenForPortal(AuthPortal.xac)?.accessToken,
          'xac-token');
      expect(storage.getAuthTokenForPortal(AuthPortal.cms)?.accessToken,
          'cms-token');
      expect(storage.isLoggedInForPortal(AuthPortal.xac), isTrue);
      expect(storage.isLoggedInForPortal(AuthPortal.cms), isTrue);

      storage.logoutPortal(AuthPortal.cms);

      expect(storage.getAuthTokenForPortal(AuthPortal.cms), isNull);
      expect(storage.isLoggedInForPortal(AuthPortal.cms), isFalse);
      expect(storage.getAuthTokenForPortal(AuthPortal.xac)?.accessToken,
          'xac-token');
      expect(storage.isLoggedInForPortal(AuthPortal.xac), isTrue);
    });

    test('persists last selected portal', () {
      storage.setLastSessionPortal(AuthPortal.cms);

      expect(storage.getLastSessionPortal(), AuthPortal.cms);
    });
  });
}