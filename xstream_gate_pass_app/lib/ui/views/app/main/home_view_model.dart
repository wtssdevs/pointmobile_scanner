import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel {
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
