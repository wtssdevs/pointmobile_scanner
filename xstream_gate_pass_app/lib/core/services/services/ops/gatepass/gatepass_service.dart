import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate-pass-access_model.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_model.dart';
import 'package:xstream_gate_pass_app/core/models/shared/api_response.dart';
import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';

@LazySingleton()
class GatePassService {
  final log = getLogger('GatePassService');
  final ApiManager _apiManager = locator<ApiManager>();

  Future<PagedList<GatePassAccess>> getPagedList(int pageNumber, int pageSize, String searchValue) async {
    try {
      List<GatePassAccess> items = <GatePassAccess>[];
      var outPut = PagedList<GatePassAccess>(totalCount: 0, items: items, pageNumber: pageNumber, pageSize: pageSize, totalPages: 0);

      final Map<String, dynamic> queryParameters = <String, dynamic>{};

      if (searchValue.isNotEmpty) {
        queryParameters['searchValue'] = searchValue;
      }

      if (pageSize > 0) {
        queryParameters['pageSize'] = pageSize;
      }
      if (pageNumber > 0) {
        queryParameters['pageNumber'] = pageNumber;
      }

      var baseResponse = await _apiManager.get(AppConst.GetAllGatePass, showLoader: false, queryParameters: queryParameters);
      if (baseResponse != null) {
//        var apiResponse = ApiResponse.fromJson(baseResponse);

        if (baseResponse != null && baseResponse["items"] != null && baseResponse["items"] is List) {
          for (final dynamic item in baseResponse["items"]) {
            if (item != null) {
              items.add(GatePassAccess.fromJson(item));
            }
          }
        }
        outPut = PagedList<GatePassAccess>.fromJsonWithItems(baseResponse, items);

        return outPut;
      }
      return outPut;
    } catch (e) {
      log.e(e.toString());
      rethrow;
    }
  }

  Future<GatePass?> create(GatePass costMobileEdit) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.CreateGatePass, showLoader: true, data: costMobileEdit.toJson());
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);
        if (apiResponse.success != null) {
          return GatePass.fromJson(apiResponse.result);
        }

        return null;
      }
      return null;
    } catch (e) {
      log.e(e.toString());
      return null;
    }
  }

  Future<GatePass?> authorizeForEntry(GatePass entity) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.AuthorizeForEntryGatePass, showLoader: true, data: entity.toJson());
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);
        if (apiResponse.success != null) {
          return GatePass.fromJson(apiResponse.result);
        }

        return null;
      }
      return null;
    } catch (e) {
      log.e(e.toString());
      return null;
    }
  }

  Future<GatePass?> authorizeExit(GatePass entity) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.AuthorizeForExitGatePass, showLoader: true, data: entity.toJson());
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);
        if (apiResponse.success != null) {
          return GatePass.fromJson(apiResponse.result);
        }

        return null;
      }
      return null;
    } catch (e) {
      log.e(e.toString());
      return null;
    }
  }

  Future<GatePass?> update(GatePass entity) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.UpdateGatePass, showLoader: true, data: entity.toJson());
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);
        if (apiResponse.success != null) {
          return GatePass.fromJson(apiResponse.result);
        }

        return null;
      }
      return null;
    } catch (e) {
      log.e(e.toString());
      return null;
    }
  }

  Future<GatePass?> rejectForEntry(GatePass entity) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.RejectEntryGatePass, showLoader: true, data: entity.toJson());
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);
        if (apiResponse.success != null) {
          return GatePass.fromJson(apiResponse.result);
        }

        return null;
      }
      return null;
    } catch (e) {
      log.e(e.toString());
      return null;
    }
  }
}
