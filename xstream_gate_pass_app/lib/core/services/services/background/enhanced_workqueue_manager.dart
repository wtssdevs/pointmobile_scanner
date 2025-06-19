import 'dart:async';
import 'dart:collection';
import 'package:sembast/timestamp.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/enums/bckground_job_type.dart';
import 'package:xstream_gate_pass_app/core/models/background_job_que/background_job_Info.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/background_job_info_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/isolate/isolate_pool_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/filestore/filestore_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/masterfiles/masterfiles_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';

/// Enhanced WorkerQueManager with enterprise-level isolate support
///
/// Features:
/// - Backward compatibility with existing API
/// - Configurable isolate vs main thread execution
/// - Advanced job prioritization and retry logic
/// - Real-time monitoring and statistics
/// - Graceful degradation and error handling
@LazySingleton()
class EnhancedWorkerQueManager {
  final log = getLogger('EnhancedWorkerQueManager');
  final _backgroundJobInfoRepository = locator<BackgroundJobInfoRepository>();
  final _connectionService = locator<ConnectionService>();
  final _fileStoreManager = locator<FileStoreManager>();
  final _masterFilesService = locator<MasterFilesService>();

  // Configuration
  bool _useIsolates = true;
  bool _isExecuting = false;
  final int _maxConcurrentTasks = 4; // Increased for isolate support
  int _runningTasks = 0;

  // Isolate management
  IsolatePoolManager? _isolatePool;
  bool _isolatePoolInitialized = false;

  // Legacy queue for fallback
  final Queue<BackgroundJobInfo> _legacyQueue = Queue();

  // Monitoring
  final StreamController<bool> _syncController =
      StreamController<bool>.broadcast();
  final StreamController<Map<String, dynamic>> _statsController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Statistics
  int _totalJobsProcessed = 0;
  int _totalJobsFailed = 0;
  final Map<String, int> _jobTypeCounters = {};

  EnhancedWorkerQueManager() {
    // Initialize async to avoid blocking constructor
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    try {
      if (_useIsolates) {
        await _initializeIsolatePool();
      }
      _initializeRepository();
      _startStatsReporting();
    } catch (e) {
      log.e('Failed to initialize enhanced worker queue: $e');
      _useIsolates = false; // Fallback to legacy mode
    }
  }

  Future<void> _initializeIsolatePool() async {
    try {
      _isolatePool = IsolatePoolManager(
        minWorkers: 2,
        maxWorkers: _maxConcurrentTasks,
        workerIdleTimeout: const Duration(minutes: 5),
        healthCheckInterval: const Duration(minutes: 2),
      );

      await _isolatePool!.initialize();
      _isolatePoolInitialized = true;

      log.i('Isolate pool initialized successfully');
    } catch (e) {
      log.e('Failed to initialize isolate pool: $e');
      _useIsolates = false;
      rethrow;
    }
  }

  void _initializeRepository() {
    _backgroundJobInfoRepository.setTableRef();
  }

  void _startStatsReporting() {
    Timer.periodic(const Duration(seconds: 30), (_) {
      _statsController.add(getStatistics());
    });
  }

  // Public API (backward compatible)

  /// Stream for sync task changes
  Stream<bool> get onSyncTaskChange => _syncController.stream;

  /// Stream for statistics updates
  Stream<Map<String, dynamic>> get onStatsChange => _statsController.stream;

  /// Enqueue a single job
  Future<void> enqueSingle(BackgroundJobInfo value,
      [bool startNow = true]) async {
    await _backgroundJobInfoRepository.insert(value);

    if (startNow) {
      await startExecution();
    }
  }

  /// Enqueue jobs for startup
  Future<void> enqueForStartUp() async {
    _initializeRepository();

    await enqueMany(<BackgroundJobInfo>[
      BackgroundJobInfo(
        jobType: BackgroundJobType.syncMasterfiles.index,
        jobArgs: "",
        lastTryTime: Timestamp.now(),
        creationTime: Timestamp.now(),
        nextTryTime: Timestamp.now(),
        id: "",
        isAbandoned: false,
      ),
    ]);
  }

