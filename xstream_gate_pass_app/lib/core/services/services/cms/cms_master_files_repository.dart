import 'package:sembast/sembast.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_lookup_base.dart';
import 'package:xstream_gate_pass_app/core/services/database/sembast_store.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';

@LazySingleton()
class CmsMasterFilesRepository {
  final log = getLogger('CmsMasterFilesRepository');
  final AppDatabase _appDatabase = locator<AppDatabase>();
  final StoreRef<String, Map<String, dynamic>> _metaStore = stringMapStoreFactory.store(AppConst.DB_CmsSyncMeta);

  Database get _database => _appDatabase.db!;

  StoreRef<int, Map<String, dynamic>> _entityStore<T extends CmsInspectionLookupBase>(
    CmsMasterFileStore<T> store,
    CmsSyncContext context,
  ) {
    return intMapStoreFactory.store(context.storeNameFor(store.storeBase));
  }

  Future<void> upsertMany<T extends CmsInspectionLookupBase>(
    CmsMasterFileStore<T> store,
    List<T> entities,
    CmsSyncContext context,
  ) async {
    final validEntities = entities.where((entity) => entity.id != null).toList(growable: false);
    if (validEntities.isEmpty) {
      return;
    }

    await _database.transaction((transaction) async {
      final entityStore = _entityStore(store, context);
      for (final entity in validEntities) {
        await entityStore.record(entity.id!).put(
              transaction,
              store.toJson(entity),
            );
      }
    });
  }

  Future<List<T>> getAll<T extends CmsInspectionLookupBase>(
    CmsMasterFileStore<T> store,
    CmsSyncContext context, {
    bool activeOnly = true,
    int? shippingLineId,
  }) async {
    final entityStore = _entityStore(store, context);
    final snapshots = await entityStore.find(_database);

    final items = snapshots
        .map((snapshot) => store.fromJson(Map<String, dynamic>.from(snapshot.value)))
        .where((entity) => entity.id != null)
        .where((entity) => !activeOnly || entity.isActive)
        .where((entity) => entity.matchesShippingLine(shippingLineId))
        .toList();

    items.sort((left, right) {
      final codeCompare = left.sortCode.compareTo(right.sortCode);
      if (codeCompare != 0) {
        return codeCompare;
      }
      return left.sortName.compareTo(right.sortName);
    });

    return items;
  }

  Future<T?> getById<T extends CmsInspectionLookupBase>(
    CmsMasterFileStore<T> store,
    CmsSyncContext context,
    int? id,
  ) async {
    if (id == null) {
      return null;
    }

    final record = await _entityStore(store, context).record(id).get(_database);
    if (record == null) {
      return null;
    }

    return store.fromJson(Map<String, dynamic>.from(record));
  }

  Future<List<T>> search<T extends CmsInspectionLookupBase>(
    CmsMasterFileStore<T> store,
    CmsSyncContext context, {
    String searchTerm = '',
    int skip = 0,
    int take = 20,
    bool activeOnly = true,
    int? shippingLineId,
  }) async {
    final normalizedSearch = searchTerm.trim().toLowerCase();
    final allItems = await getAll(
      store,
      context,
      activeOnly: activeOnly,
      shippingLineId: shippingLineId,
    );

    final filtered =
        normalizedSearch.isEmpty ? allItems : allItems.where((entity) => _matchesLookupSearch(entity, normalizedSearch)).toList(growable: false);

    if (skip >= filtered.length) {
      return <T>[];
    }

    final safeTake = take <= 0 ? 20 : take;
    final end = (skip + safeTake) > filtered.length ? filtered.length : (skip + safeTake);
    return filtered.sublist(skip, end);
  }

  Future<Set<int>> getIds<T extends CmsInspectionLookupBase>(
    CmsMasterFileStore<T> store,
    CmsSyncContext context,
  ) async {
    final snapshots = await _entityStore(store, context).findKeys(_database);
    return snapshots.toSet();
  }

  Future<void> deleteByIds<T extends CmsInspectionLookupBase>(
    CmsMasterFileStore<T> store,
    CmsSyncContext context,
    Set<int> ids,
  ) async {
    if (ids.isEmpty) {
      return;
    }

    await _database.transaction((transaction) async {
      final entityStore = _entityStore(store, context);
      for (final id in ids) {
        await entityStore.record(id).delete(transaction);
      }
    });
  }

