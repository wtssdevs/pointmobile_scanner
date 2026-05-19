import 'dart:async';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.dialogs.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/enums/basic_dialog_status.dart';
import 'package:xstream_gate_pass_app/core/models/account/GetCurrentLoginInformation.dart';
import 'package:xstream_gate_pass_app/core/models/cms/account/cms_current_login_information.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/auth_session_coordinator.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/cms_authentication_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_sync_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class CmsHomeViewModel extends BaseViewModel {
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final CmsAuthenticationService _cmsAuthenticationService = locator<CmsAuthenticationService>();
  final CmsSessionService _cmsSessionService = locator<CmsSessionService>();
  final CmsMasterFilesSyncService _cmsMasterFilesSyncService = locator<CmsMasterFilesSyncService>();
  final AuthSessionCoordinator _authSessionCoordinator = locator<AuthSessionCoordinator>();
  final DialogService _dialogService = locator<DialogService>();
  final EnvironmentService _environmentService = locator<EnvironmentService>();
  final NavigationService _navigationService = locator<NavigationService>();

  CurrentLoginInformation? _currentLoginInformation;
  CurrentLoginInformation? get currentLoginInformation => _currentLoginInformation;
  CmsCurrentLoginInformation? _cmsCurrentLoginInformation;
  CmsCurrentLoginInformation? get cmsCurrentLoginInformation => _cmsCurrentLoginInformation;

  StreamSubscription<CmsSyncProgress>? _progressSubscription;
  Map<String, CmsStoreSyncMeta> _syncSummary = {};
  CmsSyncProgress? _latestProgress;
  String? _latestSyncError;
  bool _isSyncing = false;
  bool _hasInitialised = false;

  String baseUrl = '';

  String get tenantDisplay => _cmsCurrentLoginInformation?.tenant?.tenancyName ?? _currentLoginInformation?.tenant.tenancyName ?? 'CMS tenant';

  String get userDisplay => _cmsCurrentLoginInformation?.user?.fullName ?? _currentLoginInformation?.user.showFullName ?? 'CMS user';

  int get depotCount => _cmsCurrentLoginInformation?.depotCount ?? 0;
  int get yardCount => _cmsCurrentLoginInformation?.yardCount ?? 0;
  bool get isSyncing => _isSyncing;
  String? get latestSyncError => _latestSyncError;
  int get syncedStoreCount => _syncSummary.values.where((item) => item.lastSuccessfulSyncAt != null).length;
  int get totalCachedItems => _syncSummary.values.fold(0, (sum, item) => sum + item.itemCount);
  DateTime? get lastSuccessfulSyncAt {
    final values = _syncSummary.values.map((item) => item.lastSuccessfulSyncAt).whereType<DateTime>().toList();
    if (values.isEmpty) {
      return null;
    }
    values.sort((left, right) => right.compareTo(left));
    return values.first;
  }

  String get syncCardTitle {
    if (_isSyncing) {
      return 'Syncing inspection master files';
    }
    if (_latestSyncError != null && _latestSyncError!.isNotEmpty) {
      return 'Inspection sync needs attention';
    }
    if (lastSuccessfulSyncAt != null) {
      return 'Inspection master files ready';
    }
    return 'Inspection master files not synced';
  }

  String get syncCardSubtitle {
    if (_isSyncing && _latestProgress?.message != null) {
      return _latestProgress!.message!;
    }

    final parts = <String>[
      '$syncedStoreCount/4 stores',
      '$totalCachedItems cached items',
    ];

    if (lastSuccessfulSyncAt != null) {
      parts.add('Last sync ${lastSuccessfulSyncAt.toFormattedString()}');
    } else {
      parts.add('Sync pending');
    }

    if (_latestSyncError != null && _latestSyncError!.isNotEmpty) {
      parts.add('Error: $_latestSyncError');
    }

    return parts.join(' • ');
  }

  bool get isCmsLoggedIn => _localStorageService.isLoggedInForPortal(AuthPortal.cms);

  Future<void> handleStartUpLogic() async {
    if (_hasInitialised) {
      return;
    }
    _hasInitialised = true;
    baseUrl = _environmentService.getHostName(AuthPortal.cms);
    _bindProgress();
    _cmsCurrentLoginInformation = _cmsSessionService.getCached();
    _currentLoginInformation =
        _cmsCurrentLoginInformation?.toLegacyCurrentLoginInformation() ?? _localStorageService.getUserLoginInfoForPortal(AuthPortal.cms);

    _currentLoginInformation ??= await _cmsAuthenticationService.getUserLoginInfo(true);

    _cmsCurrentLoginInformation ??= await _cmsSessionService.refreshFromServer(showLoader: false);
    _currentLoginInformation ??= _cmsCurrentLoginInformation?.toLegacyCurrentLoginInformation();
    _syncSummary = await _cmsMasterFilesSyncService.getSyncSummary();

    rebuildUi();

    if (await _cmsMasterFilesSyncService.shouldRunInitialSync()) {
      unawaited(syncNow(force: false, reason: 'initial-login'));
    }
  }

  Future<void> syncNow({
    bool force = true,
    String reason = 'manual',
  }) async {
    if (_isSyncing) {
      return;
    }

    _isSyncing = true;
    _latestSyncError = null;
    rebuildUi();

    final result = await _cmsMasterFilesSyncService.syncAll(
      force: force,
      reason: reason,
    );

    if (!result.success && !result.alreadyRunning && !result.skipped) {
      _latestSyncError = result.message;
    }

    _isSyncing = false;
    _syncSummary = await _cmsMasterFilesSyncService.getSyncSummary();
    rebuildUi();
  }

  Future<void> openSettings() async {
    await _navigationService.navigateToCmsSettingsView();
  }

  Future<void> openContainerInspections() async {
    await _navigationService.navigateToCmsContainerInspectionsListView();
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
    var confirm = await _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        data: BasicDialogStatus.warning,
        title: 'Confirm CMS Logout.',
        description: 'Are you sure you want to logout of CMS?',
        mainButtonTitle: 'Accept',
        secondaryButtonTitle: 'Decline');

    if (confirm != null) {
      return confirm.confirmed;
    }

    return false;
  }

  void _bindProgress() {
    _progressSubscription ??= _cmsMasterFilesSyncService.progressStream.listen((progress) async {
      _latestProgress = progress;
      _isSyncing = progress.inProgress;
      if (progress.failed) {
        _latestSyncError = progress.error ?? progress.message;
      } else if (progress.completed) {
        _latestSyncError = null;
      }
      _syncSummary = await _cmsMasterFilesSyncService.getSyncSummary();
      rebuildUi();
    });
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }
}
