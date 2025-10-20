import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/exception_indicators/exception_indicator.dart';

/// Indicates that a connection error occurred.
class NoConnectionIndicator extends StatelessWidget {
  const NoConnectionIndicator({
    Key? key,
    required this.onTryAgain,
  }) : super(key: key);

  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.red.withOpacity(0.9),
        child: ExceptionIndicator(
          title: 'No connection',
          message: 'Please check internet connection and try again.',
          assetName: 'assets/frustrated-face.png',
          onTryAgain: onTryAgain,
        ),
      );
}
