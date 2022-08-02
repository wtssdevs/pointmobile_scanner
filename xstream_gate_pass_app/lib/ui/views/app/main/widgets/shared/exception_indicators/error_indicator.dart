import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/app_config/app.locator.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/exception_indicators/generic_error_indicator.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/exception_indicators/no_connection_indicator.dart';

/// Based on the received error, displays either a [NoConnectionIndicator] or
/// a [GenericErrorIndicator].
class ErrorIndicator extends StatelessWidget {
  const ErrorIndicator({
    required this.error,
    required this.onTryAgain,
    Key? key,
  })  : assert(error != null),
        super(key: key);

  final dynamic error;
  final VoidCallback onTryAgain;
  // bool connectionStatus = true;

  @override
  Widget build(BuildContext context) {
    if (locator<ConnectionService>().hasConnection == false) {
      return NoConnectionIndicator(
        onTryAgain: onTryAgain,
      );
    } else {
      return GenericErrorIndicator(
        onTryAgain: onTryAgain,
      );
    }
  }
  //  error is SocketException
  //     ? NoConnectionIndicator(
  //         onTryAgain: onTryAgain,
  //       )
  //     : GenericErrorIndicator(
  //         onTryAgain: onTryAgain,
  //       );
}
