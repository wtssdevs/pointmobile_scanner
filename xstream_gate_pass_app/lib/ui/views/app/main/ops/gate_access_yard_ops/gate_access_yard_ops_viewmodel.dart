import 'package:flutter/widgets.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_license_disk.dart';
import 'dart:async';

import 'package:xstream_gate_pass_app/core/models/ops/yard_operations/yard_activity_model.dart';
import 'package:xstream_gate_pass_app/core/utils/app_permissions.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/enums/barcode_scan_type.dart';
import 'package:xstream_gate_pass_app/core/enums/loading_stockpile_type.dart';
import 'package:xstream_gate_pass_app/core/enums/stockpile_actions.dart';

import 'package:xstream_gate_pass_app/core/models/scanning/stockpile_loading_slip_qrcode_model.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/gatepass/gatepass_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/scan_manager.dart';
import 'package:xstream_gate_pass_app/ui/views/shared/localization/app_view_base_helper.dart';

class GateAccessYardOpsViewModel extends BaseViewModel with AppViewBaseHelper {
  final log = getLogger('GateAccessPreBookingViewModel');
  final _scanningService = locator<ScanningService>();
  StreamSubscription<String>? streamSubscription;
  StreamSubscription<LicenseDiskData>? discSubscription;
  final _navigationService = locator<NavigationService>();
  final bottomsheetService = locator<BottomSheetService>();
  final GatePassService _gatePassService = locator<GatePassService>();

  final _dialogService = locator<DialogService>();
  bool activityMode = false;
  final vehicleLookupController = TextEditingController();
  List<YardGatePass> vehicleMatches = [];
  String? vehicleLookupNotice;
  bool lookingUpVehicle = false;
  bool readingVehiclePhoto = false;
  bool loadingActivityPasses = false;
  int _vehicleLookupRequest = 0;
  bool _yardDisposed = false;
  YardGatePass? get selectedActivityPass {
    for (final pass in eligiblePasses) {
      if (pass.id == selectedActivityGatePassId) return pass;
    }
    return null;
  }

  static String normalizeVehicle(String value) =>
      value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  List<YardGatePass> eligiblePasses = [];
  String? selectedActivityGatePassId;
  List<YardTimelineActivity> activityTimeline = [];
  String? activityError;
  bool activityTimelineLoaded = false;
  bool get canUseStockpile =>
      hasPermission(AppPermissions.mobileOperationsYardOperations);
  bool get canRecordStockpile =>
      canUseStockpile &&
      loadingSlipQrData?.hasAllInfo() == true &&
      stockPileQrData?.hasAllInfo() == true &&
      validate &&
      isBusyProcessingScan != true;
  bool get canScanActivities =>
      hasPermission(AppPermissions.yardActivitiesScan);
  void setActivityMode(bool value) {
    if (isBusyProcessingScan == true || (value && !canScanActivities)) return;
    activityMode = value;
    validationErrors = [];
    ++_vehicleLookupRequest;
    if (value) {
      startVehicleLookup();
      refreshActivityPasses();
    } else {
      _scanningService.setBarcodeScanType(BarcodeScanType.loadConQrCode);
    }
    rebuildUi();
  }

  Future<void> refreshActivityPasses() async {
    if (_yardDisposed || !canScanActivities) return;
    loadingActivityPasses = true;
    rebuildUi();
    try {
      activityError = null;
      final passes = await _gatePassService
          .getYardActivityGatePasses(getSelectedScannerBranchId());
      if (_yardDisposed) return;
      eligiblePasses = passes;
      vehicleMatches
          .removeWhere((match) => !passes.any((pass) => pass.id == match.id));
      if (!eligiblePasses
          .any((item) => item.id == selectedActivityGatePassId)) {
        selectedActivityGatePassId = null;
        activityTimeline = [];
        activityTimelineLoaded = false;
        if (activityMode)
          _scanningService.setBarcodeScanType(BarcodeScanType.vehicleDisc);
      }
    } catch (_) {
      activityError =
          'Unable to load active gate passes. Check the connection and permissions.';
    } finally {
      loadingActivityPasses = false;
    }
    if (!_yardDisposed) rebuildUi();
  }

