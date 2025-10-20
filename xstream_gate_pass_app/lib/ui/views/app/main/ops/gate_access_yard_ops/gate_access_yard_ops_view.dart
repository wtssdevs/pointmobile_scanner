import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/build_Info_item.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/build_info_card.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/nav_action_button.dart';
import 'gate_access_yard_ops_viewmodel.dart';

class GateAccessYardOpsView extends StackedView<GateAccessYardOpsViewModel> {
  const GateAccessYardOpsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    GateAccessYardOpsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
            "${viewModel.translate('Yard')} ${viewModel.translate('Operations')}"),
      ),
      resizeToAvoidBottomInset: true,
      persistentFooterButtons: [
// Action button
        Row(
          children: [
            NavActionButton(
              label: "At Stock Pile",
              //need good icon here for truck at correct stokcpile and busy loading raw material
              icon: FontAwesomeIcons.truckRampBox,
              color: Colors.blue,
              onTap: viewModel.setAtStockPile,
              isVisible: viewModel.loadingSlipQrData?.hasAllInfo() == true &&
                  viewModel.stockPileQrData?.hasAllInfo() == true &&
                  viewModel.validate,
            ),
            NavActionButton(
              label: "Left Stock Pile",
              //need good icon here for truck at correct stokcpile and loading  is complete and can now leave
              icon: FontAwesomeIcons.truckMoving,
              color: Colors.green,
              onTap: viewModel.setLeftStockPile,
              isVisible: viewModel.loadingSlipQrData?.hasAllInfo() == true &&
                  viewModel.stockPileQrData?.hasAllInfo() == true &&
                  viewModel.validate,
            ),
          ],
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (viewModel.loadingSlipQrData?.hasAllInfo() == false &&
                viewModel.stockPileQrData?.hasAllInfo() == false)
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Scan the Loading Slip QR code and Stockpile QR code to verify truck location',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
// Match status indicator
            if (viewModel.loadingSlipQrData?.hasAllInfo() == true &&
                viewModel.stockPileQrData?.hasAllInfo() == true)
              Card(
                color: viewModel.validate ? Colors.green[50] : Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        viewModel.validate ? Icons.check_circle : Icons.error,
                        color: viewModel.validate ? Colors.green : Colors.red,
                        size: 36,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewModel.validate
                                  ? 'Stock Pile Match Confirmed'
                                  : 'Stock Pile Mismatch!',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: viewModel.validate
                                        ? Colors.green[800]
                                        : Colors.red[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              viewModel.validate
                                  ? 'Truck is at the correct Stock Pile area'
                                  : 'Truck is at the wrong Stock Pile area',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: viewModel.validate
                                        ? Colors.green[800]
                                        : Colors.red[800],
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
            verticalSpaceMedium,
            // Loading Slip QR Card
            BuildInfoCard(
              width: MediaQuery.of(context).size.width * 0.95,
              title: "Loading Slip QR Code",
              isSelected: viewModel.isScanning == true,
              onTap: () {
                viewModel.setIsScanning();
              },
              hasInfo: viewModel.loadingSlipQrData?.hasAllInfo() ?? false,
              icon: Icons.qr_code,
              color: Colors.purple,
              infoList: [
                BuildInfoItem(
                  label: viewModel.translate('VoyageNo'),
                  value: viewModel.loadingSlipQrData?.voyageNo ?? 'Not Scanned',
                ),
                BuildInfoItem(
                  label: viewModel.translate('CustomerRefNo'),
                  value: viewModel.loadingSlipQrData?.customerRefNo ??
                      'Not Scanned',
                ),
                BuildInfoItem(
                  label: viewModel.translate('LoadItemCode'),
                  value: viewModel.loadingSlipQrData?.loadItemCode ??
                      'Not Scanned',
                ),
              ],
            ),

            verticalSpaceMedium,

            // Stockpile QR Card
            BuildInfoCard(
              width: MediaQuery.of(context).size.width * 0.95,
              title: "Stockpile QR Code",
              isSelected: viewModel.isScanning == false,
              onTap: () {
                viewModel.setIsScanning();
              },
              hasInfo: viewModel.stockPileQrData?.hasAllInfo() ?? false,
              icon: Icons.location_on,
              color: Colors.orange,
              infoList: [
                // BuildInfoItem(
                //   label: viewModel.translate('VoyageNo'),
                //   value: viewModel.stockPileQrData?.voyageNo ?? 'Not Scanned',
                // ),
                BuildInfoItem(
                  label: viewModel.translate('CustomerRefNo'),
                  value:
                      viewModel.stockPileQrData?.customerRefNo ?? 'Not Scanned',
                ),
                BuildInfoItem(
                  label: viewModel.translate('LoadItemCode'),
                  value:
                      viewModel.stockPileQrData?.loadItemCode ?? 'Not Scanned',
                ),
              ],
            ),

            verticalSpaceMedium,
          ],
        ),
      ),
    );
  }

  @override
  void onDispose(GateAccessYardOpsViewModel viewModel) {
    viewModel.onDispose();
  }

  @override
  void onViewModelReady(GateAccessYardOpsViewModel viewModel) =>
      SchedulerBinding.instance.addPostFrameCallback(
        (timeStamp) => viewModel.runStartupLogic(),
      );

  @override
  GateAccessYardOpsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      GateAccessYardOpsViewModel();
}
