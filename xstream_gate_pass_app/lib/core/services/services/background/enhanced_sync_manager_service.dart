import 'dart:async';
import 'package:cron/cron.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/background_processing_migration_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/background_processing_monitor.dart';
import 'package:xstream_gate_pass_app/core/services/shared/stoppable_service.dart';

/// Enhanced sync manager with enterprise-level monitoring and migration support
///
/// Features:
/// - Seamless integration with isolate-based background processing
/// - Real-time performance monitoring
/// - Adaptive scheduling based on system performance
/// - Health monitoring and automatic recovery
/// - Backward compatibility with existing sync infrastructure
@Singleton()
class EnhancedSyncManager extends StoppableService {
  final log = getLogger('EnhancedSyncManager');
  final cron = Cron();

  // Services
  final _migrationService = locator<BackgroundProcessingMigrationService>();
  final _monitor = locator<BackgroundProcessingMonitor>();

  // Scheduling
  ScheduledTask? _syncTask;
  Timer? _healthCheckTimer;

  // Configuration
  String _syncInterval = "* * * * *"; // Default: every minute
  bool _adaptiveScheduling = true;
  Duration _healthCheckInterval = const Duration(minutes: 5);

  // State
  bool _isInitialized = false;
  DateTime? _lastSuccessfulSync;
  int _consecutiveFailures = 0;

  // Performance tracking
  final List<Duration> _syncDurations = [];
  static const int _maxDurationHistory = 20;

  EnhancedSyncManager() {
    _initializeAsync();
  }

  /// Initialize the enhanced sync manager
  Future<void> _initializeAsync() async {
    try {
      log.i('Initializing enhanced sync manager');

      // Start monitoring
      await _monitor.startMonitoring();

      // Listen to performance alerts
      _monitor.alertStream.listen(_handlePerformanceAlert);

      // Start background job
      await startBackgroundJob();

      // Start health monitoring
      _startHealthMonitoring();

      _isInitialized = true;
      log.i('Enhanced sync manager initialized successfully');
    } catch (e) {
      log.e('Failed to initialize enhanced sync manager: $e');
      _isInitialized = false;
    }
  }

  @override
  void start() async {
    super.start();

    if (!_isInitialized) {
      await _initializeAsync();
    }

    if (serviceStopped == false) {
      await startBackgroundJob();
      _startHealthMonitoring();
    }
  }

  @override
  void stop() async {
    super.stop();

    // Cancel scheduled tasks
    await _syncTask?.cancel();
    _healthCheckTimer?.cancel();

    // Stop monitoring
    _monitor.stopMonitoring();

    log.i('Enhanced sync manager stopped');
  }

  /// Start background job with enhanced scheduling
  Future<void> startBackgroundJob() async {
    try {
      // Cancel existing task
      await _syncTask?.cancel();

      // Determine sync interval
      final interval =
          _adaptiveScheduling ? _calculateAdaptiveInterval() : _syncInterval;

      log.i('Starting background job with interval: $interval');

      _syncTask = cron.schedule(Schedule.parse(interval), () async {
        if (!serviceStopped) {
          await _executeSyncWithMonitoring();
        }
      });
    } catch (e) {
      log.e('Failed to start background job: $e');
    }
  }

  /// Execute sync with performance monitoring
  Future<void> _executeSyncWithMonitoring() async {
    final startTime = DateTime.now();

    try {
      log.d('Starting background sync execution');

      // Execute sync through migration service
      await _migrationService.startExecution();

      // Track success
      final duration = DateTime.now().difference(startTime);
      _recordSyncSuccess(duration);

      log.d(
          'Background sync completed successfully in ${duration.inMilliseconds}ms');
    } catch (e) {
      // Track failure
      final duration = DateTime.now().difference(startTime);
      _recordSyncFailure(duration, e);

      log.e('Background sync failed after ${duration.inMilliseconds}ms: $e');
    }
  }

