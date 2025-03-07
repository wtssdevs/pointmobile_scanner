import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate-pass-access_model.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_access_staff_model.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_access_visitor_model.dart';
import 'package:xstream_gate_pass_app/core/models/scanning/loadcon_qrcode_model.dart';
import 'package:xstream_gate_pass_app/core/models/scanning/staff_qrcode_model.dart';
import 'package:xstream_gate_pass_app/core/models/shared/api_response.dart';
import 'package:xstream_gate_pass_app/core/models/shared/filter_params_model.dart';
import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';

@LazySingleton()
class GatePassService {
  final log = getLogger('GatePassService');
  final ApiManager _apiManager = locator<ApiManager>();

  Future<PagedList<GatePassVisitorAccess>> getVisitorPagedList(int pageNumber, int pageSize, String searchValue, int branchId) async {
    try {
      List<GatePassVisitorAccess> items = <GatePassVisitorAccess>[];
      var outPut = PagedList<GatePassVisitorAccess>(totalCount: 0, items: items, pageNumber: pageNumber, pageSize: pageSize, totalPages: 0);

      final Map<String, dynamic> queryParameters = <String, dynamic>{};

      if (searchValue.isNotEmpty) {
        queryParameters['searchValue'] = searchValue;
      }

      queryParameters['branchId'] = branchId;
      if (pageSize > 0) {
        queryParameters['pageSize'] = pageSize;
      }
      if (pageNumber > 0) {
        queryParameters['pageNumber'] = pageNumber;
      }

      var baseResponse = await _apiManager.get(AppConst.GetAllVisitorPaged, showLoader: false, queryParameters: queryParameters);
      if (baseResponse != null) {
//        var apiResponse = ApiResponse.fromJson(baseResponse);

        if (baseResponse != null && baseResponse["items"] != null && baseResponse["items"] is List) {
          for (final dynamic item in baseResponse["items"]) {
            if (item != null) {
              //var newItem = GatePassStaffAccess.fromJson(item);
              items.add(GatePassVisitorAccess.fromJson(item));
            }
          }
        }
        outPut = PagedList<GatePassVisitorAccess>.fromJsonWithItems(baseResponse, items);

        return outPut;
      }
      return outPut;
    } catch (e) {
      log.e(e.toString());
      rethrow;
    }
  }

  Future<PagedList<GatePassStaffAccess>> getStaffPagedList(int pageNumber, int pageSize, String searchValue, int branchId) async {
    try {
      List<GatePassStaffAccess> items = <GatePassStaffAccess>[];
      var outPut = PagedList<GatePassStaffAccess>(totalCount: 0, items: items, pageNumber: pageNumber, pageSize: pageSize, totalPages: 0);

      final Map<String, dynamic> queryParameters = <String, dynamic>{};

      if (searchValue.isNotEmpty) {
        queryParameters['searchValue'] = searchValue;
      }

      queryParameters['branchId'] = branchId;
      if (pageSize > 0) {
        queryParameters['pageSize'] = pageSize;
      }
      if (pageNumber > 0) {
        queryParameters['pageNumber'] = pageNumber;
      }

      var baseResponse = await _apiManager.get(AppConst.GetAllStaffPaged, showLoader: false, queryParameters: queryParameters);
      if (baseResponse != null) {
//        var apiResponse = ApiResponse.fromJson(baseResponse);

        if (baseResponse != null && baseResponse["items"] != null && baseResponse["items"] is List) {
          for (final dynamic item in baseResponse["items"]) {
            if (item != null) {
              //var newItem = GatePassStaffAccess.fromJson(item);
              items.add(GatePassStaffAccess.fromJson(item));
            }
          }
        }
        outPut = PagedList<GatePassStaffAccess>.fromJsonWithItems(baseResponse, items);

        return outPut;
      }
      return outPut;
    } catch (e) {
      log.e(e.toString());
      rethrow;
    }
  }

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

