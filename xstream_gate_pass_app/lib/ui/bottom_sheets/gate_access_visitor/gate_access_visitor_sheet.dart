import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/core/enums/barcode_scan_type.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
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
          _buildHeader(context, viewModel),
          Expanded(
            child: _buildContent(context, viewModel),
          ),
          _buildFooter(context, viewModel),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, GateAccessVisitorSheetModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Gate Pass Scanner',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kcPrimaryColor),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => completer?.call(SheetResponse(confirmed: false)),
            ),
          ],
        ),
        const Divider(),
        verticalSpaceSmall,
      ],
    );
  }

  Widget _buildContent(BuildContext context, GateAccessVisitorSheetModel viewModel) {
    // Show scan result if we have one
    // if (viewModel.scannedVisitor != null) {
    //   return _buildScanResultView(context, viewModel);
    // }

    // Show scanning UI or initial scan setup
    return viewModel.isScanning ? _buildScanResultView(context, viewModel) : _buildScanSetupView(context, viewModel);
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
                          SheetResponse(
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
                      viewModel.scanInMode ? 'Check In Visitor' : 'Check Out Visitor',
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
    bool isIn,
    IconData icon,
    Color color,
    String description,
  ) {
    final isSelected = viewModel.scanInMode == isIn;

    return GestureDetector(
      onTap: () => viewModel.setScanInMode(isIn),
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

  Widget _buildInfoCard(
    BuildContext context,
    GateAccessVisitorSheetModel viewModel,
    bool isIn,
    IconData icon,
    Color color,
    //inoput a list of strings
    List<Widget> infoList,
  ) {
    final isSelected = isIn;

    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
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
          ...infoList,
        ],
      ),
    );
  }

  Widget _buildScanResultView(BuildContext context, GateAccessVisitorSheetModel viewModel) {
    final visitor = viewModel.scannedVisitor!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Information
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: viewModel.scanInMode ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: viewModel.scanInMode ? Colors.green[200]! : Colors.orange[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  viewModel.scanInMode ? Icons.login : Icons.logout,
                  color: viewModel.scanInMode ? Colors.green[700] : Colors.orange[700],
                ),
                horizontalSpaceSmall,
                Text(
                  viewModel.scanInMode ? 'This visitor will be checked in' : 'This visitor will be checked out',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: viewModel.scanInMode ? Colors.green[700] : Colors.orange[700],
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
          // Visitor Information
          const Text(
            'Visitor Drivers Lisence Card',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          verticalSpaceSmall,
          _buildInfoCard(
            context,
            viewModel,
            visitor.hasDriverInfo,
            Icons.credit_card,
            Colors.green,
            [
              _buildInfoItem('Driver Name', visitor.driverName ?? 'Not Scanned'),
              _buildInfoItem('ID Number', visitor.driverIdNo ?? 'Not Scanned'),
              _buildInfoItem('License No', visitor.driverLicenceNo ?? 'Not Scanned'),
            ],
          ),

          verticalSpaceSmall,

          // Vehicle Information
          const Text(
            'Vehicle Lisence Disc',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          verticalSpaceSmall,
          _buildInfoCard(
            context,
            viewModel,
            visitor.hasVehicleInfo,
            Icons.directions_car,
            Colors.green,
            [
              _buildInfoItem('Registration', visitor.vehicleRegNumber ?? 'Not Scanned'),
              _buildInfoItem('Make', visitor.vehicleMake ?? 'Not Scanned'),
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

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
            visible: viewModel.scanInMode == true,
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
                true,
                Icons.login,
                Colors.green,
                'Record visitor arrival',
              ),
              _buildActionCard(
                context,
                viewModel,
                'Check Out',
                false,
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
