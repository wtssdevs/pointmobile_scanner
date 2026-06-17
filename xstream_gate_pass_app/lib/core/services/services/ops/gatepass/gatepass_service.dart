import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.dialogs.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/basic_dialog_status.dart';
import 'package:xstream_gate_pass_app/core/models/ops/gatepass/gate-pass-access_model.dart';
import 'package:xstream_gate_pass_app/core/models/ops/gatepass/gate_pass_access_staff_model.dart';
import 'package:xstream_gate_pass_app/core/models/ops/gatepass/gate_pass_access_visitor_model.dart';
import 'package:xstream_gate_pass_app/core/models/scanning/loadcon_qrcode_model.dart';
import 'package:xstream_gate_pass_app/core/models/scanning/staff_qrcode_model.dart';
import 'package:xstream_gate_pass_app/core/models/scanning/stockpile_loading_slip_qrcode_model.dart';
import 'package:xstream_gate_pass_app/core/models/shared/api_response.dart';
import 'package:xstream_gate_pass_app/core/models/shared/base_lookup.dart';
import 'package:xstream_gate_pass_app/core/models/shared/filter_params_model.dart';
import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

@LazySingleton()
class GatePassService {
  final log = getLogger('GatePassService');
  final ApiManager _apiManager = locator<ApiManager>();
  final _dialogService = locator<DialogService>();
  String? lastErrorMessage;
  String _buildLoadOptions(int pageNumber, int pageSize) {
    final skip = (pageNumber > 0 ? pageNumber - 1 : 0) * pageSize;
    final take = pageSize > 0 ? pageSize : 10;
    return jsonEncode({
      'skip': skip,
      'take': take,
      'requireTotalCount': true,
    });
  }
  Future<PagedList<GatePassVisitorAccess>> getVisitorPagedList(
      int pageNumber, int pageSize, String searchValue, int branchId) async {
    try {
      List<GatePassVisitorAccess> items = <GatePassVisitorAccess>[];
      var outPut = PagedList<GatePassVisitorAccess>(
          totalCount: 0,
          items: items,
          pageNumber: pageNumber,
          pageSize: pageSize,
          totalPages: 0);

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

      var baseResponse = await _apiManager.get(AppConst.GetAllVisitorPaged,
          showLoader: false, queryParameters: queryParameters);
      if (baseResponse != null) {
//        var apiResponse = ApiResponse.fromJson(baseResponse);

        if (baseResponse != null &&
            baseResponse["items"] != null &&
            baseResponse["items"] is List) {
          for (final dynamic item in baseResponse["items"]) {
            if (item != null) {
              //var newItem = GatePassStaffAccess.fromJson(item);
              items.add(GatePassVisitorAccess.fromJson(item));
            }
          }
        }
        outPut = PagedList<GatePassVisitorAccess>.fromJsonWithItems(
            baseResponse, items);

        return outPut;
      }
      return outPut;
    } catch (e) {
      log.e(e.toString());
      rethrow;
    }
  }

  Future<PagedList<GatePassStaffAccess>> getStaffPagedList(
      int pageNumber, int pageSize, String searchValue, int branchId) async {
    try {
      List<GatePassStaffAccess> items = <GatePassStaffAccess>[];
      var outPut = PagedList<GatePassStaffAccess>(
          totalCount: 0,
          items: items,
          pageNumber: pageNumber,
          pageSize: pageSize,
          totalPages: 0);

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

      var baseResponse = await _apiManager.get(AppConst.GetAllStaffPaged,
          showLoader: false, queryParameters: queryParameters);
      if (baseResponse != null) {
//        var apiResponse = ApiResponse.fromJson(baseResponse);

        if (baseResponse != null &&
            baseResponse["items"] != null &&
            baseResponse["items"] is List) {
          for (final dynamic item in baseResponse["items"]) {
            if (item != null) {
              //var newItem = GatePassStaffAccess.fromJson(item);
              items.add(GatePassStaffAccess.fromJson(item));
            }
          }
        }
        outPut = PagedList<GatePassStaffAccess>.fromJsonWithItems(
            baseResponse, items);

        return outPut;
      }
      return outPut;
    } catch (e) {
      log.e(e.toString());
      rethrow;
    }
  }

