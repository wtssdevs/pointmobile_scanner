import 'package:flutter_test/flutter_test.dart';
import 'package:xstream_gate_pass_app/core/enums/app_portal_mode.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';

void main() {
  group('AppPortalModeX.fromValue -', () {
    test('parses known values case/space-insensitively', () {
      expect(AppPortalModeX.fromValue('cms'), AppPortalMode.cms);
      expect(AppPortalModeX.fromValue('CMS'), AppPortalMode.cms);
      expect(AppPortalModeX.fromValue('  Xac '), AppPortalMode.xac);
      expect(AppPortalModeX.fromValue('dual'), AppPortalMode.dual);
    });

    test('falls back to dual for null / empty / unknown', () {
      expect(AppPortalModeX.fromValue(null), AppPortalMode.dual);
      expect(AppPortalModeX.fromValue(''), AppPortalMode.dual);
      expect(AppPortalModeX.fromValue('nonsense'), AppPortalMode.dual);
    });
  });

  group('AppPortalModeX.enabledPortals -', () {
    test('dual exposes both, xac first', () {
      expect(AppPortalMode.dual.enabledPortals,
          const [AuthPortal.xac, AuthPortal.cms]);
    });

    test('cms exposes only cms', () {
      expect(AppPortalMode.cms.enabledPortals, const [AuthPortal.cms]);
    });

    test('xac exposes only xac', () {
      expect(AppPortalMode.xac.enabledPortals, const [AuthPortal.xac]);
    });

    test('every mode yields a non-empty list', () {
      for (final mode in AppPortalMode.values) {
        expect(mode.enabledPortals, isNotEmpty);
      }
    });
  });
}
