import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/enums/barcode_scan_type.dart';

import 'package:xstream_gate_pass_app/core/models/ops/gatepass/gate_pass_access_staff_model.dart';
import 'package:xstream_gate_pass_app/core/models/scanning/staff_qrcode_model.dart';
import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/gatepass/gatepass_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/scan_manager.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/ui/views/shared/localization/app_view_base_helper.dart';

class GateAccessStaffListViewModel extends BaseViewModel
    with AppViewBaseHelper {
  final log = getLogger('GateAccessStaffListViewModel');
  final _connectionService = locator<ConnectionService>();
  final _scanningService = locator<ScanningService>();
  bool get hasConnection => _connectionService.hasConnection;
  StreamSubscription<String>? streamSubscription;
  final GatePassService _gatePassService = locator<GatePassService>();
  final TextEditingController filterController = TextEditingController();
  int _nextPage = 1;
  final pagingController = PagingController<int, GatePassStaffAccess>(
      firstPageKey: 1, invisibleItemsThreshold: 3);

  bool _scanInOrOut = false;
  bool get scanInOrOut => _scanInOrOut;

  bool _scanInProgress = false;
  bool get scanInProgress => _scanInProgress;

  PagedList<GatePassStaffAccess> _pagedList = PagedList<GatePassStaffAccess>(
      totalCount: 0,
      items: <GatePassStaffAccess>[],
      pageNumber: 1,
      pageSize: 10,
      totalPages: 0);

  Future<void> runStartupLogic() async {
    _scanningService.initialise(barcodeScanType: BarcodeScanType.staffQrCode);
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });

    fetchPage(_nextPage);

    // Only start listening if we don't already have an active subscription
    if (streamSubscription == null) {
      await startconnectionListen();
    }
  }

  Future<void> cancelSubscription() async {
    if (streamSubscription != null) {
      await streamSubscription!.cancel();
      streamSubscription = null;
    }
  }

//only allow one listener per view widget instance
  Future<void> startconnectionListen() async {
    await cancelSubscription();

    streamSubscription = _scanningService.rawStringStream
        .asBroadcastStream()
        .listen((data) async {
      log.i("data: $data");
      //test if data is GUID
      if (_scanInProgress) {
        return;
      }
      _scanInProgress = true;

      if (data.isNotEmpty && data.length == 36) {
        //is GUID
        if (_scanInOrOut) {
          await scanStaffIn(data);
        } else {
          //OUT
          await scanStaffOut(data);
        }
      }
      _scanInProgress = false;

      //var loadCOn = LoadconQrCodeModel.fromJson(data);

      //rebuildUi();
    });
  }

  Future<void> scanStaffIn(String code) async {
    var branchId = currentUser?.userBranches[0].id ?? 0;
    //here we save back to server
    var reponse = await _gatePassService
        .scanStaffIn(StaffQrCodeModel(code: code, branchId: branchId));
    if (reponse != null) {
      refreshList();
      //Fluttertoast.showToast(msg: "Save was successful! ", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM_LEFT, timeInSecForIosWeb: 8, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 14.0);
    } else {
      //error could not save
      //Fluttertoast.showToast(msg: "Save Failed!,Please try again or contact your system admin. ", toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.BOTTOM_LEFT, timeInSecForIosWeb: 8, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 14.0);
    }

    //rebuildUi();
  }

  Future<void> scanStaffOut(String code) async {
    var branchId = currentUser?.userBranches[0].id ?? 0;
    //here we save back to server
    var reponse = await _gatePassService
        .scanStaffOut(StaffQrCodeModel(code: code, branchId: branchId));
    if (reponse != null) {
      refreshList();
      //Fluttertoast.showToast(msg: "Save was successful! ", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM_LEFT, timeInSecForIosWeb: 8, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 14.0);
    } else {
      //error could not save
      //Fluttertoast.showToast(msg: "Save Failed!,Please try again or contact your system admin. ", toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.BOTTOM_LEFT, timeInSecForIosWeb: 8, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 14.0);
    }

    //rebuildUi();
  }

  Future<void> fetchPage(int pageKey) async {
    try {
      log.i("fetchPage | pageKey$pageKey ");
      var branchId = currentUser?.userBranches[0].id ?? 0;
      var filterValue = "";

      if (filterController.text.isNotEmpty) {
        filterValue = filterController.text;
      } else {
        filterValue = "";
      }

      _pagedList = await _gatePassService.getStaffPagedList(
          _nextPage, _pagedList.pageSize, filterValue, branchId);
      final previouslyFetchedItemsCount =
          pagingController.itemList?.length ?? 0;

      final isLastPage = _pagedList.isLastPage(previouslyFetchedItemsCount);

      if (isLastPage) {
        pagingController.appendLastPage(_pagedList.items);
      } else {
        _nextPage = pageKey + 1;
        pagingController.appendPage(_pagedList.items, _nextPage);
      }
      log.i("fetchPage | newItems: ${_pagedList.items.length} ");
    } catch (error) {
      pagingController.error = error;
      rebuildUi();
    }
  }

  refreshList() {
    _nextPage = 1;
    pagingController.refresh();
  }

  void onFilterValueChanged(String value) {
    if (value == null || value.isEmpty) {
      refreshList();
    }
  }

  void findGatePassByStaffQrCode() async {
    refreshList();
  }

  void setScanStaffOut() {
    _scanInOrOut = false;
    rebuildUi();
  }

  void setScanStaffIn() {
    _scanInOrOut = true;
    rebuildUi();
  }

  void onDispose() {
    // Cancel subscription when the view model is disposed
    cancelSubscription();
    // Dispose of other controllers
    filterController.dispose();
    pagingController.dispose();
  }
}
