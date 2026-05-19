// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/cupertino.dart' as _i29;
import 'package:flutter/foundation.dart' as _i30;
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as _i28;
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i35;
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart' as _i31;
import 'package:xstream_gate_pass_app/core/enums/filestore_type.dart' as _i33;
import 'package:xstream_gate_pass_app/core/models/ops/gatepass/gate-pass-access_model.dart'
    as _i32;
import 'package:xstream_gate_pass_app/core/models/shared/filter_params_model.dart'
    as _i34;
import 'package:xstream_gate_pass_app/ui/views/account/dual_login/dual_login_view.dart'
    as _i9;
import 'package:xstream_gate_pass_app/ui/views/app/main/account/account_view.dart'
    as _i12;
import 'package:xstream_gate_pass_app/ui/views/app/main/account/config/device_scan_settings/device_scan_settings_view.dart'
    as _i17;
import 'package:xstream_gate_pass_app/ui/views/app/main/home_view.dart' as _i3;
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/check_list/check_list_view.dart'
    as _i26;
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_manual_list/gate_access_manual_list_view.dart'
    as _i27;
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/gate_access_menu_view.dart'
    as _i18;
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_pre_booking/gate_access_pre_booking_view.dart'
    as _i19;
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_staff_list/gate_access_staff_list_view.dart'
    as _i20;
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_visitors_list/gate_access_visitors_list_view.dart'
    as _i21;
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_yard_ops/gate_access_yard_ops_view.dart'
    as _i22;
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_yard_ops_select/gate_access_yard_ops_select_view.dart'
    as _i24;
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/edit/edit_gatepass_view.dart'
    as _i11;
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/gatepass_view.dart'
    as _i10;
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/cam_barcode_reader/cam_barcode_reader_view.dart'
    as _i16;
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/cam_containerno_reader/cam_containerno_reader_view.dart'
    as _i23;
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/camera_capture_view.dart'
    as _i14;
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/editor/image_editor_view.dart'
    as _i15;
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/images_viewer_list/images_viewer_list_view.dart'
    as _i25;
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/detail/cms_inspection_detail_view.dart'
    as _i7;
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/list/cms_container_inspections_list_view.dart'
    as _i6;
import 'package:xstream_gate_pass_app/ui/views/cms/main/cms_home_view.dart'
    as _i4;
import 'package:xstream_gate_pass_app/ui/views/cms/settings/cms_settings_view.dart'
    as _i5;
import 'package:xstream_gate_pass_app/ui/views/shared/data_sync/data_sync_view.dart'
    as _i13;
import 'package:xstream_gate_pass_app/ui/views/startup/startup_view.dart'
    as _i2;
import 'package:xstream_gate_pass_app/ui/views/startup/termsandprivacy/terms_and_privacy_view.dart'
    as _i8;

class Routes {
  static const startUpView = '/';

  static const homeView = '/home-view';

  static const cmsHomeView = '/cms-home-view';

  static const cmsSettingsView = '/cms-settings-view';

  static const cmsContainerInspectionsListView =
      '/cms-container-inspections-list-view';

  static const cmsInspectionDetailView = '/cms-inspection-detail-view';

  static const termsAndPrivacyView = '/terms-and-privacy-view';

  static const dualLoginView = '/dual-login-view';

  static const gatePassView = '/gate-pass-view';

  static const gatePassEditView = '/gate-pass-edit-view';

  static const accountView = '/account-view';

  static const dataSyncView = '/data-sync-view';

  static const cameraCaptureView = '/camera-capture-view';

  static const imageEditorView = '/image-editor-view';

  static const camBarcodeReader = '/cam-barcode-reader';

  static const deviceScanSettingsView = '/device-scan-settings-view';

  static const gateAccessMenuView = '/gate-access-menu-view';

  static const gateAccessPreBookingView = '/gate-access-pre-booking-view';

  static const gateAccessStaffListView = '/gate-access-staff-list-view';

  static const gateAccessVisitorsListView = '/gate-access-visitors-list-view';

  static const gateAccessYardOpsView = '/gate-access-yard-ops-view';

  static const camContainernoReaderView = '/cam-containerno-reader-view';

  static const gateAccessYardOpsSelectView =
      '/gate-access-yard-ops-select-view';

  static const imagesViewerListView = '/images-viewer-list-view';

  static const checkListView = '/check-list-view';

  static const gateAccessManualListView = '/gate-access-manual-list-view';

