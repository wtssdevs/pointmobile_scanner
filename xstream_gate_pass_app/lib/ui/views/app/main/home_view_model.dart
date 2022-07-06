import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/app_config/app.locator.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';


class HomeViewModel extends BaseViewModel {
  var _localStorageService = locator<LocalStorageService>();
  int _currentTabIndex = 0;
  int get currentTabIndex => _currentTabIndex;

  bool _reverse = false;
  bool get reverse => _reverse;

  void setTabIndex(int value) {
    if (value < _currentTabIndex) {
      _reverse = true;
    }
    _currentTabIndex = value;
    notifyListeners();
  }

  Future handleStartUpLogic(int? tabIndex) async {
    if (tabIndex != null) {
      setTabIndex(tabIndex);
    }
  }
}