  /// Record successful sync
  void _recordSyncSuccess(Duration duration) {
    _lastSuccessfulSync = DateTime.now();
    _consecutiveFailures = 0;

    // Store duration for adaptive scheduling
    _syncDurations.add(duration);
    while (_syncDurations.length > _maxDurationHistory) {
      _syncDurations.removeAt(0);
    }

    // Adjust scheduling if needed
    if (_adaptiveScheduling) {
      _adjustSchedulingAfterSuccess();
    }
  }

  /// Record failed sync
  void _recordSyncFailure(Duration duration, dynamic error) {
    _consecutiveFailures++;

    // Adjust scheduling if needed
    if (_adaptiveScheduling) {
      _adjustSchedulingAfterFailure();
    }

    // Alert on consecutive failures
    if (_consecutiveFailures >= 3) {
      log.w(
          'Multiple consecutive sync failures detected: $_consecutiveFailures');
    }
  }

  /// Calculate adaptive sync interval based on performance
  String _calculateAdaptiveInterval() {
    // Default interval
    var intervalMinutes = 1;

    try {
      final summary = _monitor.getPerformanceSummary();

      // Adjust based on success rate
      if (summary.avgSuccessRate < 90) {
        // Poor performance - sync less frequently
        intervalMinutes = 5;
      } else if (summary.avgSuccessRate > 98) {
        // Excellent performance - can sync more frequently
        intervalMinutes = 1;
      } else {
        // Good performance - normal interval
        intervalMinutes = 2;
      }
      // Adjust based on recent sync durations
      if (_syncDurations.isNotEmpty) {
        final totalMs =
            _syncDurations.map((d) => d.inMilliseconds).reduce((a, b) => a + b);
        final avgDurationMs = totalMs / _syncDurations.length;
        if (avgDurationMs > 30000) {
          // 30 seconds
          // Slow syncs - reduce frequency
          intervalMinutes = (intervalMinutes * 1.5).round();
        }
      }

      // Adjust based on consecutive failures
      if (_consecutiveFailures > 0) {
        intervalMinutes = intervalMinutes * (_consecutiveFailures + 1);
      }

      // Cap the interval
      intervalMinutes = intervalMinutes.clamp(1, 10);
    } catch (e) {
      log.e('Error calculating adaptive interval: $e');
      intervalMinutes = 1; // Fallback to default
    }

    // Convert to cron format
    return "*/$intervalMinutes * * * *";
  }

  /// Adjust scheduling after successful sync
  void _adjustSchedulingAfterSuccess() {
    // Could implement logic to gradually increase sync frequency
    // if performance is consistently good
  }

  /// Adjust scheduling after failed sync
  void _adjustSchedulingAfterFailure() {
    // Could implement backoff strategy
    // Restart with updated interval
    startBackgroundJob().catchError((e) {
      log.e('Failed to restart background job after failure: $e');
    });
  }

  /// Start health monitoring
  void _startHealthMonitoring() {
    _healthCheckTimer?.cancel();

    _healthCheckTimer = Timer.periodic(_healthCheckInterval, (_) async {
      await _performHealthCheck();
    });
  }

  /// Perform health check
  Future<void> _performHealthCheck() async {
    try {
      final summary = _monitor.getPerformanceSummary();

      // Check if sync is completely stalled
      if (_lastSuccessfulSync != null) {
        final timeSinceLastSync =
            DateTime.now().difference(_lastSuccessfulSync!);
        if (timeSinceLastSync.inMinutes > 10) {
          log.w('No successful sync in ${timeSinceLastSync.inMinutes} minutes');

          // Try to restart sync
          await _restartSync();
        }
      }

      // Check performance health
      if (!summary.isHealthy) {
        log.w('Background processing performance is unhealthy');
        await _handleUnhealthyPerformance(summary);
      }
    } catch (e) {
      log.e('Health check failed: $e');
    }
  }

  /// Handle performance alerts
  void _handlePerformanceAlert(PerformanceAlert alert) {
    log.w('Performance alert: ${alert.message}');

    switch (alert.severity) {
      case AlertSeverity.critical:
        _handleCriticalAlert(alert);
        break;
      case AlertSeverity.warning:
        _handleWarningAlert(alert);
        break;
      case AlertSeverity.info:
        _handleInfoAlert(alert);
        break;
    }
  }

