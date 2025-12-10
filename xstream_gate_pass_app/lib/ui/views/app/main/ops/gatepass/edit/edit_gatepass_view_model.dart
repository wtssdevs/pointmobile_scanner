import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';
import 'package:flutter/services.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.dialogs.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';
import 'package:xstream_gate_pass_app/core/enums/manual_entry_step.dart';
import 'package:xstream_gate_pass_app/core/models/ops/checklists/check_list_find_template_model.dart';
import 'package:xstream_gate_pass_app/core/models/ops/gatepass/containers/gate_pass_access_container_model.dart';
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
import 'package:xstream_gate_pass_app/services/iso_type_service.dart';

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
  final _isoTypeService = locator<IsoTypeService>();
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

  bool get isManualEntryWizard => isManualInput && !_isExitMode;

  bool get isContainerCargo =>
      gatePass.gatePassBookingType == GatePassBookingType.containers;
  bool get isBreakbulkCargo => !isContainerCargo;

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

  final TextEditingController containerNumberController =
      TextEditingController();
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

  // Logistics information section
  final GlobalKey logisticsInfoCardKey =
      GlobalKey(debugLabel: 'logisticsInfoCard');
  final GlobalKey<FormFieldState> transporterDropdownKey =
      GlobalKey<FormFieldState>(debugLabel: 'transporterDropdown');

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
  ManualEntryStep _manualEntryStep = ManualEntryStep.scanDriver;
  ManualEntryStep get manualEntryStep => _manualEntryStep;

  bool get manualEntryScanComplete =>
      !isManualEntryWizard ||
      _manualEntryStep.index >= ManualEntryStep.selectTransporter.index;
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

  bool _isExitMode = false;
  bool get isExitMode => _isExitMode;

  // Exit scan tracking
  bool _driverScannedOnExit = false;
  bool get driverScannedOnExit => _driverScannedOnExit;

  bool _vehicleScannedOnExit = false;
  bool get vehicleScannedOnExit => _vehicleScannedOnExit;

  bool _trailerOneScannedOnExit = false;
  bool get trailerOneScannedOnExit => _trailerOneScannedOnExit;

  bool _trailerTwoScannedOnExit = false;
  bool get trailerTwoScannedOnExit => _trailerTwoScannedOnExit;

  String? get trailerOneEntryReg => (gatePass.trailerRegNumberOne != null &&
          gatePass.trailerRegNumberOne!.isNotEmpty)
      ? gatePass.trailerRegNumberOne
      : gatePass.trailerRegNumberOneValidation;

  bool get hasTrailerOneEntryReg =>
      trailerOneEntryReg != null && trailerOneEntryReg!.isNotEmpty;

  String? get trailerTwoEntryReg => (gatePass.trailerRegNumberTwo != null &&
          gatePass.trailerRegNumberTwo!.isNotEmpty)
      ? gatePass.trailerRegNumberTwo
      : gatePass.trailerRegNumberTwoValidation;

  bool get hasTrailerTwoEntryReg =>
      trailerTwoEntryReg != null && trailerTwoEntryReg!.isNotEmpty;

  List<BaseLookup> _customers = <BaseLookup>[];
  List<BaseLookup> get customers => _customers;
  Future<void> initialize() async {
    // Initialize scanner with the selected barcode type
    _scanningService.initialise(barcodeScanType: _barcodeScanType);
    await startScanListener();

    // For new manual entries
    if (isManualEntryWizard) {
      _manualEntryStep = ManualEntryStep.scanDriver;
      setBarcodeScanType(BarcodeScanType.driversCard);
    }
  }

  Future<void> dispose() async {
    streamSubscription?.cancel();
    streamSubscriptionForDisc?.cancel();
    containerNumberController.dispose();
    //  _scanningService.onExit(); // Properly disable scanner when done

    //super.dispose();
  }

  Future<void> onDispose() async {
    await dispose();
  }

  void scrollToWidget(GlobalKey key,
      {Duration duration = const Duration(milliseconds: 400)}) {
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
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 400), curve: Curves.easeIn);
  }

  Future<void> runStartupLogic() async {
    if (isManualInput &&
        (gatePass.id == null ||
            gatePass.id.isEmpty ||
            gatePass.id == Guid.defaultValue.toString())) {
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

      gatePass.gatePassStatus = GatePassStatus.pending;

      if (currentUser?.userBranches != null &&
          currentUser!.userBranches.isNotEmpty) {
        gatePass.branchId = currentUser!.userBranches.first.id!;
      }
      if (gatePass.containerNumber != null) {
        containerNumberController.text = gatePass.containerNumber!;
      }
      if (gatePass.gatePassBookingType == GatePassBookingType.containers) {}

      try {
        var createdGatePass = await _gatePassService.createGatePass(gatePass);

        if (createdGatePass != null) {
          _gatePass = createdGatePass;
        } else {
          Fluttertoast.showToast(
            msg: "Failed to create gate pass. Please try again.",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM_LEFT,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 14.0,
          );
          _navigationService.back();
          return;
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error creating gate pass: ${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM_LEFT,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
        _navigationService.back();
        return;
      }
    }

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

    if (gatePass.driverHasForeignID == true) {
      setBarcodeScanType(BarcodeScanType.vehicleDisc);
    } else {
      setBarcodeScanType(BarcodeScanType.driversCard);
    }

    await initialize();

    if (gatePass.gatePassStatus == GatePassStatus.inYard) {
      _isExitMode = true;
      if (gatePass.driverHasForeignID == true) {
        setBarcodeScanType(BarcodeScanType.vehicleDisc);
      } else {
        setBarcodeScanType(BarcodeScanType.driversCard);
      }
    }
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
      // Process the driversCard  data here
      // This would populate a GatePassVisitorAccess from the driversCard data
      processScanData(data, null);
    });
    // Also listen to license disk data for vehicle scans
    streamSubscriptionForDisc = _scanningService.licenseDiskDataStream
        .asBroadcastStream()
        .listen((licenseDiskData) async {
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
      clearValidationMessage("Vehicle details do not match");
      return;
    }

    bool regsMatch = _sameReg(gatePass.vehicleRegNumber, gatePass.vehicleRegNumberValidation);

    if (!regsMatch) {
      var msg = ValidationMessages.regNoMismatch("Vehicle registration",
          gatePass.vehicleRegNumber, gatePass.vehicleRegNumberValidation);
      setValidationMessage(msg);
      if (gatePass.vehicleRegNumber == null ||
          gatePass.vehicleRegNumber!.isEmpty) {
        gatePass.vehicleRegNumber = gatePass.vehicleRegNumberValidation;
      }
      logIncident(msg);
    } else {
      clearValidationMessage("Vehicle details do not match");
    }
  }

  //trailers one and two validation
  void setTrailerValidationMessage(String trailerNumber) {
    if (trailerNumber == "One") {
      if (isManualInput) {
        clearValidationMessage("Trailer one details do not match");
        return;
      }

      if (gatePass.isTrailerOneOverride == true) {
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
      if (isManualInput) {
        clearValidationMessage("Trailer two details do not match");
        return;
      }

      if (gatePass.isTrailerTwoOverride == true) {
        clearValidationMessage("Trailer two details do not match");
        return;
      }

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
            if (_isExitMode) {
              _driverScannedOnExit = true;
            }
          }
          break;

        case BarcodeScanType.vehicleDisc:
          if (vehicleLicenseData != null) {
            await processVehicleLicenseData(vehicleLicenseData);
            if (_isExitMode) {
              _vehicleScannedOnExit = true;
            }
          }
          break;

        case BarcodeScanType.trailerOneDisc:
          if (vehicleLicenseData != null) {
            await processTrailerOneLicenseData(vehicleLicenseData);
            if (_isExitMode) {
              _trailerOneScannedOnExit = true;
            }
          }
          break;

        case BarcodeScanType.trailerTwoDisc:
          if (vehicleLicenseData != null) {
            await processTrailerTwoLicenseData(vehicleLicenseData);
            if (_isExitMode) {
              _trailerTwoScannedOnExit = true;
            }
          }
          break;

        default:
          break;
      }

      setModelUpdate(_gatePass);
      rebuildUi();
      await Future.delayed(const Duration(milliseconds: 500));
      _scrollToNextCard();
    } catch (e) {
      setValidationMessage(
          ValidationMessages.scanProcessingFailed(e.toString()));
      rebuildUi();
    }
  }

  void _scrollToNextCard() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (_barcodeScanType == BarcodeScanType.driversCard) {
      setBarcodeScanType(BarcodeScanType.vehicleDisc);
      scrollToWidget(vehicleInfoCardKey);
    } else if (_barcodeScanType == BarcodeScanType.vehicleDisc) {
      if (isManualInput || hasTrailerOneEntryReg) {
        setBarcodeScanType(BarcodeScanType.trailerOneDisc);
        scrollToWidget(trailerOneInfoCardKey);
      } else if (isManualInput || hasTrailerTwoEntryReg) {
        setBarcodeScanType(BarcodeScanType.trailerTwoDisc);
        scrollToWidget(trailerTwoInfoCardKey);
      } else if (isManualInput && !_isExitMode) {
        Future.delayed(const Duration(milliseconds: 500), () {
          scrollToWidget(logisticsInfoCardKey);
        });
      } else if (_isExitMode) {
        Fluttertoast.showToast(
          msg: "Exit scanning complete. Ready to authorize exit.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        scrollToWidget(timesInfoCardKey);
      } else if (gatePass.gatePassBookingType == GatePassBookingType.containers &&
          isManualInput &&
          !_isExitMode) {
        scrollToWidget(containerInfoCardKey);
      } else {
        scrollToWidget(timesInfoCardKey);
      }
    } else if (_barcodeScanType == BarcodeScanType.trailerOneDisc) {
      if (isManualInput || hasTrailerTwoEntryReg) {
        setBarcodeScanType(BarcodeScanType.trailerTwoDisc);
        scrollToWidget(trailerTwoInfoCardKey);
      } else if (isManualInput && !_isExitMode) {
        Future.delayed(const Duration(milliseconds: 500), () {
          scrollToWidget(logisticsInfoCardKey);
        });
      } else if (_isExitMode) {
        Fluttertoast.showToast(
          msg: "Exit scanning complete. Ready to authorize exit.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        scrollToWidget(timesInfoCardKey);
      } else if (gatePass.gatePassBookingType ==
          GatePassBookingType.containers) {
        scrollToWidget(containerInfoCardKey);
      } else {
        scrollToWidget(timesInfoCardKey);
      }
    } else if (_barcodeScanType == BarcodeScanType.trailerTwoDisc) {
      if (isManualInput && !_isExitMode) {
        rebuildUi();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          rebuildUi();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            rebuildUi();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (logisticsInfoCardKey.currentContext != null) {
                Scrollable.ensureVisible(
                  logisticsInfoCardKey.currentContext!,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
                Fluttertoast.showToast(
                  msg: "Please select Transporter ↓",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                );
              } else {
                Fluttertoast.showToast(
                  msg: "Please select Transporter",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                );
              }
            });
          });
        });
      } else if (_isExitMode) {
        Fluttertoast.showToast(
          msg: "Exit scanning complete. Ready to authorize exit.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        scrollToWidget(timesInfoCardKey);
      } else {
        if (gatePass.gatePassBookingType == GatePassBookingType.containers) {
          scrollToWidget(containerInfoCardKey);
        } else {
          scrollToWidget(timesInfoCardKey);
        }
      }
    }
  }

  void _advanceManualEntryStepAfterScan() {
    switch (_manualEntryStep) {
      case ManualEntryStep.scanDriver:
        _manualEntryStep = ManualEntryStep.scanVehicle;
        setBarcodeScanType(BarcodeScanType.vehicleDisc);
        break;

      case ManualEntryStep.scanVehicle:
        _manualEntryStep = ManualEntryStep.scanTrailer1;
        setBarcodeScanType(BarcodeScanType.trailerOneDisc);
        break;

      case ManualEntryStep.scanTrailer1:
        _manualEntryStep = ManualEntryStep.scanTrailer2;
        setBarcodeScanType(BarcodeScanType.trailerTwoDisc);
        break;

      case ManualEntryStep.scanTrailer2:
        _manualEntryStep = ManualEntryStep.selectTransporter;
        break;

      case ManualEntryStep.selectTransporter:
      case ManualEntryStep.containerDetails:
      case ManualEntryStep.done:
        break;
    }

    rebuildUi();
  }

  // Process driver's license data
  Future<void> processDriversLicenseData(
      RsaDriversLicense driversLicense) async {
    gatePass.driverName =
        '${driversLicense.firstNames} ${driversLicense.surname}';
    gatePass.driverIdNoValidation = driversLicense.idNumber;
    if (isManualInput) {
      gatePass.driverIdNo = driversLicense.idNumber;
    }
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
  }

