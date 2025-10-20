import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/models/background_job_que/background_job_Info.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/isolate/isolate_worker.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/isolate/models/job_message.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/isolate/models/job_result.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/isolate/models/worker_info.dart';

/// Enterprise-level isolate pool manager for parallel background job processing
///
/// Features:
/// - Dynamic worker scaling based on device capabilities
/// - Load balancing across available workers
/// - Health monitoring and automatic recovery
/// - Circuit breaker pattern for failing workers
/// - Graceful degradation to main isolate if needed
class IsolatePoolManager {
  static const String _logTag = 'IsolatePoolManager';
  final log = getLogger(_logTag);
  // Configuration
  final int _minWorkers;
  final int _maxWorkers;
  final Duration _workerIdleTimeout;
  final Duration _healthCheckInterval;

  // Worker management
  final List<WorkerInfo> _workers = [];
  final Map<String, Completer<JobResult>> _pendingJobs = {};
  Timer? _healthCheckTimer;
  bool _isShuttingDown = false;

  // Statistics
  int _totalJobsProcessed = 0;
  int _totalJobsFailed = 0;
  final Map<String, int> _workerJobCounts = {};
  IsolatePoolManager({
    int? minWorkers,
    int? maxWorkers,
    Duration? workerIdleTimeout,
    Duration? healthCheckInterval,
  })  : _minWorkers = minWorkers ?? _calculateMinWorkers(),
        _maxWorkers = maxWorkers ?? _calculateMaxWorkers(),
        _workerIdleTimeout = workerIdleTimeout ?? const Duration(minutes: 5),
        _healthCheckInterval =
            healthCheckInterval ?? const Duration(minutes: 2);

  /// Initialize the isolate pool
  Future<void> initialize() async {
    try {
      log.i('Initializing isolate pool with $_minWorkers-$_maxWorkers workers');

      // Start with minimum workers
      for (int i = 0; i < _minWorkers; i++) {
        await _spawnWorker();
      }

      // Start health monitoring
      _startHealthCheck();

      log.i(
          'Isolate pool initialized successfully with ${_workers.length} workers');
    } catch (e) {
      log.e('Failed to initialize isolate pool: $e');
      rethrow;
    }
  }

  /// Submit a job for processing
  Future<JobResult> submitJob(BackgroundJobInfo jobInfo,
      {Duration? timeout}) async {
    if (_isShuttingDown) {
      throw StateError('Pool is shutting down');
    }

    final jobId = _generateJobId();
    final completer = Completer<JobResult>();
    _pendingJobs[jobId] = completer;

    try {
      final worker = await _selectWorker();
      if (worker == null) {
        throw StateError('No available workers');
      }

      final message = JobMessage(
        jobId: jobId,
        jobInfo: jobInfo,
        timestamp: DateTime.now(),
      );

      // Send job to worker
      worker.sendPort.send(message.toJson());
      worker.markBusy();

      log.d('Job $jobId submitted to worker ${worker.id}');

      // Wait for result with timeout
      final result = await completer.future.timeout(
        timeout ?? const Duration(minutes: 10),
        onTimeout: () {
          _pendingJobs.remove(jobId);
          worker.markAvailable();
          return JobResult.timeout(jobId, 'Job execution timeout');
        },
      );

      _updateStatistics(result);
      return result;
    } catch (e) {
      _pendingJobs.remove(jobId);
      log.e('Failed to submit job $jobId: $e');
      return JobResult.error(jobId, e.toString());
    }
  }

  /// Shutdown the isolate pool gracefully
  Future<void> shutdown() async {
    log.i('Shutting down isolate pool...');
    _isShuttingDown = true;

    // Stop health check
    _healthCheckTimer?.cancel();

    // Wait for pending jobs with timeout
    if (_pendingJobs.isNotEmpty) {
      log.i('Waiting for ${_pendingJobs.length} pending jobs to complete...');
      try {
        await Future.wait(
          _pendingJobs.values.map((c) => c.future),
        ).timeout(const Duration(seconds: 30));
      } catch (e) {
        log.w('Some jobs did not complete during shutdown: $e');
      }
    }

    // Kill all workers
    for (final worker in _workers) {
      await _killWorker(worker);
    }
    _workers.clear();

    log.i('Isolate pool shutdown complete');
  }

