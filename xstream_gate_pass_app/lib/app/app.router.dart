// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedNavigatorGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/cupertino.dart' as _i19;
import 'package:flutter/foundation.dart' as _i20;
import 'package:flutter/material.dart' as _i18;
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart' as _i1;
import 'package:stacked_services/stacked_services.dart' as _i23;
import 'package:xstream_gate_pass_app/core/enums/filestore_type.dart' as _i22;
import 'package:xstream_gate_pass_app/core/models/gatepass/gate-pass-access_model.dart'
    as _i21;
import 'package:xstream_gate_pass_app/ui/views/account/login/login_view.dart'
    as _i5;
import 'package:xstream_gate_pass_app/ui/views/app/main/account/account_view.dart'
    as _i8;
import 'package:xstream_gate_pass_app/ui/views/app/main/account/config/device_scan_settings/device_scan_settings_view.dart'
    as _i13;
import 'package:xstream_gate_pass_app/ui/views/app/main/gate_access_pre_booking_find/gate_access_pre_booking_find_view.dart'
    as _i15;
import 'package:xstream_gate_pass_app/ui/views/app/main/home_view.dart' as _i3;
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/gate_access_menu_view.dart'
    as _i14;
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_staff_list/gate_access_staff_list_view.dart'
    as _i16;
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_visitors_list/gate_access_visitors_list_view.dart'
    as _i17;
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/edit/edit_gatepass_view.dart'
    as _i7;
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/gatepass_view.dart'
    as _i6;
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/cam_barcode_reader/cam_barcode_reader_view.dart'
    as _i12;
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/camera_capture_view.dart'
    as _i10;
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/camera/editor/image_editor_view.dart'
    as _i11;
import 'package:xstream_gate_pass_app/ui/views/shared/data_sync/data_sync_view.dart'
    as _i9;
import 'package:xstream_gate_pass_app/ui/views/startup/startup_view.dart'
    as _i2;
import 'package:xstream_gate_pass_app/ui/views/startup/termsandprivacy/terms_and_privacy_view.dart'
    as _i4;

class Routes {
  static const startUpView = '/';

  static const homeView = '/home-view';

  static const termsAndPrivacyView = '/terms-and-privacy-view';

  static const loginView = '/login-view';

  static const gatePassView = '/gate-pass-view';

  static const gatePassEditView = '/gate-pass-edit-view';

  static const accountView = '/account-view';

  static const dataSyncView = '/data-sync-view';

  static const cameraCaptureView = '/camera-capture-view';

  static const imageEditorView = '/image-editor-view';

  static const camBarcodeReader = '/cam-barcode-reader';

  static const deviceScanSettingsView = '/device-scan-settings-view';

  static const gateAccessMenuView = '/gate-access-menu-view';

  static const gateAccessPreBookingFindView =
      '/gate-access-pre-booking-find-view';

  static const gateAccessStaffListView = '/gate-access-staff-list-view';

  static const gateAccessVisitorsListView = '/gate-access-visitors-list-view';

