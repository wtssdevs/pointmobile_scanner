import 'package:flutter/widgets.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/exception_indicators/exception_indicator.dart';


/// Indicates that an unknown error occurred.
class EmptyListIndicator extends StatelessWidget {
  const EmptyListIndicator({
    Key? key,
    required this.onTryAgain,
  }) : super(key: key);

  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) => ExceptionIndicator(
        title: 'Too much filtering or to little.',
        message: 'We couldn\'t find any results matching your applied filters.',
        assetName: 'assets/empty-box.png',
        onTryAgain: onTryAgain,
        hideTryButton: false,
      );
}
