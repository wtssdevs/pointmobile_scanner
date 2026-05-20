// ignore_for_file: prefer_conditional_assignment

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/models/account/AuthenticateResultModel.dart';
import 'package:xstream_gate_pass_app/core/models/account/ForgotPassword.dart';
import 'package:xstream_gate_pass_app/core/models/account/GetCurrentLoginInformation.dart';
import 'package:xstream_gate_pass_app/core/models/account/UserLoginInfo.dart';
import 'package:xstream_gate_pass_app/core/models/device/device_config.dart';

@InitializableSingleton()
class LocalStorageService {
  final log = getLogger('LocalStorageService');
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;
  Future<LocalStorageService> init() async {
    log.d('Initialized');
    if (_instance == null) {
      _instance = LocalStorageService();
    }
    _preferences = await SharedPreferences.getInstance();

    return _instance!;
  }

  DeviceConfig get getDeviceConfig {
    var deviceConfig = _getFromDisk(AppConst.deviceConfig);
    if (deviceConfig == null) {
      var newDeviceConfig =
          DeviceConfig(deviceScanningMode: DeviceModelScanningMode.pm84);
      _saveToDisk(AppConst.deviceConfig, json.encode(newDeviceConfig.toJson()));
      return newDeviceConfig;
    }

    return DeviceConfig.fromJson(json.decode(deviceConfig));
  }

  void setDeviceConfig(DeviceConfig deviceConfig) {
    _saveToDisk(AppConst.deviceConfig, json.encode(deviceConfig.toJson()));
  }

  void clearTenantId() => clearTenantIdForPortal(AuthPortal.xac);

  void clearTenantIdForPortal(AuthPortal portal) {
    _preferences!.remove(_tenantIdKey(portal));
    if (portal == AuthPortal.xac) {
      _preferences!.remove(AppConst.tenantId);
    }
  }

  void setTenantId(int value) => setTenantIdForPortal(AuthPortal.xac, value);

  void setTenantIdForPortal(AuthPortal portal, int value) {
    _saveToDisk(_tenantIdKey(portal), value);
    if (portal == AuthPortal.xac) {
      _saveToDisk(AppConst.tenantId, value);
    }
  }

  int? get getTenantId => getTenantIdForPortal(AuthPortal.xac);

  int? getTenantIdForPortal(AuthPortal portal) {
    var tenantId = _getIntFromDisk(_tenantIdKey(portal));
    if (tenantId == null && portal == AuthPortal.xac) {
      tenantId = _getIntFromDisk(AppConst.tenantId);
      if (tenantId != null) {
        _saveToDisk(_tenantIdKey(portal), tenantId);
      }
    }
    return tenantId;
  }

  AuthenticateResultModel? get getAuthToken =>
      getAuthTokenForPortal(AuthPortal.xac);

  AuthenticateResultModel? getAuthTokenForPortal(AuthPortal portal) {
    var authToken = _getFromDisk(_authTokenKey(portal));
    if (authToken == null && portal == AuthPortal.xac) {
      authToken = _getFromDisk(AppConst.auth_token);
      if (authToken != null) {
        _saveToDisk(_authTokenKey(portal), authToken);
      }
    }
    if (authToken == null) {
      return null;
    }

    return AuthenticateResultModel.fromJson(json.decode(authToken));
  }

  void setAuthToken(AuthenticateResultModel authToken) =>
      setAuthTokenForPortal(AuthPortal.xac, authToken);

  void setAuthTokenForPortal(
      AuthPortal portal, AuthenticateResultModel authToken) {
    final jsonAuthToken = json.encode(authToken.toJson());
    _saveToDisk(_authTokenKey(portal), jsonAuthToken);
    saveIsLoggedInForPortal(portal, true);
    if (portal == AuthPortal.xac) {
      _saveToDisk(AppConst.auth_token, jsonAuthToken);
      _saveToDisk(AppConst.is_logged_in, true);
    }
  }

  void clearAuthToken() => clearAuthTokenForPortal(AuthPortal.xac);

  void clearAuthTokenForPortal(AuthPortal portal) {
    _preferences!.remove(_authTokenKey(portal));
    _preferences!.remove(_tenantIdKey(portal));
    saveIsLoggedInForPortal(portal, false);
    if (portal == AuthPortal.xac) {
      _preferences!.remove(AppConst.auth_token);
      _preferences!.remove(AppConst.tenantId);
      _saveToDisk(AppConst.is_logged_in, false);
    }
  }

  void logout() => logoutPortal(AuthPortal.xac);

  void logoutPortal(AuthPortal portal) {
    clearAuthTokenForPortal(portal);
    if (portal == AuthPortal.xac) {
      clearForgotPassword();
      _preferences!.remove(AppConst.current_UserProfile);
    }
    if (portal == AuthPortal.cms) {
      _preferences!.remove(AppConst.cms_currentLoginInformation);
      _preferences!.remove(AppConst.cms_currentLoginInformationRefreshedAt);
    }
    _preferences!.remove(_userProfileKey(portal));
  }

