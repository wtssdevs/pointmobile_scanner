import 'package:dio/dio.dart' as dio_client;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/models/account/AuthenticateResultModel.dart';
import 'package:xstream_gate_pass_app/core/models/account/UserCredential.dart';
import 'package:xstream_gate_pass_app/core/services/api/cms_api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/cms_access_token_repo.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/cms_authentication_service.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('CmsAuthenticationService -', () {
    late MockCmsApiManager apiManager;
    late MockCmsAccessTokenRepo accessTokenRepo;
    late CmsAuthenticationService service;

    setUp(() {
      registerServices();
      apiManager = locator<CmsApiManager>() as MockCmsApiManager;
      accessTokenRepo = locator<CmsAccessTokenRepo>() as MockCmsAccessTokenRepo;
      service = CmsAuthenticationService();
    });

    tearDown(() => locator.reset());

    test('uses cms authenticate endpoint for login', () async {
      final credential = UserCredential(
        tenancyName: 'KHOLD',
        userNameOrEmailAddress: 'admin',
        password: 'Werner@123',
        rememberClient: true,
      );
      final authenticateResult = AuthenticateResultModel(accessToken: 'cms-token');

      when(apiManager.post(
        any,
        data: anyNamed('data'),
        options: anyNamed('options'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer(
        (_) async => {
          'result': 'cms-token',
          'success': true,
        },
      );
      when(accessTokenRepo.buildAuthenticateResultModel(any, any)).thenReturn(authenticateResult);
      when(accessTokenRepo.processAuthenticateResult(any, any)).thenAnswer((_) async => authenticateResult);

      final result = await service.login(userCredential: credential);

      final captured = verify(apiManager.post(
        captureAny,
        data: captureAnyNamed('data'),
        options: captureAnyNamed('options'),
        showLoader: captureAnyNamed('showLoader'),
      )).captured;

      expect(captured[0], AppConst.cms_authentication);
      expect(captured[1], credential.toJson());
      expect(
        (captured[2] as dio_client.Options).extra?[AppConst.requiresAuthExtraKey],
        false,
      );
      expect(captured[3], true);
      expect(result, authenticateResult);
    });
  });
}