  static const all = <String>{
    startUpView,
    homeView,
    cmsHomeView,
    cmsSettingsView,
    cmsContainerInspectionsListView,
    cmsInspectionDetailView,
    termsAndPrivacyView,
    dualLoginView,
    gatePassView,
    gatePassEditView,
    accountView,
    dataSyncView,
    cameraCaptureView,
    imageEditorView,
    camBarcodeReader,
    deviceScanSettingsView,
    gateAccessMenuView,
    gateAccessPreBookingView,
    gateAccessStaffListView,
    gateAccessVisitorsListView,
    gateAccessYardOpsView,
    camContainernoReaderView,
    gateAccessYardOpsSelectView,
    imagesViewerListView,
    checkListView,
    gateAccessManualListView,
  };
}

class StackedRouter extends _i1.RouterBase {
  final _routes = <_i1.RouteDef>[
    _i1.RouteDef(
      Routes.startUpView,
      page: _i2.StartUpView,
    ),
    _i1.RouteDef(
      Routes.homeView,
      page: _i3.HomeView,
    ),
    _i1.RouteDef(
      Routes.cmsHomeView,
      page: _i4.CmsHomeView,
    ),
    _i1.RouteDef(
      Routes.cmsSettingsView,
      page: _i5.CmsSettingsView,
    ),
    _i1.RouteDef(
      Routes.cmsContainerInspectionsListView,
      page: _i6.CmsContainerInspectionsListView,
    ),
    _i1.RouteDef(
      Routes.cmsInspectionDetailView,
      page: _i7.CmsInspectionDetailView,
    ),
    _i1.RouteDef(
      Routes.termsAndPrivacyView,
      page: _i8.TermsAndPrivacyView,
    ),
    _i1.RouteDef(
      Routes.dualLoginView,
      page: _i9.DualLoginView,
    ),
    _i1.RouteDef(
      Routes.gatePassView,
      page: _i10.GatePassView,
    ),
    _i1.RouteDef(
      Routes.gatePassEditView,
      page: _i11.GatePassEditView,
    ),
    _i1.RouteDef(
      Routes.accountView,
      page: _i12.AccountView,
    ),
    _i1.RouteDef(
      Routes.dataSyncView,
      page: _i13.DataSyncView,
    ),
    _i1.RouteDef(
      Routes.cameraCaptureView,
      page: _i14.CameraCaptureView,
    ),
    _i1.RouteDef(
      Routes.imageEditorView,
      page: _i15.ImageEditorView,
    ),
    _i1.RouteDef(
      Routes.camBarcodeReader,
      page: _i16.CamBarcodeReader,
    ),
    _i1.RouteDef(
      Routes.deviceScanSettingsView,
      page: _i17.DeviceScanSettingsView,
    ),
    _i1.RouteDef(
      Routes.gateAccessMenuView,
      page: _i18.GateAccessMenuView,
    ),
    _i1.RouteDef(
      Routes.gateAccessPreBookingView,
      page: _i19.GateAccessPreBookingView,
    ),
    _i1.RouteDef(
      Routes.gateAccessStaffListView,
      page: _i20.GateAccessStaffListView,
    ),
    _i1.RouteDef(
      Routes.gateAccessVisitorsListView,
      page: _i21.GateAccessVisitorsListView,
    ),
    _i1.RouteDef(
      Routes.gateAccessYardOpsView,
      page: _i22.GateAccessYardOpsView,
    ),
    _i1.RouteDef(
      Routes.camContainernoReaderView,
      page: _i23.CamContainernoReaderView,
    ),
    _i1.RouteDef(
      Routes.gateAccessYardOpsSelectView,
      page: _i24.GateAccessYardOpsSelectView,
    ),
    _i1.RouteDef(
      Routes.imagesViewerListView,
      page: _i25.ImagesViewerListView,
    ),
    _i1.RouteDef(
      Routes.checkListView,
      page: _i26.CheckListView,
    ),
    _i1.RouteDef(
      Routes.gateAccessManualListView,
      page: _i27.GateAccessManualListView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.StartUpView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.StartUpView(),
        settings: data,
      );
    },
    _i3.HomeView: (data) {
      final args = data.getArgs<HomeViewArguments>(
        orElse: () => const HomeViewArguments(),
      );
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i3.HomeView(key: args.key, tabIndex: args.tabIndex),
        settings: data,
      );
    },
    _i4.CmsHomeView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i4.CmsHomeView(),
        settings: data,
      );
    },
    _i5.CmsSettingsView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i5.CmsSettingsView(),
        settings: data,
      );
    },
    _i6.CmsContainerInspectionsListView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i6.CmsContainerInspectionsListView(),
        settings: data,
      );
    },
    _i7.CmsInspectionDetailView: (data) {
      final args = data.getArgs<CmsInspectionDetailViewArguments>(
        orElse: () => const CmsInspectionDetailViewArguments(),
      );
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => _i7.CmsInspectionDetailView(
            key: args.key,
            inspectionId: args.inspectionId,
            containerId: args.containerId),
        settings: data,
      );
    },
    _i8.TermsAndPrivacyView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i8.TermsAndPrivacyView(),
        settings: data,
      );
    },
    _i9.DualLoginView: (data) {
      final args = data.getArgs<DualLoginViewArguments>(
        orElse: () => const DualLoginViewArguments(),
      );
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i9.DualLoginView(key: args.key, initialPortal: args.initialPortal),
        settings: data,
      );
    },
    _i10.GatePassView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i10.GatePassView(),
        settings: data,
      );
    },
    _i11.GatePassEditView: (data) {
      final args = data.getArgs<GatePassEditViewArguments>(nullOk: false);
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i11.GatePassEditView(key: args.key, gatePass: args.gatePass),
        settings: data,
      );
    },
    _i12.AccountView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i12.AccountView(),
        settings: data,
      );
    },
    _i13.DataSyncView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i13.DataSyncView(),
        settings: data,
      );
    },
    _i14.CameraCaptureView: (data) {
      final args = data.getArgs<CameraCaptureViewArguments>(nullOk: false);
      return _i29.CupertinoPageRoute<dynamic>(
        builder: (context) => _i14.CameraCaptureView(
            key: args.key,
            refId: args.refId,
            referanceId: args.referanceId,
            fileStoreType: args.fileStoreType),
        settings: data,
      );
    },
    _i15.ImageEditorView: (data) {
      final args = data.getArgs<ImageEditorViewArguments>(nullOk: false);
      return _i29.CupertinoPageRoute<dynamic>(
        builder: (context) =>
            _i15.ImageEditorView(key: args.key, filePath: args.filePath),
        settings: data,
      );
    },
    _i16.CamBarcodeReader: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i16.CamBarcodeReader(),
        settings: data,
      );
    },
    _i17.DeviceScanSettingsView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i17.DeviceScanSettingsView(),
        settings: data,
      );
    },
    _i18.GateAccessMenuView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i18.GateAccessMenuView(),
        settings: data,
      );
    },
    _i19.GateAccessPreBookingView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i19.GateAccessPreBookingView(),
        settings: data,
      );
    },
    _i20.GateAccessStaffListView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i20.GateAccessStaffListView(),
        settings: data,
      );
    },
    _i21.GateAccessVisitorsListView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i21.GateAccessVisitorsListView(),
        settings: data,
      );
    },
    _i22.GateAccessYardOpsView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i22.GateAccessYardOpsView(),
        settings: data,
      );
    },
    _i23.CamContainernoReaderView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i23.CamContainernoReaderView(),
        settings: data,
      );
    },
    _i24.GateAccessYardOpsSelectView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i24.GateAccessYardOpsSelectView(),
        settings: data,
      );
    },
    _i25.ImagesViewerListView: (data) {
      final args = data.getArgs<ImagesViewerListViewArguments>(nullOk: false);
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => _i25.ImagesViewerListView(
            key: args.key, gatePassId: args.gatePassId),
        settings: data,
      );
    },
    _i26.CheckListView: (data) {
      final args = data.getArgs<CheckListViewArguments>(nullOk: false);
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i26.CheckListView(key: args.key, filterParams: args.filterParams),
        settings: data,
      );
    },
    _i27.GateAccessManualListView: (data) {
      return _i28.MaterialPageRoute<dynamic>(
        builder: (context) => const _i27.GateAccessManualListView(),
        settings: data,
      );
    },
  };

  @override
  List<_i1.RouteDef> get routes => _routes;

  @override
  Map<Type, _i1.StackedRouteFactory> get pagesMap => _pagesMap;
}

