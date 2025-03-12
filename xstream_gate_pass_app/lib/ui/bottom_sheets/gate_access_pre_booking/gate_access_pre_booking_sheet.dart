import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/core/models/gatepass/gate_pass_access_visitor_model.dart';
import 'package:xstream_gate_pass_app/ui/bottom_sheets/widgets/default_build_header.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';

import 'gate_access_pre_booking_sheet_model.dart';

class GateAccessPreBookingSheet
    extends StackedView<GateAccessPreBookingSheetModel> {
  final Function(SheetResponse response)? completer;
  final SheetRequest request;
  const GateAccessPreBookingSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    GateAccessPreBookingSheetModel viewModel,
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
            title: 'Find Pre-Booked Load',
          ),
          Expanded(
            child: Column(
              children: [
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
          ),
          //_buildFooter(context, viewModel),
        ],
      ),
    );
  }

  @override
  void onViewModelReady(GateAccessPreBookingSheetModel viewModel) =>
      SchedulerBinding.instance.addPostFrameCallback(
        (timeStamp) => viewModel.runStartupLogic(request.data),
      );
  @override
  GateAccessPreBookingSheetModel viewModelBuilder(BuildContext context) =>
      GateAccessPreBookingSheetModel();
}
