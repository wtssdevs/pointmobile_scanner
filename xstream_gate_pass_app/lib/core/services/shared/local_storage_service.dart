import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';

@Presolve()
class LocalStorageService {
  //final log = getLogger('LocalStorageService');
  static LocalStorageService? _instance;
  static SharedPreferences? _preferences;

  static Future<LocalStorageService?> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageService();
    }

    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }

    return _instance;
  }

  // AuthenticateResultModel? get getAuthToken {
  //   var authToken = _getFromDisk(AppConst.auth_token);
  //   if (authToken == null) {
  //     return null;
  //   }

  //   return AuthenticateResultModel.fromJson(json.decode(authToken));
  // }

  // void setAuthToken(AuthenticateResultModel authToken) {
  //   // log.v('(TRACE) LocalStorageService: setAuthToken ' + authToken.toString());
  //   _saveToDisk(AppConst.auth_token, json.encode(authToken.toJson()));
  //   saveIsLoggedIn(true);
  // }

  // void clearAuthToken() {
  //   _preferences!.remove(AppConst.auth_token);
  //   saveIsLoggedIn(false);
  // }

  // void logout() {
  //   clearAuthToken();
  //   clearForgotPassword();
  //   _preferences!.remove(AppConst.current_UserProfile);
  // }

  // CurrentLoginInformation? get getUserLoginInfo {
  //   var userLoginInfo = _getFromDisk(AppConst.current_UserProfile);
  //   if (userLoginInfo == null) {
  //     return null;
  //   }
  //   return CurrentLoginInformation.fromJson(json.decode(userLoginInfo));
  // }

  // UserLoginInfo? get getUserInfo {
  //   var userLoginInfo = getUserLoginInfo;
  //   if (userLoginInfo == null) {
  //     return null;
  //   }
  //   return userLoginInfo.user;
  // }

  // void setUserLoginInfo(CurrentLoginInformation userLoginInfo) {
  //   _saveToDisk(AppConst.current_UserProfile, json.encode(userLoginInfo.toJson()));
  // }

  bool get isLoggedIn {
    return _getFromDisk(AppConst.is_logged_in) ?? false;
  }

  void saveIsLoggedIn(bool value) {
    _saveToDisk(AppConst.is_logged_in, value);
  }

  bool get hasDisclosedBackgroundPermission {
    return _getFromDisk(AppConst.has_disclosed_background_permission) ?? false;
  }

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

    if (searchText == null || searchText.isEmpty || searchText == " ") return; //Should not be null

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
}
