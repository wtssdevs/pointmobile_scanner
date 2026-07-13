import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:xstream_gate_pass_app/core/services/api/cms_api_manager.dart';

/// Unit tests for the pure auth-retry decision used by the CMS error
/// interceptor. The interceptor must refresh + retry on a 401 (token expiry)
/// but fail fast on a 403 (permission) — retrying a 403 would loop and re-fail
/// (GitHub issue #804).
void main() {
  group('CmsApiManager.shouldRefreshAndRetryOnAuthError', () {
    test('retries on 401 (token expiry)', () {
      expect(
        CmsApiManager.shouldRefreshAndRetryOnAuthError(HttpStatus.unauthorized),
        isTrue,
      );
    });

    test('does NOT retry on 403 (permission decision) - issue #804', () {
      expect(
        CmsApiManager.shouldRefreshAndRetryOnAuthError(HttpStatus.forbidden),
        isFalse,
      );
    });

    test('does NOT retry on other status codes', () {
      expect(CmsApiManager.shouldRefreshAndRetryOnAuthError(400), isFalse);
      expect(CmsApiManager.shouldRefreshAndRetryOnAuthError(404), isFalse);
      expect(CmsApiManager.shouldRefreshAndRetryOnAuthError(500), isFalse);
      expect(CmsApiManager.shouldRefreshAndRetryOnAuthError(null), isFalse);
    });
  });
}
