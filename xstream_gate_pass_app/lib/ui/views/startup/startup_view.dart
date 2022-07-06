import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/ui/views/startup/startup_viewmodel.dart';

class StartUpView extends StatelessWidget {
  const StartUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //precacheImage(AssetImage("assets/images/wtss_logo.png"), context);
    return ViewModelBuilder<StartUpViewModel>.reactive(
      onModelReady: (model) => SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        model.runStartupLogic();
      }),
      builder: (context, model, child) => SafeArea(
        child: Text("Hello Startup"),
      ),
      // Scaffold(
      //   backgroundColor: kcButtonPrimaryActionColor,
      //   body: Center(
      //     child: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: <Widget>[
      //         Center(
      //           child: Container(
      //             alignment: Alignment.center,
      //             child: Text(
      //               //  "Proudly brought to you by",
      //               model.translate("Proudly brought to you by"),
      //               style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: Colors.white),
      //             ),
      //           ),
      //         ),
      //         SizedBox(
      //           width: 350,
      //           height: 150,
      //           child: Image.asset('assets/images/wtss_logo.png'),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      viewModelBuilder: () => StartUpViewModel(),
    );
  }
}
