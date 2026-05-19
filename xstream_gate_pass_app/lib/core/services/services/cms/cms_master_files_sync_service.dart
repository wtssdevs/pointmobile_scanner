import 'dart:async';

import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_lookup_base.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/devextreme_load_result.dart';
import 'package:xstream_gate_pass_app/core/services/api/cms_api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

@LazySingleton()
class CmsMasterFilesSyncService {
  CmsMasterFilesSyncService();

  static const int _defaultPageSize = 500;
  static const String _idSortJson = '[{"selector":"id","desc":false}]';

  final log = getLogger('CmsMasterFilesSyncService');
  final CmsApiManager _apiManager = locator<CmsApiManager>();
  final CmsSessionService _cmsSessionService = locator<CmsSessionService>();
  final CmsMasterFilesRepository _repository = locator<CmsMasterFilesRepository>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final StreamController<CmsSyncProgress> _progressController = StreamController<CmsSyncProgress>.broadcast();

  Future<CmsSyncResult>? _activeSync;

  Stream<CmsSyncProgress> get progressStream => _progressController.stream;

  Future<bool> shouldRunInitialSync() async {
    final context = _resolveContext();
    if (context == null) {
      return false;
    }

    for (final store in CmsMasterFileStores.all) {
      final meta = await _repository.getMeta(store, context);
      if (meta?.lastSuccessfulSyncAt == null) {
        return true;
      }
    }

    return false;
  }

  Future<Map<String, CmsStoreSyncMeta>> getSyncSummary() async {
    final context = _resolveContext();
    if (context == null) {
      return {};
    }

    final summary = <String, CmsStoreSyncMeta>{};
    for (final store in CmsMasterFileStores.all) {
      final meta = await _repository.getMeta(store, context);
      summary[store.storeBase] = meta ??
          CmsStoreSyncMeta(
            storeBase: store.storeBase,
            storeLabel: store.displayName,
            tenantId: context.tenantId,
            userId: context.userId,
            itemCount: await _repository.count(store, context, activeOnly: false),
          );
    }
    return summary;
  }

  Future<CmsSyncResult> syncAll({
    bool force = false,
    String reason = 'manual',
  }) {
    if (_activeSync != null) {
      return Future.value(CmsSyncResult.alreadyRunning());
    }

    final future = _runSyncAll(force: force, reason: reason);
    _activeSync = future;
    future.whenComplete(() => _activeSync = null);
    return future;
  }

  Future<CmsSyncResult> syncStore<T extends CmsInspectionLookupBase>(
    CmsMasterFileStore<T> store, {
    bool force = false,
    String reason = 'manual',
  }) async {
    if (_activeSync != null) {
      return CmsSyncResult.alreadyRunning();
    }

    final context = _resolveContext();
    if (context == null) {
      return CmsSyncResult.failure('Missing CMS sync context');
    }

    final future = _syncStore(
      store,
      context,
      force: force,
      reason: reason,
    );
    _activeSync = future;
    future.whenComplete(() => _activeSync = null);
    return future;
  }

  Future<CmsSyncResult> _runSyncAll({
    required bool force,
    required String reason,
  }) async {
    final context = _resolveContext();
    if (context == null) {
      return CmsSyncResult.failure('Missing CMS sync context');
    }

    final storeErrors = <String, String>{};
    var successfulStoreCount = 0;

    for (final store in CmsMasterFileStores.all) {
      final result = await _syncStore(
        store,
        context,
        force: force,
        reason: reason,
      );

      if (result.success || result.skipped) {
        successfulStoreCount++;
      }

      if (!result.success && !result.skipped && !result.cancelled && !result.alreadyRunning) {
        storeErrors[store.storeBase] = result.message;
      }
    }

    if (storeErrors.isEmpty) {
      return CmsSyncResult.success(
        message: 'Synced $successfulStoreCount CMS master-file stores',
      );
    }

    return CmsSyncResult.failure(
      'Some CMS master-file stores failed to sync',
      storeErrors: storeErrors,
    );
  }

