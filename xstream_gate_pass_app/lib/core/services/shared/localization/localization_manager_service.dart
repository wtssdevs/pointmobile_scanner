import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:sembast/sembast.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/models/localization/localization_value.dart';
import 'package:xstream_gate_pass_app/core/models/localization/localization_configuration.dart';
import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/database/sembast_store.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

@LazySingleton()
class LocalizationManagerService {
  final log = getLogger('LocalizationManager');
  final ApiManager _apiManager = locator<ApiManager>();
  final _appDatabase = locator<AppDatabase>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  int? userId = 0;
  StoreRef? _dbStore;
  List<LocalizationValue> _localizationValues = [];
  List<LocalizationValue> get localizationValues => _localizationValues;
//TODO save this in local db
  LocalizationConfiguration? _localizationConfiguration;
  LocalizationConfiguration? get localizationConfiguration => _localizationConfiguration;

  LocalizationManagerService() {
    setTableRef();
  }

  void setTableRef() {
    if (userId == 0) {
      userId = _localStorageService.getAuthToken?.userId;
    }

    if (_dbStore == null) {
      _dbStore = stringMapStoreFactory.store("${AppConst.DB_LocalizeValues}_$userId");
    }
  }

  Future<void> insert(LocalizationValue entity) async {
    await _dbStore!.record(entity.key).put(_appDatabase.db!, entity.toJson());
  }

  Future<void> update(LocalizationValue entity) async {
    await _dbStore!.record(entity.key).update(_appDatabase.db!, entity.toJson());
  }

  /// Save many records, create if needed.
  Future<void> upsertMany(List<LocalizationValue> entities) async {
    await _appDatabase.db!.transaction((txn) async {
      for (var entity in entities) {
        await _dbStore!.record(entity.key).put(txn, entity.toJson(), merge: true);
      }
    });
  }

  Future<LocalizationValue?> findByKey(String key) async {
    var rawMap = await _dbStore!.record(key).get(_appDatabase.db!);
    if (rawMap == null) {
      return null;
    }
    return LocalizationValue.fromJson(rawMap as Map<String, dynamic>);
  }

  Future<void> delete(LocalizationValue entity) async {
    await _dbStore!.record(entity.key).delete(_appDatabase.db!);
  }

  Future<void> deleteMany(List<LocalizationValue> entities) async {
    for (var entity in entities) {
      await _dbStore!.record(entity.key).delete(_appDatabase.db!);
    }
  }

  Future<void> clearTableTripstop() async {
    await _dbStore!.drop(_appDatabase.db!);
  }

  Future<List<LocalizationValue>> getAllLocal(String searchArg) async {
    var finder = Finder(sortOrders: [SortOrder(Field.key, false)]);

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

    final recordSnapshot = await _dbStore!.find(_appDatabase.db!, finder: finder);

    if (recordSnapshot.isEmpty) {
      List<LocalizationValue> emptyList = [];
      return emptyList;
    }

    _localizationValues.clear();
    _localizationValues = recordSnapshot.map((snapshot) {
      return LocalizationValue.fromJson(snapshot.value as Map<String, dynamic>);
    }).toList();

    return localizationValues;
  }

  Future<List<LocalizationValue>> getLocalizeValues() async {
    List<LocalizationValue> outPut = <LocalizationValue>[];
    try {
      var baseResponse = await _apiManager.get(AppConst.GetLocalizeValues, showLoader: false);

//test
      if (baseResponse != null && baseResponse['result'] != null) {
        //LocalizationConfiguration

        var localizationConfig = LocalizationConfiguration.fromJson(baseResponse['result']);
        _localizationConfiguration = localizationConfig;
        var data = localizationConfig.localization.values["XAC"];
        if (data != null) {
          data.forEach((nKey, nValue) {
            outPut.add(LocalizationValue(key: nKey, value: nValue));
          });

          await upsertMany(outPut);
          _localizationValues = outPut;
          return outPut;
        }
      }

      return outPut;
    } catch (e) {
      log.e(e.toString());
      return outPut;
    }
  }

  bool hasPermission(String key) {
    var isFound = localizationConfiguration?.auth.grantedPermissions[key];

    if (isFound != null && isFound) {
      return true;
    }

//  localizationConfiguration?.auth.grantedPermissions.forEach((nKey, nValue) {
//             outPut.add(LocalizationValue(key: nKey, value: nValue));
//           });

    return false;
  }

  String localize(String key) {
    if (localizationValues.isEmpty) {
      getAllLocal('');
    }

    var localizationValue = localizationValues.firstWhereOrNull((element) => element.key.toLowerCase() == key.toLowerCase());
    if (localizationValue != null) {
      return localizationValue.value;
    }

    return key.toTitleCase;
  }
}
