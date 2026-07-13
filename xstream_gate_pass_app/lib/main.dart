import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:xstream_gate_pass_app/app/app.bottomsheets.dart';
import 'package:xstream_gate_pass_app/app/app.dialogs.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/environment_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/thirdparty_services_module.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/setup_snackbar_ui.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = ((X509Certificate cert, String host, int port) {
        final isValidHost = AppConst.isSSLHostAllowed(host);
        //print("Host validation result for $host: $isValidHost");
        return isValidHost;
      });
  }
}

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  HttpOverrides.global = MyHttpOverrides();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  //Initialize Logging
  await FlutterLogs.initLogs(
    logLevelsEnabled: [LogLevel.INFO, LogLevel.WARNING, LogLevel.ERROR, LogLevel.SEVERE],
    timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
    directoryStructure: DirectoryStructure.FOR_DATE,
    logTypesEnabled: ["device", "network", "errors"],
    logFileExtension: LogFileExtension.TXT,
    logsWriteDirectoryName: "GatePassLogs",
    logsExportDirectoryName: "GatePassLogs/Exported",
    debugFileOperations: true,
    autoDeleteZipOnExport: true,
    isDebuggable: true,
  );

  // Env file is chosen at build time via --dart-define, so release builds never
  // require editing this file. Defaults to .env_dev for local runs.
  //   Local dev (default): fvm flutter run
  //   CMS Play release:     fvm flutter build appbundle --release --dart-define=ENV_FILE=.env_prod_cms
  // Options: .env_dev | .env_local_proxy_dev | .env_qa | .env_prod | .env_prod_cms
  const envFileToLoad = String.fromEnvironment('ENV_FILE', defaultValue: '.env_dev');
  await initialise(envFileToLoad);
  await setupLocator();
  setupExtraLocator();
  setupDialogUi();
  setupBottomSheetUi();
  setupSnackbarUi();
  locator<EnvironmentService>().setBasics();
  await locator<ConnectionService>().initialize();

  runApp(const MyApp());
}

Future initialise(String envFileToLoad) async {
  if (kDebugMode) {
    print('Loading Environment File -> $envFileToLoad');
  }
  await dotenv.load(fileName: envFileToLoad);
  if (kDebugMode) {
    print('Environement file $envFileToLoad loaded');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        title: 'Xstream Gatepass',
        theme: FlexThemeData.light(
          scheme: FlexScheme.blue,
        ),
        // The Mandy red, dark theme.
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.blueWhale),
        // Use dark or light theme based on system setting.
        themeMode: ThemeMode.light,
        navigatorKey: StackedService.navigatorKey,
        onGenerateRoute: StackedRouter().onGenerateRoute,
        navigatorObservers: [
          StackedService.routeObserver,
        ],
        builder: EasyLoading.init(),
      ),
    );
  }
}
