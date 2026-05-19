import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/api/cms_api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/access_token_repo.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/auth_session_coordinator.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/authentication_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/cms_access_token_repo.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/cms_authentication_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_inspection_line_photo_queue_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_sync_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_file_store_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_inspections_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/sync_manager_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/filestore/filestore_isolate_initializer.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/localization/localization_manager_service.dart';
import 'package:xstream_gate_pass_app/services/iso_type_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/Incidents/incident_manager_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/checklists/check_list_service_service.dart';
// @stacked-import

import 'test_helpers.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<NavigationService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<BottomSheetService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<DialogService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<LocalizationManagerService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<IsoTypeService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<IncidentManagerService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<CheckListServiceService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<LocalStorageService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<EnvironmentService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<ApiManager>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<AccessTokenRepo>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<AuthenticationService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<CmsApiManager>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<CmsAccessTokenRepo>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<CmsAuthenticationService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<CmsSessionService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<CmsMasterFilesSyncService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<CmsInspectionLinePhotoQueueService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<CmsMobileFileStoreService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<CmsMobileInspectionsService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<AuthSessionCoordinator>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<ConnectionService>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<WorkerQueManager>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<SyncManager>(onMissingStub: OnMissingStub.returnDefault),
  MockSpec<FileStoreIsolateInitializer>(onMissingStub: OnMissingStub.returnDefault),
// @stacked-mock-spec
])
void registerServices() {
  getAndRegisterNavigationService();
  getAndRegisterBottomSheetService();
  getAndRegisterDialogService();
  getAndRegisterLocalizationManagerService();
  getAndRegisterIsoTypeService();
  getAndRegisterIncidentManagerService();
  getAndRegisterCheckListServiceService();
  getAndRegisterLocalStorageService();
  getAndRegisterEnvironmentService();
  getAndRegisterApiManager();
  getAndRegisterAccessTokenRepo();
  getAndRegisterAuthenticationService();
  getAndRegisterCmsApiManager();
  getAndRegisterCmsAccessTokenRepo();
  getAndRegisterCmsAuthenticationService();
  getAndRegisterCmsSessionService();
  getAndRegisterCmsMasterFilesSyncService();
  getAndRegisterCmsInspectionLinePhotoQueueService();
  getAndRegisterCmsMobileFileStoreService();
  getAndRegisterCmsMobileInspectionsService();
  getAndRegisterAuthSessionCoordinator();
  getAndRegisterConnectionService();
  getAndRegisterWorkerQueManager();
  getAndRegisterSyncManager();
  getAndRegisterFileStoreIsolateInitializer();
// @stacked-mock-register
}

MockNavigationService getAndRegisterNavigationService() {
  _removeRegistrationIfExists<NavigationService>();
  final service = MockNavigationService();
  locator.registerSingleton<NavigationService>(service);
  return service;
}

MockBottomSheetService getAndRegisterBottomSheetService<T>({
  SheetResponse<T>? showCustomSheetResponse,
}) {
  _removeRegistrationIfExists<BottomSheetService>();
  final service = MockBottomSheetService();

  when(service.showCustomSheet<T, T>(
    enableDrag: anyNamed('enableDrag'),
    enterBottomSheetDuration: anyNamed('enterBottomSheetDuration'),
    exitBottomSheetDuration: anyNamed('exitBottomSheetDuration'),
    ignoreSafeArea: anyNamed('ignoreSafeArea'),
    isScrollControlled: anyNamed('isScrollControlled'),
    barrierDismissible: anyNamed('barrierDismissible'),
    additionalButtonTitle: anyNamed('additionalButtonTitle'),
    variant: anyNamed('variant'),
    title: anyNamed('title'),
    hasImage: anyNamed('hasImage'),
    imageUrl: anyNamed('imageUrl'),
    showIconInMainButton: anyNamed('showIconInMainButton'),
    mainButtonTitle: anyNamed('mainButtonTitle'),
    showIconInSecondaryButton: anyNamed('showIconInSecondaryButton'),
    secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
    showIconInAdditionalButton: anyNamed('showIconInAdditionalButton'),
    takesInput: anyNamed('takesInput'),
    barrierColor: anyNamed('barrierColor'),
    barrierLabel: anyNamed('barrierLabel'),
    customData: anyNamed('customData'),
    data: anyNamed('data'),
    description: anyNamed('description'),
  )).thenAnswer((realInvocation) => Future.value(showCustomSheetResponse ?? SheetResponse<T>()));

  locator.registerSingleton<BottomSheetService>(service);
  return service;
}

MockDialogService getAndRegisterDialogService() {
  _removeRegistrationIfExists<DialogService>();
  final service = MockDialogService();
  locator.registerSingleton<DialogService>(service);
  return service;
}

MockLocalizationManagerService getAndRegisterLocalizationManagerService() {
  _removeRegistrationIfExists<LocalizationManagerService>();
  final service = MockLocalizationManagerService();
  locator.registerSingleton<LocalizationManagerService>(service);
  return service;
}

MockIsoTypeService getAndRegisterIsoTypeService() {
  _removeRegistrationIfExists<IsoTypeService>();
  final service = MockIsoTypeService();
  locator.registerSingleton<IsoTypeService>(service);
  return service;
}