// Process vehicle license data
  Future<void> processVehicleLicenseData(
      LicenseDiskData vehicleLicenseData) async {
    gatePass.vehicleEngineNumber = vehicleLicenseData.engineNumber;
    gatePass.vehicleMake = vehicleLicenseData.make;
    gatePass.vehicleVinNumber = vehicleLicenseData.vin;
    gatePass.vehicleRegisterNumber = vehicleLicenseData.vehicleRegisterNo;
    gatePass.branchId = currentUser?.userBranches[0].id ?? gatePass.branchId;

    if (vehicleLicenseData.expiryDate != null &&
        vehicleLicenseData.expiryDate!.isBefore(DateTime.now())) {
      logIncident(
          "Vehicle (${vehicleLicenseData.make}, ${vehicleLicenseData.licensePlateNo}) expired on ${vehicleLicenseData.expiryDate}. Please check the vehicle's license validity. ");
    }

    if (_isExitMode) {
      gatePass.vehicleRegNumberValidation = vehicleLicenseData.licensePlateNo;

      if (!_sameReg(
          gatePass.vehicleRegNumber, vehicleLicenseData.licensePlateNo)) {
        var msg =
            "EXIT MISMATCH: Vehicle registration does not match entry record. Entry: ${gatePass.vehicleRegNumber}, Exit Scan: ${vehicleLicenseData.licensePlateNo}";
        setValidationMessage(msg);
        logIncident(msg);

        await _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          data: BasicDialogStatus.warning,
          title: "Exit Verification Warning",
          description:
              "Vehicle registration does not match entry record.\n\nEntry Record: ${gatePass.vehicleRegNumber}\nExit Scan: ${vehicleLicenseData.licensePlateNo}\n\nIncident has been logged. You may continue with exit authorization.",
          mainButtonTitle: "Continue",
        );
      } else {
        clearValidationMessage(
            "EXIT MISMATCH: Vehicle registration does not match entry record");

        Fluttertoast.showToast(
          msg: "Vehicle matches entry record ✓",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }

      _vehicleScannedOnExit = true;
      rebuildUi();
      return;
    }
    gatePass.vehicleRegNumberValidation = vehicleLicenseData.licensePlateNo;

    if (isManualInput) {
      gatePass.vehicleRegNumber = vehicleLicenseData.licensePlateNo;
    }

    setVehicleValidationMessage();


    if (showValidation) {
      scrollToFirstError();
    }
  }

  // Process trailer one license data
  Future<void> processTrailerOneLicenseData(
      LicenseDiskData vehicleLicenseData) async {
    gatePass.trailerRegNumberOneValidation = vehicleLicenseData.licensePlateNo;

    // Check if trailer one reg matches scanned data

    // Set validation message

    if (_isExitMode) {
      final expected = trailerOneEntryReg;

      if (expected != null &&
          !_sameReg(expected, vehicleLicenseData.licensePlateNo)) {
        var msg =
            "Trailer One registration on EXIT does not match: Expected $expected, Scanned ${vehicleLicenseData.licensePlateNo}";
        setValidationMessage(msg);
        logIncident("EXIT MISMATCH: $msg");

        await _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          data: BasicDialogStatus.warning,
          title: "Exit Verification Warning",
          description:
              "$msg\n\nIncident has been logged. You may continue with exit authorization.",
          mainButtonTitle: "Continue",
        );
      } else {
        clearAllValidationMessage();
        if (gatePass.trailerRegNumberOne == null ||
            gatePass.trailerRegNumberOne!.isEmpty) {
          gatePass.trailerRegNumberOne = vehicleLicenseData.licensePlateNo;
        }

        Fluttertoast.showToast(
          msg: "Trailer One matches entry record ✓",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } else {
      if (isManualInput &&
          (gatePass.trailerRegNumberOne == null ||
              gatePass.trailerRegNumberOne!.isEmpty)) {
        gatePass.trailerRegNumberOne = vehicleLicenseData.licensePlateNo;
      }

      setTrailerValidationMessage("One");
    }

    if (vehicleLicenseData.expiryDate != null &&
        vehicleLicenseData.expiryDate!.isBefore(DateTime.now())) {
      logIncident(
          "Trailer One (${vehicleLicenseData.make}, ${vehicleLicenseData.licensePlateNo}) expired on ${vehicleLicenseData.expiryDate}. Please check the vehicle's license validity. ");
    }

    if (!_isExitMode &&
        gatePass.trailerRegNumberOneMatch == false &&
        hasTrailerManualInputPermission) {
      _showTrailerOneManualInput = true;
      scrollToWidget(trailerOneInfoCardKey);
      return;
    }

    if (showValidation) {
      rebuildUi();
      scrollToFirstError();
    }
  }

// Process trailer two license data
  Future<void> processTrailerTwoLicenseData(
      LicenseDiskData vehicleLicenseData) async {
    gatePass.trailerRegNumberTwoValidation = vehicleLicenseData.licensePlateNo;

    // EXIT MODE handling
    if (_isExitMode) {
      final expected = trailerTwoEntryReg;

      if (expected != null &&
          !_sameReg(expected, vehicleLicenseData.licensePlateNo)) {
        var msg =
            "Trailer Two registration on EXIT does not match: Expected $expected, Scanned ${vehicleLicenseData.licensePlateNo}";
        setValidationMessage(msg);
        logIncident("EXIT MISMATCH: $msg");

        await _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          data: BasicDialogStatus.warning,
          title: "Exit Verification Warning",
          description:
              "$msg\n\nIncident has been logged. You may continue with exit authorization.",
          mainButtonTitle: "Continue",
        );
      } else {
        clearAllValidationMessage();
        if (gatePass.trailerRegNumberTwo == null ||
            gatePass.trailerRegNumberTwo!.isEmpty) {
          gatePass.trailerRegNumberTwo = vehicleLicenseData.licensePlateNo;
        }

        Fluttertoast.showToast(
          msg: "Trailer Two matches entry record ✓",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }

      _trailerTwoScannedOnExit = true;
      return;
    }

    // NORMAL ENTRY MODE (not exit)
    if (isManualInput &&
        (gatePass.trailerRegNumberTwo == null ||
            gatePass.trailerRegNumberTwo!.isEmpty)) {
      gatePass.trailerRegNumberTwo = vehicleLicenseData.licensePlateNo;
    }

    setTrailerValidationMessage("Two");

    if (vehicleLicenseData.expiryDate != null &&
        vehicleLicenseData.expiryDate!.isBefore(DateTime.now())) {
      logIncident(
          "Trailer Two (${vehicleLicenseData.make}, ${vehicleLicenseData.licensePlateNo}) expired on ${vehicleLicenseData.expiryDate}. Please check the vehicle's license validity. ");
    }

    if (!_isExitMode &&
        gatePass.trailerRegNumberTwoMatch == false &&
        hasTrailerManualInputPermission) {
      _showTrailerTwoManualInput = true;
      scrollToWidget(trailerTwoInfoCardKey);
      return;
    }

    if (isManualEntryWizard && !_isExitMode) {
      if (showValidation) {
        rebuildUi();
        scrollToFirstError();
      }
      return;
    }

    if (showValidation) {
      rebuildUi();
      scrollToFirstError();
    }
  }

void setContainerDeliveryType(DeliveryType? deliveryType) {
  gatePass.containerDeliveryType = deliveryType;
  gatePass.gatePassDeliveryType = deliveryType!;

  if (deliveryType != null) {
    clearValidationMessage("Delivery type is required");
  } else {
    setValidationMessage("Delivery type is required");
  }

  notifyListeners();
}

  void setContainerCargoType(GatePassContainerType? cargoType) {
    gatePass.gatePassContainerType = cargoType;

    if (cargoType != null) {
      clearValidationMessage("Cargo type is required");
      if (_isContainerInfoComplete()) {
        Fluttertoast.showToast(
          msg: "Container details complete! Ready to authorize.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        scrollToFirstError();
      } else {
        Fluttertoast.showToast(
          msg: "You can add Customer/Depot (optional) or Authorize Entry",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
      }
    } else {
      setValidationMessage("Cargo type is required");
    }

    notifyListeners();
  }

  bool _isContainerInfoComplete() {
    return gatePass.containerNumber != null &&
        gatePass.containerNumber!.isNotEmpty &&
        gatePass.containerShippingLine != null &&
        gatePass.containerShippingLine!.isNotEmpty &&
        gatePass.containerDeliveryType != null &&
        gatePass.gatePassContainerType != null;
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
        description:
            'Could not Save,Please check you internet connection and try again',
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
      description:
          'Could not authorize for entry,Please check you internet connection and try again',
      mainButtonTitle: "Ok",
    );

    return;
  }
  setBusy(true);

  // For manual entries
  if (isManualInput) {
    // Check driver information
    if ((gatePass.driverIdNo == null || gatePass.driverIdNo!.isEmpty) &&
        (gatePass.driverIdNoValidation == null ||
            gatePass.driverIdNoValidation!.isEmpty)) {
      scrollToWidget(driverInfoCardKey);
      Fluttertoast.showToast(
        msg:
        "Please scan or enter driver information before authorizing entry",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setBusy(false);
      return;
    }

    // Check vehicle information
    if ((gatePass.vehicleRegNumber == null ||
     gatePass.vehicleRegNumber!.isEmpty) &&
        (gatePass.vehicleRegNumberValidation == null ||
            gatePass.vehicleRegNumberValidation!.isEmpty)) {
      scrollToWidget(vehicleInfoCardKey);
      Fluttertoast.showToast(
        msg:
         "Please scan or enter vehicle registration before authorizing entry",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setBusy(false);
      return;
    }

    // Check transporter
    if (gatePass.transporterId == null) {
      scrollToWidget(logisticsInfoCardKey);
      Fluttertoast.showToast(
        msg: "Please select a transporter before authorizing entry",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      setBusy(false);
      return;
    }

    // Check container info if applicable
    if (!_validateContainerInfoForAuthorization()) {
      setBusy(false);
      return;
    }

    // Copy validation data to main fields if needed
    if (gatePass.driverIdNo == null &&
      gatePass.driverIdNoValidation != null) {
      gatePass.driverIdNo = gatePass.driverIdNoValidation;
    }
    if (gatePass.vehicleRegNumber == null &&
     gatePass.vehicleRegNumberValidation != null) {
      gatePass.vehicleRegNumber = gatePass.vehicleRegNumberValidation;
    }   
    if (gatePass.gatePassBookingType == GatePassBookingType.containers) {
      if (containerNumberController.text.isNotEmpty) {
        gatePass.containerNumber = containerNumberController.text.toUpperCase();
      }
      if (gatePass.containerId == null || gatePass.containerId!.isEmpty) {
        gatePass.containerId = Guid.newGuidAsString;
      }
      gatePass.handleContainers();
    }

    String? savedContainerId = gatePass.containerId;
    String? savedContainerNumber = gatePass.containerNumber;
    String? savedContainerSize = gatePass.containerSize;
    String? savedContainerType = gatePass.containerType;
    int? savedContainerSizeId = gatePass.containerSizeId;
    int? savedContainerTypeId = gatePass.containerTypeId;
    String? savedContainerShippingLine = gatePass.containerShippingLine;
    int? savedContainerShippingLineId = gatePass.containerShippingLineId;
    String? savedContainerCustomer = gatePass.containerCustomer;
    int? savedContainerCustomerId = gatePass.containerCustomerId;
    String? savedContainerDepot = gatePass.containerDepot;
    int? savedContainerDepotId = gatePass.containerDepotId;
    DeliveryType? savedContainerDeliveryType = gatePass.containerDeliveryType;
    GatePassContainerType? savedGatePassContainerType = gatePass.gatePassContainerType;
    List<GatePassAccessContainerModel>? savedContainers = gatePass.containers != null 
        ? List<GatePassAccessContainerModel>.from(gatePass.containers!) 
        : null;

    var updatedGatePass = await _gatePassService.update(gatePass);

    if (updatedGatePass != null) {
      _gatePass = updatedGatePass;
      
      if (gatePass.gatePassBookingType == GatePassBookingType.containers) {
        gatePass.containerId = savedContainerId;
        gatePass.containerNumber = savedContainerNumber;
        gatePass.containerSize = savedContainerSize;
        gatePass.containerType = savedContainerType;
        gatePass.containerSizeId = savedContainerSizeId;
        gatePass.containerTypeId = savedContainerTypeId;
        gatePass.containerShippingLine = savedContainerShippingLine;
        gatePass.containerShippingLineId = savedContainerShippingLineId;
        gatePass.containerCustomer = savedContainerCustomer;
        gatePass.containerCustomerId = savedContainerCustomerId;
        gatePass.containerDepot = savedContainerDepot;
        gatePass.containerDepotId = savedContainerDepotId;
        gatePass.containerDeliveryType = savedContainerDeliveryType;
        gatePass.gatePassContainerType = savedGatePassContainerType;
        gatePass.containers = savedContainers;
        
        gatePass.handleContainers();
      }
    } else {
      Fluttertoast.showToast(
        msg: "Failed to update gate pass. Please try again.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM_LEFT,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      setBusy(false);
      return;
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

  var response = await _gatePassService.authorizeForEntry(gatePass);
  if (response != null) {
    _gatePass = response;

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
        description:
            'Could not authorize for entry,Please check you internet connection and try again',
        mainButtonTitle: "Ok",
      );
      return;
    }

    //confirmation before we authorize
    var confirm = await _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      data: BasicDialogStatus.warning,
      title: "Confirm Exit",
      description:
          'Are you sure you want to authorize this Gate Pass for exit?',
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
    var response = await _gatePassService.authorizeExit(gatePass);
    if (response != null) {
      _gatePass = response;
      setBusy(false);
      Fluttertoast.showToast(
          msg: "Authorize for Exit was successful!",
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
      // Load general gate booking images
      _fileStoreItems = await _fileStoreRepository.getAll(
          gatePass.id!, FileStoreType.gateBookingImage, 100);

      // Load foreign license photos
      final foreignLicensePhotos = await _fileStoreRepository.getAll(
          gatePass.id!, FileStoreType.gatePassAccessDriverLicenceImage, 100);
      if (foreignLicensePhotos.isNotEmpty) {
        _foreignLicensePhotoTaken = true;
        _foreignLicensePhotoPath = foreignLicensePhotos.first;
      } else {
        _foreignLicensePhotoTaken = false;
        _foreignLicensePhotoPath = null;
      }

      // Load vehicle manual entry photos
      if (_vehicleManualEntryUsed) {
        final vehiclePhotos = await _fileStoreRepository.getAll(
            gatePass.id!, FileStoreType.gatePassVehicleImage, 100);
        if (vehiclePhotos.isNotEmpty) {
          _vehicleManualPhotoPath = vehiclePhotos.last;
          _vehicleManualPhotoTaken = true;
        } else {
          _vehicleManualPhotoPath = null;
          _vehicleManualPhotoTaken = false;
        }
      }

      // Load trailer one manual entry photos
      if (_trailerOneManualEntryUsed) {
        final trailerOnePhotos = await _fileStoreRepository.getAll(
            gatePass.id!, FileStoreType.gatePassTrailerOneImage, 100);
        if (trailerOnePhotos.isNotEmpty) {
          _trailerOneManualPhotoPath = trailerOnePhotos.last;
          _trailerOneManualPhotoTaken = true;
        } else {
          _trailerOneManualPhotoPath = null;
          _trailerOneManualPhotoTaken = false;
        }
      }

      // Load trailer two manual entry photos
      if (_trailerTwoManualEntryUsed) {
        final trailerTwoPhotos = await _fileStoreRepository.getAll(
            gatePass.id!, FileStoreType.gatePassTrailerTwoImage, 100);
        if (trailerTwoPhotos.isNotEmpty) {
          _trailerTwoManualPhotoPath = trailerTwoPhotos.last;
          _trailerTwoManualPhotoTaken = true;
        } else {
          _trailerTwoManualPhotoPath = null;
          _trailerTwoManualPhotoTaken = false;
        }
      }
    }
  }

  Future<void> goToCamCaptureContainerNoText() async {
    closeKeyboard();
    if (gatePass.id != null && gatePass.id != 0) {
      var contInfo = await _navigationService
          .navigateToCamContainernoReaderView() as ContainerInfo?;

      if (contInfo != null) {
        gatePass.containerNumber = contInfo.containerNumber;
        containerNumberController.text = contInfo.containerNumber ?? '';
        if (gatePass.containerId == null || gatePass.containerId!.isEmpty) {
          gatePass.containerId = Guid.newGuidAsString;
        }
        if (contInfo.isoType.isNotEmpty) {
          final isoType = _isoTypeService.findByCode(contInfo.isoType);

          if (isoType != null) {
            String sizeCode = isoType.size;
            if (sizeCode == '20') {
              gatePass.containerSize = '20 FT';
            } else if (sizeCode == '22') {
              gatePass.containerSize = '22 FT';
            } else if (sizeCode == '42') {
              gatePass.containerSize = '40 FT';
            } else if (sizeCode == '45') {
              gatePass.containerSize = '45 FT';
            } else if (sizeCode == '25' || sizeCode == '26') {
              gatePass.containerSize = '20 FT';
            } else if (sizeCode == '28') {
              gatePass.containerSize = '20 FT';
            } else if (sizeCode == '2E') {
              gatePass.containerSize = '20 FT';
            } else if (sizeCode == '4C') {
              gatePass.containerSize = '40 FT';
            } else if (sizeCode == 'L0' ||
                sizeCode == 'L2' ||
                sizeCode == 'L5') {
              gatePass.containerSize = '45 FT';
            } else {
              if (sizeCode.startsWith('2')) {
                gatePass.containerSize = '20 FT';
              } else if (sizeCode.startsWith('4')) {
                gatePass.containerSize = '40 FT';
              }
            }

            String sizeNumber = isoType.size; 
            String typeCode = isoType.type; 

            gatePass.containerType = "$sizeNumber$typeCode";

            switch (gatePass.containerSize) {
              case "20 FT":
                gatePass.containerSizeId = 1; 
                break;
              case "22 FT":
                gatePass.containerSizeId = 1; 
                break;
              case "40 FT":
                gatePass.containerSizeId = 2; 
                break;
              case "45 FT":
                gatePass.containerSizeId = 3; 
                break;
            }

                switch (typeCode) {
              case "GP":
                gatePass.containerTypeId = 1; // General Purpose
                break;
              case "RT":
              case "RC":
              case "RS":
                gatePass.containerTypeId = 2; // Reefer
                break;
              case "TD":
              case "TG":
              case "TN":
                gatePass.containerTypeId = 3; // Tank
                break;
              case "UT":
              case "UP":
                gatePass.containerTypeId = 4; // Open Top
                break;
              case "PF":
              case "PC":
              case "PS":
              case "PL":
                gatePass.containerTypeId = 5; // Flat/Platform
                break;
              default:
                gatePass.containerTypeId = 1; // Default to GP
            }

          } else {
           
            if (contInfo.isoType.length >= 4) {
              String fullCode = contInfo.isoType;
              String sizeCode = fullCode.substring(0, 2);
              String typeCode = fullCode.substring(2, 4);
         
              String typeLetter = typeCode.substring(0, 1).toUpperCase();

               String fullTypeCode = typeLetter;
              if (typeLetter == 'G') {
                fullTypeCode = 'GP';
              } else if (typeLetter == 'R') {
                fullTypeCode = 'RT';
              } else if (typeLetter == 'T') {
                fullTypeCode = 'TD';
              } else if (typeLetter == 'U') {
                fullTypeCode = 'UT';
              } else if (typeLetter == 'P') {
                fullTypeCode = 'PF';
              } else if (typeLetter == 'H') {
                fullTypeCode = 'HR';
              } else if (typeLetter == 'V') {
                fullTypeCode = 'VH';
              } else if (typeLetter == 'B') {
                fullTypeCode = 'BU';
              } else if (typeLetter == 'S') {
                fullTypeCode = 'SN';
              }

              gatePass.containerType = sizeCode + fullTypeCode;
                  if (sizeCode == '20' ||
                  sizeCode == '22' ||
                  sizeCode == '25' ||
                  sizeCode == '2E') {
                gatePass.containerSize = '20 FT';
                gatePass.containerSizeId = 1;
              } else if (sizeCode == '40' ||
                  sizeCode == '42' ||
                  sizeCode == '45' ||
                  sizeCode == '4C') {
                gatePass.containerSize = '40 FT';
                gatePass.containerSizeId = 2;
              } else if (sizeCode == 'L0' ||
                  sizeCode == 'L2' ||
                  sizeCode == 'L5') {
                gatePass.containerSize = '45 FT';
                gatePass.containerSizeId = 3;
              } else if (sizeCode.startsWith('2')) {
                gatePass.containerSize = '20 FT';
                gatePass.containerSizeId = 1;
              } else if (sizeCode.startsWith('4')) {
                gatePass.containerSize = '40 FT';
                gatePass.containerSizeId = 2;
              } else {
                gatePass.containerSize = '20 FT';
                gatePass.containerSizeId = 1;
              }

              if (typeLetter == 'G') {
                gatePass.containerTypeId = 1; // General Purpose
              } else if (typeLetter == 'R') {
                gatePass.containerTypeId = 2; // Reefer
              } else if (typeLetter == 'T') {
                gatePass.containerTypeId = 3; // Tank
              } else if (typeLetter == 'U') {
                gatePass.containerTypeId = 4; // Open Top
              } else if (typeLetter == 'P') {
                gatePass.containerTypeId = 5; // Flat/Platform
              } else {
                gatePass.containerTypeId = 1; // Default to GP
              }

              log.i(
                  'Fallback parsing: Size=${gatePass.containerSize}, Type=${gatePass.containerType}');
              log.i(
                  'Fallback IDs: SizeID=${gatePass.containerSizeId}, TypeID=${gatePass.containerTypeId}');
            }
          }
        }

        clearValidationMessage("Container number is required");

        Fluttertoast.showToast(
          msg: "Container ${contInfo.containerNumber} scanned successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        setModelUpdate(gatePass);
        rebuildUi();
        notifyListeners();
      }
    }
  }

  Future<void> goToCamView(FileStoreType fileStoreType) async {
    closeKeyboard();
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
    closeKeyboard();
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
    closeKeyboard();
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

    if (isManualInput) {
      gatePass.vehicleRegNumber = cleanedRegNumber;
      await _processSuccessfulVehicleEntry();
      return;
    }
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

    if (_isExitMode) {
      _vehicleScannedOnExit = true;
    }
    await promptForVehiclePhoto();

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
          "Vehicle registration", gatePass.vehicleRegNumber, enteredRegNumber),
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

    if (isManualInput) {
      gatePass.trailerRegNumberOne = registrationNumber;
      _trailerOneManualEntryUsed = true;
      _trailerOneManualPhotoTaken = false;
      gatePass.isTrailerOneManualInput = true;

      if (_isExitMode) {
        _trailerOneScannedOnExit = true;
      }

      await promptForTrailerOnePhoto();

      _showTrailerOneManualInput = false;
      setModelUpdate(gatePass);
      rebuildUi();
      return;
    }

    setTrailerValidationMessage("One");

    if (gatePass.trailerRegNumberOneMatch == true) {
      _trailerOneManualEntryUsed = true;
      _trailerOneManualPhotoTaken = false;
      gatePass.isTrailerOneManualInput = true;

      if (_isExitMode) {
        _trailerOneScannedOnExit = true;
      }
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

    if (isManualInput) {
      gatePass.trailerRegNumberTwo = registrationNumber;
      _trailerTwoManualEntryUsed = true;
      _trailerTwoManualPhotoTaken = false;
      gatePass.isTrailerTwoManualInput = true;

      if (_isExitMode) {
        _trailerTwoScannedOnExit = true;
      }

      await promptForTrailerTwoPhoto();

      _showTrailerTwoManualInput = false;
      setModelUpdate(gatePass);
      rebuildUi();
      return;
    }

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
    if (_isExitMode) {
      _trailerTwoScannedOnExit = true;
    }
    setModelUpdate(gatePass);
    rebuildUi();
  }

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
          fileStoreType: FileStoreType.gatePassVehicleImage,
        ),
      );

      await loadFileStoreImages();

      if (_fileStoreItems.length > photoCountBefore) {
        _vehicleManualPhotoPath = _fileStoreItems.lastOrNull;
        _vehicleManualPhotoTaken = true;
      }

      rebuildUi();

      FocusManager.instance.primaryFocus?.unfocus();

      await Future.delayed(const Duration(milliseconds: 300));

      if (isManualInput || hasTrailerOneEntryReg) {
        setBarcodeScanType(BarcodeScanType.trailerOneDisc);
        scrollToWidget(trailerOneInfoCardKey);
      } else if (isManualInput || hasTrailerTwoEntryReg) {
        setBarcodeScanType(BarcodeScanType.trailerTwoDisc);
        scrollToWidget(trailerTwoInfoCardKey);
      } else if (isManualInput && !_isExitMode) {
        scrollToWidget(logisticsInfoCardKey);
      } else if (gatePass.gatePassBookingType ==
              GatePassBookingType.containers &&
          isManualInput &&
          !_isExitMode) {
        scrollToWidget(containerInfoCardKey);
      } else {
        scrollToWidget(timesInfoCardKey);
      }
    }
  }

  Future<void> promptForTrailerOnePhoto() async {
    var result = await _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      data: BasicDialogStatus.info,
      title: "Photo Required",
      description:
          ValidationMessages.photoRequiredForManualInput("trailer one"),
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
          fileStoreType: FileStoreType.gatePassTrailerOneImage,
        ),
      );

      await loadFileStoreImages();

      if (_fileStoreItems.length > photoCountBefore) {
        _trailerOneManualPhotoPath = _fileStoreItems.lastOrNull;
        _trailerOneManualPhotoTaken = true;
      }

      rebuildUi();

      FocusManager.instance.primaryFocus?.unfocus();

      await Future.delayed(const Duration(milliseconds: 300));

      if (isManualInput || hasTrailerTwoEntryReg) {
        setBarcodeScanType(BarcodeScanType.trailerTwoDisc);
        scrollToWidget(trailerTwoInfoCardKey);
      } else if (isManualInput && !_isExitMode) {
        scrollToWidget(logisticsInfoCardKey);
      } else if (gatePass.gatePassBookingType ==
              GatePassBookingType.containers &&
          isManualInput &&
          !_isExitMode) {
        scrollToWidget(containerInfoCardKey);
      } else {
        scrollToWidget(timesInfoCardKey);
      }
    }
  }

  Future<void> promptForTrailerTwoPhoto() async {
    var result = await _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      data: BasicDialogStatus.info,
      title: "Photo Required",
      description:
          ValidationMessages.photoRequiredForManualInput("trailer two"),
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
          fileStoreType: FileStoreType.gatePassTrailerTwoImage,
        ),
      );

      await loadFileStoreImages();

      if (_fileStoreItems.length > photoCountBefore) {
        _trailerTwoManualPhotoPath = _fileStoreItems.lastOrNull;
        _trailerTwoManualPhotoTaken = true;
      }

      rebuildUi();

      FocusManager.instance.primaryFocus?.unfocus();

      await Future.delayed(const Duration(milliseconds: 300));

      if (isManualInput && !_isExitMode) {
        rebuildUi();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          rebuildUi();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            rebuildUi();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (logisticsInfoCardKey.currentContext != null) {
                Scrollable.ensureVisible(
                  logisticsInfoCardKey.currentContext!,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
                Fluttertoast.showToast(
                  msg: "Please select Transporter ↓",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                );
              } else {
                Fluttertoast.showToast(
                  msg: "Please select Transporter",
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.blue,
                  textColor: Colors.white,
                );
              }
            });
          });
        });
      } else {
        if (gatePass.gatePassBookingType == GatePassBookingType.containers &&
            !_isExitMode) {
          scrollToWidget(containerInfoCardKey);
        } else {
          scrollToWidget(timesInfoCardKey);
        }
      }
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
    closeKeyboard();
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
    if (isManualEntryWizard && !_isExitMode) {
      // Check driver completion
      final bool driverComplete = (gatePass.driverIdNoValidation != null &&
              gatePass.driverIdNoValidation!.isNotEmpty) ||
          (gatePass.driverIdNo != null && gatePass.driverIdNo!.isNotEmpty);

      if (!driverComplete) {
        scrollToWidget(driverInfoCardKey);
        Fluttertoast.showToast(
          msg: "Please scan or enter driver information first",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      // Check vehicle completion
      final bool vehicleComplete =
          (gatePass.vehicleRegNumberValidation != null &&
                  gatePass.vehicleRegNumberValidation!.isNotEmpty) ||
              (gatePass.vehicleRegNumber != null &&
                  gatePass.vehicleRegNumber!.isNotEmpty) ||
              _vehicleManualEntryUsed;

      if (!vehicleComplete) {
        scrollToWidget(vehicleInfoCardKey);
        Fluttertoast.showToast(
          msg: "Please scan or enter vehicle registration first",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      // Check trailer one completion (if it exists)
      final bool hasTrailerOne = (gatePass.trailerRegNumberOne != null &&
              gatePass.trailerRegNumberOne!.isNotEmpty) ||
          (gatePass.trailerRegNumberOneValidation != null &&
              gatePass.trailerRegNumberOneValidation!.isNotEmpty) ||
          _trailerOneManualEntryUsed;

      final bool trailerOneComplete = !hasTrailerOne ||
          (gatePass.trailerRegNumberOneValidation != null &&
              gatePass.trailerRegNumberOneValidation!.isNotEmpty) ||
          _trailerOneManualEntryUsed;

      if (!trailerOneComplete) {
        scrollToWidget(trailerOneInfoCardKey);
        Fluttertoast.showToast(
          msg: "Please scan or enter Trailer One registration first",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }

      // Check trailer two completion (if it exists)
      final bool hasTrailerTwo = (gatePass.trailerRegNumberTwo != null &&
              gatePass.trailerRegNumberTwo!.isNotEmpty) ||
          (gatePass.trailerRegNumberTwoValidation != null &&
              gatePass.trailerRegNumberTwoValidation!.isNotEmpty) ||
          _trailerTwoManualEntryUsed;

      final bool trailerTwoComplete = !hasTrailerTwo ||
          (gatePass.trailerRegNumberTwoValidation != null &&
              gatePass.trailerRegNumberTwoValidation!.isNotEmpty) ||
          _trailerTwoManualEntryUsed;

      if (!trailerTwoComplete) {
        scrollToWidget(trailerTwoInfoCardKey);
        Fluttertoast.showToast(
          msg: "Please scan or enter Trailer Two registration first",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        return;
      }
    }

    // Now set the transporter
    gatePass.transporterId = transporterId;

    if (isManualInput) {
      if (transporterId != null) {
        clearValidationMessage("Transporter is required for manual entries");

        // For manual entry, move the wizard past transporter
        if (isManualEntryWizard && !_isExitMode) {
          _manualEntryStep = isContainerCargo
              ? ManualEntryStep.containerDetails
              : ManualEntryStep.done;

          // Show completion message and scroll to container if needed
          if (isContainerCargo) {
            Future.delayed(const Duration(milliseconds: 300), () {
              scrollToWidget(containerInfoCardKey,
                  duration: const Duration(milliseconds: 500));

              Fluttertoast.showToast(
                msg: "Please fill in container details ↓",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.blue,
                textColor: Colors.white,
              );
            });
          } else {
            Fluttertoast.showToast(
              msg:
                  "All required information complete. Ready to authorize entry.",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              backgroundColor: Colors.green,
              textColor: Colors.white,
            );
          }
        }
      } else {
        setValidationMessage("Transporter is required for manual entries");
      }
    }

    notifyListeners();
  }

  bool _validateContainerInfoForAuthorization() {
  if (gatePass.gatePassBookingType != GatePassBookingType.containers) {
    return true; 
  }

  if (!isManualInput) {
    return true; 
  }


  // Container number validation
  if (gatePass.containerNumber == null || gatePass.containerNumber!.isEmpty) {
    scrollToWidget(containerInfoCardKey);
    Fluttertoast.showToast(
      msg: "Container number is required",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
    return false;
  }

  // Shipping line validation
  if (gatePass.containerShippingLine == null ||
      gatePass.containerShippingLine!.isEmpty) {
    scrollToWidget(containerInfoCardKey);
    return false;
  }

  // Delivery type validation
  if (gatePass.containerDeliveryType == null) {
    scrollToWidget(containerInfoCardKey);
    return false;
  }

  // Cargo type validation
  if (gatePass.gatePassContainerType == null) {
    scrollToWidget(containerInfoCardKey);
    return false;
  }

  return true;
}

  void viewVehiclePhoto() async {
    closeKeyboard();
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
    closeKeyboard();
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
    closeKeyboard();
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

    try {
      _shippingLines = await _gatePassService.getShippingLines();
      _cachedShippingLines = _shippingLines;
      _shippingLineCacheTime = DateTime.now();

      // REMOVE THIS LINE: _shippingLines = [];

      notifyListeners();
    } catch (e) {
      _shippingLines = [];
      notifyListeners();
    }
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

    try {
      _containerCustomers = await _gatePassService.getContainerCustomers();
      _cachedContainerCustomers = _containerCustomers;
      _containerCustomerCacheTime = DateTime.now();

      log.i('Loaded ${_containerCustomers.length} container customers');
      notifyListeners();
    } catch (e) {
      log.e('Error loading container customers: $e');
      _containerCustomers = [];
      notifyListeners();
    }
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

    try {
      _containerDepots = await _gatePassService.getContainerDepots();
      _cachedContainerDepots = _containerDepots;
      _containerDepotCacheTime = DateTime.now();

      log.i('Loaded ${_containerDepots.length} container depots');
      notifyListeners();
    } catch (e) {
      log.e('Error loading container depots: $e');
      _containerDepots = [];
      notifyListeners();
    }
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

  Future<void> reloadGatePassWithContainers() async {
    setBusy(true);
    try {
      var reloaded =
          await _gatePassService.getGatePassWithContainers(gatePass.id);

      if (reloaded != null) {
        _gatePass = reloaded;
        notifyListeners();
      }
    } catch (e) {
      log.e('Error reloading gate pass with containers: $e');
    } finally {
      setBusy(false);
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
      containerNumberController.text = gatePass.containerNumber ?? '';
      notifyListeners();
    }
  }

  void setShippingLine(int? shippingLineId) {
    if (shippingLineId != null) {
      var shippingLine =
          _shippingLines.firstWhereOrNull((s) => s.id == shippingLineId);

      if (shippingLine != null) {
        gatePass.containerShippingLine = shippingLine.name;
        gatePass.containerShippingLineId = shippingLine.id;

        clearValidationMessage("Shipping line is required");
      }
    } else {
      gatePass.containerShippingLine = null;
      gatePass.containerShippingLineId = null;
    }

    notifyListeners();
  }

  Future<void> rejectEntry() async {
    if (!_connectionService.hasConnection) {
      await _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        data: BasicDialogStatus.warning,
        title: "Internet Connection Failure",
        description:
            'Could not authorize for entry, please check your internet connection and try again',
        mainButtonTitle: "Ok",
      );
      return;
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

    // Here we save back to server
    var response = await _gatePassService.rejectForEntry(gatePass);
    if (response != null) {
      _gatePass = response;
      Fluttertoast.showToast(
          msg: "Save was successful!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM_LEFT,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14.0);
    } else {
      Fluttertoast.showToast(
          msg: "Save Failed! Please try again or contact your system admin.",
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

  void closeKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}

extension StringCapitalize on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}