  void logoutAllPortals() {
    logoutPortal(AuthPortal.xac);
    logoutPortal(AuthPortal.cms);
    _preferences!.remove(AppConst.lastSessionPortal);
  }

  void clearForgotPassword() {
    _preferences!.remove(AppConst.is_OTP_Pin_Request);
  }

  CurrentLoginInformation? get getUserLoginInfo =>
      getUserLoginInfoForPortal(AuthPortal.xac);

  CurrentLoginInformation? getUserLoginInfoForPortal(AuthPortal portal) {
    var userLoginInfo = _getFromDisk(_userProfileKey(portal));
    if (userLoginInfo == null && portal == AuthPortal.xac) {
      userLoginInfo = _getFromDisk(AppConst.current_UserProfile);
      if (userLoginInfo != null) {
        _saveToDisk(_userProfileKey(portal), userLoginInfo);
      }
    }
    if (userLoginInfo == null) {
      return null;
    }
    return CurrentLoginInformation.fromJson(json.decode(userLoginInfo));
  }

  UserLoginInfo? get getUserInfo {
    var userLoginInfo = getUserLoginInfo;
    if (userLoginInfo == null) {
      return null;
    }
    return userLoginInfo.user;
  }

  void setUserLoginInfo(CurrentLoginInformation userLoginInfo) =>
      setUserLoginInfoForPortal(AuthPortal.xac, userLoginInfo);

  void setUserLoginInfoForPortal(
      AuthPortal portal, CurrentLoginInformation userLoginInfo) {
    final jsonUserLoginInfo = json.encode(userLoginInfo.toJson());
    _saveToDisk(_userProfileKey(portal), jsonUserLoginInfo);
    if (portal == AuthPortal.xac) {
      _saveToDisk(AppConst.current_UserProfile, jsonUserLoginInfo);
    }
  }

  bool get isLoggedIn => isLoggedInForPortal(AuthPortal.xac);

  bool isLoggedInForPortal(AuthPortal portal) {
    var loggedIn = _getFromDisk(_isLoggedInKey(portal));
    if (loggedIn == null && portal == AuthPortal.xac) {
      loggedIn = _getFromDisk(AppConst.is_logged_in);
      if (loggedIn != null) {
        _saveToDisk(_isLoggedInKey(portal), loggedIn);
      }
    }
    return loggedIn == true;
  }

  void saveIsLoggedIn(bool value) =>
      saveIsLoggedInForPortal(AuthPortal.xac, value);

  void saveIsLoggedInForPortal(AuthPortal portal, bool value) {
    _saveToDisk(_isLoggedInKey(portal), value);
    if (portal == AuthPortal.xac) {
      _saveToDisk(AppConst.is_logged_in, value);
    }
  }

  AuthPortal? getLastSessionPortal() {
    final value = _getFromDisk(AppConst.lastSessionPortal) as String?;
    return AuthPortalMetadata.fromStorageValue(value);
  }

  void setLastSessionPortal(AuthPortal portal) {
    _saveToDisk(AppConst.lastSessionPortal, portal.storagePrefix);
  }

  String getTenantCodeForPortal(AuthPortal portal) {
    final tenantCode = _getFromDisk(_tenantCodeKey(portal));
    if (tenantCode is String && tenantCode.isNotEmpty) {
      return tenantCode;
    }
    if (portal == AuthPortal.xac) {
      return getStringByKey(AppConst.tenantCode);
    }
    return '';
  }

  void setTenantCodeForPortal(AuthPortal portal, String value) {
    setStringByKey(_tenantCodeKey(portal), value);
    if (portal == AuthPortal.xac) {
      setStringByKey(AppConst.tenantCode, value);
    }
  }

  bool get hasDisclosedBackgroundPermission {
    return _getFromDisk(AppConst.has_disclosed_background_permission) ?? false;
  }

  int? getCmsDefaultInspectionDepotId() =>
      _getIntFromDisk(AppConst.cms_defaultInspectionDepotId);

  void setCmsDefaultInspectionDepotId(int value) =>
      _saveToDisk(AppConst.cms_defaultInspectionDepotId, value);

  void clearCmsDefaultInspectionDepotId() =>
      _preferences!.remove(AppConst.cms_defaultInspectionDepotId);

  void saveHasDisclosedBackgroundPermission(bool value) {
    _saveToDisk(AppConst.has_disclosed_background_permission, value);
  }

// //ForgotPassword
//   ForgotPassword? get getForgotPassword {
//     var getForgotPassword = _getFromDisk(AppConst.is_OTP_Pin_Request);
//     if (getForgotPassword == null) {
//       return null;
//     }
//     return ForgotPassword.fromJson(json.decode(getForgotPassword));
//   }

//   void setForgotPassword(ForgotPassword value) {
//     _saveToDisk(AppConst.is_OTP_Pin_Request, json.encode(value.toJson()));
//   }

//   void clearForgotPassword() {
//     _preferences!.remove(AppConst.is_OTP_Pin_Request);
//   }
  String getStringByKey(String key) {
    var data = _getFromDisk(key);
    if (data != null) {
      if (data is String) {
        return data;
      }
    }

    return '';
  }