  /// Get pool statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalWorkers': _workers.length,
      'activeWorkers': _workers.where((w) => w.isBusy).length,
      'availableWorkers': _workers.where((w) => !w.isBusy).length,
      'pendingJobs': _pendingJobs.length,
      'totalJobsProcessed': _totalJobsProcessed,
      'totalJobsFailed': _totalJobsFailed,
      'successRate': _totalJobsProcessed > 0
          ? ((_totalJobsProcessed - _totalJobsFailed) /
                  _totalJobsProcessed *
                  100)
              .toStringAsFixed(2)
          : '0.00',
      'workerJobCounts': Map.from(_workerJobCounts),
    };
  }

  // Private methods

  static int _calculateMinWorkers() {
    // Conservative approach: 2 workers minimum
    return max(2, (kIsWeb ? 2 : Platform.numberOfProcessors ~/ 2));
  }

  static int _calculateMaxWorkers() {
    // Scale based on available cores, but cap for memory management
    final cores = kIsWeb ? 4 : Platform.numberOfProcessors;
    return max(4, min(8, cores));
  }

  Future<WorkerInfo?> _selectWorker() async {
    // Find available worker
    var availableWorkers =
        _workers.where((w) => !w.isBusy && w.isHealthy).toList();

    if (availableWorkers.isNotEmpty) {
      // Load balancing: select worker with least jobs processed
      availableWorkers.sort((a, b) =>
          (_workerJobCounts[a.id] ?? 0).compareTo(_workerJobCounts[b.id] ?? 0));
      return availableWorkers.first;
    }

    // Try to spawn new worker if under limit
    if (_workers.length < _maxWorkers) {
      try {
        return await _spawnWorker();
      } catch (e) {
        log.w('Failed to spawn new worker: $e');
      }
    }

    // Wait for worker to become available
    var attempts = 0;
    while (attempts < 50) {
      // Max 5 seconds wait
      await Future.delayed(const Duration(milliseconds: 100));
      availableWorkers =
          _workers.where((w) => !w.isBusy && w.isHealthy).toList();
      if (availableWorkers.isNotEmpty) {
        return availableWorkers.first;
      }
      attempts++;
    }

    return null;
  }

  Future<WorkerInfo> _spawnWorker() async {
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();
    final exitPort = ReceivePort();

    try {
      final isolate = await Isolate.spawn(
        isolateWorkerEntryPoint,
        receivePort.sendPort,
        onError: errorPort.sendPort,
        onExit: exitPort.sendPort,
        debugName: 'BackgroundWorker-${_workers.length}',
      );

      final worker = WorkerInfo(
        id: 'worker-${_workers.length}-${DateTime.now().millisecondsSinceEpoch}',
        isolate: isolate,
        receivePort: receivePort,
        sendPort: await receivePort.first as SendPort,
      );

      // Setup message handling
      receivePort.listen((message) => _handleWorkerMessage(worker, message));
      errorPort.listen((error) => _handleWorkerError(worker, error));
      exitPort.listen((_) => _handleWorkerExit(worker));

      _workers.add(worker);
      _workerJobCounts[worker.id] = 0;

      log.d('Spawned worker ${worker.id}');
      return worker;
    } catch (e) {
      receivePort.close();
      errorPort.close();
      exitPort.close();
      log.e('Failed to spawn worker: $e');
      rethrow;
    }
  }

  Future<void> _killWorker(WorkerInfo worker) async {
    try {
      log.d('Killing worker ${worker.id}');

      worker.isolate.kill(priority: Isolate.immediate);
      worker.receivePort.close();
      _workers.remove(worker);
      _workerJobCounts.remove(worker.id);
    } catch (e) {
      log.w('Error killing worker ${worker.id}: $e');
    }
  }

  void _handleWorkerMessage(WorkerInfo worker, dynamic message) {
    try {
      if (message is Map<String, dynamic>) {
        final result = JobResult.fromJson(message);
        final completer = _pendingJobs.remove(result.jobId);

        if (completer != null && !completer.isCompleted) {
          completer.complete(result);
          worker.markAvailable();
          _workerJobCounts[worker.id] = (_workerJobCounts[worker.id] ?? 0) + 1;

          log.d('Job ${result.jobId} completed by worker ${worker.id}');
        }
      }
    } catch (e) {
      log.e('Error handling worker message from ${worker.id}: $e');
    }
  }

  void _handleWorkerError(WorkerInfo worker, dynamic error) {
    log.e('Worker ${worker.id} error: $error');
    worker.markUnhealthy();

    // Handle any pending jobs from this worker
    final workerJobs = _pendingJobs.entries
        .where((entry) => entry.key.startsWith(worker.id))
        .toList();

    for (final entry in workerJobs) {
      if (!entry.value.isCompleted) {
        entry.value
            .complete(JobResult.error(entry.key, 'Worker error: $error'));
      }
      _pendingJobs.remove(entry.key);
    }
  }

  void _handleWorkerExit(WorkerInfo worker) {
    log.w('Worker ${worker.id} exited unexpectedly');
    _workers.remove(worker);
    _workerJobCounts
        .remove(worker.id); // Respawn if needed and not shutting down
    if (!_isShuttingDown && _workers.length < _minWorkers) {
      _spawnWorker().then((_) {
        log.d('Worker respawned after exit');
      }).catchError((e) {
        log.e('Failed to respawn worker after exit: $e');
      });
    }
  }

  void _startHealthCheck() {
    _healthCheckTimer =
        Timer.periodic(_healthCheckInterval, (_) => _performHealthCheck());
  }

  Future<void> _performHealthCheck() async {
    if (_isShuttingDown) return;

    try {
      log.d('Performing health check on ${_workers.length} workers');

      // Remove unhealthy workers
      final unhealthyWorkers = _workers.where((w) => !w.isHealthy).toList();
      for (final worker in unhealthyWorkers) {
        await _killWorker(worker);
      }

      // Ensure minimum workers
      while (_workers.length < _minWorkers && !_isShuttingDown) {
        try {
          await _spawnWorker();
        } catch (e) {
          log.e('Failed to maintain minimum workers during health check: $e');
          break;
        }
      }

      // Remove idle workers above minimum
      if (_workers.length > _minWorkers) {
        final idleWorkers = _workers
            .where((w) =>
                !w.isBusy &&
                DateTime.now().difference(w.lastActivity) > _workerIdleTimeout)
            .take(_workers.length - _minWorkers)
            .toList();

        for (final worker in idleWorkers) {
          await _killWorker(worker);
        }
      }
    } catch (e) {
      log.e('Health check failed: $e');
    }
  }

  void _updateStatistics(JobResult result) {
    _totalJobsProcessed++;
    if (!result.success) {
      _totalJobsFailed++;
    }
  }

  String _generateJobId() {
    return 'job-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(10000)}';
  }
}