class HomeViewArguments {
  const HomeViewArguments({
    this.key,
    this.tabIndex,
  });

  final _i30.Key? key;

  final int? tabIndex;

  @override
  String toString() {
    return '{"key": "$key", "tabIndex": "$tabIndex"}';
  }

  @override
  bool operator ==(covariant HomeViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.tabIndex == tabIndex;
  }

  @override
  int get hashCode {
    return key.hashCode ^ tabIndex.hashCode;
  }
}

class CmsInspectionDetailViewArguments {
  const CmsInspectionDetailViewArguments({
    this.key,
    this.inspectionId,
    this.containerId,
  });

  final _i30.Key? key;

  final int? inspectionId;

  final int? containerId;

  @override
  String toString() {
    return '{"key": "$key", "inspectionId": "$inspectionId", "containerId": "$containerId"}';
  }

  @override
  bool operator ==(covariant CmsInspectionDetailViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.inspectionId == inspectionId &&
        other.containerId == containerId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ inspectionId.hashCode ^ containerId.hashCode;
  }
}

class DualLoginViewArguments {
  const DualLoginViewArguments({
    this.key,
    this.initialPortal = _i31.AuthPortal.xac,
  });

  final _i30.Key? key;

  final _i31.AuthPortal initialPortal;

  @override
  String toString() {
    return '{"key": "$key", "initialPortal": "$initialPortal"}';
  }

