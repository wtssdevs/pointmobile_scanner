import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.bottomsheets.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/enums/barcode_scan_type.dart';
import 'package:xstream_gate_pass_app/core/models/scanning/loadcon_qrcode_model.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/gatepass/gatepass_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/scan_manager.dart';

import 'package:xstream_gate_pass_app/ui/views/shared/localization/app_view_base_helper.dart';

class GateAccessPreBookingViewModel extends BaseViewModel
    with AppViewBaseHelper {
  final log = getLogger('GateAccessPreBookingViewModel');
  final _scanningService = locator<ScanningService>();
  StreamSubscription<String>? streamSubscription;
  final TextEditingController filterController = TextEditingController();
  final TextEditingController voageNoController = TextEditingController();
  final _navigationService = locator<NavigationService>();
  final bottomsheetService = locator<BottomSheetService>();
  final GatePassService _gatePassService = locator<GatePassService>();
  // Scanning status
  bool _isScanning = false;
  bool get isScanning => _isScanning;

  LoadconQrCodeModel? _scannedQrData = null;
  LoadconQrCodeModel? get scannedQrData => _scannedQrData;
  List<String> validationErrors = [];

  runStartupLogic() async {
    // var reponse = await bottomsheetService.showCustomSheet(variant: BottomSheetType.gateAccessPreBooking, isScrollControlled: true, barrierDismissible: false, data: null);
    // if (reponse != null) {
//found populate widget
    // }
    _scanningService.initialise(barcodeScanType: BarcodeScanType.loadConQrCode);
    //we can lter do scan image of vehicle number plate or ...
    await startconnectionListen();
  }

  Future<void> startconnectionListen() async {
    streamSubscription = _scanningService.rawStringStream
        .asBroadcastStream()
        .listen((data) async {
      log.i("data: $data");
      if (isBusy == false) {
        initiateQrScan(data);
      }
    });
  }

  void onFilterValueChanged(String value) {}

  void findGatePassByVoyageNo() {
    if (voageNoController.text.isNotEmpty) {
      log.i("voyageNo: ${voageNoController.text}");

      rebuildUi();
    }
  }

  void onBarcodeScanned(String barcode) {
    if (barcode.isNotEmpty) {
//      filterController.text = barcode;
      log.i("barcode: $barcode");
      rebuildUi();
    }
  }

  Future<void> initiateQrScan(String rawData) async {
    //setBusy(true);
    try {
      //convert to correct format
      //rawData = {"TransactionNo":"PO565871","ReferenceNo":"W013244162","CustomerRefNo":"W013244162","BookingOrderNumber":"SO2619","VehicleRegistrationNumber":"LFB235MP"}
      var jsonMap = json.decode(rawData);
      var loadCOn = LoadconQrCodeModel.fromJson(jsonMap);
      //model empty check
      if (loadCOn.isModelEmpty()) {
        validationErrors = ['Invalid QR code data'];
        rebuildUi();
        return;
      }

      _scannedQrData = loadCOn;
      validationErrors = []; // Clear previous errors
      //rebuildUi();
      await findPreBookingByQrData();
    } catch (e) {
      validationErrors = ['Failed to scan QR code: ${e.toString()}'];
      setBusy(false);
      rebuildUi();
    }
  }

  Future<void> findPreBookingByQrData() async {
    try {
      // Clear previous errors
      validationErrors = [];

      if (scannedQrData == null) {
        validationErrors.add('No QR code data to search with');
        notifyListeners();
        return;
      }

      // Show loading indicator
      //setBusy(true);
      var branchId = currentUser?.userBranches[0].id ?? 0;
      scannedQrData!.branchId = branchId;
      var reponse = await _gatePassService.findPreBookedLoad(scannedQrData!);
      //setBusy(false);
      bool success = true; // Change to test different scenarios
      if (reponse == null) {
        success = false;
      }

      if (success) {
        // Handle successful finding of pre-booking
        // Navigate to details page or update UI

        await _navigationService.navigateTo(
          Routes.gatePassEditView,
          arguments: GatePassEditViewArguments(
            gatePass: reponse!,
          ),
        );

        //if wecome back to here we reset the model to null
        _scannedQrData = null;
        validationErrors = []; // Clear previous errors
        //setBusy(false);
        // _scanningService.setBarcodeScanType(BarcodeScanType.loadConQrCode);
        rebuildUi();
      } else {
        // Handle case where pre-booking not found
        setBusy(false);
        validationErrors.add(
            'No pre-booking found with the scanned QR code data: $scannedQrData');
      }
    } catch (e) {
      validationErrors.add('Error searching for pre-booking: ${e.toString()}');
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }
}
