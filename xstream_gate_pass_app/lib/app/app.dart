import 'package:stacked_services/stacked_services.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/api/cms_api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/database/sembast_store.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/access_token_repo.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/auth_session_coordinator.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/authentication_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/cms_access_token_repo.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/cms_authentication_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_sync_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_inspection_line_photo_queue_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_media_upload_queue_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_file_store_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_inspections_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_survey_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/background_job_info_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/sync_manager_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/filestore/filestore_isolate_initializer.dart';
import 'package:xstream_gate_pass_app/core/services/services/filestore/filestore_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/filestore/filestore_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/masterfiles/masterfiles_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/gatepass/gatepass_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/scan_manager.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/media_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/overlays/overlay_service.dart';
import 'package:xstream_gate_pass_app/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:xstream_gate_pass_app/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:xstream_gate_pass_app/ui/views/account/dual_login/dual_login_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/account/account_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/home_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/edit/edit_gatepass_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/gatepass_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/camera_capture_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/editor/image_editor_view.dart';

import 'package:xstream_gate_pass_app/ui/views/shared/data_sync/data_sync_view.dart';
import 'package:xstream_gate_pass_app/ui/views/startup/startup_view.dart';
import 'package:xstream_gate_pass_app/ui/views/startup/termsandprivacy/terms_and_privacy_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/cam_barcode_reader/cam_barcode_reader_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/account/config/device_scan_settings/device_scan_settings_view.dart';
import 'package:xstream_gate_pass_app/core/services/shared/localization/localization_manager_service.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/gate_access_menu_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_pre_booking/gate_access_pre_booking_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_staff_list/gate_access_staff_list_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_visitors_list/gate_access_visitors_list_view.dart';
import 'package:xstream_gate_pass_app/ui/bottom_sheets/gate_access_visitor/gate_access_visitor_sheet.dart';
import 'package:xstream_gate_pass_app/ui/bottom_sheets/gate_access_pre_booking/gate_access_pre_booking_sheet.dart';
import 'package:xstream_gate_pass_app/ui/bottom_sheets/cms_inspection_line_editor/cms_inspection_line_editor_sheet.dart';
import 'package:xstream_gate_pass_app/ui/bottom_sheets/cms_inspection_start/cms_inspection_start_sheet.dart';
import 'package:xstream_gate_pass_app/ui/bottom_sheets/cms_survey_type_picker/cms_survey_type_picker_sheet.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_yard_ops/gate_access_yard_ops_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/cam_containerno_reader/cam_containerno_reader_view.dart';
import 'package:xstream_gate_pass_app/services/iso_type_service.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_yard_ops_select/gate_access_yard_ops_select_view.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/images_viewer_list/images_viewer_list_view.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/Incidents/incident_manager_service.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/check_list/check_list_view.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/checklists/check_list_service_service.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_manual_list/gate_access_manual_list_view.dart';
import 'package:xstream_gate_pass_app/ui/bottom_sheets/manual_entry_selection/manual_entry_selection_sheet.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/main/cms_home_view.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/detail/cms_inspection_detail_view.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/list/cms_container_inspections_list_view.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/settings/cms_settings_view.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/media/cms_media_camera_capture_view.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/surveys/detail/cms_survey_detail_view.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/surveys/list/cms_surveys_list_view.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: StartUpView, initial: true),
    MaterialRoute(page: HomeView),
    MaterialRoute(page: CmsHomeView),
    MaterialRoute(page: CmsSettingsView),
    MaterialRoute(page: CmsContainerInspectionsListView),
    MaterialRoute(page: CmsInspectionDetailView),
    CupertinoRoute(page: CmsMediaCameraCaptureView),
    MaterialRoute(page: CmsSurveysListView),
    MaterialRoute(page: CmsSurveyDetailView),
    MaterialRoute(page: TermsAndPrivacyView),
    MaterialRoute(page: DualLoginView),
    MaterialRoute(page: GatePassView),
    MaterialRoute(page: GatePassEditView),
    MaterialRoute(page: AccountView),
    MaterialRoute(page: DataSyncView),
    CupertinoRoute(page: CameraCaptureView),
    CupertinoRoute(page: ImageEditorView),
    MaterialRoute(page: CamBarcodeReader),
    MaterialRoute(page: DeviceScanSettingsView),
    MaterialRoute(page: GateAccessMenuView),
    MaterialRoute(page: GateAccessPreBookingView),
    MaterialRoute(page: GateAccessStaffListView),
    MaterialRoute(page: GateAccessVisitorsListView),
    MaterialRoute(page: GateAccessYardOpsView),
    MaterialRoute(page: CamContainernoReaderView),
    MaterialRoute(page: GateAccessYardOpsSelectView),
    MaterialRoute(page: ImagesViewerListView),
    MaterialRoute(page: CheckListView),
    MaterialRoute(page: GateAccessManualListView),
// @stacked-route
  ],
  dependencies: [
    InitializableSingleton(classType: LocalStorageService),
    InitializableSingleton(classType: EnvironmentService),
    LazySingleton(classType: OverlayService),
    InitializableSingleton(classType: ConnectionService),
    Singleton(classType: NavigationService),
    InitializableSingleton(classType: AccessTokenRepo),
    InitializableSingleton(classType: CmsAccessTokenRepo),

    InitializableSingleton(classType: AppDatabase),
    LazySingleton(classType: DialogService),

    InitializableSingleton(classType: ApiManager),
    InitializableSingleton(classType: CmsApiManager),
    LazySingleton(classType: AuthenticationService),
    LazySingleton(classType: CmsAuthenticationService),
    LazySingleton(classType: CmsSessionRepository),
    LazySingleton(classType: CmsSessionService),
    LazySingleton(classType: CmsMasterFilesRepository),
    LazySingleton(classType: CmsMasterFilesSyncService),
    LazySingleton(classType: CmsMediaUploadQueueService),
    LazySingleton(classType: CmsInspectionLinePhotoQueueService),
    LazySingleton(classType: CmsMobileFileStoreService),
    LazySingleton(classType: CmsMobileInspectionsService),
    LazySingleton(classType: CmsMobileSurveyService),
    LazySingleton(classType: AuthSessionCoordinator),
    LazySingleton(classType: ScanningService),
    LazySingleton(classType: GatePassService),
    LazySingleton(classType: MasterFilesService),

    LazySingleton(classType: BackgroundJobInfoRepository),
    LazySingleton(classType: FileStoreRepository),
    LazySingleton(classType: MediaService),
    LazySingleton(classType: FileStoreManager),
    LazySingleton(classType: FileStoreIsolateInitializer),
    LazySingleton(classType: IncidentManagerService),
    //LazySingleton(classType: BackgroundProcessingConfig),
    //LazySingleton(classType: BackgroundProcessingMigrationService),
    //LazySingleton(classType: BackgroundProcessingMonitor),

    LazySingleton(classType: WorkerQueManager),

    Singleton(classType: SyncManager),
    LazySingleton(classType: LocalizationManagerService),
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: IsoTypeService),

    LazySingleton(classType: CheckListServiceService),
// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    StackedBottomsheet(classType: GateAccessVisitorSheet),
    StackedBottomsheet(classType: GateAccessPreBookingSheet),
    StackedBottomsheet(classType: ManualEntrySelectionSheet),
    StackedBottomsheet(classType: CmsInspectionLineEditorSheet),
    StackedBottomsheet(classType: CmsInspectionStartSheet),
    StackedBottomsheet(classType: CmsSurveyTypePickerSheet),
// @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),

    // @stacked-dialog
  ],
  logger: StackedLogger(),
)
class App {}
