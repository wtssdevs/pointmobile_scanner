import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.dialogs.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';
import 'package:xstream_gate_pass_app/core/models/ops/checklists/check_list_find_template_model.dart';
import 'package:xstream_gate_pass_app/core/models/shared/filter_params_model.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/Incidents/incident_manager_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/checklists/check_list_service_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_driver_temp_license.dart';
import 'package:xstream_gate_pass_app/core/services/shared/guid_generator.dart';
import 'package:xstream_gate_pass_app/core/utils/validation_messages.dart';
import 'package:xstream_gate_pass_app/core/enums/barcode_scan_type.dart';
import 'package:xstream_gate_pass_app/core/enums/basic_dialog_status.dart';
import 'package:xstream_gate_pass_app/core/enums/bckground_job_type.dart';
import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/core/enums/filestore_type.dart';
import 'package:xstream_gate_pass_app/core/models/background_job_que/background_job_Info.dart';
import 'package:xstream_gate_pass_app/core/models/basefiles/containers/container_info_extratced_model.dart';
import 'package:xstream_gate_pass_app/core/models/basefiles/filestore/filestore.dart';
import 'package:xstream_gate_pass_app/core/models/ops/gatepass/gate-pass-access_model.dart';
import 'package:xstream_gate_pass_app/core/models/ops/incidents/incident_model.dart';
import 'package:xstream_gate_pass_app/core/models/shared/base_lookup.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/filestore/filestore_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/masterfiles/masterfiles_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/gatepass/gatepass_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/scan_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_drivers_license.dart';
import 'package:xstream_gate_pass_app/core/services/services/scanning/zar_license_disk.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/media_service.dart';
import 'package:xstream_gate_pass_app/ui/views/shared/base_form_view_model.dart';
import 'package:xstream_gate_pass_app/ui/views/shared/localization/app_view_base_helper.dart';
import 'package:xstream_gate_pass_app/core/utils/app_permissions.dart';

class GatePassEditViewModel extends BaseFormViewModel with AppViewBaseHelper {
  GatePassEditViewModel(this._gatePass);
  GatePassAccess _gatePass;
  GatePassAccess get gatePass => _gatePass;
  Function? _onModelSet;

  final log = getLogger('GatePassEditViewModel');
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();
  final GatePassService _gatePassService = locator<GatePassService>();
  final _navigationService = locator<NavigationService>();
  final _dialogService = locator<DialogService>();
  final _scanningService = locator<ScanningService>();
  final _fileStoreRepository = locator<FileStoreRepository>();
  final _mediaService = locator<MediaService>();
  final _workerQueManager = locator<WorkerQueManager>();
  final _connectionService = locator<ConnectionService>();
  final _masterFilesService = locator<MasterFilesService>();
  //IncidentManagerService
  final _incidentManagerService = locator<IncidentManagerService>();
  final _checkListService = locator<CheckListServiceService>();
  final ScrollController scrollController = ScrollController();

  static List<BaseLookup>? _cachedTransporters;
  static DateTime? _transporterCacheTime;
  static const Duration _cacheExpiry = Duration(hours: 1);
  List<BaseLookup> _transporters = <BaseLookup>[];
  List<BaseLookup> get transporters => _transporters;

  bool _showVehicleManualInput = false;
  bool get showVehicleManualInput => _showVehicleManualInput;

  bool _showTrailerOneManualInput = false;
  bool get showTrailerOneManualInput => _showTrailerOneManualInput;

  bool _showTrailerTwoManualInput = false;
  bool get showTrailerTwoManualInput => _showTrailerTwoManualInput;

  FileStore? _vehicleManualPhotoPath;
  FileStore? get vehicleManualPhotoPath => _vehicleManualPhotoPath;

  FileStore? _trailerOneManualPhotoPath;
  FileStore? get trailerOneManualPhotoPath => _trailerOneManualPhotoPath;

  FileStore? _trailerTwoManualPhotoPath;
  FileStore? get trailerTwoManualPhotoPath => _trailerTwoManualPhotoPath;

  bool get isManualInput =>
      gatePass.externalId == null || gatePass.externalId!.isEmpty;
  bool get hasPreBooking => !isManualInput;

  bool get hasVehicleManualInputPermission {
    return hasPermission(
        AppPermissions.mobileOperationsAllowVehicleManualInput);
  }

  bool get hasTrailerManualInputPermission {
    return hasPermission(
        AppPermissions.mobileOperationsAllowTrailerManualInput);
  }

  bool get hasTrailerOverridePermission {
    return hasPermission(AppPermissions.mobileOperationsAllowTrailerOverride);
  }

  bool get shouldShowLogisticsActive {
    if (!isManualInput) return false;

    return gatePass.hasDriverInfo && gatePass.transporterId == null;
  }

  bool get logisticsInfoComplete => gatePass.transporterId != null;
  bool _sameReg(String? a, String? b) {
    if (a == null || b == null) return false;
    return a.replaceAll(' ', '').toUpperCase() ==
        b.replaceAll(' ', '').toUpperCase();
  }

  bool get shouldShowContainerActive {
    if (!isManualInput ||
        gatePass.gatePassBookingType != GatePassBookingType.containers) {
      return false;
    }
    return logisticsInfoComplete && !containerInfoComplete;
  }

  bool get containerInfoComplete =>
      gatePass.gatePassBookingType == GatePassBookingType.containers &&
      gatePass.containerNumber != null &&
      gatePass.containerNumber!.isNotEmpty &&
      gatePass.containerDeliveryType != null &&
      gatePass.gatePassContainerType != null &&
      gatePass.containerShippingLine != null;

// Driver information section
  final GlobalKey driverInfoCardKey = GlobalKey(debugLabel: 'driverInfoCard');
  final GlobalKey vehicleInfoCardKey = GlobalKey(debugLabel: 'vehicleInfoCard');
  final GlobalKey trailerOneInfoCardKey =
      GlobalKey(debugLabel: 'trailerOneInfoCard');
  final GlobalKey trailerTwoInfoCardKey =
      GlobalKey(debugLabel: 'trailerTwoInfoCard');

// Container information section
  final GlobalKey containerInfoCardKey =
      GlobalKey(debugLabel: 'containerInfoCard');
  final GlobalKey timesInfoCardKey = GlobalKey(debugLabel: 'timesInfoCard');

  StreamSubscription<RsaDriversLicense>? streamSubscription;
  StreamSubscription<LicenseDiskData>? streamSubscriptionForDisc;
  List<FileStore> _fileStoreItems = <FileStore>[];
  List<FileStore> get fileStoreItems => _fileStoreItems;

  static List<BaseLookup>? _cachedShippingLines;
  static DateTime? _shippingLineCacheTime;
  List<BaseLookup> _shippingLines = <BaseLookup>[];
  List<BaseLookup> get shippingLines => _shippingLines;

  static List<BaseLookup>? _cachedContainerCustomers;
  static DateTime? _containerCustomerCacheTime;
  List<BaseLookup> _containerCustomers = <BaseLookup>[];
  List<BaseLookup> get containerCustomers => _containerCustomers;

  static List<BaseLookup>? _cachedContainerDepots;
  static DateTime? _containerDepotCacheTime;
  List<BaseLookup> _containerDepots = <BaseLookup>[];
  List<BaseLookup> get containerDepots => _containerDepots;

  // Foreign license photo state
  bool _foreignLicensePhotoTaken = false;
  bool get foreignLicensePhotoTaken => _foreignLicensePhotoTaken;

  FileStore? _foreignLicensePhotoPath;
  FileStore? get foreignLicensePhotoPath => _foreignLicensePhotoPath;

  bool get hasConnection => _connectionService.hasConnection;
  List<SearchableDropdownMenuItem<int>> get serviceTypes =>
      _masterFilesService.serviceTypes;

  BarcodeScanType _barcodeScanType = BarcodeScanType.driversCard;
  BarcodeScanType get barcodeScanType => _barcodeScanType;
  void setBarcodeScanType(BarcodeScanType type) {
    _barcodeScanType = type;
    _scanningService.setBarcodeScanType(type);
    rebuildUi();
  }

  // Manual entry tracking
  bool _vehicleManualEntryUsed = false;
  bool _vehicleManualPhotoTaken = false;
  bool get vehicleManualEntryUsed => _vehicleManualEntryUsed;
  bool get vehicleManualPhotoTaken => _vehicleManualPhotoTaken;

