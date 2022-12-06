import 'dart:convert';
import 'package:sembast/sembast.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app_config/app.locator.dart';
import 'package:xstream_gate_pass_app/app_config/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/models/shared/api_response.dart';
import 'package:xstream_gate_pass_app/core/models/shared/base_lookup.dart';
import 'package:xstream_gate_pass_app/core/models/shared/merge_delta_reponse%20copy.dart';
import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/database/sembast_store.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';

@LazySingleton()
class MasterFilesService {
  final log = getLogger('MasterFilesService');
  final ApiManager _apiManager = locator<ApiManager>();
  final _appDatabase = locator<AppDatabase>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  int? userId = 0;

  MasterFilesService() {
    setTableRef();
  }
  void setTableRef() {
    if (userId == 0) {
      userId = _localStorageService.getAuthToken?.userId;
    }
  }

  Future<void> syncServerWithLocalAll() async {
    await syncServerWithLocalDetainOptionsSingle(await getDetainOptionsFromServer());
  }
  // //*************************STOP STATUS LIST START *************************************** */

  Future<List<BaseLookup>> getDetainOptionsFromServer() async {
    try {
      List<BaseLookup> entityList = <BaseLookup>[];

      //final Map<String, dynamic> data = <String, dynamic>{};

      var baseResponse = await _apiManager.post(AppConst.GetAllCustomers, showLoader: false);
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);

        if (apiResponse.success != null && apiResponse.success! == true && apiResponse.result['customerslookup'] != null) {
          for (final dynamic item in apiResponse.result['customerslookup']) {
            if (item != null) {
              var newL = BaseLookup.fromJsonManualMap(item, displayNameMap: "name", nameMap: "name", codeMap: "altCode");

              entityList.add(newL);
            }
          }

          return entityList;
        }

        return entityList;
      }
      return entityList;
    } catch (e) {
      log.e(e.toString());
      rethrow;
    }
  }

  /// Sync local data with server and merge changes
  Future<void> syncServerWithLocalDetainOptionsSingle(List<BaseLookup>? server) async {
    var local = await getAllLocalDetainOptions("");

    if (server == null) {
      server = await getDetainOptionsFromServer();
    }

    await syncServerWithLocalDetainOptions(local, server);
  }

  Future<void> syncServerWithLocalDetainOptions(List<BaseLookup> local, List<BaseLookup> server) async {
    var delta = getDeltaMerge<BaseLookup>(local, server);
    await syncdataStopStatus(delta);
  }

  Future<void> syncdataStopStatus(MergeDeltaResponse<BaseLookup> delta) async {
    // added;
    if (delta.added.isNotEmpty) {
      try {
        await upsertManyDetainOption(delta.added);
      } catch (e) {
        log.e(e);
      }
    }

    // deleted;
    if (delta.deleted.isNotEmpty) {
      await deleteManyDetainOption(delta.deleted);
    }

    // changed;
    if (delta.changed.isNotEmpty) {
      await upsertManyDetainOption(delta.changed);
    }
  }

  Future<void> insertDetainOption(BaseLookup entity) async {
    var entityTable = intMapStoreFactory.store("${AppConst.DB_Customers}_$userId");
    await entityTable.record(entity.id!).put(_appDatabase.db!, entity.toJson());
  }

  Future<void> updateDetainOption(BaseLookup entity) async {
    var entityTable = intMapStoreFactory.store("${AppConst.DB_Customers}_$userId");
    await entityTable.record(entity.id!).update(_appDatabase.db!, entity.toJson());
  }

  /// Save many records, create if needed.
  Future<void> upsertManyDetainOption(List<BaseLookup> entities) async {
    var entityTable = intMapStoreFactory.store("${AppConst.DB_Customers}_$userId");
    for (var entity in entities) {
      var updated = await entityTable.record(entity.id!).update(_appDatabase.db!, entity.toJson());

      if (updated == null) {
//insert new
        await entityTable.record(entity.id!).add(_appDatabase.db!, entity.toJson());
      }
    }
  }

  Future<void> deleteDetainOption(BaseLookup entity) async {
    //final finder = Finder(filter: Filter.byKey(tripStop.id));
    var entityTable = intMapStoreFactory.store("${AppConst.DB_Customers}_$userId");
    await entityTable.record(entity.id!).delete(_appDatabase.db!);
  }

  Future<void> deleteManyDetainOption(List<BaseLookup> entities) async {
    var entityTable = intMapStoreFactory.store("${AppConst.DB_Customers}_$userId");
    for (var entity in entities) {
      await entityTable.record(entity.id!).delete(_appDatabase.db!);
    }
  }

  Future<void> clearTableDetainOption() async {
    var entityTable = intMapStoreFactory.store("${AppConst.DB_Customers}_$userId");
    await entityTable.drop(_appDatabase.db!);
  }

  Future<List<BaseLookup>> getAllLocalDetainOptions(String searchArg) async {
    var finder = Finder(sortOrders: [SortOrder('orderBy', false, true)]);

    if (searchArg.isNotEmpty) {
      // Using a custom filter exact word (converting everything to lowercase)
      searchArg = searchArg.toLowerCase();
      var edgeCaseSearchArg = " $searchArg";
      var filter = Filter.custom((snapshot) {
        var value = snapshot["name"] as String;
        return value.toLowerCase().startsWith(searchArg) || value.toLowerCase().contains(edgeCaseSearchArg);
      });
      finder.filter = filter;
    }
    var entityTable = intMapStoreFactory.store("${AppConst.DB_Customers}_$userId");
    final recordSnapshot = await entityTable.find(_appDatabase.db!, finder: finder);

    if (recordSnapshot.isEmpty) {
      List<BaseLookup> emptyList = [];
      return emptyList;
    }

    return recordSnapshot.map((snapshot) {
      return BaseLookup.fromJsonManualMap(snapshot.value, displayNameMap: "name", nameMap: "name", codeMap: "altCode");
    }).toList();
  }
}
