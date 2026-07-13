import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/models/account/UserCredential.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/cms_access_token_repo.dart';

import '../helpers/test_helpers.dart';

void main() {
  group('CmsAccessTokenRepo -', () {
    setUp(() => registerServices());
    tearDown(() => locator.reset());

    test('builds token model from CMS authenticate result and JWT claims', () {
      final repo = CmsAccessTokenRepo();
      final token = _unsignedJwt({
        'tenantId': '77',
        'sub': '42',
      });
      final credential = UserCredential(
        tenancyName: 'cms',
        userNameOrEmailAddress: 'user',
        password: 'password',
        rememberClient: true,
      );

      final result = repo.buildAuthenticateResultModel(
        {'accessToken': token},
        credential,
      );

      expect(result.accessToken, token);
      expect(result.tenantId, 77);
      expect(result.userId, 42);
    });

    test('honors tenant id supplied by the login credential', () {
      final repo = CmsAccessTokenRepo();
      final token = _unsignedJwt({
        'tenantId': '77',
        'sub': '42',
      });
      final credential = UserCredential(
        tenancyName: 'cms',
        userNameOrEmailAddress: 'user',
        password: 'password',
        rememberClient: true,
        tenantId: 99,
      );

      final result = repo.buildAuthenticateResultModel(token, credential);

      expect(result.accessToken, token);
      expect(result.tenantId, 99);
      expect(result.userId, 42);
    });

    test('does not try to decode opaque CMS bearer tokens as JWTs', () {
      final repo = CmsAccessTokenRepo();
      final credential = UserCredential(
        tenancyName: 'cms',
        userNameOrEmailAddress: 'user',
        password: 'password',
        rememberClient: true,
      );

      final result = repo.buildAuthenticateResultModel(
        'CfDJ8OpaqueProtectedTicketValue',
        credential,
      );

      expect(result.accessToken, 'CfDJ8OpaqueProtectedTicketValue');
      expect(result.tenantId, isNull);
      expect(result.userId, isNull);
    });
  });
}

String _unsignedJwt(Map<String, dynamic> claims) {
  final header = _base64UrlJson({'alg': 'none', 'typ': 'JWT'});
  final payload = _base64UrlJson(claims);
  return '$header.$payload.';
}

String _base64UrlJson(Map<String, dynamic> value) {
  return base64Url.encode(utf8.encode(json.encode(value))).replaceAll('=', '');
}
