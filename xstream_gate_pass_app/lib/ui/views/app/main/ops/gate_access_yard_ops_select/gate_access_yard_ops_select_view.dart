import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'gate_access_yard_ops_select_viewmodel.dart';

class GateAccessYardOpsSelectView
    extends StackedView<GateAccessYardOpsSelectViewModel> {
  const GateAccessYardOpsSelectView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    GateAccessYardOpsSelectViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("GateAccessYardOpsSelectView")),
      ),
    );
  }

  @override
  GateAccessYardOpsSelectViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      GateAccessYardOpsSelectViewModel();
}