  /// Handle critical performance alert
  void _handleCriticalAlert(PerformanceAlert alert) {
    switch (alert.type) {
      case AlertType.lowSuccessRate:
      case AlertType.noAvailableWorkers:
        // Try to restart the entire background processing system
        _restartBackgroundProcessing();
        break;
      default:
        break;
    }
  }

  /// Handle warning performance alert
  void _handleWarningAlert(PerformanceAlert alert) {
    switch (alert.type) {
      case AlertType.highErrorRate:
      case AlertType.stuckExecution:
        // Adjust sync frequency
        if (_adaptiveScheduling) {
          startBackgroundJob();
        }
        break;
      default:
        break;
    }
  }

  /// Handle info performance alert
  void _handleInfoAlert(PerformanceAlert alert) {
    // Just log info alerts for now
    log.i('Performance info: ${alert.message}');
  }

  /// Handle unhealthy performance
  Future<void> _handleUnhealthyPerformance(PerformanceSummary summary) async {
    try {
      log.w('Handling unhealthy performance: ${summary.toJson()}');

      // If using enhanced manager and having issues, try rollback
      if (_migrationService.isUsingEnhanced && summary.avgSuccessRate < 80) {
        log.w('Performance is severely degraded, considering rollback');
        // Could implement automatic rollback logic here
      }
    } catch (e) {
      log.e('Error handling unhealthy performance: $e');
    }
  }

  /// Restart sync
  Future<void> _restartSync() async {
    try {
      log.i('Restarting background sync');
      stop();
      await Future.delayed(const Duration(seconds: 2));
      start();
    } catch (e) {
      log.e('Failed to restart sync: $e');
    }
  }

  /// Restart entire background processing system
  void _restartBackgroundProcessing() {
    try {
      log.w('Restarting entire background processing system');

      // This is a drastic measure - would need careful implementation
      // For now, just restart sync
      _restartSync();
    } catch (e) {
      log.e('Failed to restart background processing: $e');
    }
  }

  // Public API for configuration

  /// Set sync interval (cron format)
  void setSyncInterval(String cronExpression) {
    _syncInterval = cronExpression;
    log.i('Sync interval changed to: $cronExpression');

    if (!serviceStopped) {
      startBackgroundJob();
    }
  }

  /// Enable or disable adaptive scheduling
  void setAdaptiveScheduling(bool enabled) {
    _adaptiveScheduling = enabled;
    log.i('Adaptive scheduling ${enabled ? "enabled" : "disabled"}');

    if (!serviceStopped) {
      startBackgroundJob();
    }
  }

  /// Set health check interval
  void setHealthCheckInterval(Duration interval) {
    _healthCheckInterval = interval;
    log.i('Health check interval changed to: ${interval.inMinutes} minutes');

    if (!serviceStopped) {
      _startHealthMonitoring();
    }
  }

  /// Get sync statistics
  Map<String, dynamic> getSyncStatistics() {
    return {
      'isInitialized': _isInitialized,
      'lastSuccessfulSync': _lastSuccessfulSync?.toIso8601String(),
      'consecutiveFailures': _consecutiveFailures,
      'currentInterval': _syncInterval,
      'adaptiveScheduling': _adaptiveScheduling,
      'avgSyncDuration': _syncDurations.isNotEmpty
          ? (_syncDurations.reduce((a, b) => a + b).inMilliseconds /
                  _syncDurations.length)
              .round()
          : 0,
      'syncHistory': _syncDurations.map((d) => d.inMilliseconds).toList(),
      'performanceSummary': _monitor.getPerformanceSummary().toJson(),
    };
  }

  /// Force sync execution
  Future<void> forceSyncExecution() async {
    log.i('Forcing sync execution');
    await _executeSyncWithMonitoring();
  }

  /// Cleanup resources
  Future<void> dispose() async {
    stop();
    await _monitor.dispose();
  }
}
