import 'package:flutter_test/flutter_test.dart';
import 'package:xstream_gate_pass_app/core/models/cms/account/cms_current_login_information.dart';

import '../../helpers/cms_test_data.dart';

void main() {
  group('CmsCurrentLoginInformation -', () {
    test('round-trips rich CMS session payload and builds legacy adapter', () {
      final payload = buildCmsSessionJson();

      final session = CmsCurrentLoginInformation.fromJson(payload);
      final encoded = session.toJson();
      final legacy = session.toLegacyCurrentLoginInformation();

      expect(session.user?.id, 42);
      expect(session.tenant?.id, 7);
      expect(session.depotCount, 1);
      expect(session.yardCount, 1);
      expect(session.tenant?.image, isNotNull);
      expect(encoded['userDepots'], isA<List>());
      expect(legacy.tenant.tenancyName, 'tenant-a');
      expect(legacy.user.emailAddress, 'jane@example.com');
    });

    test('handles null depot and yard lists safely', () {
      final session = CmsCurrentLoginInformation.fromJson({
        'user': {'id': 1, 'name': 'Only', 'surname': 'User'},
        'tenant': {'id': 2, 'tenancyName': 'tenant-b', 'name': 'Tenant B'},
      });

      expect(session.depotCount, 0);
      expect(session.yardCount, 0);
      expect(session.toLegacyCurrentLoginInformation().tenant.tenancyName, 'tenant-b');
    });
  });
}
