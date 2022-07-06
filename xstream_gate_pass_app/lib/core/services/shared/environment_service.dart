import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app_config/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';

/// Returns values from the environment read from the .env file
//@LazySingleton()
@Presolve()
class EnvironmentService {
  final log = getLogger('EnvironmentService');
  // final String envFileToLoad = ".env_dev";
  // Future initialise() async {
  //   //var envFileToLoad = ".env_qa";
  //   //var envFileToLoad = ".env_prod";
  //   log.i('Load environment');
  //   await dotenv.load(fileName: envFileToLoad);
  //   log.v('Environement file $envFileToLoad loaded');
  // }

  /// Returns the value associated with the key
  String getValue(String key, {bool verbose = false}) {
    if (dotenv.isInitialized) {
      final value = dotenv.get(key, fallback: AppConst.NoKey);
      if (verbose) log.v('key:$key value:$value');
      return value;
    } else {
      return AppConst.NoKey;
    }
  }
}
