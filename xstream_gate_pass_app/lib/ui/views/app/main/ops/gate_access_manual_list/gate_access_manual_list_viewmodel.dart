import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/app/app.bottomsheets.dart';
import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_type.dart';
import 'package:xstream_gate_pass_app/core/models/ops/gatepass/gate-pass-access_model.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/gatepass/gatepass_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/guid_generator.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';

class GateAccessManualListViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _gatePassService = locator<GatePassService>();
  final _localStorageService = locator<LocalStorageService>();

 
  List<GatePassAccess> _manualEntries = [];  
  List<GatePassAccess> get manualEntries => _manualEntries;  

  bool get hasInYardEntries =>
      manualEntries.any((e) => e.gatePassStatus == GatePassStatus.inYard);
      
        get log => null;

  Future<void> initialize() async {
    await refreshList();
  }

Future<void> refreshList() async {
  setBusy(true);

      var allEntries = await _gatePassService.getManualEntries();
    

    
    if (allEntries.isNotEmpty) {

    }
    
    _manualEntries = allEntries;  
    

  
  setBusy(false);
  notifyListeners();
  
}
  Future<void> showCheckInOptions() async {
    final result = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.manualEntrySelection,
      title: 'Check In',
      description: 'Select operation type',
      data: {
        'action': 'checkin',
      },
    );

    if (result?.confirmed == true && result?.data != null) {
      final selectedType = result!.data as String;
      await _createManualEntry(
        isContainer: selectedType == 'container',
      );
    }
  }

  Future<void> showCheckOutOptions() async {
    final inYardEntries = manualEntries
        .where((e) => e.gatePassStatus == GatePassStatus.inYard)
        .toList();

    if (inYardEntries.isEmpty) return;

    final result = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.manualEntrySelection,
      title: 'Check Out',
      description: 'Select vehicle to check out',
      data: {
        'action': 'checkout',
        'entries': inYardEntries,
      },
    );

    if (result?.confirmed == true && result?.data != null) {
      final selectedEntry = result!.data as GatePassAccess;
      await openGatePass(selectedEntry);
    }
  }

  Future<void> _createManualEntry({
    required bool isContainer,
  }) async {
    final userInfo = _localStorageService.getUserLoginInfo;

    if (userInfo == null || userInfo.user == null) return;

    int branchId = 0;
    if (userInfo.user!.userBranches.isNotEmpty) {
      branchId = userInfo.user!.userBranches.first.id ?? 0;
    }

    final tenantId = userInfo.tenant?.id ?? 0;

    if (branchId == 0) return;

    final gatePass = GatePassAccess(
      id: Guid.defaultValue.toString(),
      externalId: null,
      gatePassDeliveryType: DeliveryType.receive,
      gatePassBookingType: isContainer
          ? GatePassBookingType.containers
          : GatePassBookingType.breakBulk,
      gatePassStatus: GatePassStatus.pending,
      timeAtGate: DateTime.now(),
      branchId: branchId,
      tenantId: tenantId,
    );

    final result = await _navigationService.navigateTo(
      Routes.gatePassEditView,
      arguments: GatePassEditViewArguments(
        gatePass: gatePass,
      ),
    );

    if (result != null) {
      await refreshList();
    }
  }

  Future<void> openGatePass(GatePassAccess gatePass) async {
    final result = await _navigationService.navigateTo(
      Routes.gatePassEditView,
      arguments: GatePassEditViewArguments(
        gatePass: gatePass,
      ),
    );

    if (result != null) {
      await refreshList();
    }
  }
}