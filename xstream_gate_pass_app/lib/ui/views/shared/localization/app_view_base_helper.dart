import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/models/account/GetCurrentLoginInformation.dart';
import 'package:xstream_gate_pass_app/core/models/account/UserLoginInfo.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/localization/localization_manager_service.dart';

mixin AppViewBaseHelper {
  final _localisationService = locator<LocalizationManagerService>();
 int _selectBranchId = 0;
 int get selectBranchId => _selectBranchId;
 set selectBranchId(int value) {
    _selectBranchId = value;
  }
  CurrentLoginInformation? get currentLoginInformation =>
      locator<LocalStorageService>().getUserLoginInfo;
  UserLoginInfo? get currentUser => currentLoginInformation?.user;

  String translate(String key) {
    return _localisationService.localize(key);
  }

  bool hasPermission(String key) {
    return _localisationService.hasPermission(key);
  }
  // String translate(String key, {List<dynamic> replacements}) {
  //   var stringFromFile = _localisationService[key];
  //   if (replacements != null) {
  //     for (int i = 0; i < replacements.length; i++) {
  //       stringFromFile = stringFromFile.replaceAll('{$i}', replacements[i].toString());
  //     }
  //   }

  //   return stringFromFile;
  // }
}
