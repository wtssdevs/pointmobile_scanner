import 'package:stacked/stacked_annotations.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

@LazySingleton()
class ConnectionService {
  bool _hasConnection = false;
  bool get hasConnection => _hasConnection;
  static Connectivity _connectivity = new Connectivity();
  StreamController connectionChangeController = StreamController<bool>.broadcast();

  // static Future<Connectivity?> getInstance() async {
  //   _connectivity = new Connectivity();
  //   initialize();
  // }

  Future<void> initialize() async {
    await hasInternetInternetConnection();
    _connectivity.onConnectivityChanged.listen(_connectionChange);
  }

  void _connectionChange(ConnectivityResult result) {
    hasInternetInternetConnection();
  }

  Stream get connectionChange => connectionChangeController.stream;

  Future<bool> hasInternetInternetConnection() async {
    bool previousConnection = _hasConnection;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      // this is the different
      if (await InternetConnectionChecker().hasConnection) {
        _hasConnection = true;
      } else {
        _hasConnection = false;
      }
    } else {
      _hasConnection = false;
    }

    if (previousConnection != _hasConnection) {
      connectionChangeController.add(_hasConnection);
    }
    return _hasConnection;
  }
}
