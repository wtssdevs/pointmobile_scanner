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

class GatePassEditViewModel extends BaseFormViewModel with AppViewBaseHelper {
  GatePassEditViewModel(this._gatePass);
  GatePassAccess _gatePass;
  GatePassAccess get gatePass => _gatePass;
  Function? _onModelSet;

  final log = getLogger('GatePassEditViewModel');
  final LocalStorageService _localStorageService = locator<LocalStorageService>();
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

// Driver information section
  final GlobalKey driverInfoCardKey = GlobalKey(debugLabel: 'driverInfoCard');
  final GlobalKey vehicleInfoCardKey = GlobalKey(debugLabel: 'vehicleInfoCard');
  final GlobalKey trailerOneInfoCardKey = GlobalKey(debugLabel: 'trailerOneInfoCard');
  final GlobalKey trailerTwoInfoCardKey = GlobalKey(debugLabel: 'trailerTwoInfoCard');

// Container information section
  final GlobalKey containerInfoCardKey = GlobalKey(debugLabel: 'containerInfoCard');
  final GlobalKey timesInfoCardKey = GlobalKey(debugLabel: 'timesInfoCard');

  StreamSubscription<RsaDriversLicense>? streamSubscription;
  StreamSubscription<LicenseDiskData>? streamSubscriptionForDisc;
  List<FileStore> _fileStoreItems = <FileStore>[];
  List<FileStore> get fileStoreItems => _fileStoreItems;

  // Foreign license photo state
  bool _foreignLicensePhotoTaken = false;
  bool get foreignLicensePhotoTaken => _foreignLicensePhotoTaken;

  FileStore? _foreignLicensePhotoPath;
  FileStore? get foreignLicensePhotoPath => _foreignLicensePhotoPath;

  bool get hasConnection => _connectionService.hasConnection;
  List<SearchableDropdownMenuItem<int>> get serviceTypes => _masterFilesService.serviceTypes;

  BarcodeScanType _barcodeScanType = BarcodeScanType.driversCard;
  BarcodeScanType get barcodeScanType => _barcodeScanType;
  void setBarcodeScanType(BarcodeScanType type) {
    _barcodeScanType = type;
    _scanningService.setBarcodeScanType(type);
    rebuildUi();
  }

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
    await loadFileStoreImages();
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

//_checkListService

 Future<bool> findChecklistTemplate() async {
    final checkListFindTemplateModel =
        await _checkListService.findChecklistTemplate(
      FilterParams(
        branchId: currentUser?.userBranches.first.id,
        gateAccessBookingType: gatePass.gatePassBookingType,
        gatePassAccessId: gatePass.id,
        gateAccessDeliveryType: gatePass.gatePassDeliveryType,
        checklistType: ChecklistType.gatePassAccess,
      ),
    );

    if (checkListFindTemplateModel.hasTemplate == true) {
      // If checklist is already completed simply continue without opening the view
      if (checkListFindTemplateModel.isCompleted == true) {
        return true;
      }

      // Navigate to checklist view with the template data
      return await gotoCheckListView(checkListFindTemplateModel);
    }

    return true;
  }

  Future<bool> gotoCheckListView(CheckListFindTemplateModel checkListFindTemplateModel) async {
    //check for checklist on types and  load from server
    //set screen busy for this operation

    //setBusy(true); //show loading indicator
    //disable all other inputs during this time

    var completed = await _navigationService.navigateTo(
      Routes.checkListView,
      arguments: CheckListViewArguments(
        filterParams: FilterParams(
          branchId: currentUser?.userBranches.first.id,
          gateAccessBookingType: gatePass.gatePassBookingType,
          gatePassAccessId: gatePass.id,
          gateAccessDeliveryType: gatePass.gatePassDeliveryType,
          checklistType: ChecklistType.gatePassAccess,
          templateId: checkListFindTemplateModel.templateId,
          id: checkListFindTemplateModel.checklistId,
        ),
      ),
    );

    if (completed == true) {
      // If checklist was completed, refresh the gate pass data
      return true;
    }

    return false;
  }