  Future<void> selectActivityGatePass(String? id) async {
    if (isBusyProcessingScan == true) return;
    if (id != null && !eligiblePasses.any((pass) => pass.id == id)) return;
    selectedActivityGatePassId = id;
    _scanningService.setBarcodeScanType(id == null
        ? BarcodeScanType.vehicleDisc
        : BarcodeScanType.loadConQrCode);
    vehicleMatches = [];
    vehicleLookupNotice = null;
    activityTimelineLoaded = false;
    activityTimeline = [];
    await refreshActivityTimeline();
  }

  void startVehicleLookup() {
    if (_yardDisposed || !canScanActivities || isBusyProcessingScan == true)
      return;
    ++_vehicleLookupRequest;
    selectedActivityGatePassId = null;
    activityTimeline = [];
    activityTimelineLoaded = false;
    vehicleMatches = [];
    activityError = null;
    vehicleLookupNotice = null;
    vehicleLookupController.clear();
    _scanningService.setBarcodeScanType(BarcodeScanType.vehicleDisc);
    rebuildUi();
  }

  Future<void> lookupActivityVehicle([String? registration]) async {
    if (_yardDisposed) return;
    if (!canScanActivities ||
        lookingUpVehicle ||
        readingVehiclePhoto ||
        isBusyProcessingScan == true) return;
    if (registration != null) vehicleLookupController.text = registration;
    selectedActivityGatePassId = null;
    activityTimeline = [];
    activityTimelineLoaded = false;
    _scanningService.setBarcodeScanType(BarcodeScanType.vehicleDisc);
    final query = normalizeVehicle(vehicleLookupController.text);
    FocusManager.instance.primaryFocus?.unfocus();
    if (query.isEmpty) {
      activityError =
          'Scan a licence disc or enter a registration or gate pass.';
      rebuildUi();
      return;
    }
    final request = ++_vehicleLookupRequest;
    lookingUpVehicle = true;
    vehicleMatches = [];
    vehicleLookupNotice = null;
    selectedActivityGatePassId = null;
    activityTimeline = [];
    activityTimelineLoaded = false;
    try {
      await refreshActivityPasses();
      if (request != _vehicleLookupRequest ||
          !activityMode ||
          activityError != null) return;
      final exact = eligiblePasses
          .where((pass) =>
              normalizeVehicle(pass.vehicle) == query ||
              normalizeVehicle(pass.transaction) == query)
          .toList();
      vehicleMatches = exact.isNotEmpty
          ? exact
          : eligiblePasses
              .where((pass) =>
                  normalizeVehicle(pass.vehicle).contains(query) ||
                  normalizeVehicle(pass.transaction).contains(query))
              .toList();
      if (exact.length == 1)
        await selectActivityGatePass(exact.single.id);
      else if (vehicleMatches.isEmpty)
        activityError = 'No matching gate pass is currently in this yard.';
      else
        vehicleLookupNotice =
            'Select the matching vehicle and gate pass below.';
    } finally {
      lookingUpVehicle = false;
      if (!_yardDisposed) rebuildUi();
    }
  }

  void applyRegistrationPhotoText(String text) {
    if (_yardDisposed) return;
    final normalized = normalizeVehicle(text);
    vehicleMatches = eligiblePasses.where((pass) {
      final plate = normalizeVehicle(pass.vehicle);
      return plate.length >= 3 && normalized.contains(plate);
    }).toList();
    final plates =
        vehicleMatches.map((pass) => normalizeVehicle(pass.vehicle)).toSet();
    if (plates.length == 1) {
      vehicleLookupController.text = vehicleMatches.first.vehicle;
      vehicleMatches = [];
      activityError = null;
      vehicleLookupNotice =
          'Review the extracted registration, then tap Look up.';
    } else if (plates.isEmpty) {
      activityError =
          'No in-yard registration could be read. Retake the photo or enter the registration.';
    } else {
      activityError = null;
      vehicleLookupNotice =
          'Multiple registrations were found. Select the correct gate pass below.';
    }
    rebuildUi();
  }

