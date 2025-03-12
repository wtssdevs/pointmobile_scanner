// ignore_for_file: prefer_conditional_assignment

import 'dart:async';
import 'dart:math' as math; // Add proper import for math functions
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/barcode_scan_type.dart';
import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';
import 'package:xstream_gate_pass_app/core/enums/scan_action_types.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate-pass-access_model.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_access_visitor_model.dart';
import 'package:xstream_gate_pass_app/core/services/services/masterfiles/masterfiles_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/gatepass/gatepass_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/scan_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_drivers_license.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_license_disk.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/ui/views/shared/localization/app_view_base_helper.dart';

class GateAccessVisitorSheetModel extends BaseViewModel with AppViewBaseHelper {
  final log = getLogger('GateAccessVisitorSheetModel');
  final _connectionService = locator<ConnectionService>();
  final _scanningService = locator<ScanningService>();
  final _gatePassService = locator<GatePassService>();
  final _masterfilesService = locator<MasterFilesService>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool get hasConnection => _connectionService.hasConnection;
  StreamSubscription<RsaDriversLicense>? streamSubscription;
  StreamSubscription<LicenseDiskData>? streamSubscriptionForDisc;

  List<SearchableDropdownMenuItem<int>> get serviceTypes =>
      _masterfilesService.serviceTypes;
  //

  // Scanning configuration
  BarcodeScanType _barcodeScanType = BarcodeScanType.driversCard;
  BarcodeScanType get barcodeScanType => _barcodeScanType;

  // Scan mode (in or out)
  ScanActionType _scanInMode = ScanActionType.checkIn;
  ScanActionType get scanInMode => _scanInMode;

  // Scanned data
  GatePassVisitorAccess _scannedVisitor = GatePassVisitorAccess(
    isActive: true,
    branchId: 0,
    gatePassStatus: GatePassStatus.atGate,
    gatePassBookingType: GatePassBookingType.visitor,
  );
  GatePassVisitorAccess get scannedVisitor => _scannedVisitor;

