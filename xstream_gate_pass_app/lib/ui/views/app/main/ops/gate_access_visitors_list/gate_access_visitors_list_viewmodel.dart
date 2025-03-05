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
import 'package:xstream_gate_pass_app/core/services/services/masterfiles/masterfiles_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/gatepass/gatepass_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/scan_manager.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/ui/views/shared/localization/app_view_base_helper.dart';

class GateAccessVisitorsListViewModel extends BaseViewModel with AppViewBaseHelper {
  final log = getLogger('GateAccessVisitorsListViewModel');
  final _connectionService = locator<ConnectionService>();

  final bottomsheetService = locator<BottomSheetService>();
  final _masterfilesService = locator<MasterFilesService>();
  bool get hasConnection => _connectionService.hasConnection;

  final GatePassService _gatePassService = locator<GatePassService>();
  final TextEditingController filterController = TextEditingController();
  int _nextPage = 1;
  final pagingController = PagingController<int, GatePassVisitorAccess>(firstPageKey: 1, invisibleItemsThreshold: 3);

  bool _scanInOrOut = false;
  bool get scanInOrOut => _scanInOrOut;

  PagedList<GatePassVisitorAccess> _pagedList = PagedList<GatePassVisitorAccess>(totalCount: 0, items: <GatePassVisitorAccess>[], pageNumber: 1, pageSize: 10, totalPages: 0);

  Future<void> runStartupLogic() async {
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
    await _masterfilesService.loadServiceTypes();
    fetchPage(_nextPage);
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

  Future<void> setScanStaffOut() async {
    await bottomsheetService.showCustomSheet(variant: BottomSheetType.gateAccessVisitor, isScrollControlled: true, barrierDismissible: false, data: false);
    refreshList();
  }

  Future<void> setScanStaffIn() async {
    await bottomsheetService.showCustomSheet(variant: BottomSheetType.gateAccessVisitor, isScrollControlled: true, barrierDismissible: false, data: true);
    refreshList();
  }
}
