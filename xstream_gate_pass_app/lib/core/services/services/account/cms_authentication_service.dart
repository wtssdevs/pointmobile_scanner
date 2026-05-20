import 'package:dio/dio.dart' as dio_client;
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/models/account/AuthenticateResultModel.dart';
import 'package:xstream_gate_pass_app/core/models/account/GetCurrentLoginInformation.dart';
import 'package:xstream_gate_pass_app/core/models/account/UserCredential.dart';
import 'package:xstream_gate_pass_app/core/models/shared/api_response.dart';
import 'package:xstream_gate_pass_app/core/services/api/cms_api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/account/cms_access_token_repo.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

@LazySingleton()
class CmsAuthenticationService {
  final log = getLogger('CmsAuthenticationService');
  final CmsApiManager _apiManager = locator<CmsApiManager>();
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
  final CmsAccessTokenRepo _accessTokenRepo = locator<CmsAccessTokenRepo>();
  final CmsSessionService _cmsSessionService = locator<CmsSessionService>();

  Future<AuthenticateResultModel?> login({
    required UserCredential userCredential,
  }) async {
    var authResponse = await _apiManager.post(
      AppConst.cms_authentication,
      data: userCredential.toJson(),
      options: dio_client.Options(
        extra: {AppConst.requiresAuthExtraKey: false},
      ),
      showLoader: true,
    );
    var apiResponse = ApiResponse.fromJson(authResponse);

    var authenticateResultModel = _accessTokenRepo.buildAuthenticateResultModel(apiResponse.result, userCredential);

    await processAuthenticateResult(authenticateResultModel, userCredential);
    return authenticateResultModel;
  }

  Future processAuthenticateResult(AuthenticateResultModel authenticateResultModel, UserCredential userCredential) async {
    await _accessTokenRepo.processAuthenticateResult(authenticateResultModel, userCredential);
  }

  void logOutCurrentUser() {
    _localStorageService.logoutPortal(AuthPortal.cms);
    _localStorageService.saveIsLoggedInForPortal(AuthPortal.cms, false);
  }

  Future<bool> refreshToken() async {
    final token = await _accessTokenRepo.getAccessTokenFromStorageOrRefresh();
    return token != null && token.accessToken != null && token.accessToken!.isNotEmpty;
  }

  Future<CurrentLoginInformation?> getUserLoginInfo([bool forceUpdate = false]) async {
    try {
      if (forceUpdate == false) {
        final localProfile = _cmsSessionService.getCachedLegacyProfile();
        if (localProfile != null) {
          return localProfile;
        }
      }

      final refreshedSession = await _cmsSessionService.refreshFromServer(
        showLoader: false,
      );
      return refreshedSession?.toLegacyCurrentLoginInformation() ?? _cmsSessionService.getCachedLegacyProfile();
    } catch (e) {
      log.i("$e");
      return _cmsSessionService.getCachedLegacyProfile();
    }
  }
}
