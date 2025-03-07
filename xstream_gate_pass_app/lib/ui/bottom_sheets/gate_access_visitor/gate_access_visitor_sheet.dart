import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/core/enums/barcode_scan_type.dart';
import 'package:xstream_gate_pass_app/core/enums/scan_action_types.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_access_visitor_model.dart';
import 'package:xstream_gate_pass_app/ui/bottom_sheets/widgets/default_build_header.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/build_Info_item.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/build_info_card.dart';
import 'package:xstream_gate_pass_app/ui/widgets/common/barcode_scanner_animation/barcode_scanner_animation.dart';
import 'gate_access_visitor_sheet_model.dart';

class GateAccessVisitorSheet extends StackedView<GateAccessVisitorSheetModel> {
  final Function(SheetResponse response)? completer;
  final SheetRequest request;
  const GateAccessVisitorSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    GateAccessVisitorSheetModel viewModel,
    Widget? child,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BaseSheetHeader(
            onTap: () => completer?.call(
              SheetResponse<GatePassVisitorAccess>(
                confirmed: false,
              ),
            ),
            title: 'Gate Pass Scanner',
          ),
          Expanded(
            child: _buildContent(context, viewModel),
          ),
          _buildFooter(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, GateAccessVisitorSheetModel viewModel) {
    // Show scanning UI or initial scan setup
    switch (viewModel.scanInMode) {
      case ScanActionType.checkIn:
      case ScanActionType.checkOut:
        return viewModel.isScanning ? _buildScanResultView(context, viewModel) : _buildScanSetupView(context, viewModel);
      case ScanActionType.preCheckIn:
        return _buildScanResultView(context, viewModel);

      default:
        return _buildScanSetupView(context, viewModel);
    }
  }

  Widget _buildFooter(BuildContext context, GateAccessVisitorSheetModel viewModel) {
    // Different footer based on current state
    if (viewModel.scannedVisitor.hasDriverInfo && viewModel.scannedVisitor.hasVehicleInfo) {
      // Show submit/cancel for scan results
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => viewModel.resetScanner(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: kcPrimaryColor),
              ),
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
          ),
          horizontalSpaceSmall,
          Expanded(
            child: ElevatedButton(
              onPressed: viewModel.isBusy
                  ? null
                  : () async {
                      final success = await viewModel.submitVisitorEntry();
                      if (success) {
                        completer?.call(
                          SheetResponse<GatePassVisitorAccess>(
                            confirmed: true,
                            data: viewModel.scannedVisitor,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: kcPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: viewModel.isBusy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      viewModel.scanInMode == ScanActionType.checkIn
                          ? 'Check In Visitor'
                          : viewModel.scanInMode == ScanActionType.preCheckIn
                              ? 'Validate Visitor'
                              : 'Check Out Visitor',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
        ],
      );
    } else if (viewModel.isScanning) {
      // Show cancel button during scanning
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          surfaceTintColor: Colors.red,
        ),
        onPressed: () async {
          if (viewModel.scanInMode == ScanActionType.preCheckIn) {
            //return to the list
            completer?.call(
              SheetResponse<GatePassVisitorAccess>(
                confirmed: false,
              ),
            );
            return;
          }
          viewModel.resetScanner();
        },
        icon: const FaIcon(
          FontAwesomeIcons.ban,
          color: Colors.red,
        ),
        label: const Text("Cancel Scan"), // <-- Text
      );
    } else {
      // Show scan button for initial state

      //show the start scanning button as disabled if the service type has not been selected

      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: !viewModel.hasConnection ? null : () => viewModel.startScanning(),
          style: ElevatedButton.styleFrom(
            backgroundColor: kcPrimaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, size: 20),
              horizontalSpaceSmall,
              Text(
                'Start Scanning',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildScanTypeCard(
    BuildContext context,
    GateAccessVisitorSheetModel viewModel,
    String title,
    BarcodeScanType type,
    IconData icon,
    String description,
  ) {
    final isSelected = viewModel.barcodeScanType == type;

    return GestureDetector(
      onTap: () => viewModel.setBarcodeScanType(type),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? kcPrimaryColor.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? kcPrimaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? kcPrimaryColor : Colors.grey[700],
              size: 32,
            ),
            verticalSpaceSmall,
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? kcPrimaryColor : Colors.black,
              ),
            ),
            verticalSpaceTiny,
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    GateAccessVisitorSheetModel viewModel,
    String title,
    bool isSelected,
    IconData icon,
    Color color,
    String description,
  ) {
    //final isSelected = viewModel.scanInMode == ScanActionType.checkIn;

    return GestureDetector(
      onTap: () => viewModel.setScanInMode(isSelected ? ScanActionType.checkIn : ScanActionType.checkOut),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[700],
              size: 32,
            ),
            verticalSpaceSmall,
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.black,
              ),
            ),
            verticalSpaceTiny,
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanResultView(BuildContext context, GateAccessVisitorSheetModel viewModel) {
    final visitor = viewModel.scannedVisitor;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Information
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: viewModel.scanInMode == ScanActionType.checkIn ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: viewModel.scanInMode == ScanActionType.checkIn ? Colors.green[200]! : Colors.orange[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  viewModel.scanInMode == ScanActionType.checkIn ? Icons.login : Icons.logout,
                  color: viewModel.scanInMode == ScanActionType.checkIn ? Colors.green[700] : Colors.orange[700],
                ),
                horizontalSpaceSmall,
                Text(
                  viewModel.scanInMode == ScanActionType.checkIn
                      ? 'This visitor will be checked in'
                      : viewModel.scanInMode == ScanActionType.preCheckIn
                          ? 'Find pre booked visitor for checked in'
                          : 'This visitor will be checked out',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: viewModel.scanInMode == ScanActionType.checkIn ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
          verticalSpaceTiny,
          visitor.hasDriverInfo && visitor.hasVehicleInfo
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kcPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 38,
                      ),
                      verticalSpaceSmall,
                      const Text(
                        'Scan Successful',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: kcPrimaryColor,
                        ),
                      ),
                      verticalSpaceTiny,
                      Text(
                        'Please verify the information below',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),

