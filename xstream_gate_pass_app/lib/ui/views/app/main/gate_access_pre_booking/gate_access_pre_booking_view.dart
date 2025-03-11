import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/gate_access_pre_booking/gate_access_pre_booking_viewmodel.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/build_Info_item.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/build_info_card.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/Widgets/finder_app_bar.dart';

class GateAccessPreBookingView extends StackedView<GateAccessPreBookingViewModel> {
  const GateAccessPreBookingView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    GateAccessPreBookingViewModel viewModel,
    Widget? child,
  ) {
    double searchWidth = getDeviceType(MediaQuery.of(context)) == DeviceScreenType.tablet ? MediaQuery.of(context).size.height * 0.8 : MediaQuery.of(context).size.height * 0.5;
    return Scaffold(
      appBar: AppBar(
        title: Text("${viewModel.translate('Find')} ${viewModel.translate('PreBookings')}"),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true,
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: [
        ElevatedButton.icon(
          onPressed: viewModel.scannedQrData == null ? null : () => viewModel.findPreBookingByQrData(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            disabledBackgroundColor: Colors.grey[300],
          ),
          icon: const Icon(Icons.search, color: Colors.white),
          label: const Text(
            'Find Pre-Booking',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0),
        child: Column(
          children: [
            const SizedBox(height: 5.0),
            BarcodeKeyboardListener(
              bufferDuration: const Duration(milliseconds: 200),
              caseSensitive: false,
              useKeyDownEvent: false,
              onBarcodeScanned: (barcode) {
                viewModel.onBarcodeScanned(barcode);
              },
              child: const SizedBox.shrink(),
              // child: ListTile(
              //   contentPadding: const EdgeInsets.all(0),
              //   dense: true,
              //   title: FinderAppBar(
              //     controller: viewModel.filterController,
              //     searchWidth: searchWidth,
              //     searchIcon: const Icon(
              //       Icons.qr_code_sharp,
              //       size: 20,
              //       color: kcPrimaryColor,
              //     ),
              //     placeholder:
              //         "Scan Load Confirmation QrCode", //viewModel.translate('ScanLoadConfirmationQrCode'),
              //     onChanged: (value) {
              //       viewModel.onFilterValueChanged(value);
              //     },
              //   ),
              // ),
            ),
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
                    '''1. Position the load instructions QR Code within the scanner frame\n2. Hold steady until scan completes\n3. Verify the captured information''',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            // QR Code Scanning Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Scanned QR Data Display
                  viewModel.scannedQrData != null
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BuildInfoCard(
                                width: MediaQuery.of(context).size.width * 0.95,
                                title: "Scanned Data",
                                isSelected: false,
                                hasInfo: viewModel.scannedQrData?.isModelEmpty() == false,
                                icon: Icons.directions_car,
                                color: Colors.green,
                                infoList: [
                                  BuildInfoItem(label: 'Transaction No', value: viewModel.scannedQrData?.transactionNo ?? 'Not Scanned'),
                                  BuildInfoItem(label: 'Vehicle Reg Number', value: viewModel.scannedQrData?.vehicleRegistrationNumber ?? 'Not Scanned'),
                                  BuildInfoItem(label: 'Reference No', value: viewModel.scannedQrData?.referenceNo ?? 'Not Scanned'),
                                  BuildInfoItem(label: 'Customer Ref No', value: viewModel.scannedQrData?.customerRefNo ?? 'Not Scanned'),
                                  BuildInfoItem(label: 'Booking Order No', value: viewModel.scannedQrData?.bookingOrderNumber ?? 'Not Scanned'),
                                ],
                              ),
                            ],
                          ),
                        )
                      : BuildInfoCard(
                          width: MediaQuery.of(context).size.width * 0.95,
                          title: "QR Code Scanner",
                          isSelected: true,
                          hasInfo: false,
                          icon: Icons.qr_code_scanner,
                          color: Colors.red,
                          infoList: const [
                            Text(
                              'No QR code data has been scanned yet',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                  verticalSpaceMedium,

                  // Scan Button
                ],
              ),
            ),
            // Validation Errors Display
            if (viewModel.validationErrors.isNotEmpty) ...[
              verticalSpaceMedium,
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red),
                        horizontalSpaceSmall,
                        Text(
                          'Validation Errors',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    verticalSpaceSmall,
                    ...viewModel.validationErrors.map((error) => Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 10,
                                color: Colors.red,
                              ),
                              horizontalSpaceSmall,
                              Expanded(
                                child: Text(
                                  error,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  @override
  void onViewModelReady(GateAccessPreBookingViewModel viewModel) => SchedulerBinding.instance.addPostFrameCallback(
        (timeStamp) => viewModel.runStartupLogic(),
      );

  @override
  GateAccessPreBookingViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      GateAccessPreBookingViewModel();
}