  Future<int> count<T extends CmsInspectionLookupBase>(
    CmsMasterFileStore<T> store,
    CmsSyncContext context, {
    bool activeOnly = false,
    int? shippingLineId,
  }) async {
    final items = await getAll(
      store,
      context,
      activeOnly: activeOnly,
      shippingLineId: shippingLineId,
    );
    return items.length;
  }

  Future<void> clearStore<T extends CmsInspectionLookupBase>(
    CmsMasterFileStore<T> store,
    CmsSyncContext context,
  ) async {
    await _entityStore(store, context).drop(_database);
  }

  Future<CmsStoreSyncMeta?> getMeta<T extends CmsInspectionLookupBase>(
    CmsMasterFileStore<T> store,
    CmsSyncContext context,
  ) async {
    final rawMeta = await _metaStore.record(context.storeNameFor(store.storeBase)).get(_database);
    if (rawMeta == null) {
      return null;
    }
    return CmsStoreSyncMeta.fromJson(Map<String, dynamic>.from(rawMeta));
  }

  Future<void> markAttemptStarted<T extends CmsInspectionLookupBase>(
    CmsMasterFileStore<T> store,
    CmsSyncContext context,
  ) async {
    final existing = await getMeta(store, context);
    final meta = (existing ??
            CmsStoreSyncMeta(
              storeBase: store.storeBase,
              storeLabel: store.displayName,
              tenantId: context.tenantId,
              userId: context.userId,
            ))
        .copyWith(
      storeBase: store.storeBase,
      storeLabel: store.displayName,
      tenantId: context.tenantId,
      userId: context.userId,
      lastAttemptAt: DateTime.now().toUtc(),
      clearLastError: true,
    );

    await _metaStore.record(context.storeNameFor(store.storeBase)).put(_database, meta.toJson());
  }

  Future<void> markSuccess<T extends CmsInspectionLookupBase>(
    CmsMasterFileStore<T> store,
    CmsSyncContext context, {
    required int itemCount,
    required int serverTotalCount,
  }) async {
    final existing = await getMeta(store, context);
    final meta = (existing ??
            CmsStoreSyncMeta(
              storeBase: store.storeBase,
              storeLabel: store.displayName,
              tenantId: context.tenantId,
              userId: context.userId,
            ))
        .copyWith(
      storeBase: store.storeBase,
      storeLabel: store.displayName,
      tenantId: context.tenantId,
      userId: context.userId,
      lastAttemptAt: DateTime.now().toUtc(),
      lastSuccessfulSyncAt: DateTime.now().toUtc(),
      itemCount: itemCount,
      serverTotalCount: serverTotalCount,
      clearLastError: true,
    );

    await _metaStore.record(context.storeNameFor(store.storeBase)).put(_database, meta.toJson());
  }

  Future<void> markFailure<T extends CmsInspectionLookupBase>(
    CmsMasterFileStore<T> store,
    CmsSyncContext context, {
    required String error,
  }) async {
    final existing = await getMeta(store, context);
    final meta = (existing ??
            CmsStoreSyncMeta(
              storeBase: store.storeBase,
              storeLabel: store.displayName,
              tenantId: context.tenantId,
              userId: context.userId,
            ))
        .copyWith(
      storeBase: store.storeBase,
      storeLabel: store.displayName,
      tenantId: context.tenantId,
      userId: context.userId,
      lastAttemptAt: DateTime.now().toUtc(),
      lastError: error,
    );

    await _metaStore.record(context.storeNameFor(store.storeBase)).put(_database, meta.toJson());
  }

  bool _matchesLookupSearch(CmsInspectionLookupBase entity, String normalizedSearch) {
    final values = <String?>[
      entity.code,
      entity.altCode,
      entity.name,
      entity.displayName,
    ];

    for (final value in values) {
      if (value == null || value.trim().isEmpty) {
        continue;
      }

      final normalizedValue = value.toLowerCase();
      if (normalizedValue.startsWith(normalizedSearch) || normalizedValue.contains(normalizedSearch)) {
        return true;
      }
    }

    return false;
  }
}