  /// Enqueue multiple jobs
  Future<void> enqueMany(List<BackgroundJobInfo> iterable) async {
    await _backgroundJobInfoRepository.upsertMany(iterable);
    await startExecution();
  }

  /// Start job execution
  Future<void> startExecution({bool forceRun = false}) async {
    if (_isExecuting && !forceRun) {
      return;
    }

    if (!_connectionService.hasConnection) {
      log.d('No connection available, skipping execution');
      return;
    }

    _isExecuting = true;

    try {
      if (_useIsolates && _isolatePoolInitialized) {
        await _executeWithIsolates();
      } else {
        await _executeLegacy();
      }
    } catch (e) {
      log.e('Error during job execution: $e');
    } finally {
      _isExecuting = false;
    }
  }

  /// Execute jobs using isolate pool
  Future<void> _executeWithIsolates() async {
    try {
      // Get waiting jobs from database
      final waitingJobs = await _backgroundJobInfoRepository.getAll("");
      if (waitingJobs.isEmpty) {
        return;
      }

      log.d('Processing ${waitingJobs.length} jobs with isolates');

      // Process jobs concurrently with isolates
      final futures = <Future<void>>[];

      for (final job in waitingJobs.take(_maxConcurrentTasks)) {
        if (!job.isAbandoned) {
          futures.add(_processJobWithIsolate(job));
        }
      }

      // Wait for all jobs to complete
      await Future.wait(futures);
    } catch (e) {
      log.e('Error in isolate execution: $e');
      // Fallback to legacy execution
      _useIsolates = false;
      await _executeLegacy();
    }
  }

  /// Process single job with isolate
  Future<void> _processJobWithIsolate(BackgroundJobInfo jobInfo) async {
    try {
      _runningTasks++;

      final result = await _isolatePool!.submitJob(
        jobInfo,
        timeout: const Duration(minutes: 10),
      );

      if (result.success) {
        log.d('Job ${jobInfo.id} completed successfully in isolate');
        await _backgroundJobInfoRepository.delete(jobInfo);
        _updateJobStats(jobInfo, true);
      } else {
        log.w('Job ${jobInfo.id} failed in isolate: ${result.error}');
        jobInfo.errorMessage = result.error ?? 'Unknown isolate error';
        await _updateJobValues(jobInfo);
        _updateJobStats(jobInfo, false);
      }

      _syncController.add(result.success);
    } catch (e) {
      log.e('Error processing job ${jobInfo.id} with isolate: $e');
      jobInfo.errorMessage = e.toString();
      await _updateJobValues(jobInfo);
      _updateJobStats(jobInfo, false);
      _syncController.add(false);
    } finally {
      _runningTasks--;
    }
  }

  /// Legacy execution (original implementation)
  Future<void> _executeLegacy() async {
    final waitingJobs = await _backgroundJobInfoRepository.getAll("");
    _legacyQueue.addAll(waitingJobs);

    if (_runningTasks >= _maxConcurrentTasks || _legacyQueue.isEmpty) {
      return;
    }

    while (_legacyQueue.isNotEmpty && _runningTasks < _maxConcurrentTasks) {
      final job = _legacyQueue.removeFirst();

      if (!job.isAbandoned) {
        _runningTasks++;
        unawaited(_processJobLegacy(job));
      }
    }
  }