  @override
  bool operator ==(covariant DualLoginViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.initialPortal == initialPortal;
  }

  @override
  int get hashCode {
    return key.hashCode ^ initialPortal.hashCode;
  }
}

class GatePassEditViewArguments {
  const GatePassEditViewArguments({
    this.key,
    required this.gatePass,
  });

  final _i30.Key? key;

  final _i32.GatePassAccess gatePass;

  @override
  String toString() {
    return '{"key": "$key", "gatePass": "$gatePass"}';
  }

  @override
  bool operator ==(covariant GatePassEditViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.gatePass == gatePass;
  }

  @override
  int get hashCode {
    return key.hashCode ^ gatePass.hashCode;
  }
}

class CameraCaptureViewArguments {
  const CameraCaptureViewArguments({
    this.key,
    required this.refId,
    required this.referanceId,
    required this.fileStoreType,
  });

  final _i30.Key? key;

  final String refId;

  final int referanceId;

  final _i33.FileStoreType fileStoreType;

  @override
  String toString() {
    return '{"key": "$key", "refId": "$refId", "referanceId": "$referanceId", "fileStoreType": "$fileStoreType"}';
  }

  @override
  bool operator ==(covariant CameraCaptureViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key &&
        other.refId == refId &&
        other.referanceId == referanceId &&
        other.fileStoreType == fileStoreType;
  }

  @override
  int get hashCode {
    return key.hashCode ^
        refId.hashCode ^
        referanceId.hashCode ^
        fileStoreType.hashCode;
  }
}

class ImageEditorViewArguments {
  const ImageEditorViewArguments({
    this.key,
    required this.filePath,
  });

  final _i30.Key? key;

  final String filePath;

  @override
  String toString() {
    return '{"key": "$key", "filePath": "$filePath"}';
  }

  @override
  bool operator ==(covariant ImageEditorViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.filePath == filePath;
  }

  @override
  int get hashCode {
    return key.hashCode ^ filePath.hashCode;
  }
}

class ImagesViewerListViewArguments {
  const ImagesViewerListViewArguments({
    this.key,
    required this.gatePassId,
  });

  final _i30.Key? key;

  final String gatePassId;

  @override
  String toString() {
    return '{"key": "$key", "gatePassId": "$gatePassId"}';
  }

  @override
  bool operator ==(covariant ImagesViewerListViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.gatePassId == gatePassId;
  }

  @override
  int get hashCode {
    return key.hashCode ^ gatePassId.hashCode;
  }
}

class CheckListViewArguments {
  const CheckListViewArguments({
    this.key,
    required this.filterParams,
  });

  final _i30.Key? key;

  final _i34.FilterParams filterParams;

  @override
  String toString() {
    return '{"key": "$key", "filterParams": "$filterParams"}';
  }

  @override
  bool operator ==(covariant CheckListViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key && other.filterParams == filterParams;
  }

  @override
  int get hashCode {
    return key.hashCode ^ filterParams.hashCode;
  }
}