  bool _trailerOneManualEntryUsed = false;
  bool _trailerOneManualPhotoTaken = false;
  bool get trailerOneManualEntryUsed => _trailerOneManualEntryUsed;
  bool get trailerOneManualPhotoTaken => _trailerOneManualPhotoTaken;

  bool _trailerTwoManualEntryUsed = false;
  bool _trailerTwoManualPhotoTaken = false;
  bool get trailerTwoManualEntryUsed => _trailerTwoManualEntryUsed;
  bool get trailerTwoManualPhotoTaken => _trailerTwoManualPhotoTaken;

  List<BaseLookup> _customers = <BaseLookup>[];
  List<BaseLookup> get customers => _customers;
  Future<void> initialize() async {
    // Initialize scanner with the selected barcode type
    _scanningService.initialise(barcodeScanType: _barcodeScanType);
    await startScanListener();
  }

  Future<void> dispose() async {
    streamSubscription?.cancel();
    streamSubscriptionForDisc?.cancel();
    //  _scanningService.onExit(); // Properly disable scanner when done

    //super.dispose();
  }

  Future<void> onDispose() async {
    await dispose();
  }

  void scrollToWidget(GlobalKey key, {Duration duration = const Duration(milliseconds: 400)}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: duration,
          curve: Curves.easeIn,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
        );
      }
    });
  }

// Scroll to driver and vehicle info section
  void scrollToDriverInfo() {
    scrollToWidget(driverInfoCardKey);
  }

  void scrollToVehicleInfoCardKey() {
    scrollToWidget(vehicleInfoCardKey);
  }

// Scroll to container info
  void scrollToContainerInfo() {
    scrollToWidget(containerInfoCardKey);
  }

// Example of scrolling to a section based on validation errors
  void scrollToFirstError() {
    scrollController.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
  }

  Future<void> runStartupLogic() async {
  if (gatePass.gatePassBookingType == GatePassBookingType.containers) {
    await loadShippingLines();
    await loadContainerCustomers();
    await loadContainerDepots();
  }

  if (gatePass.gatePassBookingType == GatePassBookingType.containers &&
      gatePass.id != null && 
      gatePass.id.isNotEmpty &&
      (gatePass.containers == null || gatePass.containers!.isEmpty)) {
    await reloadGatePassWithContainers();
  }
  
  if (gatePass.gatePassBookingType == GatePassBookingType.containers &&
      gatePass.containerNumber == null &&
      gatePass.containers != null &&
      gatePass.containers!.isNotEmpty) {
    loadContainerDetailsFromArray();
  }
  
  await loadFileStoreImages();
  
  if (isManualInput) {
    loadTransporters();
    loadCustomers();
  }
  
  notifyListeners();
  
  //_customers = await _masterFilesService.getAllLocalDetainOptions("");

  //setCustomValidations();
  if (gatePass.driverHasForeignID == true) {
    setBarcodeScanType(BarcodeScanType.vehicleDisc);
  } else {
    setBarcodeScanType(BarcodeScanType.driversCard);
  }

  await initialize();
}

  void toggleVehicleManualInput() {
    _showVehicleManualInput = !_showVehicleManualInput;
    rebuildUi();
  }

  void toggleTrailerOneManualInput() {
    _showTrailerOneManualInput = !_showTrailerOneManualInput;
    rebuildUi();
  }

  void toggleTrailerTwoManualInput() {
    _showTrailerTwoManualInput = !_showTrailerTwoManualInput;
    rebuildUi();
  }
