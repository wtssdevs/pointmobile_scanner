import 'package:flutter/widgets.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/sync_manager_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/stoppable_service.dart';

class LifeCycleManager extends StatefulWidget {
  final Widget? child;
  LifeCycleManager({Key? key, this.child}) : super(key: key);

  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager>
    with WidgetsBindingObserver {
  final log = getLogger('LifeCycleManager');
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();
  final NavigationService _navigationService = locator<NavigationService>();
  List<StoppableService> services = [
    locator<SyncManager>(),
  ];

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //log.d('LifeCycle - state = $state');
    if (state == AppLifecycleState.resumed) {
      services.forEach((service) {
        service.start();
      });
      //log.d('LifeCycle - state = $state, Route:${_navigationService.}');
    } else {
      services.forEach((service) {
        service.stop();
      });
      // _navigationService.back();
      //log.d('LifeCycle - state = $state, Route:${_navigationService.currentRoute}');
    }
    switch (state) {
      case AppLifecycleState.resumed:
        //here we need to check if current user was in middel op OTP PAssword Reset.

        break;
      default:
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }
}
