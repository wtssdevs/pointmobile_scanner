import 'dart:async';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.dialogs.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/enums/basic_dialog_status.dart';
import 'package:xstream_gate_pass_app/core/models/cms/account/cms_current_login_information.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_lookup_base.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/auth_session_coordinator.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_sync_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

class CmsSettingsViewModel extends BaseViewModel {
  static const String refreshSessionKey = 'refreshSessionKey';
  static const String syncAllKey = 'syncAllKey';

  final CmsSessionService _cmsSessionService = locator<CmsSessionService>();
  final CmsMasterFilesSyncService _cmsMasterFilesSyncService =
      locator<CmsMasterFilesSyncService>();
  final AuthSessionCoordinator _authSessionCoordinator =
      locator<AuthSessionCoordinator>();
  final DialogService _dialogService = locator<DialogService>();
  final EnvironmentService _environmentService = locator<EnvironmentService>();
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();
  final NavigationService _navigationService = locator<NavigationService>();

  StreamSubscription<CmsSyncProgress>? _progressSubscription;
  CmsCurrentLoginInformation? _currentSession;
  Map<String, CmsStoreSyncMeta> _syncSummary = {};
  CmsSyncProgress? _latestProgress;
  String? _latestError;
  bool _initialized = false;

  String baseUrl = '';

  CmsCurrentLoginInformation? get currentSession => _currentSession;
  Map<String, CmsStoreSyncMeta> get syncSummary => _syncSummary;
  CmsSyncProgress? get latestProgress => _latestProgress;
  String? get latestError => _latestError;
  List<CmsMasterFileStore<CmsInspectionLookupBase>> get stores =>
      CmsMasterFileStores.all;

  int get depotCount => _currentSession?.depotCount ?? 0;
  int get yardCount => _currentSession?.yardCount ?? 0;
  String get tenantDisplay =>
      _currentSession?.tenant?.tenancyName ?? 'CMS tenant';
  String get userDisplay =>
      _currentSession?.user?.fullName ??
      _currentSession?.user?.userName ??
      'CMS user';
  bool get isCmsLoggedIn =>
      _localStorageService.isLoggedInForPortal(AuthPortal.cms);

  Future<void> initialise() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    baseUrl = _environmentService.getHostName(AuthPortal.cms);
    _bindProgress();
    await _reload();
  }

  CmsStoreSyncMeta? metaFor(CmsMasterFileStore<CmsInspectionLookupBase> store) {
    return _syncSummary[store.storeBase];
  }

  bool isStoreSyncing(CmsMasterFileStore<CmsInspectionLookupBase> store) {
    return busy(store.storeBase) ||
        (_latestProgress?.inProgress == true &&
            _latestProgress?.storeBase == store.storeBase);
  }

  Future<void> refreshSessionInfo() async {
    setBusyForObject(refreshSessionKey, true);
    try {
      _currentSession =
          await _cmsSessionService.refreshFromServer(showLoader: false);
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

  Future<void> syncStore(
      CmsMasterFileStore<CmsInspectionLookupBase> store) async {
    setBusyForObject(store.storeBase, true);
    try {
      final result =
          await _cmsMasterFilesSyncService.syncStore(store, force: true);
      if (!result.success && !result.alreadyRunning) {
        _latestError = result.message;
      }
    } finally {
      await _reloadSummaryOnly();
      setBusyForObject(store.storeBase, false);
      rebuildUi();
    }
  }

  void close() {
    _navigationService.back();
  }

  Future<void> switchToXac() async {
    await _authSessionCoordinator.switchToPortal(AuthPortal.xac);
  }

  Future<void> logoutCms() async {
    final confirmed = await _confirmLogout();
    if (confirmed) {
      await _authSessionCoordinator.logoutPortal(AuthPortal.cms);
    }
  }

  Future<bool> _confirmLogout() async {
    final confirm = await _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      data: BasicDialogStatus.warning,
      title: 'Confirm CMS Logout.',
      description: 'Are you sure you want to logout of CMS?',
      mainButtonTitle: 'Accept',
      secondaryButtonTitle: 'Decline',
    );

    return confirm?.confirmed == true;
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
    _progressSubscription ??=
        _cmsMasterFilesSyncService.progressStream.listen((progress) async {
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
