import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/models/account/GetCurrentLoginInformation.dart';
import 'package:xstream_gate_pass_app/core/models/cms/account/cms_current_login_information.dart';
import 'package:xstream_gate_pass_app/core/services/api/cms_api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_repository.dart';

@LazySingleton()
class CmsSessionService {
  final log = getLogger('CmsSessionService');
  final CmsApiManager _apiManager = locator<CmsApiManager>();
  final CmsSessionRepository _repository = locator<CmsSessionRepository>();

  Future<CmsCurrentLoginInformation?> refreshFromServer({
    bool showLoader = false,
  }) async {
    try {
      final response = await _apiManager.post(
        "/api/services/app/Session/GetCurrentLoginInformations",
        showLoader: showLoader,
      );

      if (response is! Map) {
        return _repository.getCached();
      }

      final payload = response['result'] is Map ? Map<String, dynamic>.from(response['result'] as Map) : Map<String, dynamic>.from(response);
      final session = CmsCurrentLoginInformation.fromJson(payload);
      await _repository.save(session);
      return session;
    } catch (error) {
      log.e('Failed to refresh CMS current login information', error);
      return _repository.getCached();
    }
  }

  CmsCurrentLoginInformation? getCached() => _repository.getCached();

  CurrentLoginInformation? getCachedLegacyProfile() {
    return _repository.getCachedLegacyProfile();
  }

  DateTime? getLastRefreshedAt() => _repository.getLastRefreshedAt();

  void clear() => _repository.clear();
}
