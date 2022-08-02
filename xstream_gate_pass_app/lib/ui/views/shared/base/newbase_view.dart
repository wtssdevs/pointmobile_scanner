import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'newbase_view_model.dart';

class StartBaseView extends StatelessWidget {
  const StartBaseView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StartBaseViewModel>.reactive(
      viewModelBuilder: () => StartBaseViewModel(),
      builder: (context, model, child) => WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(),
      ),
    );
  }
}
