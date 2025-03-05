// ignore_for_file: prefer_conditional_assignment

import 'dart:async';
import 'dart:math' as math; // Add proper import for math functions
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/enums/barcode_scan_type.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate-pass-access_model.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_access_visitor_model.dart';
import 'package:xstream_gate_pass_app/core/models/scanning/staff_qrcode_model.dart';
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

  bool get hasConnection => _connectionService.hasConnection;
  StreamSubscription<RsaDriversLicense>? streamSubscription;
  StreamSubscription<LicenseDiskData>? streamSubscriptionForDisc;

  //

  // Scanning configuration
  BarcodeScanType _barcodeScanType = BarcodeScanType.driversCard;
  BarcodeScanType get barcodeScanType => _barcodeScanType;

  // Scan mode (in or out)
  bool _scanInMode = true;
  bool get scanInMode => _scanInMode;

  // Scanned data
  GatePassVisitorAccess? _scannedVisitor;
  GatePassVisitorAccess? get scannedVisitor => _scannedVisitor;

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
    _scanningService.onExit(); // Properly disable scanner when done
    super.dispose();
  }

  void setBarcodeScanType(BarcodeScanType type) {
    _barcodeScanType = type;
    _scanningService.setBarcodeScanType(type);
    rebuildUi();
  }

  void setScanInMode(bool inMode) {
    _scanInMode = inMode;
    rebuildUi();
  }

  Future<void> startScanListener() async {
    // Cancel any existing subscription
    streamSubscription?.cancel();
    streamSubscriptionForDisc?.cancel();

    // Also listen to license disk data for vehicle scans
    streamSubscription = _scanningService.licenseStream.asBroadcastStream().listen((data) async {
      log.i("Drivers Card data received");
      // Process the driversCard  data here
      // This would populate a GatePassVisitorAccess from the driversCard data
      processScanData(data, null);
    });
    // Also listen to license disk data for vehicle scans
    streamSubscriptionForDisc = _scanningService.licenseDiskDataStream.asBroadcastStream().listen((licenseDiskData) async {
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

    _isScanning = true;
    _errorMessage = null;
    _scannedVisitor = null;
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

  Future<void> processScanData(RsaDriversLicense? rsaDriversLicense, LicenseDiskData? vehicleLicenseData) async {
    _isScanning = false;

    try {
      // Process the scanned data based on scan type
      if (_barcodeScanType == BarcodeScanType.driversCard && rsaDriversLicense != null) {
        // Process driver's license data
        _scannedVisitor = await processDriversLicenseData(rsaDriversLicense);
      } else if (_barcodeScanType == BarcodeScanType.vehicleDisc && vehicleLicenseData != null) {
        // Process vehicle license data
        _scannedVisitor = await processVehicleLicenseData(vehicleLicenseData);
      }

      rebuildUi();
    } catch (e) {
      _errorMessage = "Failed to process scan data: ${e.toString()}";
      rebuildUi();
    }
  }

  Future<GatePassVisitorAccess> processDriversLicenseData(RsaDriversLicense data) async {
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
        gatePassStatus: scanInMode ? GatePassStatus.atGate : GatePassStatus.inYard,
        gatePassBookingType: GatePassBookingType.visitor,
        professionalDrivingPermitExpiryDate: data.prdpExpiry,
      );
    } else {
      _scannedVisitor!.driverName = '${data.firstNames} ${data.surname}';
      _scannedVisitor!.driverIdNo = data.idNumber;
      _scannedVisitor!.driverLicenceNo = data.licenseNumber;
      _scannedVisitor!.driverLicenceIssueDate = data.issueDates?.firstOrNull;
      _scannedVisitor!.driverLicenceExpiryDate = data.validTo;
      _scannedVisitor!.driversLicenceCodes = data.vehicleCodes.join(',');
      _scannedVisitor!.gatePassStatus = scanInMode ? GatePassStatus.atGate : GatePassStatus.inYard;
      _scannedVisitor!.gatePassBookingType = GatePassBookingType.visitor;
      _scannedVisitor!.professionalDrivingPermitExpiryDate = data.prdpExpiry;
    }

    return _scannedVisitor!;
  }

  Future<GatePassVisitorAccess> processVehicleLicenseData(LicenseDiskData data) async {
    // In a real implementation, this would parse the vehicle license data
    // For demonstration, we're creating a sample visitor

    var branchId = currentUser?.userBranches[0].id ?? 0;

    if (_scannedVisitor == null) {
      _scannedVisitor = GatePassVisitorAccess(
        isActive: true,
        branchId: branchId,
        gatePassStatus: scanInMode ? GatePassStatus.atGate : GatePassStatus.inYard,
        gatePassBookingType: GatePassBookingType.visitor,
        vehicleEngineNumber: data.engineNumber,
        vehicleMake: data.make,
        vehicleRegNumber: data.licensePlateNo,
        vehicleVinNumber: data.vin,
        vehicleRegisterNumber: data.vehicleRegisterNo,
      );
    } else {
      //Update
      _scannedVisitor!.gatePassStatus = scanInMode ? GatePassStatus.atGate : GatePassStatus.inYard;
      _scannedVisitor!.gatePassBookingType = GatePassBookingType.visitor;
      _scannedVisitor!.vehicleEngineNumber = data.engineNumber;
      _scannedVisitor!.vehicleMake = data.make;
      _scannedVisitor!.vehicleRegNumber = data.licensePlateNo;
      _scannedVisitor!.vehicleVinNumber = data.vin;
      _scannedVisitor!.vehicleRegisterNumber = data.vehicleRegisterNo;
    }

    return _scannedVisitor!;
  }

  Future<bool> submitVisitorEntry() async {
    if (_scannedVisitor == null) return false;

    try {
      setBusy(true);

      var branchId = currentUser?.userBranches[0].id ?? 0;
      var code = _scannedVisitor!.driverLicenceNo ?? "";

      if (_scanInMode) {
        // Check in visitor
        var response = await _gatePassService.scanStaffIn(StaffQrCodeModel(code: code, branchId: branchId));

        return response != null;
      } else {
        // Check out visitor
        var response = await _gatePassService.scanStaffOut(StaffQrCodeModel(code: code, branchId: branchId));

        return response != null;
      }
    } catch (e) {
      log.e("Error submitting visitor: ${e.toString()}");
      _errorMessage = e.toString();
      return false;
    } finally {
      setBusy(false);
    }
  }

  void resetScanner() {
    _scannedVisitor = null;
    _errorMessage = null;
    _isScanning = false;
    rebuildUi();
  }
}
