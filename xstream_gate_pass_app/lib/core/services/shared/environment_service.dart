import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';

/// Returns values from the environment read from the .env file
@InitializableSingleton()
class EnvironmentService {
  final log = getLogger('EnvironmentService');
  String baseUrl = "";
  Future<void> init() async {
    log.d('Initialized');
  }

  void setBasics() async {
    log.d('setBasics');
    baseUrl = "${getValue(AppConst.API_Base_Url)}/";
  }

  /// Returns the value associated with the key
  String getValue(String key, {bool verbose = false}) {
    if (dotenv.isInitialized) {
      final value = dotenv.get(key, fallback: AppConst.NoKey);
      if (verbose) log.d('key:$key value:$value');
      return value;
    } else {
      return AppConst.NoKey;
    }
  }
}