  Future<PagedList<GatePassAccess>> getPagedList(
      int pageNumber, int pageSize, String searchValue) async {
    try {
      List<GatePassAccess> items = <GatePassAccess>[];
      var outPut = PagedList<GatePassAccess>(
          totalCount: 0,
          items: items,
          pageNumber: pageNumber,
          pageSize: pageSize,
          totalPages: 0);

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

      var baseResponse = await _apiManager.get(AppConst.GetAllGatePass,
          showLoader: false, queryParameters: queryParameters);
      if (baseResponse != null) {
//        var apiResponse = ApiResponse.fromJson(baseResponse);

        if (baseResponse != null &&
            baseResponse["items"] != null &&
            baseResponse["items"] is List) {
          for (final dynamic item in baseResponse["items"]) {
            if (item != null) {
              items.add(GatePassAccess.fromJson(item));
            }
          }
        }
        outPut =
            PagedList<GatePassAccess>.fromJsonWithItems(baseResponse, items);

        return outPut;
      }
      return outPut;
    } catch (e) {
      log.e(e.toString());
      rethrow;
    }
  }

  Future<PagedList<GatePassAccess>> getPagedFilteredList(
      FilterParams filterParams) async {
    try {
      List<GatePassAccess> items = <GatePassAccess>[];
      var outPut = PagedList<GatePassAccess>(
          totalCount: 0,
          items: items,
          pageNumber: filterParams.pageNumber,
          pageSize: filterParams.pageSize,
          totalPages: 0);

      final Map<String, dynamic> queryParameters = <String, dynamic>{};

      bool isFilterApplied = false;

      if (filterParams.voyageNo != null && filterParams.voyageNo!.isNotEmpty) {
        queryParameters['voyageNo'] = filterParams.voyageNo;
        isFilterApplied = true;
      }

      if (filterParams.vehicleRegNumber != null &&
          filterParams.vehicleRegNumber!.isNotEmpty) {
        queryParameters['vehicleRegNumber'] = filterParams.vehicleRegNumber;
        isFilterApplied = true;
      }

      if (filterParams.containerNumber != null &&
          filterParams.containerNumber!.isNotEmpty) {
        queryParameters['containerNumber'] = filterParams.containerNumber;
        isFilterApplied = true;
      }

      if (filterParams.transactionNo != null &&
          filterParams.transactionNo!.isNotEmpty) {
        queryParameters['transactionNo'] = filterParams.transactionNo;
        isFilterApplied = true;
      }
      if ((filterParams.branchId ?? 0) > 0) {
        queryParameters['branchId'] = filterParams.branchId;
        isFilterApplied = true;
      }
      if (filterParams.pageSize > 0) {
        queryParameters['pageSize'] = filterParams.pageSize;
      }
      if (filterParams.pageNumber > 0) {
        queryParameters['pageNumber'] = filterParams.pageNumber;
      }

      var baseResponse = await _apiManager.get(AppConst.GetAllGatePass,
          showLoader: false, queryParameters: queryParameters);
      if (baseResponse != null) {
        if (baseResponse != null &&
            baseResponse["items"] != null &&
            baseResponse["items"] is List) {
          for (final dynamic item in baseResponse["items"]) {
            if (item != null) {
              items.add(GatePassAccess.fromJson(item));
            }
          }
        }
        outPut =
            PagedList<GatePassAccess>.fromJsonWithItems(baseResponse, items);

        return outPut;
      }
      return outPut;
    } catch (e) {
      log.e(e.toString());
      rethrow;
    }
  }

  Future<GatePassVisitorAccess?> findPreBookedVisitor(
      GatePassVisitorAccess entity) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.findPreBookedVisitor,
          showLoader: true, data: entity.toJson());
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

