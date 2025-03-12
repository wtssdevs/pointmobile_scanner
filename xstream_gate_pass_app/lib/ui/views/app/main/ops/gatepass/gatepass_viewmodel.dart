import 'dart:async';

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';

import 'package:xstream_gate_pass_app/core/models/gatepass/gate-pass-access_model.dart';

import 'package:xstream_gate_pass_app/core/models/shared/filter_params_model.dart';

import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/gatepass/gatepass_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/scan_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_drivers_license.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/media_service.dart';
import 'package:xstream_gate_pass_app/core/utils/app_permissions.dart';
import 'package:xstream_gate_pass_app/ui/views/shared/localization/app_view_base_helper.dart';

class GatePassViewModel extends BaseViewModel with AppViewBaseHelper {
  final log = getLogger('GatePassViewModel');
  final GatePassService _gatePassService = locator<GatePassService>();
  final _mediaService = locator<MediaService>();
  final _navigationService = locator<NavigationService>();
  final _scanningService = locator<ScanningService>();
  int _nextPage = 1;
  final pagingController = PagingController<int, GatePassAccess>(
      firstPageKey: 1, invisibleItemsThreshold: 3);

  PagedList<GatePassAccess> _pagedList = PagedList<GatePassAccess>(
      totalCount: 0,
      items: <GatePassAccess>[],
      pageNumber: 1,
      pageSize: 10,
      totalPages: 0);

  final TextEditingController filterController = TextEditingController();
  StreamSubscription<RsaDriversLicense>? streamSubscription;
  final _connectionService = locator<ConnectionService>();
  bool get hasConnection => _connectionService.hasConnection;
  FilterParams _filterParams = FilterParams();
  FilterParams get filterParams => _filterParams;

  RsaDriversLicense? _rsaDriversLicense;
  RsaDriversLicense? get rsaDriversLicense => _rsaDriversLicense;

  void setscanMode(bool value) {
    //_scanningService.setScanMode(value);
  }

  void startconnectionListen() {
    streamSubscription =
        _scanningService.licenseStream.asBroadcastStream().listen((data) {
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
      _filterParams.pageNumber = _nextPage;
      _filterParams.pageSize = _pagedList.pageSize;
      _pagedList = await _gatePassService.getPagedFilteredList(filterParams);
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

  Future<void> fetchLastPage(int pageKey) async {
    try {
      log.i("fetchPage | pageKey$pageKey ");

      var filterValue = "";

      // if (filterController.text.isNotEmpty) {
      //   filterValue = filterController.text;
      // }

      var pagedList = await _gatePassService.getPagedList(
          pageKey, _pagedList.pageSize, filterValue);

      if (pagedList.items.isNotEmpty &&
          pagingController.itemList != null &&
          pagingController.itemList!.isNotEmpty) {
        //find all items in the pagingController list that are int pagedlist items and update/replace them with the new pagedlist items
        for (var item in pagedList.items) {
          var index = pagingController.itemList
              ?.firstWhereOrNull((element) => element.id == item.id);
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

   // _scanningService.onExit();
  }

  void onFilterValueChanged(String? value) {
    //refreshList();
    if (value == null || value.isEmpty) {
      _filterParams.clear();
      refreshList();
    }
  }

  refreshList() {
    _nextPage = 1;
    pagingController.refresh();
  }

  Future goToDetail(GatePassAccess entity) async {
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
    await _navigationService.navigateTo(
      Routes.gatePassEditView,
      arguments: GatePassEditViewArguments(
        gatePass: GatePassAccess(
          id: "",
          gatePassStatus: GatePassStatus.atGate,
          branchId: currentUser?.userBranches.first.id ?? 0,
          gatePassBookingType: GatePassBookingType.none,
          gatePassDeliveryType: DeliveryType.receive,
        ),
      ),
    );

    refreshList();
  }

  void onBarcodeScanned(String barcode) {
    if (barcode.isNotEmpty) {
//      filterController.text = barcode;
      log.i("barcode: $barcode");
      rebuildUi();
    }
  }

  void findGatePassByVehicleRegNumber() {
    //VehicleRegNumber
    if (filterController.text.isNotEmpty) {
      _filterParams.clear();
      _filterParams.vehicleRegNumber = filterController.text;
      refreshList();
    }
  }

  void findGatePassByVoyageNo() {
//VoyageNo
    if (filterController.text.isNotEmpty) {
      _filterParams.clear();
      _filterParams.voyageNo = filterController.text;
      refreshList();
    }
  }
}