  void setStringByKey(String key, String value) {
    if (value.isEmpty) {
      _preferences!.remove(key);
    } else {
      _saveToDisk(key, value);
    }
  }

  List<String> getRecentSearches() {
    List<String> outPut = [];
    var data = _getFromDisk(AppConst.recentSearches);
    if (data != null) {
      for (String item in data) {
        outPut.add(item);
      }
    }

    return outPut;
  }

  void clearRecentSearches() {
    _preferences!.remove(AppConst.recentSearches);
  }

  void saveToRecentSearches(String? searchText) {
    if (searchText != null) {
      searchText = searchText.trim();
    }

    if (searchText == null || searchText.isEmpty || searchText == " ") {
      return; //Should not be null
    }

    var listData = getRecentSearches();
    //Use `Set` to avoid duplication of recentSearches
    Set<String> allSearches = listData.toSet();

    //Place it at first in the set
    var allSearchesToSet = ({searchText, ...allSearches}).toList();
    if (allSearchesToSet.length >= 20) {
      allSearchesToSet.removeLast();
    }

    _saveToDisk(AppConst.recentSearches, allSearchesToSet);
  }
  // Theme:------------------------------------------------------
/*  Future<bool> get isDarkMode {
    return _sharedPreference.then((prefs) {
      return prefs.getBool(AppConst.is_dark_mode) ?? false;
    });
  }

  Future<void> changeBrightnessToDark(bool value) {
    return _sharedPreference.then((prefs) {
      return prefs.setBool(AppConst.is_dark_mode, value);
    });
  }*/

  // Language:---------------------------------------------------
// /*
//   Future<String> get currentLanguage {
//     return _sharedPreference.then((prefs) {
//       return prefs.getString(AppConst.current_language);
//     });
//   }
//
//   Future<void> changeLanguage(String language) {
//     return _sharedPreference.then((prefs) {
//       return prefs.setString(AppConst.current_language, language);
//     });
//   }
// */
  int? getNavTabIndex(String key) => _getFromDisk(key) ?? null;
  void setNavTabIndex(String key, int value) => _saveToDisk(key, value);
  void clearNavTabIndex(String key) => _preferences!.remove(key);

  // bool get darkMode => _getFromDisk(AppConst.DarkModeKey) ?? false;
  // set darkMode(bool value) => _saveToDisk(AppConst.DarkModeKey, value);

  // List<String> get languages => _getFromDisk(AppConst.AppLanguagesKey) ?? <String>[];
  // set languages(List<String> appLanguages) => _saveToDisk(AppConst.AppLanguagesKey, appLanguages);

  //General CRUD :---------------
// updated _saveToDisk function that handles all types

  int? _getIntFromDisk(String key) {
    var value = _preferences!.getInt(key);
    return value;
  }

  String _authTokenKey(AuthPortal portal) => portal == AuthPortal.cms
      ? AppConst.cms_auth_token
      : AppConst.xac_auth_token;

  String _isLoggedInKey(AuthPortal portal) => portal == AuthPortal.cms
      ? AppConst.cms_is_logged_in
      : AppConst.xac_is_logged_in;

  String _tenantIdKey(AuthPortal portal) =>
      portal == AuthPortal.cms ? AppConst.cms_tenantId : AppConst.xac_tenantId;

  String _userProfileKey(AuthPortal portal) => portal == AuthPortal.cms
      ? AppConst.cms_currentUserProfile
      : AppConst.xac_currentUserProfile;

  String _tenantCodeKey(AuthPortal portal) => portal == AuthPortal.cms
      ? AppConst.cms_tenantCode
      : AppConst.xac_tenantCode;

  dynamic _getFromDisk(String key) {
    var value = _preferences!.get(key);
    //log.v('getFromDisk. key: $key value: $value');
    return value;
  }

  void _saveToDisk<T>(String key, T content) {
    // log.v('saveToDisk. key: $key value: $content');

    if (content is String) {
      _preferences!.setString(key, content);
    }
    if (content is bool) {
      _preferences!.setBool(key, content);
    }
    if (content is int) {
      _preferences!.setInt(key, content);
    }
    if (content is double) {
      _preferences!.setDouble(key, content);
    }
    if (content is List<String>) {
      _preferences!.setStringList(key, content);
    }
  }

  void setForgotPassword(ForgotPassword forgotPasswordReponse) {
    _saveToDisk(AppConst.is_OTP_Pin_Request,
        json.encode(forgotPasswordReponse.toJson()));
  }
}
