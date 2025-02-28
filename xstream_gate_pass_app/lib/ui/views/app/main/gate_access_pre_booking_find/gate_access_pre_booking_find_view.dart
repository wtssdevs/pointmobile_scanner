import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gatepass/Widgets/finder_app_bar.dart';

import 'gate_access_pre_booking_find_viewmodel.dart';

class GateAccessPreBookingFindView
    extends StackedView<GateAccessPreBookingFindViewModel> {
  const GateAccessPreBookingFindView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    GateAccessPreBookingFindViewModel viewModel,
    Widget? child,
  ) {
    double searchWidth =
        getDeviceType(MediaQuery.of(context)) == DeviceScreenType.tablet
            ? MediaQuery.of(context).size.height * 0.8
            : MediaQuery.of(context).size.height * 0.5;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${viewModel.translate('Find')} ${viewModel.translate('PreBookings')}"),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            BarcodeKeyboardListener(
              bufferDuration: const Duration(milliseconds: 200),
              caseSensitive: false,
              useKeyDownEvent: false,
              onBarcodeScanned: (barcode) {
                viewModel.onBarcodeScanned(barcode);
              },
              child: ListTile(
                contentPadding: const EdgeInsets.all(0),
                dense: true,
                title: FinderAppBar(
                  controller: viewModel.filterController,
                  searchWidth: searchWidth,
                  searchIcon: const Icon(
                    Icons.qr_code_sharp,
                    size: 20,
                    color: kcPrimaryColor,
                  ),
                  placeholder:
                      "Scan Load Confirmation QrCode", //viewModel.translate('ScanLoadConfirmationQrCode'),
                  onChanged: (value) {
                    viewModel.onFilterValueChanged(value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            ListTile(
              contentPadding: const EdgeInsets.all(0),
              dense: true,
              trailing: IconButton(
                tooltip: "Find by values",
                iconSize: 28,
                onPressed: () async {
                  viewModel.findGatePassByVoyageNo();
                },
                icon: const Icon(
                  Icons.search,
                  color: kcPrimaryColor,
                ),
              ),
              title: FinderAppBar(
                controller: viewModel.voageNoController,
                searchWidth: searchWidth,
                searchIcon: const Icon(
                  FontAwesomeIcons.truck,
                  size: 14,
                  color: kcPrimaryColor,
                ),
                placeholder: viewModel.translate('VoyageNo'),
                onChanged: (value) {
                  viewModel.onFilterValueChanged(value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onViewModelReady(GateAccessPreBookingFindViewModel viewModel) =>
      SchedulerBinding.instance.addPostFrameCallback(
        (timeStamp) => viewModel.runStartupLogic(),
      );

  @override
  GateAccessPreBookingFindViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      GateAccessPreBookingFindViewModel();
}
