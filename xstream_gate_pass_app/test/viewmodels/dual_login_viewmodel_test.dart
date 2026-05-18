import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/ui/views/account/dual_login/dual_login_viewmodel.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('DualLoginViewModel -', () {
    late MockLocalStorageService localStorageService;

    setUp(() {
      registerServices();
      localStorageService = locator<LocalStorageService>() as MockLocalStorageService;
      when(localStorageService.getTenantCodeForPortal(AuthPortal.xac)).thenReturn('xac-code');
      when(localStorageService.getTenantCodeForPortal(AuthPortal.cms)).thenReturn('cms-code');
    });

    tearDown(() => locator.reset());

    test('defaults to XAC and loads remembered tenant codes independently', () {
      final model = DualLoginViewModel()..initialise();

      expect(model.selectedPortal, AuthPortal.xac);
      expect(model.xacTenantCodeController.text, 'xac-code');
      expect(model.cmsTenantCodeController.text, 'cms-code');

      model.disposeControllers();
    });

    test('supports CMS as initial portal', () {
      final model = DualLoginViewModel(initialPortal: AuthPortal.cms);

      expect(model.selectedPortal, AuthPortal.cms);

      model.disposeControllers();
    });

    test('selecting CMS updates selected portal without a mounted PageView', () async {
      final model = DualLoginViewModel();

      await model.selectPortal(AuthPortal.cms);

      expect(model.selectedPortal, AuthPortal.cms);

      model.disposeControllers();
    });

    test('validation errors remain portal-specific', () async {
      final model = DualLoginViewModel();

      await model.signIn(AuthPortal.xac);

      expect(
        model.validationFor(AuthPortal.xac, DualLoginViewModel.tenantCodeField),
        isNotNull,
      );
      expect(
        model.validationFor(AuthPortal.cms, DualLoginViewModel.tenantCodeField),
        isNull,
      );

      await model.signIn(AuthPortal.cms);

      expect(
        model.validationFor(AuthPortal.cms, DualLoginViewModel.tenantCodeField),
        isNotNull,
      );

      model.disposeControllers();
    });
  });
}