  Future<CmsSyncResult> _syncStore<T extends CmsInspectionLookupBase>(
    CmsMasterFileStore<T> store,
    CmsSyncContext context, {
    required bool force,
    required String reason,
  }) async {
    final existingMeta = await _repository.getMeta(store, context);
    if (!force && reason == 'initial-login' && existingMeta?.lastSuccessfulSyncAt != null) {
      return CmsSyncResult.skipped(
        '${store.displayName} already synced for this CMS session',
      );
    }

    await _repository.markAttemptStarted(store, context);
    _emitProgress(
      CmsSyncProgress(
        storeBase: store.storeBase,
        storeLabel: store.displayName,
        inProgress: true,
        message: 'Syncing ${store.displayName}...',
      ),
    );

    try {
      var skip = 0;
      int? totalCount;
      var pageIndex = 0;
      final serverIds = <int>{};

      while (true) {
        if (!_isCurrentContext(context)) {
          return CmsSyncResult.cancelled(
            'CMS session changed while syncing ${store.displayName}',
          );
        }

        pageIndex++;
        final response = await _apiManager.get(
          store.endpoint,
          showLoader: false,
          queryParameters: {
            'skip': skip,
            'take': _defaultPageSize,
            'requireTotalCount': true,
            'sort': _idSortJson,
          },
        );

        final loadResult = DevExtremeLoadResult<T>.fromDynamic(response, store.fromJson);
        totalCount ??= loadResult.totalCount;
        final items = loadResult.data.where((entity) => entity.id != null).toList();
        final pageCount = totalCount == 0 ? 0 : ((totalCount + _defaultPageSize - 1) / _defaultPageSize).ceil();

        _emitProgress(
          CmsSyncProgress(
            storeBase: store.storeBase,
            storeLabel: store.displayName,
            pageIndex: pageIndex,
            pageCount: pageCount,
            inProgress: true,
            message: pageCount > 0 ? 'Syncing ${store.displayName} page $pageIndex of $pageCount' : 'Syncing ${store.displayName}',
          ),
        );

        await _repository.upsertMany(store, items, context);
        serverIds.addAll(items.map((entity) => entity.id!));

        skip += _defaultPageSize;
        if (totalCount == 0 || skip >= totalCount || items.isEmpty) {
          break;
        }
      }

      if (!_isCurrentContext(context)) {
        return CmsSyncResult.cancelled(
          'CMS session changed while finalising ${store.displayName}',
        );
      }

      final localIds = await _repository.getIds(store, context);
      final idsToDelete = localIds.difference(serverIds);
      await _repository.deleteByIds(store, context, idsToDelete);
      final finalCount = await _repository.count(
        store,
        context,
        activeOnly: false,
      );
      await _repository.markSuccess(
        store,
        context,
        itemCount: finalCount,
        serverTotalCount: totalCount,
      );

      _emitProgress(
        CmsSyncProgress(
          storeBase: store.storeBase,
          storeLabel: store.displayName,
          completed: true,
          message: '${store.displayName} synced successfully',
        ),
      );

      return CmsSyncResult.success(
        message: '${store.displayName} synced successfully',
      );
    } catch (error) {
      log.e('Failed to sync CMS master-file store ${store.storeBase}', error);
      await _repository.markFailure(
        store,
        context,
        error: error.toString(),
      );
      _emitProgress(
        CmsSyncProgress(
          storeBase: store.storeBase,
          storeLabel: store.displayName,
          failed: true,
          error: error.toString(),
          message: 'Failed to sync ${store.displayName}',
        ),
      );
      return CmsSyncResult.failure(
        'Failed to sync ${store.displayName}',
      );
    }
  }

  CmsSyncContext? _resolveContext() {
    final cachedSession = _cmsSessionService.getCached();
    final cachedToken = _localStorageService.getAuthTokenForPortal(AuthPortal.cms);
    final tenantId = cachedSession?.tenant?.id ?? _localStorageService.getTenantIdForPortal(AuthPortal.cms) ?? cachedToken?.tenantId;
    final userId = cachedSession?.user?.id ?? cachedToken?.userId;

    if (tenantId == null || userId == null) {
      return null;
    }

    return CmsSyncContext(tenantId: tenantId, userId: userId);
  }

  bool _isCurrentContext(CmsSyncContext context) {
    final latestContext = _resolveContext();
    return latestContext != null && latestContext.matches(context);
  }

  void _emitProgress(CmsSyncProgress progress) {
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }
}
