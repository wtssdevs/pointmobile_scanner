import 'package:overlay_support/overlay_support.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/exception_indicators/no_connetion_overlay.dart';

@LazySingleton()
class OverlayService {
  final log = getLogger('OverlayService');
  OverlaySupportEntry? entry;
  Future showNetworkConnection(showNoConnectionOverlay,
      {String? message}) async {
    if (showNoConnectionOverlay && entry == null) {
      entry = showOverlayNotification((context) {
        return NetworkErrorAnimation(
          message: message,
        );
      }, duration: Duration.zero);
    }
    if (entry != null && showNoConnectionOverlay == false) {
      entry!.dismiss(animate: false);
      await entry!.dismissed;
      entry = null;
    }
  }
}