  /// Process job on main isolate (legacy)
  Future<void> _processJobLegacy(BackgroundJobInfo jobInfo) async {
    bool deleteJob = false;
    jobInfo.lastTryTime = Timestamp.now();

    try {
      switch (jobInfo.getJobType) {
        case BackgroundJobType.none:
          deleteJob = true;
          break;
        case BackgroundJobType.syncMasterfiles:
          await _masterFilesService.syncServerWithLocalAll();
          deleteJob = true;
          break;
        case BackgroundJobType.syncImages:
          if (jobInfo.jobArgs != null) {
            var refIdAsString = asT<String>(jobInfo.jobArgs);
            if (refIdAsString != null) {
              await _fileStoreManager.uploadImageToServer(refIdAsString);
            }
          }
          await _fileStoreManager.clearOld();
          deleteJob = true;
          break;
        case BackgroundJobType.clearCache:
          // Implement cache clearing
          deleteJob = true;
          break;
        case BackgroundJobType.emailLog:
          // Implement email log
          deleteJob = true;
          break;
        default:
          deleteJob = true;
      }

      if (deleteJob) {
        await _backgroundJobInfoRepository.delete(jobInfo);
        _updateJobStats(jobInfo, true);
      } else {
        await _updateJobValues(jobInfo);
        _updateJobStats(jobInfo, false);
      }

      _syncController.add(deleteJob);
    } catch (e) {
      jobInfo.errorMessage = e.toString();
      await _updateJobValues(jobInfo);
      _updateJobStats(jobInfo, false);
      _syncController.add(false);
      log.e('Error processing job ${jobInfo.id}: $e');
    } finally {
      _runningTasks--;
    }
  }

  /// Update job retry values
  Future<void> _updateJobValues(BackgroundJobInfo jobInfo) async {
    jobInfo.tryCount = jobInfo.calculateTryCount();

    if (jobInfo.isAbandoned) {
      await _backgroundJobInfoRepository.delete(jobInfo);
      return;
    }

    final newNextTryTime = jobInfo.calculateNextTryTime();
    if (newNextTryTime != null) {
      jobInfo.nextTryTime = Timestamp.fromDateTime(newNextTryTime);
    } else {
      jobInfo.isAbandoned = true;
    }

    await _backgroundJobInfoRepository.update(jobInfo);
  }

  /// Update job statistics
  void _updateJobStats(BackgroundJobInfo jobInfo, bool success) {
    _totalJobsProcessed++;
    if (!success) {
      _totalJobsFailed++;
    }

    final jobTypeName = jobInfo.getJobType.toString();
    _jobTypeCounters[jobTypeName] = (_jobTypeCounters[jobTypeName] ?? 0) + 1;
  }

  /// Get comprehensive statistics
  Map<String, dynamic> getStatistics() {
    final baseStats = {
      'executionMode': _useIsolates ? 'isolates' : 'legacy',
      'isExecuting': _isExecuting,
      'runningTasks': _runningTasks,
      'maxConcurrentTasks': _maxConcurrentTasks,
      'totalJobsProcessed': _totalJobsProcessed,
      'totalJobsFailed': _totalJobsFailed,
      'successRate': _totalJobsProcessed > 0
          ? ((_totalJobsProcessed - _totalJobsFailed) /
                  _totalJobsProcessed *
                  100)
              .toStringAsFixed(2)
          : '0.00',
      'jobTypeCounters': Map.from(_jobTypeCounters),
      'legacyQueueSize': _legacyQueue.length,
    };

    // Add isolate pool stats if available
    if (_isolatePool != null) {
      baseStats['isolatePool'] = _isolatePool!.getStatistics();
    }

    return baseStats;
  }

  /// Configure execution mode
  void setExecutionMode({required bool useIsolates}) {
    if (_useIsolates != useIsolates) {
      _useIsolates = useIsolates;
      log.i(
          'Execution mode changed to: ${useIsolates ? "isolates" : "legacy"}');

      if (useIsolates && !_isolatePoolInitialized) {
        _initializeIsolatePool().catchError((e) {
          log.e('Failed to initialize isolate pool after mode change: $e');
          _useIsolates = false;
        });
      }
    }
  }

  /// Cleanup resources
  Future<void> dispose() async {
    log.i('Disposing enhanced worker queue manager');

    await _syncController.close();
    await _statsController.close();

    if (_isolatePool != null) {
      await _isolatePool!.shutdown();
    }

    _legacyQueue.clear();
  }

  /// Delayed execution restart
  Future<void> delayStartQue({int delayInSec = 10}) async {
    await Future.delayed(Duration(seconds: delayInSec), () {
      startExecution();
    });
  }

  // Backward compatibility aliases
  bool get isExecuting => _isExecuting;
  int get maxConcurrentTasks => _maxConcurrentTasks;
  int get runningTasks => _runningTasks;
}
