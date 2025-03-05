import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:sembast/sembast.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
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
  List<SearchableDropdownMenuItem<int>> _serviceTypes = [];
  List<SearchableDropdownMenuItem<int>> get serviceTypes => _serviceTypes;
  MasterFilesService() {
    setTableRef();
  }
  void setTableRef() {
    if (userId == 0) {
      userId = _localStorageService.getAuthToken?.userId;
    }
  }

  Future<void> loadServiceTypes() async {
    if (_serviceTypes.isEmpty) {
      var localServiceTypes = await getAllLocalByStore(AppConst.DB_ServiceTypes, "");
      _serviceTypes = localServiceTypes
          .map(
            (e) => SearchableDropdownMenuItem(
              value: e.id,
              label: e.name ?? '',
              child: Text('${e.name}'),
            ),
          )
          .toList();
    }
  }

  Future<List<BaseLookup>> getAllServiceTypes() async {
    try {
      List<BaseLookup> entityList = <BaseLookup>[];

      //final Map<String, dynamic> data = <String, dynamic>{};

      var baseResponse = await _apiManager.get(AppConst.GetAllServiceTypesCached, showLoader: false);
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);

        if (apiResponse.success != null && apiResponse.success! == true && apiResponse.result['items'] != null) {
          for (final dynamic item in apiResponse.result['items']) {
            if (item != null) {
              var newL = BaseLookup.fromJsonManualMap(item, idMap: "id", displayNameMap: "name", nameMap: "name", codeMap: "code");

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

  // Future<List<BaseLookup>> getDetainOptionsFromServer() async {
  //   try {
  //     List<BaseLookup> entityList = <BaseLookup>[];

  //     //final Map<String, dynamic> data = <String, dynamic>{};

  //     var baseResponse = await _apiManager.post(AppConst.GetAllCustomers, showLoader: false);
  //     if (baseResponse != null) {
  //       var apiResponse = ApiResponse.fromJson(baseResponse);

  //       if (apiResponse.success != null && apiResponse.success! == true && apiResponse.result['customerslookup'] != null) {
  //         for (final dynamic item in apiResponse.result['customerslookup']) {
  //           if (item != null) {
  //             var newL = BaseLookup.fromJsonManualMap(item, idMap: "id", displayNameMap: "name", nameMap: "name", codeMap: "altCode");

  //             entityList.add(newL);
  //           }
  //         }

  //         return entityList;
  //       }

  //       return entityList;
  //     }
  //     return entityList;
  //   } catch (e) {
  //     log.e(e.toString());
  //     rethrow;
  //   }
  // }

  //Main Sync action for all remote to local db type by store
  Future<void> syncServerWithLocalAll() async {
    await syncServerWithLocalSingle(AppConst.DB_ServiceTypes, await getAllServiceTypes());
  }

  /// Sync local data with server and merge changes
  Future<void> syncServerWithLocalSingle(String store, List<BaseLookup>? server) async {
    var local = await getAllLocalByStore(store, "");

    server ??= await getAllServiceTypes();

    await syncServerWithLocalByStore(store, local, server);
  }

  Future<void> syncServerWithLocalByStore(String store, List<BaseLookup> local, List<BaseLookup> server) async {
    var delta = getDeltaMerge<BaseLookup>(local, server);
    await syncdataStopStatus(store, delta);
  }

  Future<void> syncdataStopStatus(String store, MergeDeltaResponse<BaseLookup> delta) async {
    // added;
    if (delta.added.isNotEmpty) {
      try {
        await upsertManyLocalDB(store, delta.added);
      } catch (e) {
        log.e(e);
      }
    }

    // deleted;
    if (delta.deleted.isNotEmpty) {
      await deleteManyLocalDB(store, delta.deleted);
    }

    // changed;
    if (delta.changed.isNotEmpty) {
      await upsertManyLocalDB(store, delta.changed);
    }
  }

  Future<void> insertLocalDB(String store, BaseLookup entity) async {
    var entityTable = intMapStoreFactory.store("${store}_$userId");
    await entityTable.record(entity.id!).put(_appDatabase.db!, entity.toJson());
  }

  Future<void> updateLocalDB(String store, BaseLookup entity) async {
    var entityTable = intMapStoreFactory.store("${store}_$userId");
    await entityTable.record(entity.id!).update(_appDatabase.db!, entity.toJson());
  }

  /// Save many records, create if needed.
  Future<void> upsertManyLocalDB(String store, List<BaseLookup> entities) async {
    var entityTable = intMapStoreFactory.store("${store}_$userId");
    for (var entity in entities) {
      var updated = await entityTable.record(entity.id!).update(_appDatabase.db!, entity.toJson());

      if (updated == null) {
//insert new
        await entityTable.record(entity.id!).add(_appDatabase.db!, entity.toJson());
      }
    }
  }

  Future<void> deleteLocalDB(String store, BaseLookup entity) async {
    //final finder = Finder(filter: Filter.byKey(tripStop.id));
    var entityTable = intMapStoreFactory.store("${store}_$userId");
    await entityTable.record(entity.id!).delete(_appDatabase.db!);
  }

  Future<void> deleteManyLocalDB(String store, List<BaseLookup> entities) async {
    var entityTable = intMapStoreFactory.store("${store}_$userId");
    for (var entity in entities) {
      await entityTable.record(entity.id!).delete(_appDatabase.db!);
    }
  }

  Future<void> clearTable(String store) async {
    var entityTable = intMapStoreFactory.store("${store}_$userId");
    await entityTable.drop(_appDatabase.db!);
  }

  Future<List<BaseLookup>> getAllLocalByStore(String store, String searchArg) async {
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
    var entityTable = intMapStoreFactory.store("${store}_$userId");
    final recordSnapshot = await entityTable.find(_appDatabase.db!, finder: finder);

    if (recordSnapshot.isEmpty) {
      List<BaseLookup> emptyList = [];
      return emptyList;
    }

    return recordSnapshot.map((snapshot) {
      return BaseLookup.fromJsonManualMap(snapshot.value, idMap: "id", displayNameMap: "name", nameMap: "name", codeMap: "code");
    }).toList();
  }

  Future<List<BaseLookup>> getAllPagedByStore(String store, String searchArg) async {
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
    var entityTable = intMapStoreFactory.store("${store}_$userId");

    //  await entityTable.

    final recordSnapshot = await entityTable.find(_appDatabase.db!, finder: finder);

    if (recordSnapshot.isEmpty) {
      List<BaseLookup> emptyList = [];
      return emptyList;
    }

    return recordSnapshot.map((snapshot) {
      return BaseLookup.fromJsonManualMap(snapshot.value, idMap: snapshot.key.toString(), displayNameMap: "name", nameMap: "name", codeMap: "altCode");
    }).toList();
  }
}
