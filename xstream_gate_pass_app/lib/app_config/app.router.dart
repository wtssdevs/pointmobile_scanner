// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// StackedRouterGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs, unused_import, non_constant_identifier_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../core/enums/filestore_type.dart';
import '../core/models/gatepass/gate_pass_model.dart';
import '../ui/views/account/login/login_view.dart';
import '../ui/views/app/main/account/account_view.dart';
import '../ui/views/app/main/home_view.dart';
import '../ui/views/app/main/ops/gatepass/edit/edit_gatepass_view.dart';
import '../ui/views/app/main/ops/gatepass/gatepass_view.dart';
import '../ui/views/app/main/widgets/shared/camera/camera_capture_view.dart';
import '../ui/views/app/main/widgets/shared/camera/editor/image_editor_view.dart';
import '../ui/views/shared/data_sync/data_sync_view.dart';
import '../ui/views/startup/startup_view.dart';
import '../ui/views/startup/termsandprivacy/terms_and_privacy_view.dart';

class Routes {
  static const String startUpView = '/';
  static const String homeView = '/home-view';
  static const String termsAndPrivacyView = '/terms-and-privacy-view';
  static const String loginView = '/login-view';
  static const String gatePassView = '/gate-pass-view';
  static const String gatePassEditView = '/gate-pass-edit-view';
  static const String accountView = '/account-view';
  static const String dataSyncView = '/data-sync-view';
  static const String cameraCaptureView = '/camera-capture-view';
  static const String imageEditorView = '/image-editor-view';
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
  };
}

class StackedRouter extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.startUpView, page: StartUpView),
    RouteDef(Routes.homeView, page: HomeView),
    RouteDef(Routes.termsAndPrivacyView, page: TermsAndPrivacyView),
    RouteDef(Routes.loginView, page: LoginView),
    RouteDef(Routes.gatePassView, page: GatePassView),
    RouteDef(Routes.gatePassEditView, page: GatePassEditView),
    RouteDef(Routes.accountView, page: AccountView),
    RouteDef(Routes.dataSyncView, page: DataSyncView),
    RouteDef(Routes.cameraCaptureView, page: CameraCaptureView),
    RouteDef(Routes.imageEditorView, page: ImageEditorView),
  ];
  @override
  Map<Type, StackedRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, StackedRouteFactory>{
    StartUpView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const StartUpView(),
        settings: data,
      );
    },
    HomeView: (data) {
      var args = data.getArgs<HomeViewArguments>(
        orElse: () => HomeViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => HomeView(
          key: args.key,
          tabIndex: args.tabIndex,
        ),
        settings: data,
      );
    },
    TermsAndPrivacyView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const TermsAndPrivacyView(),
        settings: data,
      );
    },
    LoginView: (data) {
      var args = data.getArgs<LoginViewArguments>(
        orElse: () => LoginViewArguments(),
      );
      return MaterialPageRoute<dynamic>(
        builder: (context) => LoginView(key: args.key),
        settings: data,
      );
    },
    GatePassView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const GatePassView(),
        settings: data,
      );
    },
    GatePassEditView: (data) {
      var args = data.getArgs<GatePassEditViewArguments>(nullOk: false);
      return MaterialPageRoute<dynamic>(
        builder: (context) => GatePassEditView(
          key: args.key,
          gatePass: args.gatePass,
        ),
        settings: data,
      );
    },
    AccountView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const AccountView(),
        settings: data,
      );
    },
    DataSyncView: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => const DataSyncView(),
        settings: data,
      );
    },
    CameraCaptureView: (data) {
      var args = data.getArgs<CameraCaptureViewArguments>(nullOk: false);
      return CupertinoPageRoute<dynamic>(
        builder: (context) => CameraCaptureView(
          key: args.key,
          refId: args.refId,
          referanceId: args.referanceId,
          fileStoreType: args.fileStoreType,
        ),
        settings: data,
      );
    },
    ImageEditorView: (data) {
      var args = data.getArgs<ImageEditorViewArguments>(nullOk: false);
      return CupertinoPageRoute<dynamic>(
        builder: (context) => ImageEditorView(
          key: args.key,
          filePath: args.filePath,
        ),
        settings: data,
      );
    },
  };
}

/// ************************************************************************
/// Arguments holder classes
/// *************************************************************************

/// HomeView arguments holder class
class HomeViewArguments {
  final Key? key;
  final int? tabIndex;
  HomeViewArguments({this.key, this.tabIndex});
}

/// LoginView arguments holder class
class LoginViewArguments {
  final Key? key;
  LoginViewArguments({this.key});
}

/// GatePassEditView arguments holder class
class GatePassEditViewArguments {
  final Key? key;
  final GatePass gatePass;
  GatePassEditViewArguments({this.key, required this.gatePass});
}

/// CameraCaptureView arguments holder class
class CameraCaptureViewArguments {
  final Key? key;
  final int refId;
  final int referanceId;
  final FileStoreType fileStoreType;
  CameraCaptureViewArguments(
      {this.key,
      required this.refId,
      required this.referanceId,
      required this.fileStoreType});
}

/// ImageEditorView arguments holder class
class ImageEditorViewArguments {
  final Key? key;
  final String filePath;
  ImageEditorViewArguments({this.key, required this.filePath});
}

/// ************************************************************************
/// Extension for strongly typed navigation
/// *************************************************************************

extension NavigatorStateExtension on NavigationService {
  Future<dynamic> navigateToStartUpView({
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo(
      Routes.startUpView,
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToHomeView({
    Key? key,
    int? tabIndex,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo(
      Routes.homeView,
      arguments: HomeViewArguments(key: key, tabIndex: tabIndex),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToTermsAndPrivacyView({
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo(
      Routes.termsAndPrivacyView,
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToLoginView({
    Key? key,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo(
      Routes.loginView,
      arguments: LoginViewArguments(key: key),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToGatePassView({
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo(
      Routes.gatePassView,
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToGatePassEditView({
    Key? key,
    required GatePass gatePass,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo(
      Routes.gatePassEditView,
      arguments: GatePassEditViewArguments(key: key, gatePass: gatePass),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToAccountView({
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo(
      Routes.accountView,
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToDataSyncView({
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo(
      Routes.dataSyncView,
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToCameraCaptureView({
    Key? key,
    required int refId,
    required int referanceId,
    required FileStoreType fileStoreType,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo(
      Routes.cameraCaptureView,
      arguments: CameraCaptureViewArguments(
          key: key,
          refId: refId,
          referanceId: referanceId,
          fileStoreType: fileStoreType),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }

  Future<dynamic> navigateToImageEditorView({
    Key? key,
    required String filePath,
    int? routerId,
    bool preventDuplicates = true,
    Map<String, String>? parameters,
    Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
        transition,
  }) async {
    return navigateTo(
      Routes.imageEditorView,
      arguments: ImageEditorViewArguments(key: key, filePath: filePath),
      id: routerId,
      preventDuplicates: preventDuplicates,
      parameters: parameters,
      transition: transition,
    );
  }
}