          verticalSpaceSmall,
          !visitor.hasDriverInfo || !visitor.hasVehicleInfo ? _buildScanningView(context, viewModel) : const SizedBox.shrink(),
          verticalSpaceSmall,

          BuildInfoCard(
            width: MediaQuery.of(context).size.width * 0.95,
            title: "Visitor Drivers Lisence Card",
            isIn: visitor.hasDriverInfo,
            icon: Icons.credit_card,
            color: Colors.green,
            infoList: [
              BuildInfoItem(label: 'Driver Name', value: visitor.driverName ?? 'Not Scanned'),
              BuildInfoItem(label: 'ID Number', value: visitor.driverIdNo ?? 'Not Scanned'),
              BuildInfoItem(label: 'License No', value: visitor.driverLicenceNo ?? 'Not Scanned'),
            ],
          ),

          verticalSpaceSmall,
          BuildInfoCard(
            width: MediaQuery.of(context).size.width * 0.95,
            title: "Vehicle Lisence Disc",
            isIn: visitor.hasVehicleInfo,
            icon: Icons.directions_car,
            color: Colors.green,
            infoList: [
              BuildInfoItem(label: 'Registration', value: visitor.vehicleRegNumber ?? 'Not Scanned'),
              BuildInfoItem(label: 'Make', value: visitor.vehicleMake ?? 'Not Scanned'),
            ],
          ),
          verticalSpaceTiny,

          if (viewModel.errorMessage != null) ...[
            verticalSpaceMedium,
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700]),
                  horizontalSpaceSmall,
                  Expanded(
                    child: Text(
                      viewModel.errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScanningView(BuildContext context, GateAccessVisitorSheetModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //create animated barcode scanning indicator
          const SizedBox(
            height: 60,
            width: 100,
            child: BarcodeScannerAnimation(),
          ),

          verticalSpaceSmall,
          Text(
            viewModel.barcodeScanType == BarcodeScanType.driversCard ? 'Scan Driver\'s License Card...' : 'Scan Vehicle License Disc...',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          verticalSpaceTiny,
          Text(
            'Please hold the barcode scanner steady',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanSetupView(BuildContext context, GateAccessVisitorSheetModel viewModel) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // In/Out selection

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[150],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.grey[700]),
                horizontalSpaceSmall,
                Expanded(
                  child: Text(
                    "Is this visitor entering or exiting?",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          verticalSpaceTiny,

          Visibility(
            visible: viewModel.scanInMode == ScanActionType.checkIn,
            child: Form(
              key: viewModel.formKey,
              child: SearchableDropdownFormField<int>(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                dialogOffset: 1,
                dropDownMaxHeight: 400,
                backgroundDecoration: (child) => Card(
                  margin: EdgeInsets.zero,
                  //color: Colors.lightBlue,
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: child,
                  ),
                ),
                hintText: Text(viewModel.translate('ServiceTypes')),
                margin: const EdgeInsets.all(2),
                items: viewModel.serviceTypes,
                validator: (val) {
                  if (val == null) return 'Cant be empty';
                  return null;
                },
                onSaved: (val) {
                  viewModel.onServiceTypeChanged(val);
                },
                onChanged: (val) => viewModel.onServiceTypeChanged(val),
              ),
            ),
          ),

          verticalSpaceMedium,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionCard(
                context,
                viewModel,
                'Check In',
                viewModel.scanInMode == ScanActionType.checkIn ? true : false,
                Icons.login,
                Colors.green,
                'Record visitor arrival',
              ),
              _buildActionCard(
                context,
                viewModel,
                'Check Out',
                viewModel.scanInMode == ScanActionType.checkOut ? true : false,
                Icons.logout,
                Colors.redAccent,
                'Record visitor departure',
              ),
            ],
          ),

          verticalSpaceMedium,
          if (viewModel.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700]),
                  horizontalSpaceSmall,
                  Expanded(
                    child: Text(
                      viewModel.errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
            verticalSpaceSmall,
          ],
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.info_outline, color: kcPrimaryColor),
                    horizontalSpaceSmall,
                    Text(
                      'Instructions',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: kcPrimaryColor,
                      ),
                    ),
                  ],
                ),
                verticalSpaceSmall,
                Text(
                  '1. Position the driver\'s license barcode within the scanner frame\n2. Hold steady until scan completes\n3. Position the vehicle license disk barcode within the scanner frame\n4. Hold steady until scan completes\n5. Verify the captured information',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onViewModelReady(GateAccessVisitorSheetModel viewModel) => SchedulerBinding.instance.addPostFrameCallback(
        (timeStamp) => viewModel.runStartupLogic(request.data),
      );
  @override
  GateAccessVisitorSheetModel viewModelBuilder(BuildContext context) => GateAccessVisitorSheetModel();
}