extension NavigatorStateExtension on _i35.NavigationService {
  Future<dynamic> navigateToStartUpView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.startUpView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToHomeView({
    _i30.Key? key,
    int? tabIndex,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.homeView,
        arguments: HomeViewArguments(key: key, tabIndex: tabIndex),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCmsHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.cmsHomeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCmsSettingsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.cmsSettingsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCmsContainerInspectionsListView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.cmsContainerInspectionsListView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCmsInspectionDetailView({
    _i30.Key? key,
    int? inspectionId,
    int? containerId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.cmsInspectionDetailView,
        arguments: CmsInspectionDetailViewArguments(
            key: key, inspectionId: inspectionId, containerId: containerId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToTermsAndPrivacyView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.termsAndPrivacyView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToDualLoginView({
    _i30.Key? key,
    _i31.AuthPortal initialPortal = _i31.AuthPortal.xac,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.dualLoginView,
        arguments:
            DualLoginViewArguments(key: key, initialPortal: initialPortal),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToGatePassView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.gatePassView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToGatePassEditView({
    _i30.Key? key,
    required _i32.GatePassAccess gatePass,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.gatePassEditView,
        arguments: GatePassEditViewArguments(key: key, gatePass: gatePass),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToAccountView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.accountView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToDataSyncView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.dataSyncView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCameraCaptureView({
    _i30.Key? key,
    required String refId,
    required int referanceId,
    required _i33.FileStoreType fileStoreType,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.cameraCaptureView,
        arguments: CameraCaptureViewArguments(
            key: key,
            refId: refId,
            referanceId: referanceId,
            fileStoreType: fileStoreType),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToImageEditorView({
    _i30.Key? key,
    required String filePath,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.imageEditorView,
        arguments: ImageEditorViewArguments(key: key, filePath: filePath),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCamBarcodeReader([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.camBarcodeReader,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToDeviceScanSettingsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.deviceScanSettingsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToGateAccessMenuView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.gateAccessMenuView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToGateAccessPreBookingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.gateAccessPreBookingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToGateAccessStaffListView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.gateAccessStaffListView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToGateAccessVisitorsListView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.gateAccessVisitorsListView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToGateAccessYardOpsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.gateAccessYardOpsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCamContainernoReaderView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.camContainernoReaderView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToGateAccessYardOpsSelectView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.gateAccessYardOpsSelectView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToImagesViewerListView({
    _i30.Key? key,
    required String gatePassId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.imagesViewerListView,
        arguments:
            ImagesViewerListViewArguments(key: key, gatePassId: gatePassId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToCheckListView({
    _i30.Key? key,
    required _i34.FilterParams filterParams,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.checkListView,
        arguments: CheckListViewArguments(key: key, filterParams: filterParams),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> navigateToGateAccessManualListView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.gateAccessManualListView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithStartUpView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.startUpView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithHomeView({
    _i30.Key? key,
    int? tabIndex,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.homeView,
        arguments: HomeViewArguments(key: key, tabIndex: tabIndex),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCmsHomeView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.cmsHomeView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCmsSettingsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.cmsSettingsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCmsContainerInspectionsListView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.cmsContainerInspectionsListView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCmsInspectionDetailView({
    _i30.Key? key,
    int? inspectionId,
    int? containerId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.cmsInspectionDetailView,
        arguments: CmsInspectionDetailViewArguments(
            key: key, inspectionId: inspectionId, containerId: containerId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithTermsAndPrivacyView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.termsAndPrivacyView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithDualLoginView({
    _i30.Key? key,
    _i31.AuthPortal initialPortal = _i31.AuthPortal.xac,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.dualLoginView,
        arguments:
            DualLoginViewArguments(key: key, initialPortal: initialPortal),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithGatePassView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.gatePassView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithGatePassEditView({
    _i30.Key? key,
    required _i32.GatePassAccess gatePass,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.gatePassEditView,
        arguments: GatePassEditViewArguments(key: key, gatePass: gatePass),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithAccountView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.accountView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithDataSyncView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.dataSyncView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCameraCaptureView({
    _i30.Key? key,
    required String refId,
    required int referanceId,
    required _i33.FileStoreType fileStoreType,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.cameraCaptureView,
        arguments: CameraCaptureViewArguments(
            key: key,
            refId: refId,
            referanceId: referanceId,
            fileStoreType: fileStoreType),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithImageEditorView({
    _i30.Key? key,
    required String filePath,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.imageEditorView,
        arguments: ImageEditorViewArguments(key: key, filePath: filePath),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCamBarcodeReader([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.camBarcodeReader,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithDeviceScanSettingsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.deviceScanSettingsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithGateAccessMenuView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.gateAccessMenuView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithGateAccessPreBookingView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.gateAccessPreBookingView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithGateAccessStaffListView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.gateAccessStaffListView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithGateAccessVisitorsListView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.gateAccessVisitorsListView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithGateAccessYardOpsView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.gateAccessYardOpsView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCamContainernoReaderView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.camContainernoReaderView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithGateAccessYardOpsSelectView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.gateAccessYardOpsSelectView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithImagesViewerListView({
    _i30.Key? key,
    required String gatePassId,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.imagesViewerListView,
        arguments:
            ImagesViewerListViewArguments(key: key, gatePassId: gatePassId),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithCheckListView({
    _i30.Key? key,
    required _i34.FilterParams filterParams,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.checkListView,
        arguments: CheckListViewArguments(key: key, filterParams: filterParams),
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }

  Future<dynamic> replaceWithGateAccessManualListView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.gateAccessManualListView,
        id: routerId,
        preventDuplicates: preventDuplicates,
        parameters: parameters,
        transition: transition);
  }
}
