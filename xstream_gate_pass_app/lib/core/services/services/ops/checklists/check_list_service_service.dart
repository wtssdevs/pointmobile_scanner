import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/models/ops/checklists/check_list_find_template_model.dart';
import 'package:xstream_gate_pass_app/core/models/ops/checklists/check_list_model.dart';
import 'package:xstream_gate_pass_app/core/models/ops/checklists/check_list_response_model.dart';
import 'package:xstream_gate_pass_app/core/models/shared/api_response.dart';
import 'package:xstream_gate_pass_app/core/models/shared/filter_params_model.dart';
import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';

@LazySingleton()
class CheckListServiceService {
  final log = getLogger('CheckListServiceService');
  final ApiManager _apiManager = locator<ApiManager>();

  Future<CheckList?> getEmptyChecklistForGatePass(FilterParams entity) async {
    var baseResponse = await _apiManager.post(AppConst.getEmptyChecklistForGatePass, showLoader: true, data: entity.toJson());
    if (baseResponse != null) {
      var apiResponse = ApiResponse.fromJson(baseResponse);
      if (apiResponse.success != null) {
        return CheckList.fromJson(apiResponse.result);
      }
    }
    return null;
  }

//
  Future<CheckList?> submitResponses(CheckListResponseModel entity) async {
    var baseResponse = await _apiManager.post(AppConst.submitResponses, showLoader: true, data: entity.toJson());
    if (baseResponse != null) {
      var apiResponse = ApiResponse.fromJson(baseResponse);
      if (apiResponse.success != null) {
        return CheckList.fromJson(apiResponse.result);
      }
    }
    return null;
  }

  Future<CheckListFindTemplateModel> findChecklistTemplate(FilterParams entity) async {
    var baseResponse = await _apiManager.post(AppConst.findChecklistTemplate, showLoader: true, data: entity.toJson());
    if (baseResponse != null) {
      var apiResponse = ApiResponse.fromJson(baseResponse);
      if (apiResponse.success != null) {
        return CheckListFindTemplateModel.fromJson(apiResponse.result);
      }
    }
    return CheckListFindTemplateModel(hasTemplate: false, templateId: null);
  }
}
