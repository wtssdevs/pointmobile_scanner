import 'dart:async';
import 'dart:io';
import 'package:sembast/sembast.dart';
import 'package:path/path.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app_config/app.locator.dart';
import 'package:xstream_gate_pass_app/app_config/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/filestore_type.dart';
import 'package:xstream_gate_pass_app/core/models/basefiles/filestore/filestore.dart';
import 'package:xstream_gate_pass_app/core/services/database/sembast_store.dart';
import 'package:xstream_gate_pass_app/core/services/shared/guid_generator.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';


@LazySingleton()
class FileStoreRepository {
  final log = getLogger('FileStoreRepository');
  final _appDatabase = locator<AppDatabase>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();

  int? userId = 0;
  StoreRef? _store;

  FileStoreRepository() {
    setTableRef();
  }
  void setTableRef() {
    if (userId == 0) {
      if (_localStorageService.getAuthToken == null && _localStorageService.getUserInfo != null && _localStorageService.getUserInfo!.id != null) {
//try get from userinfo
        userId = _localStorageService.getUserInfo!.id;
      } else {
        userId = _localStorageService.getAuthToken?.userId;
      }
    }

    if (_store == null) {
      _store = stringMapStoreFactory.store("${AppConst.DB_FileStore}_$userId");
    }
  }

  Future<String> insert(FileStore entity) async {
    entity.id = Guid.newGuidAsString;
    entity.fileName = basename(entity.fileName);
    await _store!.record(entity.id).put(_appDatabase.db!, entity.toJson());
    return entity.id;
  }

  Future<String> upSert(FileStore entity) async {
    var oldEntity = await getByFilter(entity);
    if (oldEntity == null) {
      //not found we have new
      entity.id = Guid.newGuidAsString;
    } else {
      entity.id = oldEntity.id;
    }

    entity.fileName = basename(entity.fileName);
    await _store!.record(entity.id).put(_appDatabase.db!, entity.toJson());
    return entity.id;
  }

  Future<void> update(FileStore entity) async {
    await _store!.record(entity.id).update(_appDatabase.db!, entity.toJson());
  }

  Future<void> delete(FileStore entity) async {
    //final finder = Finder(filter: Filter.byKey(tripStop.id));

    await _store!.record(entity.id).delete(_appDatabase.db!);
  }

  Future<void> deleteMany(List<FileStore> entities) async {
    for (var entity in entities) {
      await _store!.record(entity.id).delete(_appDatabase.db!);
    }
  }

  /// Save many records, create if needed.
  Future<void> upsertMany(List<FileStore> entities) async {
    await _appDatabase.db!.transaction((txn) async {
      for (var entity in entities) {
        if (entity.id == "") {
          entity.id = Guid.newGuidAsString;
        }
        await _store!.record(entity.id).put(txn, entity.toJson(), merge: true);
      }
    });
  }

  Future<void> clearTable() async {
    await _store!.drop(_appDatabase.db!);
  }

  Future<void> clearOldImages() async {
    var list = await getByIsUploaded(true, 200);

    var now = new DateTime.now();
    var nowLess14Days = now.subtract(Duration(days: 14));

    var toClear = list.where((e) => e.createdDateTime.toDateTime().isBefore(nowLess14Days)).toList();

    if (toClear.isNotEmpty) {
      await deleteMany(toClear);
    }
  }

  Future<List<FileStore>> getByIsUploaded(bool upLoaded, [int? limit = 10]) async {
    var finder = Finder(sortOrders: [SortOrder(Field.key, false)], filter: Filter.equals('upLoaded', upLoaded), limit: limit);

    final recordSnapshot = await _store!.find(_appDatabase.db!, finder: finder);

    if (recordSnapshot.isEmpty) {
      List<FileStore> emptyList = [];
      return emptyList;
    }

    return recordSnapshot.map((snapshot) {
      return FileStore.fromJson(snapshot.value);
    }).toList();
  }

  Future<FileStore?> getByFilter(FileStore fileStore) async {
    var filter = Filter.and([
      Filter.equals('refId', fileStore.refId),
      Filter.equals('filestoreType', fileStore.filestoreType),
    ]);
    var finder = Finder(sortOrders: [SortOrder(Field.key, false)], filter: filter, limit: 1);

    final recordSnapshot = await _store!.findFirst(_appDatabase.db!, finder: finder);

    if (recordSnapshot == null) {
      return null;
    }

    var outPutFileStore = FileStore.fromJson(recordSnapshot.value);

    return outPutFileStore;
  }

  Future<FileStore?> getByRefId(String id) async {
    var finder = Finder(sortOrders: [SortOrder(Field.key, false)], filter: Filter.equals('id', id));

    final recordSnapshot = await _store!.findFirst(_appDatabase.db!, finder: finder);

    if (recordSnapshot == null) {
      return null;
    }

    var outPutFileStore = FileStore.fromJson(recordSnapshot.value);

    return outPutFileStore;
  }

  Future<List<FileStore>> getAll(int refId, [int? limit = 10]) async {
    var filter = Filter.and([
      Filter.equals('refId', refId),
      Filter.equals('filestoreType', FileStoreType.image.index),
    ]);
    var finder = Finder(sortOrders: [SortOrder(Field.key, false)], filter: filter, limit: limit);

    final recordSnapshot = await _store!.find(_appDatabase.db!, finder: finder);

    if (recordSnapshot.isEmpty) {
      List<FileStore> emptyList = [];
      return emptyList;
    }

    return recordSnapshot.map((snapshot) {
      return FileStore.fromJson(snapshot.value);
    }).toList();
  }

  Future<List<FileStore>> getAllByRefIdType(int refId, int fileStoreType, [int? limit = 10]) async {
    var filter = Filter.and([
      Filter.equals('refId', refId),
      Filter.equals('filestoreType', fileStoreType),
    ]);
    var finder = Finder(sortOrders: [SortOrder(Field.key, false)], filter: filter, limit: limit);

    final recordSnapshot = await _store!.find(_appDatabase.db!, finder: finder);

    if (recordSnapshot.isEmpty) {
      List<FileStore> emptyList = [];
      return emptyList;
    }

    return recordSnapshot.map((snapshot) {
      return FileStore.fromJson(snapshot.value);
    }).toList();
  }

  Future<File?> getSignatureByRefIdAndType(int refId, int fileStoreType) async {
    var filter = Filter.and([
      Filter.equals('refId', refId),
      Filter.equals('filestoreType', fileStoreType),
    ]);
    var finder = Finder(sortOrders: [SortOrder(Field.key, false)], filter: filter);

    final recordSnapshot = await _store!.findFirst(_appDatabase.db!, finder: finder);
    if (recordSnapshot == null) {
      return null;
    }

    var outPutFileStore = FileStore.fromJson(recordSnapshot.value);
    var file = File(outPutFileStore.path);

    return file;
  }

  Future<FileStore?> getByRefIdAndType(int refId, int fileStoreType) async {
    var filter = Filter.and([
      Filter.equals('refId', refId),
      Filter.equals('filestoreType', fileStoreType),
    ]);
    var finder = Finder(sortOrders: [SortOrder(Field.key, false)], filter: filter);

    final recordSnapshot = await _store!.findFirst(_appDatabase.db!, finder: finder);
    if (recordSnapshot == null) {
      return null;
    }

    var outPutFileStore = FileStore.fromJson(recordSnapshot.value);

    return outPutFileStore;
  }
}
