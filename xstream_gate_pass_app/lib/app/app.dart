import 'package:stacked_services/stacked_services.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/database/sembast_store.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/access_token_repo.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/authentication_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/background_job_info_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/sync_manager_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';
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
import 'package:xstream_gate_pass_app/ui/views/account/login/login_view.dart';
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
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_yard_ops/gate_access_yard_ops_view.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: StartUpView, initial: true),
    MaterialRoute(page: HomeView),
    MaterialRoute(page: TermsAndPrivacyView),
    MaterialRoute(page: LoginView),
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
// @stacked-route
  ],
  dependencies: [
    InitializableSingleton(classType: LocalStorageService),
    InitializableSingleton(classType: EnvironmentService),
    LazySingleton(classType: OverlayService),
    InitializableSingleton(classType: ConnectionService),
    Singleton(classType: NavigationService),
    InitializableSingleton(classType: AccessTokenRepo),

    InitializableSingleton(classType: AppDatabase),
    LazySingleton(classType: DialogService),

    InitializableSingleton(classType: ApiManager),
    LazySingleton(classType: AuthenticationService),
    LazySingleton(classType: ScanningService),
    LazySingleton(classType: GatePassService),
    LazySingleton(classType: MasterFilesService),

    LazySingleton(classType: BackgroundJobInfoRepository),
    LazySingleton(classType: FileStoreRepository),
    LazySingleton(classType: MediaService),
    LazySingleton(classType: FileStoreManager),

    LazySingleton(classType: WorkerQueManager),

    Singleton(classType: SyncManager),
    LazySingleton(classType: LocalizationManagerService),
    LazySingleton(classType: BottomSheetService),
// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    StackedBottomsheet(classType: GateAccessVisitorSheet),
    StackedBottomsheet(classType: GateAccessPreBookingSheet),
// @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
  logger: StackedLogger(),
)
class App {}
