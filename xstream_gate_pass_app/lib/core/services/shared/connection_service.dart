import 'package:dart_ping/dart_ping.dart';
import 'package:stacked/stacked_annotations.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/overlays/overlay_service.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';

@InitializableSingleton()
class ConnectionService implements InitializableDependency {
  final log = getLogger('ConnectionService');
  final _environmentService = locator<EnvironmentService>();

  final _localStorageService = locator<LocalStorageService>();
  final OverlayService _overlayService = locator<OverlayService>();
  bool _hasConnection = true;
  List<ConnectivityResult> _connectivityResult = [ConnectivityResult.none];
  String _connectivityResultName = "";
  int latency = 0;
  bool _busyChecking = false;
  bool get hasConnection => _hasConnection;
//_localStorageService
  bool get _showNoConnectionOverlay => _hasConnection == false;
  String get showConnectionStatus => _hasConnection == true ? "Online" : "Offline";

  String get showConnectivityResultDisplayName => _connectivityResultName;

  static final Connectivity _connectivity = Connectivity();
  InternetConnectionChecker _internetConnectionChecker = InternetConnectionChecker();

  StreamController connectionChangeController = StreamController<bool>.broadcast();

  String getConnectivityResultDisplayName() {
    if (_connectivityResult.contains(ConnectivityResult.wifi)) {
      _connectivityResultName = "Wifi";
      return _connectivityResultName;
    }
    if (_connectivityResult.contains(ConnectivityResult.mobile)) {
      _connectivityResultName = "Mobile Data";
      return _connectivityResultName;
    }
    if (_connectivityResult.contains(ConnectivityResult.none)) {
      _connectivityResultName = "None";
      return _connectivityResultName;
    }
    if (_connectivityResult.contains(ConnectivityResult.bluetooth)) {
      _connectivityResultName = "Bluetooth";
      return _connectivityResultName;
    }
    _connectivityResultName = "";
    return _connectivityResultName;
  }

  Future<void> pingGetLatency() async {
    String baseUrl = _environmentService.getValue(AppConst.Base_hostname);

    if (baseUrl.isNullOrWhiteSpace) {
      baseUrl = _environmentService.baseUrl;
    }

    // if (kDebugMode) {
    //   baseUrl = "google.com";
    // }
    log.d("ping test start - $baseUrl");
    final result = await Ping(baseUrl, count: 3).stream.first;
    if (result.error != null) {
      result;
    }

    latency = result.response?.time?.inMilliseconds ?? 0;
    log.d("ping test end - $latency ms");
  }

  @override
  Future<InternetConnectionChecker> init() async {
    log.d('Initialized');
    _internetConnectionChecker = _internetConnectionChecker = InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 5), // Custom check timeout
      checkInterval: const Duration(seconds: 5), // Custom check interval

      addresses: [
        AddressCheckOptions(hostname: _environmentService.getValue(AppConst.Base_hostname), port: 443),
      ],
    );

    await pingGetLatency();
    return _internetConnectionChecker;
  }

  Future<void> initialize() async {
    await hasInternetInternetConnection();
    _internetConnectionChecker.onStatusChange.listen(_timedConnectionChange);
    _connectivity.onConnectivityChanged.listen(_connectionChange);
  }

  void _timedConnectionChange(InternetConnectionStatus result) {
    hasInternetInternetConnection();
  }

  void _connectionChange(List<ConnectivityResult> result) {
    _connectivityResult = result;
    hasInternetInternetConnection();
  }

  Stream get connectionChange => connectionChangeController.stream;

  Future<bool> hasInternetInternetConnection() async {
    if (_busyChecking) {
      return _hasConnection;
    }
    _busyChecking = true;
    bool previousConnection = _hasConnection;
    _connectivityResult = await (Connectivity().checkConnectivity());
    getConnectivityResultDisplayName();
    if (_connectivityResult.contains(ConnectivityResult.mobile) || _connectivityResult.contains(ConnectivityResult.wifi)) {
      // this is the different
      if (await _internetConnectionChecker.hasConnection) {
        _hasConnection = true;
        await pingGetLatency();
      } else {
        _hasConnection = false;
      }
    } else {
      _hasConnection = false;
    }

    if (previousConnection != _hasConnection) {
      connectionChangeController.add(_hasConnection);
    }

    _overlayService.showNetworkConnection(_showNoConnectionOverlay);
    _busyChecking = false;
    return _hasConnection;
  }
}
