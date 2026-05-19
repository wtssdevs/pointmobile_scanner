import 'dart:async';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/models/cms/account/cms_current_login_information.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_lookup_base.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_sync_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';

class CmsSettingsViewModel extends BaseViewModel {
  static const String refreshSessionKey = 'refreshSessionKey';
  static const String syncAllKey = 'syncAllKey';

  final CmsSessionService _cmsSessionService = locator<CmsSessionService>();
  final CmsMasterFilesSyncService _cmsMasterFilesSyncService = locator<CmsMasterFilesSyncService>();
  final NavigationService _navigationService = locator<NavigationService>();

  StreamSubscription<CmsSyncProgress>? _progressSubscription;
  CmsCurrentLoginInformation? _currentSession;
  Map<String, CmsStoreSyncMeta> _syncSummary = {};
  CmsSyncProgress? _latestProgress;
  String? _latestError;
  bool _initialized = false;

  CmsCurrentLoginInformation? get currentSession => _currentSession;
  Map<String, CmsStoreSyncMeta> get syncSummary => _syncSummary;
  CmsSyncProgress? get latestProgress => _latestProgress;
  String? get latestError => _latestError;
  List<CmsMasterFileStore<CmsInspectionLookupBase>> get stores => CmsMasterFileStores.all;

  int get depotCount => _currentSession?.depotCount ?? 0;
  int get yardCount => _currentSession?.yardCount ?? 0;
  String get tenantDisplay => _currentSession?.tenant?.tenancyName ?? 'CMS tenant';
  String get userDisplay => _currentSession?.user?.fullName ?? _currentSession?.user?.userName ?? 'CMS user';

  Future<void> initialise() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    _bindProgress();
    await _reload();
  }

  CmsStoreSyncMeta? metaFor(CmsMasterFileStore<CmsInspectionLookupBase> store) {
    return _syncSummary[store.storeBase];
  }

  bool isStoreSyncing(CmsMasterFileStore<CmsInspectionLookupBase> store) {
    return busy(store.storeBase) || (_latestProgress?.inProgress == true && _latestProgress?.storeBase == store.storeBase);
  }

  Future<void> refreshSessionInfo() async {
    setBusyForObject(refreshSessionKey, true);
    try {
      _currentSession = await _cmsSessionService.refreshFromServer(showLoader: false);
      _latestError = null;
    } catch (error) {
      _latestError = error.toString();
    } finally {
      await _reloadSummaryOnly();
      setBusyForObject(refreshSessionKey, false);
      rebuildUi();
    }
  }

  Future<void> syncAll() async {
    setBusyForObject(syncAllKey, true);
    try {
      final result = await _cmsMasterFilesSyncService.syncAll(force: true);
      if (!result.success && !result.alreadyRunning) {
        _latestError = result.message;
      }
    } finally {
      await _reloadSummaryOnly();
      setBusyForObject(syncAllKey, false);
      rebuildUi();
    }
  }

  Future<void> syncStore(CmsMasterFileStore<CmsInspectionLookupBase> store) async {
    setBusyForObject(store.storeBase, true);
    try {
      final result = await _cmsMasterFilesSyncService.syncStore(store, force: true);
      if (!result.success && !result.alreadyRunning) {
        _latestError = result.message;
      }
    } finally {
      await _reloadSummaryOnly();
      setBusyForObject(store.storeBase, false);
      rebuildUi();
    }
  }

  Future<void> close() async {
    await _navigationService.back();
  }

  Future<void> _reload() async {
    _currentSession = _cmsSessionService.getCached();
    await _reloadSummaryOnly();
    rebuildUi();
  }

  Future<void> _reloadSummaryOnly() async {
    _syncSummary = await _cmsMasterFilesSyncService.getSyncSummary();
  }

  void _bindProgress() {
    _progressSubscription ??= _cmsMasterFilesSyncService.progressStream.listen((progress) async {
      _latestProgress = progress;
      if (progress.failed) {
        _latestError = progress.error ?? progress.message;
      } else if (progress.completed) {
        _latestError = null;
      }
      await _reloadSummaryOnly();
      rebuildUi();
    });
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }
}
