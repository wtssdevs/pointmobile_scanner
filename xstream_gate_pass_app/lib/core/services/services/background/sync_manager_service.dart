import 'dart:async';
import 'package:cron/cron.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app_config/app.locator.dart';
import 'package:xstream_gate_pass_app/app_config/app.logger.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';
import 'package:xstream_gate_pass_app/core/services/shared/stoppable_service.dart';


@Singleton()
class SyncManager extends StoppableService {
  final log = getLogger('SyncManager');
  final cron = Cron();
  late ScheduledTask st;
  final _workerQueManager = locator<WorkerQueManager>();

  SyncManager() {
    startBackgroundJob();
  }

  @override
  void start() async {
    super.start();
    // start subscription again
    if (serviceStopped == false) {
      await startBackgroundJob();
    }
  }

  @override
  void stop() async {
    super.stop();
    // cancel stream subscription
    await st.cancel();
  }

  Future<void> startBackgroundJob() async {
    String timer = "* * * * *";

    st = cron.schedule(Schedule.parse(timer), () async {
      if (!serviceStopped) {
        //sync data every 1 min
        log.d("startBackgroundJob is running ");
        await _workerQueManager.startExecution();
      }
    });
  }
}