  Future<void> captureRegistrationPhoto() async {
    if (_yardDisposed ||
        !canScanActivities ||
        readingVehiclePhoto ||
        lookingUpVehicle ||
        isBusyProcessingScan == true) return;
    startVehicleLookup();
    final request = ++_vehicleLookupRequest;
    readingVehiclePhoto = true;
    activityError = null;
    vehicleLookupNotice = null;
    rebuildUi();
    try {
      final text = await _scanningService.captureRegistrationPhotoText();
      if (text == null || !activityMode || request != _vehicleLookupRequest)
        return;
      await refreshActivityPasses();
      if (activityError != null ||
          !activityMode ||
          request != _vehicleLookupRequest) return;
      if (activityMode && request == _vehicleLookupRequest)
        applyRegistrationPhotoText(text);
    } catch (_) {
      activityError =
          'Unable to read the registration photo. Retake it or use text lookup.';
    } finally {
      readingVehiclePhoto = false;
      if (!_yardDisposed) rebuildUi();
    }
  }

  Future<void> scanRegistrationWithCamera() async {
    if (_yardDisposed ||
        !canScanActivities ||
        readingVehiclePhoto ||
        lookingUpVehicle ||
        isBusyProcessingScan == true) return;
    startVehicleLookup();
    final result = await _navigationService
        .navigateToCamLicensePlateReader(returnResult: true);
    if (result is String && result.isNotEmpty) {
      await lookupActivityVehicle(result);
    }
  }

  Future<void> refreshActivityTimeline() async {
    final id = selectedActivityGatePassId;
    if (id == null) return;
    try {
      final result = await _gatePassService.getYardActivityTimeline(id);
      if (_yardDisposed || selectedActivityGatePassId != id) return;
      activityTimeline = result;
      activityTimelineLoaded = true;
    } catch (_) {
      activityTimelineLoaded = false;
      activityError =
          'Unable to refresh the timeline. Refresh before relying on the displayed state.';
    }
    rebuildUi();
  }

  Future<void> scanActivityWithCamera() async {
    if (selectedActivityGatePassId == null || isBusyProcessingScan == true)
      return;
    final result = await _navigationService
        .navigateToCamBarcodeReader(returnResult: true);
    if (result is String && result.isNotEmpty) await scanActivity(result);
  }