  Future<PagedList<GatePassAccess>> getPagedFilteredList(FilterParams filterParams) async {
    try {
      List<GatePassAccess> items = <GatePassAccess>[];
      var outPut = PagedList<GatePassAccess>(totalCount: 0, items: items, pageNumber: filterParams.pageNumber, pageSize: filterParams.pageSize, totalPages: 0);

      final Map<String, dynamic> queryParameters = <String, dynamic>{};

      bool isFilterApplied = false;

      if (filterParams.voyageNo != null && filterParams.voyageNo!.isNotEmpty) {
        queryParameters['voyageNo'] = filterParams.voyageNo;
        isFilterApplied = true;
      }

      if (filterParams.vehicleRegNumber != null && filterParams.vehicleRegNumber!.isNotEmpty) {
        queryParameters['vehicleRegNumber'] = filterParams.vehicleRegNumber;
        isFilterApplied = true;
      }

      if (filterParams.containerNumber != null && filterParams.containerNumber!.isNotEmpty) {
        queryParameters['containerNumber'] = filterParams.containerNumber;
        isFilterApplied = true;
      }

      if (filterParams.transactionNo != null && filterParams.transactionNo!.isNotEmpty) {
        queryParameters['transactionNo'] = filterParams.transactionNo;
        isFilterApplied = true;
      }

      if (filterParams.pageSize > 0) {
        queryParameters['pageSize'] = filterParams.pageSize;
      }
      if (filterParams.pageNumber > 0) {
        queryParameters['pageNumber'] = filterParams.pageNumber;
      }

      var baseResponse = await _apiManager.get(AppConst.GetAllGatePass, showLoader: false, queryParameters: queryParameters);
      if (baseResponse != null) {
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

  Future<GatePassVisitorAccess?> findPreBookedVisitor(GatePassVisitorAccess entity) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.findPreBookedVisitor, showLoader: true, data: entity.toJson());
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);
        if (apiResponse.success != null) {
          return GatePassVisitorAccess.fromJson(apiResponse.result);
        }
      }
      return null;
    } catch (e) {
      log.e(e.toString());
    }

    return null;
  }

  Future<GatePassAccess?> findPreBookedLoad(LoadconQrCodeModel entity) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.findPreBookedLoad, showLoader: true, data: entity.toJson());
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);
        if (apiResponse.success != null) {
          return GatePassAccess.fromJson(apiResponse.result);
        }
      }
      return null;
    } catch (e) {
      log.e(e.toString());
    }

    return null;
  }

  Future<bool> scanVisitorOut(GatePassVisitorAccess entity) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.scanVisitorOut, showLoader: true, data: entity.toJson());
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);
        if (apiResponse.success != null) {
          return apiResponse.success!;
        }
      }
      return false;
    } catch (e) {
      log.e(e.toString());
    }

    return false;
  }

  Future<bool> scanVisitorIn(GatePassVisitorAccess entity) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.scanVisitorIn, showLoader: true, data: entity.toJson());
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);
        if (apiResponse.success != null) {
          return apiResponse.success!;
        }
      }
      return false;
    } catch (e) {
      log.e(e.toString());
    }

    return false;
  }

  //*******************STAFF ***************

  Future<GatePassStaffAccess?> scanStaffIn(StaffQrCodeModel entity) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.scanStaffIn, showLoader: true, data: entity.toJson());
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);
        if (apiResponse.success != null) {
          return GatePassStaffAccess.fromJson(apiResponse.result);
        }
      }
    } catch (e) {
      log.e(e.toString());
    }

    return null;
  }

  Future<GatePassStaffAccess?> scanStaffOut(StaffQrCodeModel entity) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.scanStaffOut, showLoader: true, data: entity.toJson());
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);
        if (apiResponse.success != null) {
          return GatePassStaffAccess.fromJson(apiResponse.result);
        }
      }
    } catch (e) {
      log.e(e.toString());
    }

    return null;
  }

  Future<GatePassAccess?> create(GatePassAccess costMobileEdit) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.scanStaffOut, showLoader: true, data: costMobileEdit.toJson());
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);
        if (apiResponse.success != null) {
          return GatePassAccess.fromJson(apiResponse.result);
        }

        return null;
      }
      return null;
    } catch (e) {
      log.e(e.toString());
      return null;
    }
  }

  Future<GatePassAccess?> authorizeForEntry(GatePassAccess entity) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.AuthorizeForEntryGatePass, showLoader: true, data: entity.toJson());
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);
        if (apiResponse.success != null) {
          return GatePassAccess.fromJson(apiResponse.result);
        }

        return null;
      }
      return null;
    } catch (e) {
      log.e(e.toString());
      return null;
    }
  }

  Future<GatePassAccess?> authorizeExit(GatePassAccess entity) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.AuthorizeForExitGatePass, showLoader: true, data: entity.toJson());
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);
        if (apiResponse.success != null) {
          return GatePassAccess.fromJson(apiResponse.result);
        }

        return null;
      }
      return null;
    } catch (e) {
      log.e(e.toString());
      return null;
    }
  }

  Future<GatePassAccess?> update(GatePassAccess entity) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.UpdateGatePass, showLoader: true, data: entity.toJson());
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);
        if (apiResponse.success != null) {
          return GatePassAccess.fromJson(apiResponse.result);
        }

        return null;
      }
      return null;
    } catch (e) {
      log.e(e.toString());
      return null;
    }
  }

  Future<GatePassAccess?> rejectForEntry(GatePassAccess entity) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.RejectEntryGatePass, showLoader: true, data: entity.toJson());
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);
        if (apiResponse.success != null) {
          return GatePassAccess.fromJson(apiResponse.result);
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
