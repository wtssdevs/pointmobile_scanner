import 'dart:io';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app_config/app.locator.dart';
import 'package:xstream_gate_pass_app/app_config/app.router.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/dialogs/setup_dialog_ui.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = ((X509Certificate cert, String host, int port) {
        final isValidHost = ["xstream-tms.com", "b71b-169-159-185-137.ngrok.io"].contains(host); // <-- allow only hosts in array
        return isValidHost;
      });
  }
}

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  //var envFileToLoad = ".env_dev";
  //var envFileToLoad = ".env_ngrok_dev";
  //var envFileToLoad = ".env_qa";
  var envFileToLoad = ".env_prod";
  await initialise(envFileToLoad);

  await setupLocator();
  setupDialogUi();
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
    return MaterialApp(
      title: 'Xstream Gatepass',
      theme: FlexThemeData.light(
        scheme: FlexScheme.blueWhale,
      ),
      // The Mandy red, dark theme.
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.blueWhale),
      // Use dark or light theme based on system setting.
      themeMode: ThemeMode.light,
      navigatorKey: StackedService.navigatorKey,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      builder: EasyLoading.init(),
    );
  }
}
