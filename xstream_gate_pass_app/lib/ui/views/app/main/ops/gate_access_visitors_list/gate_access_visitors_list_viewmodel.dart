import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.bottomsheets.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/enums/barcode_scan_type.dart';

import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_access_staff_model.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_access_visitor_model.dart';
import 'package:xstream_gate_pass_app/core/models/scanning/staff_qrcode_model.dart';
import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/gatepass/gatepass_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/scan_manager.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/ui/views/shared/localization/app_view_base_helper.dart';

class GateAccessVisitorsListViewModel extends BaseViewModel with AppViewBaseHelper {
  final log = getLogger('GateAccessVisitorsListViewModel');
  final _connectionService = locator<ConnectionService>();
  final _scanningService = locator<ScanningService>();
  final bottomsheetService = locator<BottomSheetService>();
  bool get hasConnection => _connectionService.hasConnection;
  StreamSubscription<String>? streamSubscription;
  final GatePassService _gatePassService = locator<GatePassService>();
  final TextEditingController filterController = TextEditingController();
  int _nextPage = 1;
  final pagingController = PagingController<int, GatePassVisitorAccess>(firstPageKey: 1, invisibleItemsThreshold: 3);

  BarcodeScanType _barcodeScanType = BarcodeScanType.driversCard;
  BarcodeScanType get barcodeScanType => _barcodeScanType;

  bool _scanInOrOut = false;
  bool get scanInOrOut => _scanInOrOut;

  PagedList<GatePassVisitorAccess> _pagedList = PagedList<GatePassVisitorAccess>(totalCount: 0, items: <GatePassVisitorAccess>[], pageNumber: 1, pageSize: 10, totalPages: 0);

  void setBarcodeScanType(BarcodeScanType value) {
    _barcodeScanType = value;
    _scanningService.setBarcodeScanType(barcodeScanType);
    rebuildUi();
  }

  Future<void> runStartupLogic() async {
    _scanningService.initialise(barcodeScanType: barcodeScanType);
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });

    fetchPage(_nextPage);

    await startconnectionListen();
  }

  Future<void> startconnectionListen() async {
    streamSubscription = _scanningService.rawStringStream.asBroadcastStream().listen((data) async {
      log.i("data: $data");
      //test if data is GUID

      //convert to correct format
      //var loadCOn = LoadconQrCodeModel.fromJson(data);

      //rebuildUi();
    });
  }

  Future<void> scanStaffIn(String code) async {
    var branchId = currentUser?.userBranches[0].id ?? 0;
    //here we save back to server
    var reponse = await _gatePassService.scanStaffIn(StaffQrCodeModel(code: code, branchId: branchId));
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
    var reponse = await _gatePassService.scanStaffOut(StaffQrCodeModel(code: code, branchId: branchId));
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

      _pagedList = await _gatePassService.getVisitorPagedList(_nextPage, _pagedList.pageSize, filterValue, branchId);
      final previouslyFetchedItemsCount = pagingController.itemList?.length ?? 0;

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
    rebuildUi();
  }

  Future<void> setScanStaffIn() async {
    await bottomsheetService.showCustomSheet(
      variant: BottomSheetType.gateAccessVisitor,
      isScrollControlled: true,
      barrierDismissible: false,
    );

    //rebuildUi();
  }
}