  // Scanning status
  bool _isScanning = false;
  bool get isScanning => _isScanning;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    // Initialize scanner with the selected barcode type
    _scanningService.initialise(barcodeScanType: _barcodeScanType);
    await startScanListener();
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    streamSubscriptionForDisc?.cancel();
    //_scanningService.onExit(); // Properly disable scanner when done
    super.dispose();
  }

  void setBarcodeScanType(BarcodeScanType type) {
    _barcodeScanType = type;
    _scanningService.setBarcodeScanType(type);
    //rebuildUi();
  }

  void setScanInMode(ScanActionType inMode) {
    _scanInMode = inMode;
    rebuildUi();
  }

  Future<void> startScanListener() async {
    // Cancel any existing subscription
    streamSubscription?.cancel();
    streamSubscriptionForDisc?.cancel();

    // Also listen to license disk data for vehicle scans
    streamSubscription =
        _scanningService.licenseStream.asBroadcastStream().listen((data) async {
      log.i("Drivers Card data received");
      // Process the driversCard  data here
      // This would populate a GatePassVisitorAccess from the driversCard data
      processScanData(data, null);
    });
    // Also listen to license disk data for vehicle scans
    streamSubscriptionForDisc = _scanningService.licenseDiskDataStream
        .asBroadcastStream()
        .listen((licenseDiskData) async {
      log.i("Drivers Card data received");
      // Process the license disk data here
      // This would populate a GatePassVisitorAccess from the license disk data
      processScanData(null, licenseDiskData);
    });
  }

  Future<void> startScanning() async {
    if (!hasConnection) {
      _errorMessage = "No connection available. Please check your network.";
      rebuildUi();
      return;
    }
    if (_scannedVisitor.serviceTypeId == null &&
        _scanInMode == ScanActionType.checkIn) {
      _errorMessage = "Please select a service type.";
      rebuildUi();
      return;
    }
    _isScanning = true;
    _errorMessage = null;

    rebuildUi();

    try {
      // The actual scanning is handled by the hardware scanner
      // which will send data through the streams we're listening to
      log.i("Starting scanner with type: ${_barcodeScanType.toString()}");

//start stream listening here

      // The ScanningService will handle the hardware specifics,
      // we just need to make sure it's properly initialized
      if (!_scanningService.initScanner!) {
        _scanningService.initialise(barcodeScanType: _barcodeScanType);
      }
      initialize();
      // ScanningService automatically activates the scanner hardware
      // when initialized - we just need to wait for the scan data
    } catch (e) {
      _errorMessage = "Failed to start scanner: ${e.toString()}";
      _isScanning = false;
      rebuildUi();
    }
  }

  Future<void> processScanData(RsaDriversLicense? rsaDriversLicense,
      LicenseDiskData? vehicleLicenseData) async {
    //_isScanning = false;

    try {
      // Process the scanned data based on scan type
      if (_barcodeScanType == BarcodeScanType.driversCard &&
          rsaDriversLicense != null) {
        // Process driver's license data
        _scannedVisitor = await processDriversLicenseData(rsaDriversLicense);
        setBarcodeScanType(BarcodeScanType.vehicleDisc);
      } else if (_barcodeScanType == BarcodeScanType.vehicleDisc &&
          vehicleLicenseData != null) {
        // Process vehicle license data
        _scannedVisitor = await processVehicleLicenseData(vehicleLicenseData);
      }

      rebuildUi();
    } catch (e) {
      _errorMessage = "Failed to process scan data: ${e.toString()}";
      rebuildUi();
    }
  }

  Future<GatePassVisitorAccess> processDriversLicenseData(
      RsaDriversLicense data) async {
    //Map scanned data to the GatePassVisitorAccess model
    //update fields based on scanned data
    var branchId = currentUser?.userBranches[0].id ?? 0;

    if (_scannedVisitor == null) {
      _scannedVisitor = GatePassVisitorAccess(
        isActive: true,
        branchId: branchId,
        driverName: '${data.firstNames} ${data.surname}',
        driverIdNo: data.idNumber,
        driverLicenceNo: data.licenseNumber,
        driverLicenceIssueDate: data.issueDates?.firstOrNull,
        driverLicenceExpiryDate: data.validTo,
        driversLicenceCodes: data.vehicleCodes.join(','),
        gatePassStatus: _scanInMode == ScanActionType.checkIn
            ? GatePassStatus.atGate
            : GatePassStatus.inYard,
        gatePassBookingType: GatePassBookingType.visitor,
        professionalDrivingPermitExpiryDate: data.prdpExpiry,
      );
    } else {
      _scannedVisitor.driverName = '${data.firstNames} ${data.surname}';
      _scannedVisitor.driverIdNo = data.idNumber;
      _scannedVisitor.driverLicenceNo = data.licenseNumber;
      _scannedVisitor.driverLicenceIssueDate = data.issueDates?.firstOrNull;
      _scannedVisitor.driverLicenceExpiryDate = data.validTo;
      _scannedVisitor.driversLicenceCodes = data.vehicleCodes.join(',');
      _scannedVisitor.gatePassStatus = _scanInMode == ScanActionType.checkIn
          ? GatePassStatus.atGate
          : GatePassStatus.inYard;
      _scannedVisitor.gatePassBookingType = GatePassBookingType.visitor;
      _scannedVisitor.professionalDrivingPermitExpiryDate = data.prdpExpiry;
      _scannedVisitor.branchId = branchId;
    }

    return _scannedVisitor;
  }

  Future<GatePassVisitorAccess> processVehicleLicenseData(
      LicenseDiskData data) async {
    // In a real implementation, this would parse the vehicle license data
    // For demonstration, we're creating a sample visitor

    var branchId = currentUser?.userBranches[0].id ?? 0;

    if (_scannedVisitor == null) {
      _scannedVisitor = GatePassVisitorAccess(
        isActive: true,
        branchId: branchId,
        gatePassStatus: _scanInMode == ScanActionType.checkIn
            ? GatePassStatus.atGate
            : GatePassStatus.inYard,
        gatePassBookingType: GatePassBookingType.visitor,
        vehicleEngineNumber: data.engineNumber,
        vehicleMake: data.make,
        vehicleRegNumber: data.licensePlateNo,
        vehicleVinNumber: data.vin,
        vehicleRegisterNumber: data.vehicleRegisterNo,
      );
    } else {
      //Update
      _scannedVisitor.gatePassStatus = _scanInMode == ScanActionType.checkIn
          ? GatePassStatus.atGate
          : GatePassStatus.inYard;
      _scannedVisitor.gatePassBookingType = GatePassBookingType.visitor;
      _scannedVisitor.vehicleEngineNumber = data.engineNumber;
      _scannedVisitor.vehicleMake = data.make;
      _scannedVisitor.vehicleRegNumber = data.licensePlateNo;
      _scannedVisitor.vehicleVinNumber = data.vin;
      _scannedVisitor.vehicleRegisterNumber = data.vehicleRegisterNo;
      _scannedVisitor.branchId = branchId;
    }

    return _scannedVisitor;
  }

  Future<bool> submitVisitorEntry() async {
    if (_scannedVisitor.hasDriverInfo == false &&
        _scannedVisitor.hasVehicleInfo == false) {
      _errorMessage = "No driver or vehicle information found.";
      rebuildUi();
      return false;
    }

    try {
      setBusy(true);

      if (_scanInMode == ScanActionType.checkIn) {
        // Check in visitor
        var response = await _gatePassService.scanVisitorIn(_scannedVisitor);

        return response;
      } else if (_scanInMode == ScanActionType.checkOut) {
        // Check out visitor
        var response = await _gatePassService.scanVisitorOut(_scannedVisitor);

        return response;
      } else if (_scanInMode == ScanActionType.preCheckIn) {
        // Check out visitor
        var response =
            await _gatePassService.findPreBookedVisitor(_scannedVisitor);
        if (response != null) {
          _scannedVisitor = response;

          return true;
        }
        return false;
      }
      return false;
    } catch (e) {
      log.e("Error submitting visitor: ${e.toString()}");
      _errorMessage = e.toString();
      return false;
    } finally {
      EasyLoading.dismiss();
      setBusy(false);
    }
  }

  void resetScanner() {
    _errorMessage = null;
    _isScanning = false;
    setBarcodeScanType(BarcodeScanType.driversCard);
    runStartupLogic(_scanInMode);
  }

  runStartupLogic(ScanActionType data) async {
    var branchId = currentUser?.userBranches[0].id ?? 0;
    setBarcodeScanType(BarcodeScanType.driversCard);
    
    _scanInMode = data;

    _scannedVisitor = GatePassVisitorAccess(
      isActive: true,
      branchId: branchId,
      gatePassStatus: GatePassStatus.atGate,
      gatePassBookingType: GatePassBookingType.visitor,
    );
    if (ScanActionType.preCheckIn == data) {
      _isScanning = true;
      setBarcodeScanType(BarcodeScanType.driversCard);
      await startScanning();
    } else {
      rebuildUi();
    }
  }

  onServiceTypeChanged(int? val) {
    _errorMessage = null;

    _scannedVisitor.serviceTypeId = val;
    rebuildUi();
  }
}
