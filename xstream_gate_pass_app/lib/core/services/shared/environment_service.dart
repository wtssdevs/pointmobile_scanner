import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';

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
    baseUrl = "${getBaseUrl(AuthPortal.xac)}/";
  }

  String getBaseUrl(AuthPortal portal) {
    final key = portal == AuthPortal.cms
        ? AppConst.CMS_API_Base_Url
        : AppConst.API_Base_Url;
    final value = getValue(key);
    if (value == AppConst.NoKey || value.isEmpty) {
      return getValue(AppConst.API_Base_Url);
    }
    return value;
  }

  String getHostName(AuthPortal portal) {
    final key = portal == AuthPortal.cms
        ? AppConst.CMS_Base_hostname
        : AppConst.Base_hostname;
    final value = getValue(key);
    if (value == AppConst.NoKey || value.isEmpty) {
      return getValue(AppConst.Base_hostname);
    }
    return value;
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