//_checkListService

  Future<bool> findChecklistTemplate({bool isReject = false}) async {
    late final ChecklistType checklistType;
    late final DeliveryType deliveryType;
    late final GatePassBookingType bookingType;

    if (isReject) {
      checklistType = ChecklistType.reject;
      deliveryType = gatePass.gatePassDeliveryType;
      bookingType = gatePass.gatePassBookingType;
    } else {
      deliveryType = gatePass.gatePassDeliveryType;
      bookingType = gatePass.gatePassBookingType;

      final resolveResult = await _checkListService.resolveChecklistType(
        gatePass.gatePassStatus.name.capitalize(),
      );

      if (resolveResult == null ||
          resolveResult.checklistType == null ||
          resolveResult.deliveryType == null) {
        log.e(
            'Checklist type resolution failed for status: ${gatePass.gatePassStatus}');
        return false;
      }

      checklistType = ChecklistType.values.firstWhere(
        (e) => e.value == int.tryParse(resolveResult.checklistType ?? ''),
        orElse: () {
          log.e('Unknown checklistType: ${resolveResult.checklistType}');
          return ChecklistType.gatePassAccess;
        },
      );
    }

    final checkListFindTemplateModel =
        await _checkListService.findChecklistTemplate(
      FilterParams(
        branchId: currentUser?.userBranches.first.id,
        gateAccessBookingType: bookingType,
        gatePassAccessId: gatePass.id,
        gateAccessDeliveryType: deliveryType,
        checklistType: checklistType,
      ),
    );

    if (checkListFindTemplateModel.hasTemplate == true) {
      if (checkListFindTemplateModel.isCompleted == true) {
        return true;
      }

      return await gotoCheckListView(checkListFindTemplateModel,
          isReject: isReject);
    }
    return true;
  }

  Future<bool> gotoCheckListView(
      CheckListFindTemplateModel checkListFindTemplateModel,
      {bool isReject = false}) async {
    late final ChecklistType checklistType;
    late final DeliveryType deliveryType;
    late final GatePassBookingType bookingType;

    if (isReject) {
      checklistType = ChecklistType.reject;
      deliveryType = gatePass.gatePassDeliveryType;
      bookingType = gatePass.gatePassBookingType;
    } else {
      deliveryType = gatePass.gatePassDeliveryType;
      bookingType = gatePass.gatePassBookingType;

      final resolveResult = await _checkListService.resolveChecklistType(
        gatePass.gatePassStatus.name.capitalize(),
      );

      if (resolveResult == null ||
          resolveResult.checklistType == null ||
          resolveResult.deliveryType == null) {
        log.e(
            'Checklist type resolution failed in gotoCheckListView for status: ${gatePass.gatePassStatus}');
        return false;
      }

      checklistType = ChecklistType.values.firstWhere(
        (e) => e.value == int.tryParse(resolveResult.checklistType ?? ''),
        orElse: () {
          log.e('Unknown checklistType: ${resolveResult.checklistType}');
          return ChecklistType.gatePassAccess;
        },
      );
    }

    final currentChecklistId = checkListFindTemplateModel.checklistId;

    final completed = await _navigationService.navigateTo(
      Routes.checkListView,
      arguments: CheckListViewArguments(
        filterParams: FilterParams(
          branchId: currentUser?.userBranches.first.id,
          gateAccessBookingType: bookingType,
          gatePassAccessId: gatePass.id,
          gateAccessDeliveryType: deliveryType,
          checklistType: checklistType,
          templateId: checkListFindTemplateModel.templateId,
          id: currentChecklistId,
        ),
      ),
    );

    return completed == true;
  }

  Future<void> startScanListener() async {
    setModelUpdate(_gatePass);

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
      log.i("Vehicle Lisence Plate data received");
      // Process the license disk data here
      // This would populate a GatePassVisitorAccess from the license disk data
      processScanData(null, licenseDiskData);
    });
  }

  void setDriverValidationMessage() {
    if (isManualInput) {
      clearValidationMessage("Driver details do not match");
      return;
    }
    var msg = ValidationMessages.getDriverIdMismatchMessage(
        gatePass.driverIdNo, gatePass.driverIdNoValidation);
    if (gatePass.driverIdNoMatch == false) {
      setValidationMessage(msg);
      //enque incident
      logIncident(msg);
    } else {
      clearValidationMessage(msg);
    }
  }

  void setVehicleValidationMessage() {
    if (isManualInput) {
      if (gatePass.transporterId == null) {
        setValidationMessage("Transporter is required for manual entries");
      } else {
        clearValidationMessage("Transporter is required for manual entries");
      }
      clearValidationMessage("Vehicle details do not match");
      return;
    }

    var msg = ValidationMessages.regNoMismatch("Vehicle registration",
        gatePass.vehicleRegNumber, gatePass.vehicleRegNumberValidation);
    if (gatePass.vehicleRegNoMatch == false) {
      setValidationMessage(msg);
      if (hasVehicleManualInputPermission) {
        _showVehicleManualInput = true;
        scrollToVehicleInfoCardKey();
      }
      logIncident(msg);
    } else {
      clearValidationMessage(msg);
    }
  }

  //trailers one and two validation
  void setTrailerValidationMessage(String trailerNumber) {
    if (trailerNumber == "One") {
      if (isManualInput) {
        clearValidationMessage("Trailer one details do not match");
        return;
      }
      var msg = ValidationMessages.regNoMismatch("Trailer One registration",
          gatePass.trailerRegNumberOne, gatePass.trailerRegNumberOneValidation);
      if (gatePass.trailerRegNumberOneMatch == false) {
        setValidationMessage(msg);
        if (hasTrailerManualInputPermission) {
          _showTrailerOneManualInput = true;
          scrollToWidget(trailerOneInfoCardKey);
        }
        logIncident(msg);
      } else {
        clearValidationMessage(msg);
      }
    } else {
      var msg = ValidationMessages.regNoMismatch(
        "Trailer Two registration",
        gatePass.trailerRegNumberTwo,
        gatePass.trailerRegNumberTwoValidation,
      );
      if (gatePass.trailerRegNumberTwoMatch == false) {
        setValidationMessage(msg);
        if (hasTrailerManualInputPermission) {
          _showTrailerTwoManualInput = true;
          scrollToWidget(trailerTwoInfoCardKey);
        }
        logIncident(msg);
      } else {
        clearValidationMessage(msg);
      }
    }
  }

  // Future<void> processScanData(RsaDriversLicense? rsaDriversLicense, LicenseDiskData? vehicleLicenseData) async {
  //   //_isScanning = false;
  //   clearAllValidationMessage();
  //   try {
  //     // Process the scanned data based on scan type
  //     if (_barcodeScanType == BarcodeScanType.driversCard && rsaDriversLicense != null) {
  //       // Process driver's license data

  //       gatePass.driverName = '${rsaDriversLicense.firstNames} ${rsaDriversLicense.surname}';
  //       //gatePass.driverIdNo = rsaDriversLicense.idNumber;
  //       gatePass.driverIdNoValidation = rsaDriversLicense.idNumber;

  //       setDriverValidationMessage();

  //       gatePass.driverLicenceNo = rsaDriversLicense.licenseNumber;
  //       gatePass.driverLicenceIssueDate = rsaDriversLicense.issueDates?.firstOrNull;
  //       gatePass.driverLicenceExpiryDate = rsaDriversLicense.validTo;
  //       gatePass.driversLicenceCodes = rsaDriversLicense.vehicleCodes.join(',');
  //       gatePass.professionalDrivingPermitExpiryDate = rsaDriversLicense.prdpExpiry;

  //       setBarcodeScanType(BarcodeScanType.vehicleDisc);
  //       if (showValidation) {
  //         scrollToFirstError();
  //       } else {
  //         scrollToVehicleInfoCardKey();
  //       }
  //     } else if (_barcodeScanType == BarcodeScanType.vehicleDisc && vehicleLicenseData != null) {
  //       // Process vehicle license data

  //       gatePass.vehicleEngineNumber = vehicleLicenseData.engineNumber;
  //       gatePass.vehicleMake = vehicleLicenseData.make;
  //       //gatePass.vehicleRegNumber = vehicleLicenseData.licensePlateNo;
  //       gatePass.vehicleRegNumberValidation = vehicleLicenseData.licensePlateNo;

  //       setVehicleValidationMessage();
  //       gatePass.vehicleVinNumber = vehicleLicenseData.vin;
  //       gatePass.vehicleRegisterNumber = vehicleLicenseData.vehicleRegisterNo;
  //       if (showValidation) {
  //         scrollToFirstError();
  //       }
  //     }
  //     setModelUpdate(_gatePass);
  //     rebuildUi();
  //   } catch (e) {
  //     setValidationMessage("Failed to process scan data: ${e.toString()}");
  //     rebuildUi();
  //   }
  // }

  Future<void> processScanData(RsaDriversLicense? rsaDriversLicense,
      LicenseDiskData? vehicleLicenseData) async {
    clearAllValidationMessage();
    try {
      // Route processing based on the current barcode scan type
      switch (_barcodeScanType) {
        case BarcodeScanType.driversCard:
          if (rsaDriversLicense != null) {
            await processDriversLicenseData(rsaDriversLicense);
          }
          break;

        case BarcodeScanType.vehicleDisc:
          if (vehicleLicenseData != null) {
            await processVehicleLicenseData(vehicleLicenseData);
          }
          break;

        case BarcodeScanType.trailerOneDisc:
          if (vehicleLicenseData != null) {
            await processTrailerOneLicenseData(vehicleLicenseData);
          }
          break;

        case BarcodeScanType.trailerTwoDisc:
          if (vehicleLicenseData != null) {
            await processTrailerTwoLicenseData(vehicleLicenseData);
          }
          break;

        default:
          // Handle other barcode types if needed
          break;
      }

      setModelUpdate(_gatePass);
      rebuildUi();
    } catch (e) {
      setValidationMessage(ValidationMessages.scanProcessingFailed(e.toString()));
      rebuildUi();
    }
  }

  // Process driver's license data
  Future<void> processDriversLicenseData(RsaDriversLicense driversLicense) async {
    gatePass.driverName ='${driversLicense.firstNames} ${driversLicense.surname}';
    gatePass.driverIdNoValidation = driversLicense.idNumber;
    if (isManualInput) {gatePass.driverIdNo = driversLicense.idNumber;}
    setDriverValidationMessage();

    gatePass.driverLicenceNo = driversLicense.licenseNumber;
    gatePass.driverLicenceIssueDate = driversLicense.issueDates?.firstOrNull;
    gatePass.driverLicenceExpiryDate = driversLicense.validTo;
    gatePass.driversLicenceCodes = driversLicense.vehicleCodes.join(',');
    gatePass.professionalDrivingPermitExpiryDate = driversLicense.prdpExpiry;

    //check if the drivers license has expired ,if true then we log an incident
    if (driversLicense.validTo != null &&
        driversLicense.validTo.isBefore(DateTime.now())) {
      logIncident(
          "Driver (${driversLicense.firstNames} ${driversLicense.surname}, ${driversLicense.idNumber}) with license (${driversLicense.licenseNumber}) expired on ${driversLicense.validTo}. Please check the driver's license validity. ");
    }
    if (driversLicense.prdpExpiry != null &&
        driversLicense.prdpExpiry!.isBefore(DateTime.now())) {
      logIncident(
          "Driver (${driversLicense.firstNames} ${driversLicense.surname}, ${driversLicense.idNumber}) with PRDP expired on ${driversLicense.prdpExpiry}. Please check the driver's PRDP validity. ");
    }
    // Navigate to appropriate section
    if (showValidation) {
      scrollToFirstError();
    } else {
      // Move to vehicle disc scanning
      setBarcodeScanType(BarcodeScanType.vehicleDisc);
      scrollToVehicleInfoCardKey();
    }
  }

  // Process vehicle license data
  Future<void> processVehicleLicenseData(
      LicenseDiskData vehicleLicenseData) async {
    gatePass.vehicleEngineNumber = vehicleLicenseData.engineNumber;
    gatePass.vehicleMake = vehicleLicenseData.make;
    gatePass.vehicleRegNumberValidation = vehicleLicenseData.licensePlateNo;
    if (isManualInput) {
      gatePass.vehicleRegNumber = vehicleLicenseData.licensePlateNo;
    }
    setVehicleValidationMessage();
    gatePass.vehicleVinNumber = vehicleLicenseData.vin;
    gatePass.vehicleRegisterNumber = vehicleLicenseData.vehicleRegisterNo;

    if (vehicleLicenseData.expiryDate != null &&
        vehicleLicenseData.expiryDate!.isBefore(DateTime.now())) {
      logIncident(
          "Vehicle (${vehicleLicenseData.make}, ${vehicleLicenseData.licensePlateNo}) expired on ${vehicleLicenseData.expiryDate}. Please check the vehicle's license validity. ");
    }
    // Determine next scan target based on trailer existence
    BarcodeScanType nextScanType = BarcodeScanType.vehicleDisc; // Default
    GlobalKey? nextSection;

    if (gatePass.trailerRegNumberOne != null &&
        gatePass.trailerRegNumberOne!.isNotEmpty) {
      nextScanType = BarcodeScanType.trailerOneDisc;
      nextSection = trailerOneInfoCardKey;
    } else if (gatePass.trailerRegNumberTwo != null &&
        gatePass.trailerRegNumberTwo!.isNotEmpty) {
      nextScanType = BarcodeScanType.trailerTwoDisc;
      nextSection = trailerTwoInfoCardKey;
    } else if (gatePass.gatePassBookingType == GatePassBookingType.containers) {
      nextSection = containerInfoCardKey;
    }

    // Set next scan type and scroll to appropriate section
    setBarcodeScanType(nextScanType);

    if (showValidation) {
      scrollToFirstError();
    } else if (nextSection != null) {
      scrollToWidget(nextSection);
    }
  }

  // Process trailer one license data
  Future<void> processTrailerOneLicenseData(
      LicenseDiskData vehicleLicenseData) async {
    gatePass.trailerRegNumberOneValidation = vehicleLicenseData.licensePlateNo;

    // Check if trailer one reg matches scanned data

    // Set validation message
    setTrailerValidationMessage("One");
    if (vehicleLicenseData.expiryDate != null &&
        vehicleLicenseData.expiryDate!.isBefore(DateTime.now())) {
      logIncident(
          "Trailer One (${vehicleLicenseData.make}, ${vehicleLicenseData.licensePlateNo}) expired on ${vehicleLicenseData.expiryDate}. Please check the vehicle's license validity. ");
    }

    if (gatePass.trailerRegNumberOneMatch == false &&
        hasTrailerManualInputPermission) {
      _showTrailerOneManualInput = true;
      scrollToWidget(trailerOneInfoCardKey);
      return;
    }
    // Determine next scan target
    BarcodeScanType nextScanType = BarcodeScanType.trailerOneDisc; // Default
    GlobalKey? nextSection;

    if (gatePass.trailerRegNumberTwo != null &&
        gatePass.trailerRegNumberTwo!.isNotEmpty) {
      nextScanType = BarcodeScanType.trailerTwoDisc;
      nextSection = trailerTwoInfoCardKey;
    } else if (gatePass.gatePassBookingType == GatePassBookingType.containers) {
      nextSection = containerInfoCardKey;
    }

    // Set next scan type and scroll to appropriate section
    setBarcodeScanType(nextScanType);

    if (showValidation) {
      rebuildUi();
      scrollToFirstError();
    } else if (nextSection != null) {
      scrollToWidget(nextSection);
    }
  }

  // Process trailer two license data
  Future<void> processTrailerTwoLicenseData(
      LicenseDiskData vehicleLicenseData) async {
    gatePass.trailerRegNumberTwoValidation = vehicleLicenseData.licensePlateNo;

    // Check if trailer two reg matches scanned data
    // Set validation message
    setTrailerValidationMessage("Two");

    if (vehicleLicenseData.expiryDate != null &&
        vehicleLicenseData.expiryDate!.isBefore(DateTime.now())) {
      logIncident(
          "Trailer Two (${vehicleLicenseData.make}, ${vehicleLicenseData.licensePlateNo}) expired on ${vehicleLicenseData.expiryDate}. Please check the vehicle's license validity. ");
    }

    if (gatePass.trailerRegNumberTwoMatch == false &&
        hasTrailerManualInputPermission) {
      _showTrailerTwoManualInput = true;
      scrollToWidget(trailerTwoInfoCardKey);
      return;
    }

    if (showValidation) {
      rebuildUi();
      scrollToFirstError();
    }
    // After trailer two, move to container info if applicable
    if (gatePass.gatePassBookingType == GatePassBookingType.containers) {
      scrollToContainerInfo();
    } else {
      //go back to top
      scrollToFirstError();
    }
  }

  handleBackButton() async {
    _navigationService.back();
  }

  setCustomValidations() {
    if (gatePass.customerId == null || gatePass.customerId == 0) {
      setValidationMessage(ValidationMessages.customerRequired);
    } else {
      clearValidationMessage(ValidationMessages.customerRequired);
    }
  }

  listenToModelSet(Function onModelSet) {
    _onModelSet = onModelSet;
  }

  setModelUpdate(GatePassAccess entity) {
    _onModelSet?.call(entity);
    notifyListeners();
  }

  void setModeldata(GatePassAccess updatedData) {
    _gatePass = updatedData;

    //updateHasEdit(true);
    notifyListeners();
  }

  void onFilterValueChanged(String value) {}

  Future<void> save() async {
    if (!_connectionService.hasConnection) {
      //internet Message
      return;
    }

    notifyListeners();
  }

  Future<void> getStoragePermissions() async {
    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }
    var mediaLibraryStatus = await Permission.mediaLibrary.status;
    if (!mediaLibraryStatus.isGranted) {
      await Permission.mediaLibrary.request();
    }
    var camStatus = await Permission.camera.status;
    if (!camStatus.isGranted) {
      await Permission.camera.request();
    }
  }

  void setDocRecievedChange(bool? val) {
    if (val != null) {
      //gatePass.gatePassQuestions?.hasDeliveryDocuments = val;
      notifyListeners();
    }
  }

  void modelNotifyListeners() {
    notifyListeners();
  }

  Future<void> saveOnly() async {
    if (!_connectionService.hasConnection) {
      await _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        data: BasicDialogStatus.warning,
        title: "Internet Connection Failure",
        description: 'Could not Save,Please check you internet connection and try again',
        mainButtonTitle: "Ok",
      );
    }

    if (gatePass.gatePassBookingType == GatePassBookingType.containers) {
      if (gatePass.containerId == null || gatePass.containerId!.isEmpty) {
        gatePass.containerId = Guid.newGuidAsString;
      }

      gatePass.handleContainers();
    }

    //here we save back to server
    GatePassAccess? reponse;
    if (gatePass.id == 0) {
      reponse = await _gatePassService.create(gatePass);
    } else {
      reponse = await _gatePassService.update(gatePass);
    }

    if (reponse != null) {
      _gatePass = reponse;
      Fluttertoast.showToast(
          msg: "Save was successful! ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14.0);
    } else {
      //error could not save
      Fluttertoast.showToast(
          msg: "Save Failed!,Please try again or contact your system admin. ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0);
    }

    //update Screen UI state with model changes
    setModelUpdate(_gatePass);
    notifyListeners();
  }

  Future<void> authorizeEntry() async {
    if (!_connectionService.hasConnection) {
      var confirm = await _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        data: BasicDialogStatus.warning,
        title: "Internet Connection Failure",
        description: 'Could not authorize for entry,Please check you internet connection and try again',
        mainButtonTitle: "Ok",
      );

      return;
    }
    setBusy(true);

    // For manual entries
    if (isManualInput) {
      if (gatePass.driverIdNo == null &&
          gatePass.driverIdNoValidation != null) {
        gatePass.driverIdNo = gatePass.driverIdNoValidation;
      }
      if (gatePass.vehicleRegNumber == null &&
          gatePass.vehicleRegNumberValidation != null) {
        gatePass.vehicleRegNumber = gatePass.vehicleRegNumberValidation;
      }

      // Create the gatepass first if it's a new manual entry
      if (gatePass.id == Guid.defaultValue.toString() || gatePass.id.isEmpty) {
        log.i('Creating new manual gate pass before authorization');

        gatePass.id = Guid.newGuidAsString;
        gatePass.isActive = true;
        gatePass.canRelease = false;
        gatePass.timeAtGate = DateTime.now();
        gatePass.isManualInput = true;
        gatePass.isHazardous = false;
        gatePass.hasBeenPrinted = false;
        gatePass.timeInYardDuration = 0;
        gatePass.isOverride ??= false;
        gatePass.isVehicleManualInput ??= false;
        gatePass.isTrailerOneManualInput ??= false;
        gatePass.isTrailerTwoManualInput ??= false;
        gatePass.isTrailerOneOverride ??= false;
        gatePass.isTrailerTwoOverride ??= false;
        gatePass.driverHasForeignID ??= false;
        gatePass.grossWeightIn ??= 0;
        gatePass.grossWeightOut ??= 0;
        gatePass.tareWeightIn ??= 0;
        gatePass.tareWeightOut ??= 0;
        gatePass.netWeightIn ??= 0;
        gatePass.netWeightOut ??= 0;
        gatePass.varianceIn ??= 0;
        gatePass.varianceOut ??= 0;
        gatePass.productVariance ??= 0;
        gatePass.totalProductGrossWeight ??= 0;
        gatePass.vehicleTare ??= 0;

        if (gatePass.gatePassBookingType == GatePassBookingType.containers) {
          gatePass.containerId =
              "00000000-0000-0000-0000-000000000000"; 
          gatePass.handleContainers();

          if (gatePass.containers != null && gatePass.containers!.isNotEmpty) {
           }
        }

        var createdGatePass = await _gatePassService.createGatePass(gatePass);

        if (createdGatePass == null) {
          Fluttertoast.showToast(
              msg: "Failed to create gate pass. Please try again.",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM_LEFT,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 14.0);
          setBusy(false);
          return;
        }

        _gatePass = createdGatePass;
      }
    }
    gatePass.timeInYardDuration ??= 0;

    //confirmation before we authorize
    var confirm = await _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      data: BasicDialogStatus.warning,
      title: "Confirm Entry",
      description: 'Are you sure you want to authorize this Gate Pass?',
      mainButtonTitle: "Confirm",
      secondaryButtonTitle: "Cancel",
    );
    if (confirm != null && confirm.confirmed == false) {
      setBusy(false);
      return;
    }

    //check for entry checklist
    var checkListCompleted = await findChecklistTemplate();

    if (checkListCompleted == false) {
      setBusy(false);
      return; // If checklist is not completed, do not proceed with authorization
      // Checklist is complete, proceed with authorization
    }

    var reponse = await _gatePassService.authorizeForEntry(gatePass);
    if (reponse != null) {
      _gatePass = reponse;

      Fluttertoast.showToast(
          msg: "Authorize for Entry was successful! ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14.0);
      _navigationService.back(result: true);
    } else {
      //error could not save
      Fluttertoast.showToast(
          msg: "Save Failed!,Please try again or contact your system admin. ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0);
    }
    setBusy(false);
  }

  Future<void> authorizeExit() async {
    if (!_connectionService.hasConnection) {
      await _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        data: BasicDialogStatus.warning,
        title: "Internet Connection Failure",
        description: 'Could not authorize for entry,Please check you internet connection and try again',
        mainButtonTitle: "Ok",
      );
    }

    //confirmation before we authorize
    var confirm = await _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      data: BasicDialogStatus.warning,
      title: "Confirm Exit",
      description: 'Are you sure you want to authorize this Gate Pass?',
      mainButtonTitle: "Confirm",
      secondaryButtonTitle: "Cancel",
    );
    if (confirm != null && confirm.confirmed == false) {
      return;
    }

    setBusy(true);

    //check for entry checklist
    var checkListCompleted = await findChecklistTemplate();
    if (checkListCompleted == false) {
      setBusy(false);
      return; // If checklist is not completed, do not proceed with authorization
      // Checklist is complete, proceed with authorization
    }
    //here we save back to server
    var reponse = await _gatePassService.authorizeExit(gatePass);
    if (reponse != null) {
      _gatePass = reponse;
      setBusy(false);
      Fluttertoast.showToast(
          msg: "Authorize for Exit was successful! ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14.0);
    } else {
      //error could not save
      Fluttertoast.showToast(
          msg: "Save Failed!,Please try again or contact your system admin. ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0);
    }

    _navigationService.back(result: true);
  }

  Future<void> rejectEntry() async {
    if (!_connectionService.hasConnection) {
      await _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        data: BasicDialogStatus.warning,
        title: "Internet Connection Failure",
        description: 'Could not authorize for entry,Please check you internet connection and try again',
        mainButtonTitle: "Ok",
      );
    }

    var confirm = await _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      data: BasicDialogStatus.warning,
      title: "Confirm Rejection",
      description: 'Are you sure you want to reject this Gate Pass?',
      mainButtonTitle: "Confirm",
      secondaryButtonTitle: "Cancel",
    );
    if (confirm != null && confirm.confirmed == false) {
      return;
    }

    setBusy(true);

    final checklistCompleted = await findChecklistTemplate(isReject: true);
    if (!checklistCompleted) {
      setBusy(false);
      return;
    }

    //here we save back to server
    var reponse = await _gatePassService.rejectForEntry(gatePass);
    if (reponse != null) {
      _gatePass = reponse;
      Fluttertoast.showToast(
          msg: "Save was successful! ",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14.0);
    } else {
      Fluttertoast.showToast(
          msg: "Save Failed!,Please try again or contact your system admin. ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0);
    }

    setModelUpdate(_gatePass);
    notifyListeners();

    _navigationService.back();
  }

  Future<void> onTabBarTap(int index) async {
    switch (index) {
      case 1:
        await loadFileStoreImages();
        notifyListeners();
        break;
      default:
    }
  }

  Future<void> loadFileStoreImages() async {
    if (gatePass.id != null && gatePass.id != 0) {
      _fileStoreItems = await _fileStoreRepository.getAll(
          gatePass.id!, FileStoreType.gateBookingImage, 100);

      final foreignLicensePhotos = await _fileStoreRepository.getAll(
          gatePass.id!, FileStoreType.gatePassAccessDriverLicenceImage, 100);
      if (foreignLicensePhotos.isNotEmpty) {
        _foreignLicensePhotoTaken = true;
        _foreignLicensePhotoPath = foreignLicensePhotos.first;
      } else {
        _foreignLicensePhotoTaken = false;
        _foreignLicensePhotoPath = null;
      }
    }
  }
  Future<void> goToCamCaptureContainerNoText() async {
    if (gatePass.id != null && gatePass.id != 0) {
      var contInfo = await _navigationService
          .navigateToCamContainernoReaderView() as ContainerInfo?;
      if (contInfo != null) {
        gatePass.containerNumber = contInfo.containerNumber;

        String sizeStr = contInfo.isoType.substring(0, 2);
        String typeStr = contInfo.isoType.substring(2, 4);

        gatePass.containerSize = sizeStr + " FT";
        gatePass.containerType = typeStr;

        switch (sizeStr) {
          case "20":
            gatePass.containerSizeId = 1;
            break;
          case "40":
            gatePass.containerSizeId = 2;
            break;
          case "45":
            gatePass.containerSizeId = 3;
            break;
          case "48":
            gatePass.containerSizeId = 4;
            break;
          case "53":
            gatePass.containerSizeId = 5;
            break;
          default:
            gatePass.containerSizeId = 2;
        }

        switch (typeStr.toUpperCase()) {
          case "GP":
            gatePass.containerTypeId = 1;
            break;
          case "HC":
            gatePass.containerTypeId = 2;
            break;
          case "RF":
            gatePass.containerTypeId = 3;
            break;
          default:
            gatePass.containerTypeId = 1;
        }
        rebuildUi();
      }
    }
  }

  Future<void> goToCamView(FileStoreType fileStoreType) async {
    await getStoragePermissions();
    if (gatePass.id != null && gatePass.id != 0) {
      await _navigationService.navigateTo(
        Routes.cameraCaptureView,
        arguments: CameraCaptureViewArguments(
            refId: gatePass.id!, referanceId: 0, fileStoreType: fileStoreType),
      );

      await loadFileStoreImages();

      notifyListeners();
    }
  }

  Future<void> captureForeignLicensePhoto() async {
    await getStoragePermissions();
    if (gatePass.id != null && gatePass.id != 0) {
      await _navigationService.navigateTo(
        Routes.cameraCaptureView,
        arguments: CameraCaptureViewArguments(
            refId: gatePass.id,
            referanceId: 0,
            fileStoreType: FileStoreType.gatePassAccessDriverLicenceImage),
      );

      // Load updated images and foreign license photo state
      await loadFileStoreImages();
      notifyListeners();
    }
  }

  Future<void> saveImageToLocalDb(
      {required File galleryFile, required String tempFilePath}) async {
    await _fileStoreRepository.insert(
      FileStore(
          desc: "",
          referanceId: 0,
          filestoreType: FileStoreType.image.value,
          path: galleryFile.path,
          tempPath: tempFilePath,
          fileName: galleryFile.path,
          createdDateTime: Timestamp.now(),
          refId: gatePass.id!),
    );
  }

  Future<void> deleteImage(FileStore fileItem) async {
    var confirm = await _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        data: BasicDialogStatus.warning,
        title: "Delete Image?.",
        description: 'Are you sure you want to Delete this image?',
        mainButtonTitle: "Confirm",
        takesInput: false,
        secondaryButtonTitle: "Cancel");

    if (confirm != null && confirm.confirmed) {
      await _fileStoreRepository.delete(fileItem);

      //server side delete of image
      await _workerQueManager.enqueSingle(BackgroundJobInfo(
          refTransactionId: gatePass.id,
          jobType: BackgroundJobType.syncImages.index,
          jobArgs: fileItem.fileName,
          lastTryTime: Timestamp.now(),
          creationTime: Timestamp.now(),
          nextTryTime: Timestamp.now(),
          id: "",
          isAbandoned: false));
    }
    await loadFileStoreImages();
    notifyListeners();
  }

  Future<void> openImagePicker() async {
    await getStoragePermissions();
    if (gatePass.id != null && gatePass.id != 0) {
      var selectedImages = await _mediaService.pickMultiImages();
      if (selectedImages != null) {
        for (var xfile in selectedImages) {
          final file = File(xfile.path);
          await saveImageToLocalDb(galleryFile: file, tempFilePath: xfile.path);
        }

        await loadFileStoreImages();
        //await save();
      }
    }

    notifyListeners();
  }

  String _cleanRegistrationNumber(String regNumber) {
    return regNumber.replaceAll(' ', '').toUpperCase();
  }

  bool _validateRegistrationFormat(String regNumber) {
    String cleaned = regNumber.replaceAll(' ', '');

    if (cleaned.isEmpty || cleaned.length < 3 || cleaned.length > 10) {
      setValidationMessage(ValidationMessages.invalidRegNumberLength);
      return false;
    }

    if (!RegExp(r'^[A-Za-z0-9-]+$').hasMatch(cleaned)) {
      setValidationMessage(ValidationMessages.invalidRegNumberCharacters);
      return false;
    }

    return true;
  }


  Future<void> manualInputVehicle(String registrationNumber) async {
    if (!_validateRegistrationFormat(registrationNumber)) {
      return;
    }

    String cleanedRegNumber = _cleanRegistrationNumber(registrationNumber);

    gatePass.vehicleRegNumberValidation = cleanedRegNumber;
    setVehicleValidationMessage();

    if (!_isRegistrationMatch()) {
      await _handleRegistrationMismatch(cleanedRegNumber);
      return;
    }

    await _processSuccessfulVehicleEntry();
  }
  bool _isRegistrationMatch() {
    return gatePass.vehicleRegNoMatch == true;
  }


  Future<void> _processSuccessfulVehicleEntry() async {
    _vehicleManualEntryUsed = true;
    _vehicleManualPhotoTaken = false;
    gatePass.isManualInput = true;
    gatePass.isVehicleManualInput = true;

    await promptForVehiclePhoto();

    BarcodeScanType nextScanType = _determineNextScanType();
    GlobalKey? nextSection = _determineNextSection();

    setBarcodeScanType(nextScanType);

    if (nextSection != null) {
      scrollToWidget(nextSection);
    }

    _showVehicleManualInput = false;
    setModelUpdate(gatePass);
    rebuildUi();
  }

  BarcodeScanType _determineNextScanType() {
    if (gatePass.trailerRegNumberOne?.isNotEmpty == true) {
      return BarcodeScanType.trailerOneDisc;
    }
    if (gatePass.trailerRegNumberTwo?.isNotEmpty == true) {
      return BarcodeScanType.trailerTwoDisc;
    }
    return BarcodeScanType.vehicleDisc;
  }

  GlobalKey? _determineNextSection() {
    if (gatePass.trailerRegNumberOne?.isNotEmpty == true) {
      return trailerOneInfoCardKey;
    }
    if (gatePass.trailerRegNumberTwo?.isNotEmpty == true) {
      return trailerTwoInfoCardKey;
    }
    if (gatePass.gatePassBookingType == GatePassBookingType.containers) {
      return containerInfoCardKey;
    }
    return null;
  }

  Future<void> _handleRegistrationMismatch(String enteredRegNumber) async {
    var result = await _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      data: BasicDialogStatus.error,
      title: "License Mismatch",
      description: ValidationMessages.regNoMismatch(
          "Vehicle registration",
           gatePass.vehicleRegNumber,
            enteredRegNumber),
            mainButtonTitle: "Re-enter",
      secondaryButtonTitle: "Reject Entry",
    );

    if (result?.confirmed == true) {
      _showVehicleManualInput = true;
    } else {
      await rejectEntry();
    }

    setModelUpdate(gatePass);
    rebuildUi();
  }



  Future<void> manualInputTrailerOne(String registrationNumber) async {
    if (registrationNumber.contains(' ')) {
      setValidationMessage(ValidationMessages.noSpacesAllowed);
      return;
    }

    registrationNumber = registrationNumber.replaceAll(' ', '').toUpperCase();
    gatePass.trailerRegNumberOneValidation = registrationNumber;

    setTrailerValidationMessage("One");

    if (gatePass.trailerRegNumberOneMatch == true) {
      _trailerOneManualEntryUsed = true;
      _trailerOneManualPhotoTaken = false;
      gatePass.isTrailerOneManualInput = true;

      await promptForTrailerOnePhoto();

      BarcodeScanType nextScanType = BarcodeScanType.trailerOneDisc;
      GlobalKey? nextSection;

      if (gatePass.trailerRegNumberTwo != null &&
          gatePass.trailerRegNumberTwo!.isNotEmpty) {
        nextScanType = BarcodeScanType.trailerTwoDisc;
        nextSection = trailerTwoInfoCardKey;
      } else if (gatePass.gatePassBookingType ==
          GatePassBookingType.containers) {
        nextSection = containerInfoCardKey;
      }

      setBarcodeScanType(nextScanType);
      if (nextSection != null) {
        scrollToWidget(nextSection);
      }

      _showTrailerOneManualInput = false;
    } else {
      if (hasTrailerOverridePermission) {
        await showTrailerOneOverrideDialog(registrationNumber);
        gatePass.isManualInput = true;
        gatePass.isOverride = true;
      } else {
        var result = await _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          data: BasicDialogStatus.error,
          title: "License Mismatch",
          description: ValidationMessages.regNoMismatch(
              "Trailer One registration",
              gatePass.trailerRegNumberOne,
              registrationNumber),
          mainButtonTitle: "Re-enter",
          secondaryButtonTitle: "Reject Entry",
        );

        if (result?.confirmed == true) {
          _showTrailerOneManualInput = true;
          gatePass.isManualInput = true;
        } else {
          await rejectEntry();
        }
      }
    }

    setModelUpdate(gatePass);
    rebuildUi();
  }

  // Manual Trailer Two Input
  Future<void> manualInputTrailerTwo(String registrationNumber) async {
    if (registrationNumber.contains(' ')) {
      setValidationMessage(ValidationMessages.noSpacesAllowed);
      return;
    }

    registrationNumber = registrationNumber.replaceAll(' ', '').toUpperCase();
    gatePass.trailerRegNumberTwoValidation = registrationNumber;
    setTrailerValidationMessage("Two");

    if (gatePass.trailerRegNumberTwoMatch == true) {
      _trailerTwoManualEntryUsed = true;
      _trailerTwoManualPhotoTaken = false;
      gatePass.isTrailerTwoManualInput = true;
      await promptForTrailerTwoPhoto();

      if (gatePass.gatePassBookingType == GatePassBookingType.containers) {
        scrollToContainerInfo();
      } else {
        scrollToFirstError();
      }

      _showTrailerTwoManualInput = false;
    } else {
      if (hasTrailerOverridePermission) {
        await showTrailerTwoOverrideDialog(registrationNumber);
        gatePass.isManualInput = true;
        gatePass.isOverride = true;
      } else {
        var result = await _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          data: BasicDialogStatus.error,
          title: "License Mismatch",
          description: ValidationMessages.regNoMismatch(
              "Trailer Two registration",
              gatePass.trailerRegNumberTwo,
              registrationNumber),
          mainButtonTitle: "Re-enter",
          secondaryButtonTitle: "Reject Entry",
        );

        if (result?.confirmed == true) {
          _showTrailerTwoManualInput = true;
          gatePass.isManualInput = true;
          gatePass.isTrailerTwoOverride = true;
        } else {
          await rejectEntry();
        }
      }
    }

    setModelUpdate(gatePass);
    rebuildUi();
  }

  // Trailer Override
  Future<void> showTrailerOneOverrideDialog(String enteredReg) async {
    var confirm = await _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      data: BasicDialogStatus.warning,
      title: "Trailer Override Required",
      description: ValidationMessages.overrideConfirmation(
          "Trailer One", gatePass.trailerRegNumberOne ?? "N/A", enteredReg),
      mainButtonTitle: "Override & Proceed",
      secondaryButtonTitle: "Edit",
      additionalButtonTitle: "Reject Entry",
    );

    if (confirm == null) {
      _showTrailerOneManualInput = true;
      scrollToWidget(trailerOneInfoCardKey);
      rebuildUi();
      return;
    }

    if (confirm.confirmed == true) {
      gatePass.trailerRegNumberOneValidation = enteredReg;

      clearAllValidationMessage();
      _trailerOneManualEntryUsed = true;
      gatePass.isManualInput = true;
      _trailerOneManualPhotoTaken = false;
      gatePass.isTrailerOneOverride = true;

      await promptForTrailerOnePhoto();

      BarcodeScanType nextScanType = BarcodeScanType.trailerOneDisc;
      GlobalKey? nextSection;

      if (gatePass.trailerRegNumberTwo != null &&
          gatePass.trailerRegNumberTwo!.isNotEmpty) {
        nextScanType = BarcodeScanType.trailerTwoDisc;
        nextSection = trailerTwoInfoCardKey;
      } else if (gatePass.gatePassBookingType ==
          GatePassBookingType.containers) {
        nextSection = containerInfoCardKey;
      }

      setBarcodeScanType(nextScanType);
      if (nextSection != null) {
        scrollToWidget(nextSection);
      }

      _showTrailerOneManualInput = false;
    } else if (confirm.responseData == 'secondary') {
      _showTrailerOneManualInput = true;
      scrollToWidget(trailerOneInfoCardKey);
    } else if (confirm.responseData == 'additional') {
      await rejectEntry();
    } else {
      _showTrailerOneManualInput = true;
      scrollToWidget(trailerOneInfoCardKey);
    }

    setModelUpdate(gatePass);
    rebuildUi();
  }

  Future<void> showTrailerTwoOverrideDialog(String enteredReg) async {
    var confirm = await _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      data: BasicDialogStatus.warning,
      title: "Trailer Override Required",
      description: ValidationMessages.overrideConfirmation(
          "Trailer Two", gatePass.trailerRegNumberTwo ?? "N/A", enteredReg),
      mainButtonTitle: "Override & Proceed",
      secondaryButtonTitle: "Edit",
      additionalButtonTitle: "Reject Entry",
    );

    if (confirm == null) {
      _showTrailerTwoManualInput = true;
      scrollToWidget(trailerTwoInfoCardKey);
      rebuildUi();
      return;
    }

    if (confirm.confirmed == true) {
      gatePass.trailerRegNumberTwoValidation = enteredReg;

      clearAllValidationMessage();
      _trailerTwoManualPhotoTaken = false;
      _trailerTwoManualEntryUsed = true;
      gatePass.isManualInput = true;
      gatePass.isOverride = true;
      gatePass.isTrailerTwoOverride = true;

      await promptForTrailerTwoPhoto();

      if (gatePass.gatePassBookingType == GatePassBookingType.containers) {
        scrollToContainerInfo();
      } else {
        scrollToFirstError();
      }

      _showTrailerTwoManualInput = false;
    } else if (confirm.responseData == 'secondary') {
      _showTrailerTwoManualInput = true;
      scrollToWidget(trailerTwoInfoCardKey);
    } else if (confirm.responseData == 'additional') {
      await rejectEntry();
    } else {
      _showTrailerTwoManualInput = true;
      scrollToWidget(trailerTwoInfoCardKey);
    }

    setModelUpdate(gatePass);
    rebuildUi();
  }
    /// Photo capture methods
  Future<void> promptForVehiclePhoto() async {
    var result = await _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      data: BasicDialogStatus.info,
      title: "Photo Required",
      description: ValidationMessages.photoRequiredForManualInput("vehicle"),
      mainButtonTitle: "Take Photo",
      secondaryButtonTitle: "Cancel",
    );

    if (result?.confirmed == true) {
      var photoCountBefore = _fileStoreItems.length;

      await _navigationService.navigateTo(
        Routes.cameraCaptureView,
        arguments: CameraCaptureViewArguments(
          refId: gatePass.id!,
          referanceId: 0,
          fileStoreType: FileStoreType.gateBookingImage,
        ),
      );

      await loadFileStoreImages();

      if (_fileStoreItems.length > photoCountBefore) {
        _vehicleManualPhotoPath = _fileStoreItems.lastOrNull;
        _vehicleManualPhotoTaken = true;
      }

      rebuildUi();
    }
  }

  Future<void> promptForTrailerOnePhoto() async {
    var result = await _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      data: BasicDialogStatus.info,
      title: "Photo Required",
      description: ValidationMessages.photoRequiredForManualInput("trailer one"),
      mainButtonTitle: "Take Photo",
      secondaryButtonTitle: "Cancel",
    );

    if (result?.confirmed == true) {
      var photoCountBefore = _fileStoreItems.length;

      await _navigationService.navigateTo(
        Routes.cameraCaptureView,
        arguments: CameraCaptureViewArguments(
          refId: gatePass.id!,
          referanceId: 0,
          fileStoreType: FileStoreType.gateBookingImage,
        ),
      );

      await loadFileStoreImages();

      if (_fileStoreItems.length > photoCountBefore) {
        _trailerOneManualPhotoPath = _fileStoreItems.lastOrNull;
        _trailerOneManualPhotoTaken = true;
      }

      rebuildUi();
    }
  }

  Future<void> promptForTrailerTwoPhoto() async {
    var result = await _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      data: BasicDialogStatus.info,
      title: "Photo Required",
      description: ValidationMessages.photoRequiredForManualInput("trailer two"),
      mainButtonTitle: "Take Photo",
      secondaryButtonTitle: "Cancel",
    );

    if (result?.confirmed == true) {
      var photoCountBefore = _fileStoreItems.length;

      await _navigationService.navigateTo(
        Routes.cameraCaptureView,
        arguments: CameraCaptureViewArguments(
          refId: gatePass.id!,
          referanceId: 0,
          fileStoreType: FileStoreType.gateBookingImage,
        ),
      );

      await loadFileStoreImages();

      if (_fileStoreItems.length > photoCountBefore) {
        _trailerTwoManualPhotoPath = _fileStoreItems.lastOrNull;
        _trailerTwoManualPhotoTaken = true;
      }

      rebuildUi();
    }
  }
    Future<void> logIncident(String message) async {
    //try to send if fail then we log it to the que

    var newIncident = Incident(
      id: Guid.newGuidAsString,
      gatePassAccessId: gatePass.id,
      //incidentType: IncidentType.gatePassIncident,
      message: "Status:${gatePass.gatePassStatus.displayName} ,$message",
      branchId: gatePass.branchId,
      revolved: false,
    );

    bool couldSend = false;
    try {
      ///..ohter
      await _incidentManagerService.createIncident(newIncident.toJson());
      couldSend = true;
    } catch (e) {
      couldSend = false;
      log.e("Error checking connection: $e");
    }

    if (couldSend == false) {
      await _workerQueManager.enqueSingle(
        BackgroundJobInfo(
          jobType: BackgroundJobType.createIncident.index,
          jobArgs: newIncident.toJson(),
          lastTryTime: Timestamp.now(),
          creationTime: Timestamp.now(),
          nextTryTime: Timestamp.now(),
          refTransactionId: gatePass.id,
          id: "",
          isAbandoned: false,
        ),
        true,
      );
    }
  }

