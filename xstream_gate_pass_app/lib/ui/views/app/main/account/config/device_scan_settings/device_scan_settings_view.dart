import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'device_scan_settings_viewmodel.dart';

class DeviceScanSettingsView extends StackedView<DeviceScanSettingsViewModel> {
  const DeviceScanSettingsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    DeviceScanSettingsViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
      ),
    );
  }

  @override
  DeviceScanSettingsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      DeviceScanSettingsViewModel();
}