  Future<void> startScanListener() async {
    setModelUpdate(_gatePass);

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
      log.i("Vehicle Lisence Plate data received");
      // Process the license disk data here
      // This would populate a GatePassVisitorAccess from the license disk data
      processScanData(null, licenseDiskData);
    });
  }

  void setDriverValidationMessage() {
    var msg = ValidationMessages.getDriverIdMismatchMessage(gatePass.driverIdNo, gatePass.driverIdNoValidation);
    if (gatePass.driverIdNoMatch == false) {
      setValidationMessage(msg);
      //enque incident
      logIncident(msg);
    } else {
      clearValidationMessage(msg);
    }
  }

  void setVehicleValidationMessage() {
    var msg = ValidationMessages.regNoMismatch("Vehicle registration", gatePass.vehicleRegNumber, gatePass.vehicleRegNumberValidation);
    if (gatePass.vehicleRegNoMatch == false) {
      setValidationMessage(msg);
      logIncident(msg);
    } else {
      clearValidationMessage(msg);
    }
  }

  //trailers one and two validation
  void setTrailerValidationMessage(String trailerNumber) {
    if (trailerNumber == "One") {
      var msg = ValidationMessages.regNoMismatch("Trailer One registration", gatePass.trailerRegNumberOne, gatePass.trailerRegNumberOneValidation);
      if (gatePass.trailerRegNumberOneMatch == false) {
        setValidationMessage(msg);
        logIncident(msg);
      } else {
        clearValidationMessage(msg);
      }
    } else if (trailerNumber == "Two") {
      var msg = ValidationMessages.regNoMismatch("Trailer Two registration", gatePass.trailerRegNumberTwo, gatePass.trailerRegNumberTwoValidation);
      if (gatePass.trailerRegNumberTwoMatch == false) {
        setValidationMessage(msg);
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

  Future<void> processScanData(RsaDriversLicense? rsaDriversLicense, LicenseDiskData? vehicleLicenseData) async {
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
    gatePass.driverName = '${driversLicense.firstNames} ${driversLicense.surname}';
    gatePass.driverIdNoValidation = driversLicense.idNumber;

    setDriverValidationMessage();

    gatePass.driverLicenceNo = driversLicense.licenseNumber;
    gatePass.driverLicenceIssueDate = driversLicense.issueDates?.firstOrNull;
    gatePass.driverLicenceExpiryDate = driversLicense.validTo;
    gatePass.driversLicenceCodes = driversLicense.vehicleCodes.join(',');
    gatePass.professionalDrivingPermitExpiryDate = driversLicense.prdpExpiry;

    //check if the drivers license has expired ,if true then we log an incident
    if (driversLicense.validTo != null && driversLicense.validTo.isBefore(DateTime.now())) {
      logIncident("Driver (${driversLicense.firstNames} ${driversLicense.surname}, ${driversLicense.idNumber}) with license (${driversLicense.licenseNumber}) expired on ${driversLicense.validTo}. Please check the driver's license validity. ");
    }
    if (driversLicense.prdpExpiry != null && driversLicense.prdpExpiry!.isBefore(DateTime.now())) {
      logIncident("Driver (${driversLicense.firstNames} ${driversLicense.surname}, ${driversLicense.idNumber}) with PRDP expired on ${driversLicense.prdpExpiry}. Please check the driver's PRDP validity. ");
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
  Future<void> processVehicleLicenseData(LicenseDiskData vehicleLicenseData) async {
    gatePass.vehicleEngineNumber = vehicleLicenseData.engineNumber;
    gatePass.vehicleMake = vehicleLicenseData.make;
    gatePass.vehicleRegNumberValidation = vehicleLicenseData.licensePlateNo;

    setVehicleValidationMessage();
    gatePass.vehicleVinNumber = vehicleLicenseData.vin;
    gatePass.vehicleRegisterNumber = vehicleLicenseData.vehicleRegisterNo;

    if (vehicleLicenseData.expiryDate != null && vehicleLicenseData.expiryDate!.isBefore(DateTime.now())) {
      logIncident("Vehicle (${vehicleLicenseData.make}, ${vehicleLicenseData.licensePlateNo}) expired on ${vehicleLicenseData.expiryDate}. Please check the vehicle's license validity. ");
    }
    // Determine next scan target based on trailer existence
    BarcodeScanType nextScanType = BarcodeScanType.vehicleDisc; // Default
    GlobalKey? nextSection;

    if (gatePass.trailerRegNumberOne != null && gatePass.trailerRegNumberOne!.isNotEmpty) {
      nextScanType = BarcodeScanType.trailerOneDisc;
      nextSection = trailerOneInfoCardKey;
    } else if (gatePass.trailerRegNumberTwo != null && gatePass.trailerRegNumberTwo!.isNotEmpty) {
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
  Future<void> processTrailerOneLicenseData(LicenseDiskData vehicleLicenseData) async {
    gatePass.trailerRegNumberOneValidation = vehicleLicenseData.licensePlateNo;

    // Check if trailer one reg matches scanned data

    // Set validation message
    setTrailerValidationMessage("One");
    if (vehicleLicenseData.expiryDate != null && vehicleLicenseData.expiryDate!.isBefore(DateTime.now())) {
      logIncident("Trailer One (${vehicleLicenseData.make}, ${vehicleLicenseData.licensePlateNo}) expired on ${vehicleLicenseData.expiryDate}. Please check the vehicle's license validity. ");
    }
    // Determine next scan target
    BarcodeScanType nextScanType = BarcodeScanType.trailerOneDisc; // Default
    GlobalKey? nextSection;

    if (gatePass.trailerRegNumberTwo != null && gatePass.trailerRegNumberTwo!.isNotEmpty) {
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
  Future<void> processTrailerTwoLicenseData(LicenseDiskData vehicleLicenseData) async {
    gatePass.trailerRegNumberTwoValidation = vehicleLicenseData.licensePlateNo;

    // Check if trailer two reg matches scanned data
    // Set validation message
    setTrailerValidationMessage("Two");
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
    //here we save back to server
    GatePassAccess? reponse;
    if (gatePass.id == 0) {
      reponse = await _gatePassService.create(gatePass);
    } else {
      reponse = await _gatePassService.update(gatePass);
    }

    if (reponse != null) {
      _gatePass = reponse;
      Fluttertoast.showToast(msg: "Save was successful! ", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM_LEFT, timeInSecForIosWeb: 8, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 14.0);
    } else {
      //error could not save
      Fluttertoast.showToast(msg: "Save Failed!,Please try again or contact your system admin. ", toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.BOTTOM_LEFT, timeInSecForIosWeb: 8, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 14.0);
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

      Fluttertoast.showToast(msg: "Authorize for Entry was successful! ", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM_LEFT, timeInSecForIosWeb: 8, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 14.0);
      _navigationService.back();
    } else {
      //error could not save
      Fluttertoast.showToast(msg: "Save Failed!,Please try again or contact your system admin. ", toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.BOTTOM_LEFT, timeInSecForIosWeb: 8, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 14.0);
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
      Fluttertoast.showToast(msg: "Authorize for Exit was successful! ", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM_LEFT, timeInSecForIosWeb: 8, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 14.0);
    } else {
      //error could not save
      Fluttertoast.showToast(msg: "Save Failed!,Please try again or contact your system admin. ", toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.BOTTOM_LEFT, timeInSecForIosWeb: 8, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 14.0);
    }

    _navigationService.back();
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

//confirmation before we reject
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

    //here we save back to server
    var reponse = await _gatePassService.rejectForEntry(gatePass);
    if (reponse != null) {
      _gatePass = reponse;
      Fluttertoast.showToast(msg: "Save was successful! ", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM_LEFT, timeInSecForIosWeb: 8, backgroundColor: Colors.green, textColor: Colors.white, fontSize: 14.0);
    } else {
      //error could not save
      Fluttertoast.showToast(msg: "Save Failed!,Please try again or contact your system admin. ", toastLength: Toast.LENGTH_LONG, gravity: ToastGravity.BOTTOM_LEFT, timeInSecForIosWeb: 8, backgroundColor: Colors.red, textColor: Colors.white, fontSize: 14.0);
    }

    //update Screen UI state with model changes
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
      _fileStoreItems = await _fileStoreRepository.getAll(gatePass.id!, FileStoreType.gateBookingImage, 100);

      // Load foreign license photos and update state
      final foreignLicensePhotos = await _fileStoreRepository.getAll(gatePass.id!, FileStoreType.gatePassAccessDriverLicenceImage, 100);
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
      var contInfo = await _navigationService.navigateToCamContainernoReaderView() as ContainerInfo?;
      if (contInfo != null) {
        gatePass.containerNumber = contInfo.containerNumber;
        gatePass.containerSize = contInfo.isoType.substring(0, 2);
        gatePass.containerType = contInfo.isoType.substring(2, 4);
        rebuildUi();
      }
    }
  }

  Future<void> goToCamView(FileStoreType fileStoreType) async {
    await getStoragePermissions();
    if (gatePass.id != null && gatePass.id != 0) {
      await _navigationService.navigateTo(
        Routes.cameraCaptureView,
        arguments: CameraCaptureViewArguments(refId: gatePass.id!, referanceId: 0, fileStoreType: fileStoreType),
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
        arguments: CameraCaptureViewArguments(refId: gatePass.id, referanceId: 0, fileStoreType: FileStoreType.gatePassAccessDriverLicenceImage),
      );

      // Load updated images and foreign license photo state
      await loadFileStoreImages();
      notifyListeners();
    }
  }

  Future<void> saveImageToLocalDb({required File galleryFile, required String tempFilePath}) async {
    await _fileStoreRepository.insert(
      FileStore(desc: "", referanceId: 0, filestoreType: FileStoreType.image.value, path: galleryFile.path, tempPath: tempFilePath, fileName: galleryFile.path, createdDateTime: Timestamp.now(), refId: gatePass.id!),
    );
  }

  Future<void> deleteImage(FileStore fileItem) async {
    var confirm = await _dialogService.showCustomDialog(variant: DialogType.infoAlert, data: BasicDialogStatus.warning, title: "Delete Image?.", description: 'Are you sure you want to Delete this image?', mainButtonTitle: "Confirm", takesInput: false, secondaryButtonTitle: "Cancel");

    if (confirm != null && confirm.confirmed) {
      await _fileStoreRepository.delete(fileItem);

      //server side delete of image
      await _workerQueManager.enqueSingle(BackgroundJobInfo(refTransactionId: gatePass.id, jobType: BackgroundJobType.syncImages.index, jobArgs: fileItem.fileName, lastTryTime: Timestamp.now(), creationTime: Timestamp.now(), nextTryTime: Timestamp.now(), id: "", isAbandoned: false));
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
}