//

  BaseLookup? getCustomer() {
    if (gatePass.customerName != null && gatePass.customerName!.isNotEmpty) {
      return BaseLookup(
          // code: gatePass.customerCode,
          id: gatePass.customerId,
          name: gatePass.customerName,
          displayName: gatePass.customerName);
    }
    if (gatePass.customerId == null) {
      return null;
    }
    var found = customers.firstWhereOrNull((e) => e.id == gatePass.customerId);
    if (found != null) {
      return found;
    }

    return null;
  }

  void setCustomer(BaseLookup selectedItem) {
    gatePass.customerId = selectedItem.id;
    gatePass.customerName = selectedItem.name;
//    gatePass.cu = selectedItem.code;

    notifyListeners();
  }

  void routePop() {
    _scanningService.setBarcodeScanType(BarcodeScanType.loadConQrCode);
  }

  void viewAllForeignLicensePhotos() async {
    if (_foreignLicensePhotoPath != null) {
      await _navigationService.navigateTo(
        Routes.imagesViewerListView,
        arguments: ImagesViewerListViewArguments(
          gatePassId: gatePass.id,
        ),
      );
    }
  }

  void setTransporter(int? transporterId) {
    gatePass.transporterId = transporterId;

    if (isManualInput) {
      if (transporterId != null) {
        clearValidationMessage("Transporter is required for manual entries");
      } else {
        setValidationMessage("Transporter is required for manual entries");
      }
    }

    notifyListeners();
  }

  void viewVehiclePhoto() async {
    if (_vehicleManualPhotoPath != null) {
      await _navigationService.navigateTo(
        Routes.imagesViewerListView,
        arguments: ImagesViewerListViewArguments(
          gatePassId: gatePass.id,
        ),
      );
    } else {
      await promptForVehiclePhoto();
    }
  }

  void viewTrailerOnePhoto() async {
    if (_trailerOneManualPhotoPath != null) {
      await _navigationService.navigateTo(
        Routes.imagesViewerListView,
        arguments: ImagesViewerListViewArguments(
          gatePassId: gatePass.id,
        ),
      );
    } else {
      await promptForTrailerOnePhoto();
    }
  }

  void viewTrailerTwoPhoto() async {
    if (_trailerTwoManualPhotoPath != null) {
      await _navigationService.navigateTo(
        Routes.imagesViewerListView,
        arguments: ImagesViewerListViewArguments(
          gatePassId: gatePass.id,
        ),
      );
    } else {
      await promptForTrailerTwoPhoto();
    }
  }

  Future<void> loadTransporters() async {
    if (_cachedTransporters != null &&
        _transporterCacheTime != null &&
        DateTime.now().difference(_transporterCacheTime!) < _cacheExpiry) {
      _transporters = _cachedTransporters!;
      notifyListeners();
      return;
    }

    _transporters = await _gatePassService.getTransporters();
    _cachedTransporters = _transporters;
    _transporterCacheTime = DateTime.now();

    notifyListeners();
  }

  Future<void> refreshTransporters() async {
    _cachedTransporters = null;
    await loadTransporters();
  }

  Future<void> loadCustomers() async {
      _customers = await _gatePassService.getCustomers();
      notifyListeners();
  }

  // Load Shipping Lines
  Future<void> loadShippingLines() async {
    if (_cachedShippingLines != null &&
        _shippingLineCacheTime != null &&
        DateTime.now().difference(_shippingLineCacheTime!) < _cacheExpiry) {
      _shippingLines = _cachedShippingLines!;
      notifyListeners();
      return;
    }
      _shippingLines = await _gatePassService.getShippingLines();
      _cachedShippingLines = _shippingLines;
      _shippingLineCacheTime = DateTime.now();
      _shippingLines = [];
      notifyListeners();
  }

  Future<void> refreshShippingLines() async {
    _cachedShippingLines = null;
    await loadShippingLines();
  }

