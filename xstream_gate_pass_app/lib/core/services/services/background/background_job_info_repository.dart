
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app_config/app.locator.dart';
import 'package:xstream_gate_pass_app/app_config/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/models/background_job_que/background_job_Info.dart';
import 'package:xstream_gate_pass_app/core/services/database/sembast_store.dart';
import 'package:xstream_gate_pass_app/core/services/shared/guid_generator.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';


@LazySingleton()
class BackgroundJobInfoRepository {
  final log = getLogger('BackgroundJobInfoRepository');
  final _appDatabase = locator<AppDatabase>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  int? userId = 0;
  StoreRef? _store;

  BackgroundJobInfoRepository() {
    setTableRef();
  }

  void setTableRef() {
    if (userId == 0) {
      userId = _localStorageService.getAuthToken?.userId;
    }

    _store ??= stringMapStoreFactory.store("${AppConst.DB_BackgroundJobInfo}_$userId");
  }

  Future<void> insert(BackgroundJobInfo entity) async {
    entity.id = Guid.newGuidAsString;
    await _store!.record(entity.id).put(_appDatabase.db!, entity.toJson());
  }

  Future<void> update(BackgroundJobInfo entity) async {
    await _store!.record(entity.id).update(_appDatabase.db!, entity.toJson());
  }

  Future<void> delete(BackgroundJobInfo entity) async {
    //final finder = Finder(filter: Filter.byKey(tripStop.id));

    await _store!.record(entity.id).delete(_appDatabase.db!);
  }

  Future<void> deleteMany(List<BackgroundJobInfo> entities) async {
    for (var entity in entities) {
      await _store!.record(entity.id).delete(_appDatabase.db!);
    }
  }

  /// Save many records, create if needed.
  Future<void> upsertMany(List<BackgroundJobInfo> entities) async {
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

  Future<List<BackgroundJobInfo>> getAll(String searchArg) async {
    var filter = Filter.and([
      Filter.equals('isAbandoned', false),
      // Filter.greaterThanOrEquals(
      //   'nextTryTime',
      //   Timestamp.now(),
      // ),
    ]);
    var finder = Finder(sortOrders: [SortOrder("tryCount")], filter: filter, limit: 300);

    final recordSnapshot = await _store!.find(_appDatabase.db!, finder: finder);

    if (recordSnapshot.isEmpty) {
      List<BackgroundJobInfo> emptyList = [];
      return emptyList;
    }

    var outPutList = recordSnapshot.map((snapshot) {
      return BackgroundJobInfo.fromJson(snapshot.value);
    }).toList();
    var dateNow = DateTime.now();
    //filter date delay
    outPutList = outPutList.where((x) => x.nextTryTime.toDateTime().isBefore(dateNow)).toList();

    // for (var x in outPutList) {
    //   var isBefore = x.nextTryTime.toDateTime().isBefore(dateNow);
    //   log.d("Next :${x.nextTryTime.toDateTime().toIso8601String()},Now: ${dateNow.toIso8601String()},is Before: $isBefore");
    // }

    return outPutList;
  }
}
