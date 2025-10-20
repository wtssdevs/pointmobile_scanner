import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

class StartBaseViewModel extends BaseViewModel {
  final NavigationService? _navigationService = locator<NavigationService>();
  final LocalStorageService? _localStorageService =
      locator<LocalStorageService>();

  Future handleStartUpLogic() async {}
}