// Load Container Customers
  Future<void> loadContainerCustomers() async {
    if (_cachedContainerCustomers != null &&
        _containerCustomerCacheTime != null &&
        DateTime.now().difference(_containerCustomerCacheTime!) <
            _cacheExpiry) {
      _containerCustomers = _cachedContainerCustomers!;
      notifyListeners();
      return;
    }


      _containerCustomers = await _gatePassService.getContainerCustomers();
      _cachedContainerCustomers = _containerCustomers;
      _containerCustomerCacheTime = DateTime.now();
      notifyListeners();
  }

  Future<void> refreshContainerCustomers() async {
    _cachedContainerCustomers = null;
    await loadContainerCustomers();
  }

// Load Container Depots
  Future<void> loadContainerDepots() async {
    if (_cachedContainerDepots != null &&
        _containerDepotCacheTime != null &&
        DateTime.now().difference(_containerDepotCacheTime!) < _cacheExpiry) {
      _containerDepots = _cachedContainerDepots!;
      notifyListeners();
      return;
    }


      _containerDepots = await _gatePassService.getContainerDepots();
      _cachedContainerDepots = _containerDepots;
      _containerDepotCacheTime = DateTime.now();
      notifyListeners();
  }

  Future<void> refreshContainerDepots() async {
    _cachedContainerDepots = null;
    await loadContainerDepots();
  }

