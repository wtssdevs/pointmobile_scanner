import 'dart:convert';

import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/models/account/GetCurrentLoginInformation.dart';
import 'package:xstream_gate_pass_app/core/models/cms/account/cms_current_login_information.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

@LazySingleton()
class CmsSessionRepository {
  final log = getLogger('CmsSessionRepository');
  final LocalStorageService _localStorageService = locator<LocalStorageService>();

  Future<void> save(CmsCurrentLoginInformation session) async {
    _localStorageService.setStringByKey(
      AppConst.cms_currentLoginInformation,
      jsonEncode(session.toJson()),
    );
    _localStorageService.setStringByKey(
      AppConst.cms_currentLoginInformationRefreshedAt,
      DateTime.now().toUtc().toIso8601String(),
    );
    _localStorageService.setUserLoginInfoForPortal(
      AuthPortal.cms,
      session.toLegacyCurrentLoginInformation(),
    );
  }

  CmsCurrentLoginInformation? getCached() {
    final rawJson = _localStorageService.getStringByKey(AppConst.cms_currentLoginInformation);
    if (rawJson.isEmpty) {
      return null;
    }

    try {
      return CmsCurrentLoginInformation.fromJson(
        Map<String, dynamic>.from(jsonDecode(rawJson) as Map),
      );
    } catch (error) {
      log.e('Failed to parse cached CMS current login information', error);
      return null;
    }
  }

  CurrentLoginInformation? getCachedLegacyProfile() {
    return _localStorageService.getUserLoginInfoForPortal(AuthPortal.cms);
  }

  DateTime? getLastRefreshedAt() {
    final rawValue = _localStorageService.getStringByKey(AppConst.cms_currentLoginInformationRefreshedAt);
    if (rawValue.isEmpty) {
      return null;
    }
    return DateTime.tryParse(rawValue);
  }

  void clear() {
    _localStorageService.setStringByKey(AppConst.cms_currentLoginInformation, '');
    _localStorageService.setStringByKey(
      AppConst.cms_currentLoginInformationRefreshedAt,
      '',
    );
  }
}