  Future<void> scanActivity(String token) async {
    final gatePassId = selectedActivityGatePassId;
    if (!canScanActivities ||
        gatePassId == null ||
        isBusyProcessingScan == true) return;
    setIsBusyProcessingScan(true, rebuildThisUi: true);
    activityError = null;
    try {
      var result = await _gatePassService.scanYardActivity(gatePassId, token);
      while (result.outcome == YardScanOutcome.confirmationRequired) {
        final confirmation = await _dialogService.showConfirmationDialog(
            title: 'Missing preceding activities',
            description:
                '${result.missingActivities.join(', ')}\nContinue recording this activity?',
            confirmationTitle: 'Continue',
            cancelTitle: 'Cancel');
        if (confirmation?.confirmed != true) return;
        result = await _gatePassService.scanYardActivity(gatePassId, token,
            acknowledgement: result.acknowledgement);
      }
      switch (result.outcome) {
        case YardScanOutcome.recorded:
        case YardScanOutcome.alreadyRecorded:
          await refreshActivityTimeline();
          await _dialogService.showDialog(
              title: result.outcome == YardScanOutcome.recorded
                  ? 'Recorded successfully'
                  : 'Already recorded',
              description: result.effectiveTimeText ??
                  result.effectiveAt ??
                  'Refresh the timeline for the recorded time.');
          break;
        case YardScanOutcome.activitySkipped:
          activityError =
              'This activity was skipped. A manager must restore it or add a timestamp.';
          break;
        case YardScanOutcome.invalidToken:
          activityError = 'Invalid QR token.';
          break;
        case YardScanOutcome.revokedToken:
          activityError = 'This QR token has been revoked.';
          break;
        case YardScanOutcome.activityNotApplicable:
          activityError =
              'This activity does not belong to the selected gate-pass snapshot or yard setup.';
          break;
        case YardScanOutcome.gatePassIneligible:
          activityError =
              'The gate pass is unavailable or no longer in the yard.';
          await refreshActivityPasses();
          break;
        case YardScanOutcome.unauthorized:
          activityError = 'You do not have permission to record this activity.';
          break;
        case YardScanOutcome.concurrentStateChange:
          activityError = 'The activity changed. Refresh and scan again.';
          await refreshActivityTimeline();
          break;
        default:
          activityError =
              'The request could not be completed. Refresh and retry.';
      }
    } catch (_) {
      activityError =
          'The server did not confirm completion. Check the connection and refresh the timeline before retrying.';
    } finally {
      setIsBusyProcessingScan(false, rebuildThisUi: true);
    }
  }

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
    activityMode = false;
    _scanningService.initialise(barcodeScanType: BarcodeScanType.loadConQrCode);
    //we can lter do scan image of vehicle number plate or ...
    await startconnectionListen();
  }

  Future<void> startconnectionListen() async {
    await streamSubscription?.cancel();
    await discSubscription?.cancel();
    discSubscription = _scanningService.licenseDiskDataStream.listen((data) {
      if (activityMode &&
          canScanActivities &&
          selectedActivityGatePassId == null)
        lookupActivityVehicle(data.licensePlateNo);
    });
    streamSubscription = _scanningService.rawStringStream
        .asBroadcastStream()
        .listen((data) async {
      // Opaque activity tokens must not appear in routine logs.
      if (isBusyProcessingScan == false) {
        if (activityMode) {
          if (selectedActivityGatePassId == null) {
            activityError =
                'Find the vehicle by licence disc, registration photo, or text lookup before scanning an activity.';
            rebuildUi();
          } else if (!lookingUpVehicle && !readingVehiclePhoto)
            await scanActivity(data);
        } else if (canUseStockpile) {
          await initiateQrScan(data);
        }
      }
    });
  }

  Future<void> updateGatePassEventStatus(StockpileActions action) async {
    if (!canRecordStockpile) return;
    try {
      validationErrors = [];
      setIsBusyProcessingScan(true, rebuildThisUi: true);
      loadingSlipQrData!.stockpileAction = action;
      var branchId = getSelectedScannerBranchId();
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
    if (!canUseStockpile) return;
    if (rawData.trim().startsWith('yac1.')) {
      validationErrors = [
        'This is an activity QR code. Open Activity tracking, select the gate pass, then scan again.'
      ];
      rebuildUi();
      return;
    }
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
      validationErrors = [
        'Unable to read this QR code. Scan a valid Loading Slip or Stockpile QR code.'
      ];
      setIsBusyProcessingScan(false, rebuildThisUi: true);
    }
  }

  void setIsScanning() {
    if (!canUseStockpile) return;
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
    if (_yardDisposed) return;
    _yardDisposed = true;
    ++_vehicleLookupRequest;
    streamSubscription?.cancel();
    discSubscription?.cancel();
    vehicleLookupController.dispose();
    // _scanningService.onExit();
  }

  Future<void> setAtStockPile() async {
    if (!canRecordStockpile) return;
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
    if (!canRecordStockpile) return;
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