  static const all = <String>{
    startUpView,
    homeView,
    termsAndPrivacyView,
    loginView,
    gatePassView,
    gatePassEditView,
    accountView,
    dataSyncView,
    cameraCaptureView,
    imageEditorView,
    camBarcodeReader,
    deviceScanSettingsView,
    gateAccessMenuView,
    gateAccessPreBookingFindView,
    gateAccessStaffListView,
    gateAccessVisitorsListView,
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
      Routes.termsAndPrivacyView,
      page: _i4.TermsAndPrivacyView,
    ),
    _i1.RouteDef(
      Routes.loginView,
      page: _i5.LoginView,
    ),
    _i1.RouteDef(
      Routes.gatePassView,
      page: _i6.GatePassView,
    ),
    _i1.RouteDef(
      Routes.gatePassEditView,
      page: _i7.GatePassEditView,
    ),
    _i1.RouteDef(
      Routes.accountView,
      page: _i8.AccountView,
    ),
    _i1.RouteDef(
      Routes.dataSyncView,
      page: _i9.DataSyncView,
    ),
    _i1.RouteDef(
      Routes.cameraCaptureView,
      page: _i10.CameraCaptureView,
    ),
    _i1.RouteDef(
      Routes.imageEditorView,
      page: _i11.ImageEditorView,
    ),
    _i1.RouteDef(
      Routes.camBarcodeReader,
      page: _i12.CamBarcodeReader,
    ),
    _i1.RouteDef(
      Routes.deviceScanSettingsView,
      page: _i13.DeviceScanSettingsView,
    ),
    _i1.RouteDef(
      Routes.gateAccessMenuView,
      page: _i14.GateAccessMenuView,
    ),
    _i1.RouteDef(
      Routes.gateAccessPreBookingFindView,
      page: _i15.GateAccessPreBookingFindView,
    ),
    _i1.RouteDef(
      Routes.gateAccessStaffListView,
      page: _i16.GateAccessStaffListView,
    ),
    _i1.RouteDef(
      Routes.gateAccessVisitorsListView,
      page: _i17.GateAccessVisitorsListView,
    ),
  ];

  final _pagesMap = <Type, _i1.StackedRouteFactory>{
    _i2.StartUpView: (data) {
      return _i18.MaterialPageRoute<dynamic>(
        builder: (context) => const _i2.StartUpView(),
        settings: data,
      );
    },
    _i3.HomeView: (data) {
      final args = data.getArgs<HomeViewArguments>(
        orElse: () => const HomeViewArguments(),
      );
      return _i18.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i3.HomeView(key: args.key, tabIndex: args.tabIndex),
        settings: data,
      );
    },
    _i4.TermsAndPrivacyView: (data) {
      return _i18.MaterialPageRoute<dynamic>(
        builder: (context) => const _i4.TermsAndPrivacyView(),
        settings: data,
      );
    },
    _i5.LoginView: (data) {
      final args = data.getArgs<LoginViewArguments>(
        orElse: () => const LoginViewArguments(),
      );
      return _i18.MaterialPageRoute<dynamic>(
        builder: (context) => _i5.LoginView(key: args.key),
        settings: data,
      );
    },
    _i6.GatePassView: (data) {
      return _i18.MaterialPageRoute<dynamic>(
        builder: (context) => const _i6.GatePassView(),
        settings: data,
      );
    },
    _i7.GatePassEditView: (data) {
      final args = data.getArgs<GatePassEditViewArguments>(nullOk: false);
      return _i18.MaterialPageRoute<dynamic>(
        builder: (context) =>
            _i7.GatePassEditView(key: args.key, gatePass: args.gatePass),
        settings: data,
      );
    },
    _i8.AccountView: (data) {
      return _i18.MaterialPageRoute<dynamic>(
        builder: (context) => const _i8.AccountView(),
        settings: data,
      );
    },
    _i9.DataSyncView: (data) {
      return _i18.MaterialPageRoute<dynamic>(
        builder: (context) => const _i9.DataSyncView(),
        settings: data,
      );
    },
    _i10.CameraCaptureView: (data) {
      final args = data.getArgs<CameraCaptureViewArguments>(nullOk: false);
      return _i19.CupertinoPageRoute<dynamic>(
        builder: (context) => _i10.CameraCaptureView(
            key: args.key,
            refId: args.refId,
            referanceId: args.referanceId,
            fileStoreType: args.fileStoreType),
        settings: data,
      );
    },
    _i11.ImageEditorView: (data) {
      final args = data.getArgs<ImageEditorViewArguments>(nullOk: false);
      return _i19.CupertinoPageRoute<dynamic>(
        builder: (context) =>
            _i11.ImageEditorView(key: args.key, filePath: args.filePath),
        settings: data,
      );
    },
    _i12.CamBarcodeReader: (data) {
      return _i18.MaterialPageRoute<dynamic>(
        builder: (context) => const _i12.CamBarcodeReader(),
        settings: data,
      );
    },
    _i13.DeviceScanSettingsView: (data) {
      return _i18.MaterialPageRoute<dynamic>(
        builder: (context) => const _i13.DeviceScanSettingsView(),
        settings: data,
      );
    },
    _i14.GateAccessMenuView: (data) {
      return _i18.MaterialPageRoute<dynamic>(
        builder: (context) => const _i14.GateAccessMenuView(),
        settings: data,
      );
    },
    _i15.GateAccessPreBookingFindView: (data) {
      return _i18.MaterialPageRoute<dynamic>(
        builder: (context) => const _i15.GateAccessPreBookingFindView(),
        settings: data,
      );
    },
    _i16.GateAccessStaffListView: (data) {
      return _i18.MaterialPageRoute<dynamic>(
        builder: (context) => const _i16.GateAccessStaffListView(),
        settings: data,
      );
    },
    _i17.GateAccessVisitorsListView: (data) {
      return _i18.MaterialPageRoute<dynamic>(
        builder: (context) => const _i17.GateAccessVisitorsListView(),
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

  final _i20.Key? key;

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

class LoginViewArguments {
  const LoginViewArguments({this.key});

  final _i20.Key? key;

  @override
  String toString() {
    return '{"key": "$key"}';
  }

  @override
  bool operator ==(covariant LoginViewArguments other) {
    if (identical(this, other)) return true;
    return other.key == key;
  }

  @override
  int get hashCode {
    return key.hashCode;
  }
}

class GatePassEditViewArguments {
  const GatePassEditViewArguments({
    this.key,
    required this.gatePass,
  });

  final _i20.Key? key;

  final _i21.GatePassAccess gatePass;

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

  final _i20.Key? key;

  final int refId;

  final int referanceId;

  final _i22.FileStoreType fileStoreType;

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

  final _i20.Key? key;

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

extension NavigatorStateExtension on _i23.NavigationService {
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
    _i20.Key? key,
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

  Future<dynamic> navigateToLoginView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo<dynamic>(Routes.loginView,
        arguments: LoginViewArguments(key: key),
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
    _i20.Key? key,
    required _i21.GatePassAccess gatePass,
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
    _i20.Key? key,
    required int refId,
    required int referanceId,
    required _i22.FileStoreType fileStoreType,
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
    _i20.Key? key,
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

  Future<dynamic> navigateToGateAccessPreBookingFindView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return navigateTo<dynamic>(Routes.gateAccessPreBookingFindView,
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
    _i20.Key? key,
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

  Future<dynamic> replaceWithLoginView({
    _i20.Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return replaceWith<dynamic>(Routes.loginView,
        arguments: LoginViewArguments(key: key),
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
    _i20.Key? key,
    required _i21.GatePassAccess gatePass,
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
    _i20.Key? key,
    required int refId,
    required int referanceId,
    required _i22.FileStoreType fileStoreType,
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
    _i20.Key? key,
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

  Future<dynamic> replaceWithGateAccessPreBookingFindView([
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  ]) async {
    return replaceWith<dynamic>(Routes.gateAccessPreBookingFindView,
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
}
