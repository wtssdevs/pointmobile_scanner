import 'package:stacked_services/stacked_services.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/authentication_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/gatepass/gatepass_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/scan_manager.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/ui/views/account/login/login_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/home_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/edit/edit_gatepass_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/gatepass_view.dart';
import 'package:xstream_gate_pass_app/ui/views/startup/startup_view.dart';
import 'package:xstream_gate_pass_app/ui/views/startup/termsandprivacy/terms_and_privacy_view.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: StartUpView, initial: true),
    MaterialRoute(page: HomeView),
    MaterialRoute(page: TermsAndPrivacyView),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: GatePassView),
    MaterialRoute(page: GatePassEditView),
  ],
  dependencies: [
    Presolve(classType: LocalStorageService, presolveUsing: LocalStorageService.getInstance),
    // Presolve(classType: AppDatabase, presolveUsing: AppDatabase.getInstance),
    LazySingleton(classType: ConnectionService),
    LazySingleton(classType: EnvironmentService),
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: ApiManager),
    LazySingleton(classType: AuthenticationService),
    LazySingleton(classType: ScanningService),
    LazySingleton(classType: GatePassService),

    //Local Repos
  ],
  logger: StackedLogger(),
)
class AppSetup {
  /** Serves no purpose besides having an annotation attached to it */
}