// Validate all container required fields
  void validateContainerInfo() {
    if (gatePass.gatePassBookingType != GatePassBookingType.containers) {
      return;
    }

    bool isValid = true;

    // Container number validation
    if (gatePass.containerNumber == null || gatePass.containerNumber!.isEmpty) {
      setValidationMessage("Container number is required");
      isValid = false;
    } else {
      clearValidationMessage("Container number is required");
    }

    // Delivery type validation
    if (gatePass.containerDeliveryType == null) {
      setValidationMessage("Delivery type is required");
      isValid = false;
    } else {
      clearValidationMessage("Delivery type is required");
    }

    // Cargo type validation
    if (gatePass.gatePassContainerType == null) {
      setValidationMessage("Cargo type is required");
      isValid = false;
    } else {
      clearValidationMessage("Cargo type is required");
    }

    // Shipping line validation
    if (gatePass.containerShippingLine == null ||
        gatePass.containerShippingLine!.isEmpty) {
      setValidationMessage("Shipping line is required");
      isValid = false;
    } else {
      clearValidationMessage("Shipping line is required");
    }

    if (!isValid) {
      scrollToContainerInfo();
    }
  }

  void setShippingLine(int? shippingLineId) {

    if (shippingLineId != null) {
      var shippingLine =
          _shippingLines.firstWhereOrNull((s) => s.id == shippingLineId);

      if (shippingLine != null) {
        gatePass.containerShippingLine = shippingLine.name;
        gatePass.containerShippingLineId = shippingLine.id;
      }
    } else {
      gatePass.containerShippingLine = null;
      gatePass.containerShippingLineId = null;
    }

    clearValidationMessage("Shipping line is required");
    notifyListeners();
  }

  void setContainerCustomer(int? customerId) {
    if (customerId != null) {
      var customer =
          _containerCustomers.firstWhereOrNull((c) => c.id == customerId);

      if (customer != null) {
        gatePass.containerCustomer = customer.name;
        gatePass.containerCustomerId = customer.id;
      }
    } else {
      gatePass.containerCustomer = null;
      gatePass.containerCustomerId = null;
    }

    notifyListeners();
  }

  void setContainerDepot(int? depotId) {
    if (depotId != null) {
      var depot = _containerDepots.firstWhereOrNull((d) => d.id == depotId);
      if (depot != null) {
        gatePass.containerDepot = depot.name;
        gatePass.containerDepotId = depot.id;
      }
    } else {
      gatePass.containerDepot = null;
      gatePass.containerDepotId = null;
    }

    notifyListeners();
  }

  Future<void> reloadGatePassWithContainers() async {

      setBusy(true);

      var reloaded = await _gatePassService.getGatePassWithContainers(gatePass.id);

      if (reloaded != null) 
      {
        _gatePass = reloaded;
        notifyListeners();
       }

  }

  void loadContainerDetailsFromArray() {
    if (gatePass.gatePassBookingType == GatePassBookingType.containers &&
        gatePass.containers != null &&
        gatePass.containers!.isNotEmpty) {
      var firstContainer = gatePass.containers!.first;

      gatePass.containerId = firstContainer.id;
      gatePass.containerNumber = firstContainer.containerNumber;
      gatePass.containerSize = firstContainer.containerSize;
      gatePass.containerSizeId = firstContainer.containerSizeId;
      gatePass.containerType = firstContainer.containerType;
      gatePass.containerTypeId = firstContainer.containerTypeId;

      // Set IDs first
      gatePass.containerShippingLineId = firstContainer.shippingLineId;
      gatePass.containerCustomerId = firstContainer.customerId;
      gatePass.containerDepotId = firstContainer.depotId;

      // Then lookup names from IDs
      if (firstContainer.shippingLineId != null) {
        var shippingLine = _shippingLines
            .firstWhereOrNull((s) => s.id == firstContainer.shippingLineId);
        gatePass.containerShippingLine =
            shippingLine?.name ?? firstContainer.containerShippingLine;
      } else {
        gatePass.containerShippingLine = firstContainer.containerShippingLine;
      }

      if (firstContainer.customerId != null) {
        var customer = _containerCustomers
            .firstWhereOrNull((c) => c.id == firstContainer.customerId);
        gatePass.containerCustomer =
            customer?.name ?? firstContainer.containerCustomer;
      } else {
        gatePass.containerCustomer = firstContainer.containerCustomer;
      }

      if (firstContainer.depotId != null) {
        var depot = _containerDepots
            .firstWhereOrNull((d) => d.id == firstContainer.depotId);
        gatePass.containerDepot = depot?.name ?? firstContainer.containerDepot;
      } else {
        gatePass.containerDepot = firstContainer.containerDepot;
      }

      gatePass.containerDeliveryType = firstContainer.containerDeliveryType;
      gatePass.gatePassContainerType = firstContainer.gatePassContainerType;
      notifyListeners();
    }
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