//findGatePassByVoyageNo
  Future<GatePassAccess?> findPreBookedLoadByVoyageNo(
      FilterParams entity) async {
    try {
      var baseResponse = await _apiManager.post(
          AppConst.findPreBookedLoadByVoyageNo,
          showLoader: true,
          data: entity.toJson());
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

  Future<GatePassAccess?> findPreBookedLoad(LoadconQrCodeModel entity) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.findPreBookedLoad,
          showLoader: true, data: entity.toJson());
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
      var baseResponse = await _apiManager.post(AppConst.scanVisitorOut,
          showLoader: true, data: entity.toJson());
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
      var baseResponse = await _apiManager.post(AppConst.scanVisitorIn,
          showLoader: true, data: entity.toJson());
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
      var baseResponse = await _apiManager.post(AppConst.scanStaffIn,
          showLoader: true, data: entity.toJson());
      if (baseResponse != null) {
        var apiResponse = BaseResponse.fromJson(baseResponse);
        if (apiResponse.success != null && apiResponse.success == true) {
          return GatePassStaffAccess.fromJson(apiResponse.result);
        } else {
          await _dialogService.showCustomDialog(
            variant: DialogType.infoAlert,
            title: apiResponse.title,
            description: apiResponse.message,
            data: BasicDialogStatus.error,
            mainButtonTitle: "Ok",
          );

          return null;
        }
      }
    } catch (e) {
      log.e(e.toString());
    }

    return null;
  }

  Future<GatePassStaffAccess?> scanStaffOut(StaffQrCodeModel entity) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.scanStaffOut,
          showLoader: true, data: entity.toJson());
      if (baseResponse != null) {
        var apiResponse = BaseResponse.fromJson(baseResponse);
        if (apiResponse.success != null && apiResponse.success == true) {
          return GatePassStaffAccess.fromJson(apiResponse.result);
        }

        await _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          title: apiResponse.title,
          description: apiResponse.message,
          data: BasicDialogStatus.error,
          mainButtonTitle: "Ok",
        );

        return null;
      }
    } catch (e) {
      log.e(e.toString());
    }

    return null;
  }

  Future<GatePassAccess?> create(GatePassAccess costMobileEdit) async {
    try {
      var baseResponse = await _apiManager.post(AppConst.scanStaffOut,
          showLoader: true, data: costMobileEdit.toJson());
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

  Future<GatePassAccess?> createGatePass(GatePassAccess gatePassAccess) async {
    var jsonData = gatePassAccess.toJson();
    var baseResponse = await _apiManager.post(
        '/api/services/app/GatePassAccess/Create',
        showLoader: true,
        data: jsonData);

    if (baseResponse == null) return null;

    if (baseResponse is Map<String, dynamic>) {
      if (baseResponse.containsKey('result') &&
          baseResponse['result'] != null) {
        return GatePassAccess.fromJson(baseResponse['result']);
      } else if (baseResponse.containsKey('id')) {
        return GatePassAccess.fromJson(baseResponse);
      }
    }

    return null;
  }

  Future<bool> setCmsGatePassEvent(
      StockpileLoadingSlipQrCodeModel entity) async {
    var baseResponse = await _apiManager.post(AppConst.setCmsGatePassEvent,
        showLoader: true, data: entity.toJson());
    if (baseResponse != null) {
      var apiResponse = ApiResponse.fromJson(baseResponse);
      if (apiResponse.success != null) {
        return apiResponse.success!;
      }

      return false;
    }
    return false;
  }

  Future<GatePassAccess?> authorizeForEntry(GatePassAccess entity) async {
    try {
      var baseResponse = await _apiManager.post(
          AppConst.AuthorizeForEntryGatePass,
          showLoader: true,
          data: entity.toJson());
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
    lastErrorMessage = null;
    try {
      var baseResponse = await _apiManager.post(
          AppConst.AuthorizeForExitGatePass,
          showLoader: true,
          data: entity.toJson());
      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);
        if (apiResponse.success == true && apiResponse.result != null) {
          return GatePassAccess.fromJson(apiResponse.result);
        }

        lastErrorMessage = apiResponse.error?.details?.trim().isNotEmpty == true
            ? apiResponse.error?.details?.trim()
            : apiResponse.error?.message?.trim().isNotEmpty == true
                ? apiResponse.error?.message?.trim()
                : apiResponse.message?.trim();
        return null;
      }
      lastErrorMessage = "No response received from server.";
      return null;
    } catch (e) {
      if (e is DioException) {
        final payload = e.response?.data;
        if (payload is Map<String, dynamic>) {
          final apiError = ApiResponse.fromJson(payload);
          lastErrorMessage = apiError.error?.details?.trim().isNotEmpty == true
              ? apiError.error?.details?.trim()
              : apiError.error?.message?.trim().isNotEmpty == true
                  ? apiError.error?.message?.trim()
                  : apiError.message?.trim();
        } else if (payload is String && payload.trim().isNotEmpty) {
          lastErrorMessage = payload;
        }
      }
      lastErrorMessage ??= e.toString();
      log.e(e.toString());
      return null;
    }
  }

Future<GatePassAccess?> update(GatePassAccess entity) async {
  try {
    log.i('Attempting to update gatepass: ${entity.id}');

    final dto = entity.toJson();
    log.i('Sending update data: $dto');

    final baseResponse = await _apiManager.put(
      AppConst.UpdateGatePass,    
      showLoader: true,
      data: dto,
    );

    if (baseResponse == null) {
      return null;
    }

    log.i('Update response received: $baseResponse');

    final apiResponse = ApiResponse.fromJson(baseResponse);

    if (apiResponse.success == true && apiResponse.result != null) {
      return GatePassAccess.fromJson(apiResponse.result);
    }

    if (apiResponse.error != null) {
      log.e('Update failed with error: ${apiResponse.error}');
    }

    return null;
  } catch (e) {
    log.e('Update exception: $e');
    return null;
  }
}


  Future<GatePassAccess?> rejectForEntry(GatePassAccess entity) async {
    try {
      var baseResponse = await _apiManager.post(
        AppConst.RejectEntryGatePass,
        showLoader: true,
        data: entity.toJson(),
      );

      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);

        if (apiResponse.success == true && apiResponse.result != null) {
          return GatePassAccess.fromJson(apiResponse.result);
        }

        // Handle UserFriendlyException
        if (apiResponse.error != null) {
          final message = apiResponse.result!['details'] ??
              apiResponse.result!['message'] ??
              "Reject failed.";

          await locator<DialogService>().showCustomDialog(
            variant: DialogType.infoAlert,
            data: BasicDialogStatus.error,
            title: "Rejection Failed",
            description: message,
            mainButtonTitle: "Ok",
          );
        }
      }

      return null;
    } catch (e) {
      log.e(e.toString());
      return null;
    }
  }

  Future<GatePassAccess?> saveManualInput({
    required String gatePassId,
    required String registrationNumber,
    required bool isVehicle,
    int? trailerNumber,
    required String photoBase64,
    String? photoFileName,
  }) async {
    try {
      final payload = {
        'gatePassId': gatePassId,
        'registrationNumber':
            registrationNumber.replaceAll(' ', '').toUpperCase(),
        'isVehicle': isVehicle,
        if (trailerNumber != null) 'trailerNumber': trailerNumber,
        'photoBase64': photoBase64,
        if (photoFileName != null) 'photoFileName': photoFileName,
      };

      var baseResponse = await _apiManager.post(
        '/api/services/app/MobileGatePassAccess/SaveManualInput',
        showLoader: true,
        data: payload,
      );

      if (baseResponse != null) {
        var apiResponse = ApiResponse.fromJson(baseResponse);
        if (apiResponse.success == true && apiResponse.result != null) {
          return GatePassAccess.fromJson(apiResponse.result);
        }
      }
      return null;
    } catch (e) {
      log.e('Error saving manual input: $e');
      return null;
    }
  }

  Future<List<GatePassAccess>> getManualEntries({int? branchId}) async {
    var response = await _apiManager.get(
      '/api/services/app/MobileGatePassAccess/GetManualEntries',
      showLoader: true,
      queryParameters: {
        'PageNumber': 1,
        'PageSize': 100,
        'BranchId': branchId ?? 0,
      },
    );

    if (response != null) {
      var items = response['items'] as List? ?? [];
      return items.map((item) => GatePassAccess.fromJson(item)).toList();
    }
    return [];
  }

  Future<List<BaseLookup>> getTransporters({
    String? searchValue,
    int pageNumber = 1,
    int pageSize = 10,
    int? branchId,
  }) async {
    var baseResponse = await _apiManager.get(
      '/api/services/app/Transporter/GetTransportersForLookup',
      showLoader: false,
      queryParameters: {
        'PageNumber': pageNumber,
        'PageSize': pageSize,
        if ((branchId ?? 0) > 0) 'BranchId': branchId,
        if (searchValue != null && searchValue.isNotEmpty)
          'SearchValue': searchValue,
      },
    );

    if (baseResponse == null) return [];

    List<dynamic> data = [];

    if (baseResponse is Map && baseResponse.containsKey('items')) {
      data = baseResponse['items'] as List? ?? [];
    } else if (baseResponse is Map && baseResponse.containsKey('result')) {
      var result = baseResponse['result'];
      data = result is Map && result.containsKey('items')
          ? result['items'] as List? ?? []
          : result is List
              ? result
              : [];
    } else if (baseResponse is Map && baseResponse.containsKey('data')) {
      data = baseResponse['data'] as List? ?? [];
    } else if (baseResponse is List) {
      data = baseResponse;
    }

    return _parseLookupResponse(data);
  }

  Future<List<BaseLookup>> getShippingLines({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    var baseResponse = await _apiManager.get(
      '/api/services/app/Shippingline/GetLookup',
      showLoader: false,
      queryParameters: {
        'loadOptions': _buildLoadOptions(pageNumber, pageSize),
      },
    );

    return _parseLookupResponse(baseResponse, includeCodeAndDisplayName: true);
  }

  Future<List<BaseLookup>> getCustomers({
    int pageNumber = 1,
    int pageSize = 10,
    int? branchId,
  }) async {
    var baseResponse = await _apiManager.get(
      '/api/services/app/Customer/GetLookup',
      showLoader: false,
      queryParameters: {
        'loadOptions': _buildLoadOptions(pageNumber, pageSize),
        if ((branchId ?? 0) > 0) 'branchId': branchId,
      },
    );

    return _parseLookupResponse(baseResponse);
  }

  Future<List<BaseLookup>> getContainerCustomers({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    return await getCustomers(pageNumber: pageNumber, pageSize: pageSize);
  }

  Future<List<BaseLookup>> getContainerDepots({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    var baseResponse = await _apiManager.get(
      '/api/services/app/Depot/GetAll',
      showLoader: false,
      queryParameters: {
        'loadOptions': _buildLoadOptions(pageNumber, pageSize),
      },
    );

    if (baseResponse == null) return [];

    List<dynamic> data = [];

    if (baseResponse is Map && baseResponse.containsKey('result')) {
      var result = baseResponse['result'];
      data = result is Map && result.containsKey('items')
          ? result['items'] as List? ?? []
          : result is List
              ? result
              : [];
    } else if (baseResponse is Map && baseResponse.containsKey('data')) {
      data = baseResponse['data'] as List? ?? [];
    } else if (baseResponse is List) {
      data = baseResponse;
    }

    return _parseBaseLookupList(data, includeCodeAndDisplayName: true);
  }

  Future<GatePassAccess?> getGatePassWithContainers(String gatePassId) async {
    try {
      var baseResponse = await _apiManager.get(
        '/api/services/app/GatePassAccess/GetForEditById',
        showLoader: false,
        queryParameters: {'id': gatePassId},
      );

      if (baseResponse == null) return null;

      if (baseResponse is Map<String, dynamic>) {
        if (baseResponse.containsKey('result') &&
            baseResponse['result'] != null) {
          return GatePassAccess.fromJson(baseResponse['result']);
        } else if (baseResponse.containsKey('id')) {
          return GatePassAccess.fromJson(baseResponse);
        }
      }

      return null;
    } catch (e, stackTrace) {
      log.e('Error getting gate pass: $e');
      log.e('Stack trace: $stackTrace');
      return null;
    }
  }

  List<BaseLookup> _parseLookupResponse(dynamic baseResponse,
      {bool includeCodeAndDisplayName = false}) {
    if (baseResponse == null) return [];

    List<dynamic> data = [];

    if (baseResponse is List) {
      data = baseResponse;
    } else if (baseResponse is Map && baseResponse.containsKey('result')) {
      data = baseResponse['result'] as List? ?? [];
    } else if (baseResponse is Map && baseResponse.containsKey('data')) {
      data = baseResponse['data'] as List? ?? [];
    }

    return _parseBaseLookupList(data,
        includeCodeAndDisplayName: includeCodeAndDisplayName);
  }

  List<BaseLookup> _parseBaseLookupList(List<dynamic> data,
      {bool includeCodeAndDisplayName = false}) {
    return data.where((item) => item != null && item is Map).map((item) {
      return BaseLookup(
        id: item['id'] is int
            ? item['id']
            : int.tryParse(item['id'].toString()),
        name: item['name']?.toString() ?? '',
        code: includeCodeAndDisplayName ? item['code']?.toString() : null,
        displayName:
            includeCodeAndDisplayName ? item['name']?.toString() ?? '' : null,
      );
    }).toList();
  }
}