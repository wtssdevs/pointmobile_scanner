import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/models/account/AuthenticateResultModel.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/auth_session_coordinator.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:stacked_services/stacked_services.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('AuthSessionCoordinator -', () {
    late MockLocalStorageService localStorageService;
    late MockConnectionService connectionService;
    late MockNavigationService navigationService;

    setUp(() {
      registerServices();
      localStorageService = locator<LocalStorageService>() as MockLocalStorageService;
      connectionService = locator<ConnectionService>() as MockConnectionService;
      navigationService = locator<NavigationService>() as MockNavigationService;
    });

    tearDown(() => locator.reset());

    test('uses last CMS session when it is locally valid offline', () async {
      when(localStorageService.getLastSessionPortal()).thenReturn(AuthPortal.cms);
      when(localStorageService.isLoggedInForPortal(AuthPortal.cms))
          .thenReturn(true);
      when(localStorageService.getAuthTokenForPortal(AuthPortal.cms)).thenReturn(
        AuthenticateResultModel(
          accessToken: 'cms-token',
          tenancyName: 'cms',
          userNameOrEmailAddress: 'user',
          password: 'password',
        ),
      );
      when(connectionService.hasConnection).thenReturn(false);

      final portal = await AuthSessionCoordinator().resolveStartupPortal();

      expect(portal, AuthPortal.cms);
      verify(localStorageService.setLastSessionPortal(AuthPortal.cms)).called(1);
    });

    test('routes to dual login with requested initial portal', () async {
      await AuthSessionCoordinator().routeToLogin(AuthPortal.cms);

      final captured = verify(navigationService.clearStackAndShow(
        Routes.dualLoginView,
        arguments: captureAnyNamed('arguments'),
      )).captured.single as DualLoginViewArguments;

      expect(captured.initialPortal, AuthPortal.cms);
    });
  });
}