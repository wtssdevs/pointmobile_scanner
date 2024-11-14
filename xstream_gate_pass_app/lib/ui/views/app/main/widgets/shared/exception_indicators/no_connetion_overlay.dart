import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_text.dart';

class NetworkErrorAnimation extends StatefulWidget {
  const NetworkErrorAnimation({super.key, this.message});
  final String? message;

  @override
  State<NetworkErrorAnimation> createState() => _NetworkErrorAnimationState();
}

class _NetworkErrorAnimationState extends State<NetworkErrorAnimation> {
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(
        sigmaX: 6.0,
        sigmaY: 6.0,
      ),
      child: Dialog(
        insetPadding: const EdgeInsets.all(0.0),
        backgroundColor: Colors.white.withOpacity(0.5),
        child: Container(
          padding: const EdgeInsets.only(left: 8, right: 8),
          alignment: Alignment.bottomCenter,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //verticalSpaceMassive,
              AppText.body(
                "No connection!",
                align: TextAlign.center,
                color: Colors.red,
                fontSize: 36,
              ),
              AppText.body(
                "Please check internet connection and try again.",
                align: TextAlign.center,
                color: Colors.black,
                fontSize: 21,
              ),
              if (widget.message != null)
                AppText.body(
                  widget.message!,
                  align: TextAlign.center,
                  color: Colors.black,
                  fontSize: 26,
                ),

              Lottie.asset('assets/animations/noconnection.json'),
            ],
          ),
        ),
      ),
    );
  }
}
