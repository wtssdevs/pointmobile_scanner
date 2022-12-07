import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app_config/app.locator.dart';
import 'package:xstream_gate_pass_app/app_config/app.logger.dart';
import 'package:xstream_gate_pass_app/app_config/app.router.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_type.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_model.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_question.dart';
import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/gatepass/gatepass_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/scan_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_drivers_license.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';

class GatePassViewModel extends BaseViewModel {
  final log = getLogger('GatePassViewModel');
  final GatePassService _gatePassService = locator<GatePassService>();

  final _navigationService = locator<NavigationService>();

  int _nextPage = 1;
  final pagingController = PagingController<int, GatePass>(firstPageKey: 1, invisibleItemsThreshold: 5);

  final PagedList<GatePass> _pagedList = PagedList<GatePass>(totalCount: 0, items: <GatePass>[], pageNumber: 1, pageSize: 15, totalPages: 0);

  final _scanningService = locator<ScanningService>();
  final TextEditingController filterController = TextEditingController();
  StreamSubscription<RsaDriversLicense>? streamSubscription;
  final _connectionService = locator<ConnectionService>();
  bool get hasConnection => _connectionService.hasConnection;

  RsaDriversLicense? _rsaDriversLicense;
  RsaDriversLicense? get rsaDriversLicense => _rsaDriversLicense;

  void startconnectionListen() {
    streamSubscription = _scanningService.licenseStream.asBroadcastStream().listen((data) {
      log.i('Barcode Model Recieved? $data');
      _rsaDriversLicense = data;
      notifyListeners();
    });
  }

  Future<void> runStartupLogic() async {
    pagingController.addPageRequestListener((pageKey) {
      fetchPage(pageKey);
    });
    //_scanningService.initialise();
    //startconnectionListen();
    fetchPage(_nextPage);
    notifyListeners();
  }

  Future<void> fetchPage(int pageKey) async {
    try {
      log.i("fetchPage | pageKey$pageKey ");

      var filterValue = "";

      if (filterController.text.isNotEmpty) {
        filterValue = filterController.text;
      }

      final newPage = await _gatePassService.getPagedList(_pagedList.pageNumber, _pagedList.pageSize, filterValue);

      final previouslyFetchedItemsCount = pagingController.itemList?.length ?? 0;

      final isLastPage = newPage.isLastPage(previouslyFetchedItemsCount);

      final newItems = newPage.items;

      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        _nextPage = pageKey + 1;
        pagingController.appendPage(newItems, _nextPage);
      }
      log.i("fetchPage | newItems: ${newItems.length} ");
      notifyListeners();
    } catch (error) {
      pagingController.error = error;
      notifyListeners();
    }
  }

  void onDispose() async {
    if (streamSubscription != null) {
      await streamSubscription?.cancel();
    }

    _scanningService.onExit();
  }

  void onFilterValueChanged(String value) {
    refreshList();
  }

  refreshList() {
    _nextPage = 1;
    pagingController.refresh();
  }

  Future goToDetail(GatePass entity) async {
    await _navigationService.navigateTo(
      Routes.gatePassEditView,
      arguments: GatePassEditViewArguments(
        gatePass: entity,
      ),
    );

    refreshList();
  }

  Future onAddNewGatePass() async {
    await _navigationService.navigateTo(
      Routes.gatePassEditView,
      arguments: GatePassEditViewArguments(
        gatePass: GatePass(
            id: 0,
            gatePassStatus: GatePassStatus.atGate.index,
            vehicleRegNumber: "",
            timeAtGate: DateTime.now(),
            gatePassQuestions: GatePassQuestions(),
            gatePassType: GatePassType.delivery.index),
      ),
    );

    refreshList();
  }
}