MockIncidentManagerService getAndRegisterIncidentManagerService() {
  _removeRegistrationIfExists<IncidentManagerService>();
  final service = MockIncidentManagerService();
  locator.registerSingleton<IncidentManagerService>(service);
  return service;
}

MockCheckListServiceService getAndRegisterCheckListServiceService() {
  _removeRegistrationIfExists<CheckListServiceService>();
  final service = MockCheckListServiceService();
  locator.registerSingleton<CheckListServiceService>(service);
  return service;
}

MockLocalStorageService getAndRegisterLocalStorageService() {
  _removeRegistrationIfExists<LocalStorageService>();
  final service = MockLocalStorageService();
  locator.registerSingleton<LocalStorageService>(service);
  return service;
}

MockEnvironmentService getAndRegisterEnvironmentService() {
  _removeRegistrationIfExists<EnvironmentService>();
  final service = MockEnvironmentService();
  locator.registerSingleton<EnvironmentService>(service);
  return service;
}

MockApiManager getAndRegisterApiManager() {
  _removeRegistrationIfExists<ApiManager>();
  final service = MockApiManager();
  locator.registerSingleton<ApiManager>(service);
  return service;
}

MockAccessTokenRepo getAndRegisterAccessTokenRepo() {
  _removeRegistrationIfExists<AccessTokenRepo>();
  final service = MockAccessTokenRepo();
  locator.registerSingleton<AccessTokenRepo>(service);
  return service;
}

MockAuthenticationService getAndRegisterAuthenticationService() {
  _removeRegistrationIfExists<AuthenticationService>();
  final service = MockAuthenticationService();
  locator.registerSingleton<AuthenticationService>(service);
  return service;
}

MockCmsApiManager getAndRegisterCmsApiManager() {
  _removeRegistrationIfExists<CmsApiManager>();
  final service = MockCmsApiManager();
  locator.registerSingleton<CmsApiManager>(service);
  return service;
}

MockCmsAccessTokenRepo getAndRegisterCmsAccessTokenRepo() {
  _removeRegistrationIfExists<CmsAccessTokenRepo>();
  final service = MockCmsAccessTokenRepo();
  locator.registerSingleton<CmsAccessTokenRepo>(service);
  return service;
}

MockCmsAuthenticationService getAndRegisterCmsAuthenticationService() {
  _removeRegistrationIfExists<CmsAuthenticationService>();
  final service = MockCmsAuthenticationService();
  locator.registerSingleton<CmsAuthenticationService>(service);
  return service;
}

MockCmsSessionService getAndRegisterCmsSessionService() {
  _removeRegistrationIfExists<CmsSessionService>();
  final service = MockCmsSessionService();
  locator.registerSingleton<CmsSessionService>(service);
  return service;
}

MockCmsMasterFilesSyncService getAndRegisterCmsMasterFilesSyncService() {
  _removeRegistrationIfExists<CmsMasterFilesSyncService>();
  final service = MockCmsMasterFilesSyncService();
  locator.registerSingleton<CmsMasterFilesSyncService>(service);
  return service;
}

MockCmsInspectionLinePhotoQueueService getAndRegisterCmsInspectionLinePhotoQueueService() {
  _removeRegistrationIfExists<CmsInspectionLinePhotoQueueService>();
  final service = MockCmsInspectionLinePhotoQueueService();
  locator.registerSingleton<CmsInspectionLinePhotoQueueService>(service);
  return service;
}

MockCmsMobileFileStoreService getAndRegisterCmsMobileFileStoreService() {
  _removeRegistrationIfExists<CmsMobileFileStoreService>();
  final service = MockCmsMobileFileStoreService();
  locator.registerSingleton<CmsMobileFileStoreService>(service);
  return service;
}

MockCmsMobileInspectionsService getAndRegisterCmsMobileInspectionsService() {
  _removeRegistrationIfExists<CmsMobileInspectionsService>();
  final service = MockCmsMobileInspectionsService();
  locator.registerSingleton<CmsMobileInspectionsService>(service);
  return service;
}

MockAuthSessionCoordinator getAndRegisterAuthSessionCoordinator() {
  _removeRegistrationIfExists<AuthSessionCoordinator>();
  final service = MockAuthSessionCoordinator();
  locator.registerSingleton<AuthSessionCoordinator>(service);
  return service;
}

MockConnectionService getAndRegisterConnectionService() {
  _removeRegistrationIfExists<ConnectionService>();
  final service = MockConnectionService();
  locator.registerSingleton<ConnectionService>(service);
  return service;
}

MockWorkerQueManager getAndRegisterWorkerQueManager() {
  _removeRegistrationIfExists<WorkerQueManager>();
  final service = MockWorkerQueManager();
  locator.registerSingleton<WorkerQueManager>(service);
  return service;
}

MockSyncManager getAndRegisterSyncManager() {
  _removeRegistrationIfExists<SyncManager>();
  final service = MockSyncManager();
  locator.registerSingleton<SyncManager>(service);
  return service;
}

MockFileStoreIsolateInitializer getAndRegisterFileStoreIsolateInitializer() {
  _removeRegistrationIfExists<FileStoreIsolateInitializer>();
  final service = MockFileStoreIsolateInitializer();
  locator.registerSingleton<FileStoreIsolateInitializer>(service);
  return service;
}
// @stacked-mock-create

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}
