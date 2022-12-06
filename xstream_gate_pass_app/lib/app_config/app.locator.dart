// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:stacked_core/stacked_core.dart';
import 'package:stacked_services/stacked_services.dart';

import '../core/services/api/api_manager.dart';
import '../core/services/database/sembast_store.dart';
import '../core/services/services/account/authentication_service.dart';
import '../core/services/services/background/background_job_info_repository.dart';
import '../core/services/services/background/sync_manager_service.dart';
import '../core/services/services/background/workqueue_manager.dart';
import '../core/services/services/filestore/filestore_manager.dart';
import '../core/services/services/filestore/filestore_repository.dart';
import '../core/services/services/masterfiles/masterfiles_service.dart';
import '../core/services/services/ops/gatepass/gatepass_service.dart';
import '../core/services/services/scanning/scan_manager.dart';
import '../core/services/shared/connection_service.dart';
import '../core/services/shared/environment_service.dart';
import '../core/services/shared/local_storage_service.dart';
import '../core/services/shared/media_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator(
    {String? environment, EnvironmentFilter? environmentFilter}) async {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  final localStorageService = await LocalStorageService.getInstance();
  locator.registerSingleton(localStorageService);

  final appDatabase = await AppDatabase.getInstance();
  locator.registerSingleton(appDatabase);

  locator.registerLazySingleton(() => ConnectionService());
  locator.registerLazySingleton(() => EnvironmentService());
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => ApiManager());
  locator.registerLazySingleton(() => AuthenticationService());
  locator.registerLazySingleton(() => ScanningService());
  locator.registerLazySingleton(() => GatePassService());
  locator.registerLazySingleton(() => MasterFilesService());
  locator.registerLazySingleton(() => BackgroundJobInfoRepository());
  locator.registerLazySingleton(() => FileStoreRepository());
  locator.registerLazySingleton(() => MediaService());
  locator.registerLazySingleton(() => FileStoreManager());
  locator.registerLazySingleton(() => WorkerQueManager());
  locator.registerSingleton(SyncManager());
}
