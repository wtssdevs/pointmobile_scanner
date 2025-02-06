import 'dart:async';

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';

import 'package:xstream_gate_pass_app/core/models/gatepass/gate-pass-access_model.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_model.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_question.dart';
import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/gatepass/gatepass_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/scan_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_drivers_license.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/media_service.dart';

class GatePassViewModel extends BaseViewModel {
  final log = getLogger('GatePassViewModel');
  final GatePassService _gatePassService = locator<GatePassService>();
  final _mediaService = locator<MediaService>();
  final _navigationService = locator<NavigationService>();
  final _scanningService = locator<ScanningService>();
  int _nextPage = 1;
  final pagingController = PagingController<int, GatePassAccess>(firstPageKey: 1, invisibleItemsThreshold: 5);

  PagedList<GatePassAccess> _pagedList = PagedList<GatePassAccess>(totalCount: 0, items: <GatePassAccess>[], pageNumber: 1, pageSize: 10, totalPages: 0);

  final TextEditingController filterController = TextEditingController();
  StreamSubscription<RsaDriversLicense>? streamSubscription;
  final _connectionService = locator<ConnectionService>();
  bool get hasConnection => _connectionService.hasConnection;

  RsaDriversLicense? _rsaDriversLicense;
  RsaDriversLicense? get rsaDriversLicense => _rsaDriversLicense;

  void setscanMode(bool value) {
    //_scanningService.setScanMode(value);
  }

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

    fetchPage(_nextPage);

    await _mediaService.int();
  }

  // Future<void> fetchPage(int pageKey) async {
  //   try {
  //     log.i("fetchPage | pageKey$pageKey ");

  //     var filterValue = "";

  //     if (filterController.text.isNotEmpty) {
  //       filterValue = filterController.text;
  //     }

  //     final newPage = await _gatePassService.getPagedList(_pagedList.pageNumber, _pagedList.pageSize, filterValue);

  //     final previouslyFetchedItemsCount = pagingController.itemList?.length ?? 0;

  //     final isLastPage = newPage.isLastPage(previouslyFetchedItemsCount);

  //     final newItems = newPage.items;

  //     if (isLastPage) {
  //       pagingController.appendLastPage(newItems);
  //     } else {
  //       _nextPage = pageKey + 1;
  //       pagingController.appendPage(newItems, _nextPage);
  //     }
  //     log.i("fetchPage | newItems: ${newItems.length} ");
  //     notifyListeners();
  //   } catch (error) {
  //     pagingController.error = error;
  //     notifyListeners();
  //   }
  // }

  Future<void> fetchPage(int pageKey) async {
    try {
      log.i("fetchPage | pageKey$pageKey ");

      var filterValue = "";

      if (filterController.text.isNotEmpty) {
        filterValue = filterController.text;
      }

      _pagedList = await _gatePassService.getPagedList(_pagedList.pageNumber, _pagedList.pageSize, filterValue);
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

  Future<void> fetchLastPage(int pageKey) async {
    try {
      log.i("fetchPage | pageKey$pageKey ");

      var filterValue = "";

      if (filterController.text.isNotEmpty) {
        filterValue = filterController.text;
      }

      var pagedList = await _gatePassService.getPagedList(_pagedList.pageNumber, _pagedList.pageSize, filterValue);

      if (pagedList.items.isNotEmpty && pagingController.itemList != null && pagingController.itemList!.isNotEmpty) {
        //find all items in the pagingController list that are int pagedlist items and update/replace them with the new pagedlist items
        for (var item in pagedList.items) {
          var index = pagingController.itemList?.firstWhereOrNull((element) => element.id == item.id);
          if (index != null) {
            index = item;
          }
        }
      }

      //rebuildUi();
    } catch (error) {
      pagingController.error = error;
      rebuildUi();
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

    //refreshList();
    await fetchLastPage(_pagedList.pageNumber);
  }

  Future onAddNewGatePass() async {
    // await _navigationService.navigateTo(
    //   Routes.gatePassEditView,
    //   arguments: GatePassEditViewArguments(
    //     gatePass: GatePass(id: 0, gatePassStatus: GatePassStatus.atGate.index, vehicleRegNumber: "", timeAtGate: DateTime.now(), gatePassQuestions: GatePassQuestions(), gatePassType: GatePassType.delivery.index),
    //   ),
    // );

    refreshList();
  }

  void onBarcodeScanned(String barcode) {
    if (barcode.isNotEmpty) {
//      filterController.text = barcode;
      log.i("barcode: $barcode");
      rebuildUi();
    }
  }

  void goToFindGatePass() {}
}
