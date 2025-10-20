import 'package:flutter_test/flutter_test.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('DeviceScanSettingsViewModel Tests -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());
  });
}
