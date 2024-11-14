import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/models/account/GetCurrentLoginInformation.dart';
import 'package:xstream_gate_pass_app/core/models/background_job_que/background_job_Info.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/background_job_info_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

class DataSyncViewModel extends BaseViewModel {
  final log = getLogger('DataSyncViewModel');

  final TextEditingController filterController = TextEditingController();
  final _connectionService = locator<ConnectionService>();
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();
  final _workerQueManager = locator<WorkerQueManager>();
  final _backgroundJobInfoRepository = locator<BackgroundJobInfoRepository>();
  bool get hasConnection => _connectionService.hasConnection;
  bool get isExecuting => _workerQueManager.isExecuting;
//get current user details for trip checklists types verify

  List<BackgroundJobInfo> _sync = [];
  List<BackgroundJobInfo> get sync => _sync;

  bool get hasSyncTasks => sync.isNotEmpty;

  StreamSubscription? connectionStreamSubscription;
  StreamSubscription? syncTaskStreamSubscription;
  bool isPageLoad = true;
  CurrentLoginInformation? get appSession =>
      _localStorageService.getUserLoginInfo;

  Future<void> runStartupLogic() async {
    await loadSyncData();
    notifyListeners();
    startconnectionListen();
    isPageLoad = false;
  }

  void startconnectionListen() {
    connectionStreamSubscription =
        _connectionService.connectionChange.asBroadcastStream().listen((data) {
      if (_connectionService.hasConnection) {
        onRefresh();
      }
    });

    syncTaskStreamSubscription =
        _workerQueManager.onSyncTaskChange.asBroadcastStream().listen((data) {
      onRefresh();
    });
  }

  Future<void> loadSyncData() async {
    _sync = await _backgroundJobInfoRepository.getAll("");
  }

  Future<void> onRefresh() async {
    await loadSyncData();
    await _workerQueManager.startExecution();
    notifyListeners();
  }

  Future<void> syncData() async {
    await _workerQueManager.startExecution();
    notifyListeners();
  }

  Future<void> onDispose() async {
    if (connectionStreamSubscription != null) {
      await connectionStreamSubscription?.cancel();
    }
    if (syncTaskStreamSubscription != null) {
      await syncTaskStreamSubscription?.cancel();
    }
  }
}
