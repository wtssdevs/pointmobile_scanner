// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedLocatorGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, implementation_imports, depend_on_referenced_packages

import 'package:stacked_services/src/bottom_sheet/bottom_sheet_service.dart';
import 'package:stacked_services/src/dialog/dialog_service.dart';
import 'package:stacked_services/src/navigation/navigation_service.dart';
import 'package:stacked_shared/stacked_shared.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/sync_manager_service.dart';

import '../core/services/api/api_manager.dart';
import '../core/services/api/cms_api_manager.dart';
import '../core/services/database/sembast_store.dart';
import '../core/services/services/account/access_token_repo.dart';
import '../core/services/services/account/auth_session_coordinator.dart';
import '../core/services/services/account/authentication_service.dart';
import '../core/services/services/account/cms_access_token_repo.dart';
import '../core/services/services/account/cms_authentication_service.dart';
import '../core/services/services/background/background_job_info_repository.dart';
import '../core/services/services/background/workqueue_manager.dart';
import '../core/services/services/cms/cms_inspection_line_photo_queue_service.dart';
import '../core/services/services/cms/cms_master_files_repository.dart';
import '../core/services/services/cms/cms_master_files_sync_service.dart';
import '../core/services/services/cms/cms_media_upload_queue_service.dart';
import '../core/services/services/cms/cms_mobile_file_store_service.dart';
import '../core/services/services/cms/cms_mobile_inspections_service.dart';
import '../core/services/services/cms/cms_mobile_survey_service.dart';
import '../core/services/services/cms/cms_session_repository.dart';
import '../core/services/services/cms/cms_session_service.dart';
import '../core/services/services/filestore/filestore_isolate_initializer.dart';
import '../core/services/services/filestore/filestore_manager.dart';
import '../core/services/services/filestore/filestore_repository.dart';
import '../core/services/services/masterfiles/masterfiles_service.dart';
import '../core/services/services/ops/Incidents/incident_manager_service.dart';
import '../core/services/services/ops/checklists/check_list_service_service.dart';
import '../core/services/services/ops/gatepass/gatepass_service.dart';
import '../core/services/services/scanning/scan_manager.dart';
import '../core/services/shared/connection_service.dart';
import '../core/services/shared/environment_service.dart';
import '../core/services/shared/local_storage_service.dart';
import '../core/services/shared/localization/localization_manager_service.dart';
import '../core/services/shared/media_service.dart';
import '../core/services/shared/overlays/overlay_service.dart';
import '../services/iso_type_service.dart';

final locator = StackedLocator.instance;

Future<void> setupLocator({
  String? environment,
  EnvironmentFilter? environmentFilter,
}) async {
// Register environments
  locator.registerEnvironment(
      environment: environment, environmentFilter: environmentFilter);

// Register dependencies
  final localStorageService = LocalStorageService();
  await localStorageService.init();
  locator.registerSingleton(localStorageService);

  final environmentService = EnvironmentService();
  await environmentService.init();
  locator.registerSingleton(environmentService);

  locator.registerLazySingleton(() => OverlayService());
  final connectionService = ConnectionService();
  await connectionService.init();
  locator.registerSingleton(connectionService);

  locator.registerSingleton(NavigationService());
  final accessTokenRepo = AccessTokenRepo();
  await accessTokenRepo.init();
  locator.registerSingleton(accessTokenRepo);

  final cmsAccessTokenRepo = CmsAccessTokenRepo();
  await cmsAccessTokenRepo.init();
  locator.registerSingleton(cmsAccessTokenRepo);

  final appDatabase = AppDatabase();
  await appDatabase.init();
  locator.registerSingleton(appDatabase);

  locator.registerLazySingleton(() => DialogService());
  final apiManager = ApiManager();
  await apiManager.init();
  locator.registerSingleton(apiManager);

  final cmsApiManager = CmsApiManager();
  await cmsApiManager.init();
  locator.registerSingleton(cmsApiManager);

  locator.registerLazySingleton(() => AuthenticationService());
  locator.registerLazySingleton(() => CmsAuthenticationService());
  locator.registerLazySingleton(() => CmsSessionRepository());
  locator.registerLazySingleton(() => CmsSessionService());
  locator.registerLazySingleton(() => CmsMasterFilesRepository());
  locator.registerLazySingleton(() => CmsMasterFilesSyncService());
  locator.registerLazySingleton(() => CmsMediaUploadQueueService());
  locator.registerLazySingleton(() => CmsInspectionLinePhotoQueueService());
  locator.registerLazySingleton(() => CmsMobileFileStoreService());
  locator.registerLazySingleton(() => CmsMobileInspectionsService());
  locator.registerLazySingleton(() => CmsMobileSurveyService());
  locator.registerLazySingleton(() => AuthSessionCoordinator());
  locator.registerLazySingleton(() => ScanningService());
  locator.registerLazySingleton(() => GatePassService());
  locator.registerLazySingleton(() => MasterFilesService());
  locator.registerLazySingleton(() => BackgroundJobInfoRepository());
  locator.registerLazySingleton(() => FileStoreRepository());
  locator.registerLazySingleton(() => MediaService());
  locator.registerLazySingleton(() => FileStoreManager());
  locator.registerLazySingleton(() => FileStoreIsolateInitializer());
  locator.registerLazySingleton(() => IncidentManagerService());
  locator.registerLazySingleton(() => WorkerQueManager());
  locator.registerSingleton(SyncManager());
  locator.registerLazySingleton(() => LocalizationManagerService());
  locator.registerLazySingleton(() => BottomSheetService());
  locator.registerLazySingleton(() => IsoTypeService());
  locator.registerLazySingleton(() => CheckListServiceService());
}
