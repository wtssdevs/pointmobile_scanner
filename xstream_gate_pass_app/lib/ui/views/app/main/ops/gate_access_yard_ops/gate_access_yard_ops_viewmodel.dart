import 'dart:async';
import 'dart:convert';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/enums/barcode_scan_type.dart';
import 'package:xstream_gate_pass_app/core/enums/loading_stockpile_type.dart';
import 'package:xstream_gate_pass_app/core/enums/stockpile_actions.dart';
import 'package:xstream_gate_pass_app/core/models/scanning/loadcon_qrcode_model.dart';
import 'package:xstream_gate_pass_app/core/models/scanning/stockpile_loading_slip_qrcode_model.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/gatepass/gatepass_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/scan_manager.dart';
import 'package:xstream_gate_pass_app/ui/views/shared/localization/app_view_base_helper.dart';

class GateAccessYardOpsViewModel extends BaseViewModel with AppViewBaseHelper {
  final log = getLogger('GateAccessPreBookingViewModel');
  final _scanningService = locator<ScanningService>();
  StreamSubscription<String>? streamSubscription;
  final _navigationService = locator<NavigationService>();
  final bottomsheetService = locator<BottomSheetService>();
  final GatePassService _gatePassService = locator<GatePassService>();

  final _dialogService = locator<DialogService>();
  // Scanning status
  bool? _isScanning = true;
  bool? get isScanning => _isScanning;

  bool? _isBusyProcessingScan = false;
  bool? get isBusyProcessingScan => _isBusyProcessingScan;

  void setIsBusyProcessingScan(bool value, {bool rebuildThisUi = false}) {
    _isBusyProcessingScan = value;
    if (rebuildThisUi) {
      rebuildUi();
    }
  }

  StockpileLoadingSlipQrCodeModel? _loadingSlipQrData = null;
  StockpileLoadingSlipQrCodeModel? get loadingSlipQrData => _loadingSlipQrData;

  StockpileLoadingSlipQrCodeModel? _stockPileQrData = null;
  StockpileLoadingSlipQrCodeModel? get stockPileQrData => _stockPileQrData;

  bool get validate =>
      _stockPileQrData == _loadingSlipQrData &&
      _loadingSlipQrData?.loadingStockpileType ==
          LoadingStockpileType.loadingSlip &&
      _stockPileQrData?.loadingStockpileType == LoadingStockpileType.stockPile;

  List<String> validationErrors = [];

  runStartupLogic() async {
    _scanningService.initialise(barcodeScanType: BarcodeScanType.loadConQrCode);
    //we can lter do scan image of vehicle number plate or ...
    await startconnectionListen();
  }

  Future<void> startconnectionListen() async {
    streamSubscription = _scanningService.rawStringStream
        .asBroadcastStream()
        .listen((data) async {
      log.i("data: $data");
      if (isBusyProcessingScan == false) {
        initiateQrScan(data);
      }
    });
  }

  Future<void> updateGatePassEventStatus(StockpileActions action) async {
    try {
      validationErrors = [];
      setIsBusyProcessingScan(true, rebuildThisUi: true);
      loadingSlipQrData!.stockpileAction = action;
      var branchId = currentUser?.userBranches[0].id ?? 0;
      loadingSlipQrData!.branchId = branchId;
      var reponse =
          await _gatePassService.setCmsGatePassEvent(loadingSlipQrData!);

      if (reponse == true) {
        await _dialogService.showDialog(
          title: 'Success',
          description: 'Status updated successfully',
        );

        _navigationService.back();
      } else {
        await _dialogService.showDialog(
          title: 'Error',
          description: 'Failed to update status',
        );
      }
      setIsBusyProcessingScan(false, rebuildThisUi: true);
    } catch (e) {
      validationErrors = ['Failed to update CMS ${e.toString()}'];
      setIsBusyProcessingScan(false, rebuildThisUi: true);
    }
  }

  Future<void> initiateQrScan(String rawData) async {
    //setBusy(true);
    try {
      //convert to correct format
      //data: {"VoyageNo":"PO416632","CustomerRefNo":"UG - 4502192786","LoadItemCode":"CHROME CONCENTRATE","CmsGatePassId":"276040","LoadingStockpileType":0}
      if (isScanning == true) {
        _loadingSlipQrData = StockpileLoadingSlipQrCodeModel.fromJson(rawData);
        //model empty check
        if (_loadingSlipQrData?.hasAllInfo() == false) {
          validationErrors = ['Invalid QR code data'];
          setIsBusyProcessingScan(false, rebuildThisUi: true);
          return;
        }

        if (_loadingSlipQrData?.loadingStockpileType !=
            LoadingStockpileType.loadingSlip) {
          validationErrors = [
            'Invalid QR code data, not a loading slip QR Code'
          ];
          _loadingSlipQrData?.clearInfo();
          setIsBusyProcessingScan(false, rebuildThisUi: true);
          return;
        }

        _isScanning = false;
        rebuildUi();
      } else if (isScanning == false) {
        _stockPileQrData = StockpileLoadingSlipQrCodeModel.fromJson(rawData);
        if (_stockPileQrData?.hasAllInfo() == false) {
          validationErrors = ['Invalid QR code data'];
          setIsBusyProcessingScan(false, rebuildThisUi: true);
          return;
        }
        if (_stockPileQrData?.loadingStockpileType !=
            LoadingStockpileType.stockPile) {
          validationErrors = ['Invalid QR code data, not a stock pile QR Code'];
          _stockPileQrData?.clearInfo();
          setIsBusyProcessingScan(false, rebuildThisUi: true);
          return;
        }
      }

      if (_loadingSlipQrData?.hasAllInfo() == false ||
          _stockPileQrData?.hasAllInfo() == false) {
        validationErrors = ['Invalid QR code data'];
        setIsBusyProcessingScan(false, rebuildThisUi: true);
        return;
      }

      validationErrors = []; // Clear previous errors

      if (validate) {
        _isScanning = null;

        rebuildUi();
        setIsBusyProcessingScan(false);
      }

      //rebuildUi();
      //await findPreBookingByQrData();
    } catch (e) {
      validationErrors = ['Failed to scan QR code: ${e.toString()}'];
      setIsBusyProcessingScan(false, rebuildThisUi: true);
    }
  }

  void setIsScanning() {
    if (_isScanning != null) {
      _isScanning = !_isScanning!;
    } else {
      _isScanning = true;
    }
    rebuildUi();
  }

  void resetScans() {
    _loadingSlipQrData = null;
    _stockPileQrData = null;
    _scanningService.setBarcodeScanType(BarcodeScanType.loadConQrCode);
    rebuildUi();
  }

  void onDispose() {
    streamSubscription?.cancel();
    // _scanningService.onExit();
  }

  Future<void> setAtStockPile() async {
    //need confirm dialog here
    var confirmed = await _dialogService.showConfirmationDialog(
      title: "Confirmation",
      description: "Are you sure you want to set the status to At Stock Pile?",
    );

    if (confirmed != null && confirmed.confirmed == true) {
      await updateGatePassEventStatus(StockpileActions.atStockPile);
    }
  }

  Future<void> setLeftStockPile() async {
    //need confirm dialog here
    var confirmed = await _dialogService.showConfirmationDialog(
      title: "Confirmation",
      description:
          "Are you sure you want to set the status to Left Stock Pile?",
    );

    if (confirmed != null && confirmed.confirmed == true) {
      await updateGatePassEventStatus(StockpileActions.leftStockPile);
    }
  }
}
