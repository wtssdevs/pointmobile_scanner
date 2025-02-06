import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:sembast/timestamp.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/enums/bckground_job_type.dart';
import 'package:xstream_gate_pass_app/core/models/background_job_que/background_job_Info.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/background_job_info_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/filestore/filestore_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/masterfiles/masterfiles_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';

@LazySingleton()
class WorkerQueManager {
  final log = getLogger('WorkerQueManager');
  final _backgroundJobInfoRepository = locator<BackgroundJobInfoRepository>();
  bool isExecuting = false;
  final Queue<BackgroundJobInfo> _input = Queue();
  // final StreamController _streamController = StreamController();
  final StreamController _syncController = StreamController<bool>.broadcast();
  final _connectionService = locator<ConnectionService>();
  final _fileStoreManager = locator<FileStoreManager>();
  final _masterFilesService = locator<MasterFilesService>();

  final int maxConcurrentTasks = 1;
  int runningTasks = 0;
  WorkerQueManager() {
    // initialize();
  }

  void initialize() {
    _backgroundJobInfoRepository.setTableRef();
  }

  //_backgroundJobInfoRepository
  //get stream for sync que tasks
  Stream get onSyncTaskChange => _syncController.stream;

  Future<void> enqueSingle(BackgroundJobInfo value, [bool startNow = true]) async {
    //_input.add(value);

    await _backgroundJobInfoRepository.insert(value);
    //here we will que to databse
    if (startNow) {
      startExecution();
    }
  }

  Future<void> enqueForStartUp() async {
    initialize();

    //here we will que to databse
    await enqueMany(<BackgroundJobInfo>[
      // BackgroundJobInfo(
      //     jobType: BackgroundJobType. .index,
      //     jobArgs: "",
      //     lastTryTime: Timestamp.now(),
      //     creationTime: Timestamp.now(),
      //     nextTryTime: Timestamp.now(),
      //     id: "",
      //     isAbandoned: false),
      BackgroundJobInfo(jobType: BackgroundJobType.syncMasterfiles.index, jobArgs: "", lastTryTime: Timestamp.now(), creationTime: Timestamp.now(), nextTryTime: Timestamp.now(), id: "", isAbandoned: false),
    ]);
  }

  Future<void> enqueMany(List<BackgroundJobInfo> iterable) async {
    //_input.addAll(iterable);
    //here we will que to databse
    await _backgroundJobInfoRepository.upsertMany(iterable);
    startExecution();
  }

  Future<void> startExecution() async {
    if (isExecuting) {
      //should we delay and call self again?
      //await delayStartQue();
      return;
    }

    if (_connectionService.hasConnection == false) {
      return;
    }

    //get que from  database and fill
    var waitingJobs = await _backgroundJobInfoRepository.getAll("");
    _input.addAll(waitingJobs);

    //breakout if nothing to do
    if (runningTasks == maxConcurrentTasks || _input.isEmpty) {
      return;
    }

    while (!isExecuting && _input.isNotEmpty) {
      isExecuting = true;

      //excute Task then remove from list
      var firstJob = _input.removeFirst();
      //_streamController.add(firstJob);
      if (firstJob.isAbandoned == false) {
        // await Future.delayed(Duration(seconds: firstJob.tryCount == 0 ? 0 : firstJob.tryCount * 15), () async {

        // });

        await tryProcessJob(firstJob);
        if (kDebugMode) {
          log.d('TryProcessJob Complete: ${firstJob.getJobType}, Job Remaining : ${_input.length}');
        }
      } else {
        //TODO clean job list from db and report issues maybe...
//         await _backgroundJobInfoRepository.delete(firstJob);
      }
      isExecuting = false;
    }
  }

  Future<void> delayStartQue({int delayInSec = 10}) async {
    await Future.delayed(Duration(seconds: delayInSec), () {
      startExecution();
    });
  }

  Future<void> updateJobValues(BackgroundJobInfo jobInfo) async {
    jobInfo.tryCount = jobInfo.calculateTryCount();

    if (jobInfo.isAbandoned) {
      await _backgroundJobInfoRepository.delete(jobInfo);
    }

    var newNextTryTime = jobInfo.calculateNextTryTime();
    if (newNextTryTime != null) {
      jobInfo.nextTryTime = Timestamp.fromDateTime(newNextTryTime);
    } else {
      jobInfo.isAbandoned = true;
    }

    await _backgroundJobInfoRepository.update(jobInfo);
  }

  Future<void> tryProcessJob(BackgroundJobInfo jobInfo) async {
    bool deleteJob = false;
    jobInfo.lastTryTime = Timestamp.now();
    try {
      switch (jobInfo.getJobType) {
        case BackgroundJobType.none:
          deleteJob = true;
          break;
        case BackgroundJobType.syncMasterfiles:
          //await _masterFilesService.syncServerWithLocalAll();
          deleteJob = true;
          break;
        case BackgroundJobType.syncImages:
          if (jobInfo.jobArgs != null) {
            var refIdAsString = asT<String>(jobInfo.jobArgs);
            if (refIdAsString != null) {
              await _fileStoreManager.uploadImageToServer(refIdAsString);
            }
          } else {
            //sync top 10
          }

          await _fileStoreManager.clearOld();
          deleteJob = true;
          break;

        case BackgroundJobType.clearCache:
          break;
        case BackgroundJobType.emailLog:
          break;

        default:
      }

      if (deleteJob) {
        await _backgroundJobInfoRepository.delete(jobInfo);
      } else {
        await updateJobValues(jobInfo);
      }

      isExecuting = false;
      _syncController.add(deleteJob);
    } catch (e) {
      jobInfo.errorMessage = e.toString();
      await updateJobValues(jobInfo);

      isExecuting = false;
      log.e(e);

      // FlutterLogs.logThis(
      //     tag: 'BackgroundJob',
      //     subTag: "${jobInfo.getJobType}",
      //     logMessage: 'Caught an exception!',
      //     exception: e is Exception ? e : null,
      //     errorMessage: e.toString(),
      //     level: LogLevel.ERROR);
    }
    //broadcast sync failed
    _syncController.add(false);
  }
}
