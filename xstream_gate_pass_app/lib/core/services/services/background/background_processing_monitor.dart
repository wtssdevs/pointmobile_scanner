import 'dart:async';
import 'dart:collection';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/background_processing_migration_service.dart';

/// Performance monitoring dashboard for background processing
///
/// Provides:
/// - Real-time performance metrics
/// - Historical data tracking
/// - Health status monitoring
/// - Performance alerting
/// - Resource usage tracking
@LazySingleton()
class BackgroundProcessingMonitor {
  final log = getLogger('BackgroundProcessingMonitor');

  final _migrationService = locator<BackgroundProcessingMigrationService>();

  // Monitoring state
  bool _isMonitoring = false;
  Timer? _monitoringTimer;

  // Metrics storage
  final Queue<Map<String, dynamic>> _metricsHistory = Queue();
  static const int _maxHistorySize = 100;

  // Performance thresholds
  static const double _errorRateThreshold = 5.0; // 5%
  static const double _successRateThreshold = 95.0; // 95%
  static const int _maxResponseTimeMs = 30000; // 30 seconds

  // Alerts
  final StreamController<PerformanceAlert> _alertController = StreamController<PerformanceAlert>.broadcast();
  final List<PerformanceAlert> _activeAlerts = [];

  // Statistics
  final StreamController<PerformanceMetrics> _metricsController = StreamController<PerformanceMetrics>.broadcast();

  /// Stream for performance alerts
  Stream<PerformanceAlert> get alertStream => _alertController.stream;

  /// Stream for performance metrics
  Stream<PerformanceMetrics> get metricsStream => _metricsController.stream;

  /// Start monitoring
  Future<void> startMonitoring({Duration interval = const Duration(seconds: 30)}) async {
    if (_isMonitoring) {
      log.w('Monitoring already started');
      return;
    }

    log.i('Starting background processing monitoring');
    _isMonitoring = true;

    _monitoringTimer = Timer.periodic(interval, (_) => _collectMetrics());

    // Also listen to migration status changes
    _migrationService.migrationStatusStream.listen(_processMigrationStatus);
  }

  /// Stop monitoring
  void stopMonitoring() {
    if (!_isMonitoring) {
      return;
    }

    log.i('Stopping background processing monitoring');
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  /// Collect performance metrics
  Future<void> _collectMetrics() async {
    try {
      final activeManager = _migrationService.activeManager;
      if (activeManager == null) {
        return;
      }

      Map<String, dynamic> stats = {};

      // Get stats based on manager type
      if (_migrationService.isUsingEnhanced) {
        stats = activeManager.getStatistics();
      } else {
        stats = {
          'executionMode': 'legacy',
          'isExecuting': activeManager.isExecuting,
          'runningTasks': activeManager.runningTasks,
          'maxConcurrentTasks': activeManager.maxConcurrentTasks,
          'totalJobsProcessed': 0,
          'totalJobsFailed': 0,
          'successRate': '100.00',
        };
      }

      final timestamp = DateTime.now();
      final metrics = PerformanceMetrics.fromStats(stats, timestamp);

      // Store in history
      _storeMetrics(stats, timestamp);

      // Check for alerts
      _checkForAlerts(metrics);

      // Broadcast metrics
      _metricsController.add(metrics);
    } catch (e) {
      log.e('Error collecting metrics: $e');
    }
  }

  /// Store metrics in history
  void _storeMetrics(Map<String, dynamic> stats, DateTime timestamp) {
    final metricsEntry = {
      'timestamp': timestamp.toIso8601String(),
      'stats': Map.from(stats),
    };

    _metricsHistory.add(metricsEntry);

    // Maintain history size
    while (_metricsHistory.length > _maxHistorySize) {
      _metricsHistory.removeFirst();
    }
  }

  /// Check for performance alerts
  void _checkForAlerts(PerformanceMetrics metrics) {
    final alerts = <PerformanceAlert>[];

    // Check error rate
    if (metrics.errorRate > _errorRateThreshold) {
      alerts.add(PerformanceAlert(
        type: AlertType.highErrorRate,
        severity: AlertSeverity.warning,
        message: 'High error rate detected: ${metrics.errorRate.toStringAsFixed(2)}%',
        value: metrics.errorRate,
        threshold: _errorRateThreshold,
        timestamp: metrics.timestamp,
      ));
    }

    // Check success rate
    if (metrics.successRate < _successRateThreshold) {
      alerts.add(PerformanceAlert(
        type: AlertType.lowSuccessRate,
        severity: AlertSeverity.critical,
        message: 'Low success rate detected: ${metrics.successRate.toStringAsFixed(2)}%',
        value: metrics.successRate,
        threshold: _successRateThreshold,
        timestamp: metrics.timestamp,
      ));
    }

    // Check for stuck jobs
    if (metrics.isExecuting && metrics.runningTasks == 0) {
      alerts.add(PerformanceAlert(
        type: AlertType.stuckExecution,
        severity: AlertSeverity.warning,
        message: 'Execution is marked as running but no tasks are active',
        value: 0,
        threshold: 1,
        timestamp: metrics.timestamp,
      ));
    }

    // Check isolate pool health (if using enhanced manager)
    if (metrics.executionMode == 'isolates' && metrics.availableWorkers == 0) {
      alerts.add(PerformanceAlert(
        type: AlertType.noAvailableWorkers,
        severity: AlertSeverity.critical,
        message: 'No isolate workers available',
        value: 0,
        threshold: 1,
        timestamp: metrics.timestamp,
      ));
    }

    // Process new alerts
    for (final alert in alerts) {
      _processAlert(alert);
    }
  }

  /// Process migration status changes
  void _processMigrationStatus(Map<String, dynamic> status) {
    try {
      final migrationCompleted = status['migrationCompleted'] as bool? ?? false;
      final usingEnhanced = status['usingEnhanced'] as bool? ?? false;

      if (migrationCompleted && usingEnhanced) {
        _processAlert(PerformanceAlert(
          type: AlertType.migrationSuccess,
          severity: AlertSeverity.info,
          message: 'Successfully migrated to enhanced background processing',
          value: 1,
          threshold: 1,
          timestamp: DateTime.now(),
        ));
      } else if (migrationCompleted && !usingEnhanced) {
        _processAlert(PerformanceAlert(
          type: AlertType.migrationRollback,
          severity: AlertSeverity.warning,
          message: 'Background processing rolled back to legacy mode',
          value: 0,
          threshold: 1,
          timestamp: DateTime.now(),
        ));
      }
    } catch (e) {
      log.e('Error processing migration status: $e');
    }
  }

  /// Process individual alert
  void _processAlert(PerformanceAlert alert) {
    // Check if this is a duplicate alert
    final isDuplicate = _activeAlerts.any((a) => a.type == alert.type && a.severity == alert.severity && DateTime.now().difference(a.timestamp).inMinutes < 5);

    if (!isDuplicate) {
      _activeAlerts.add(alert);
      _alertController.add(alert);

      log.w('Performance alert: ${alert.message}');

      // Cleanup old alerts
      _cleanupOldAlerts();
    }
  }

  /// Cleanup old alerts
  void _cleanupOldAlerts() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    _activeAlerts.removeWhere((alert) => alert.timestamp.isBefore(cutoff));
  }

  /// Get current performance summary
  PerformanceSummary getPerformanceSummary() {
    if (_metricsHistory.isEmpty) {
      return PerformanceSummary.empty();
    }

    final recent = _metricsHistory.toList();
    final totalEntries = recent.length;

    // Calculate averages from recent metrics
    double avgSuccessRate = 0;
    double avgErrorRate = 0;
    int totalJobs = 0;
    int totalFailures = 0;

    for (final entry in recent) {
      final stats = entry['stats'] as Map<String, dynamic>;
      final successRateStr = stats['successRate'] as String? ?? '100.00';
      final successRate = double.tryParse(successRateStr) ?? 100.0;

      avgSuccessRate += successRate;
      avgErrorRate += (100.0 - successRate);
      totalJobs += stats['totalJobsProcessed'] as int? ?? 0;
      totalFailures += stats['totalJobsFailed'] as int? ?? 0;
    }

    avgSuccessRate /= totalEntries;
    avgErrorRate /= totalEntries;

    return PerformanceSummary(
      avgSuccessRate: avgSuccessRate,
      avgErrorRate: avgErrorRate,
      totalJobsProcessed: totalJobs,
      totalJobsFailed: totalFailures,
      activeAlerts: _activeAlerts.length,
      isHealthy: avgSuccessRate >= _successRateThreshold && avgErrorRate <= _errorRateThreshold,
      executionMode: _migrationService.isUsingEnhanced ? 'isolates' : 'legacy',
      metricsCollected: totalEntries,
      monitoringActive: _isMonitoring,
    );
  }

  /// Get metrics history
  List<Map<String, dynamic>> getMetricsHistory({int? limit}) {
    final history = _metricsHistory.toList();
    if (limit != null && limit < history.length) {
      return history.sublist(history.length - limit);
    }
    return history;
  }

  /// Get active alerts
  List<PerformanceAlert> getActiveAlerts() {
    _cleanupOldAlerts();
    return List.from(_activeAlerts);
  }

  /// Clear all alerts
  void clearAlerts() {
    _activeAlerts.clear();
    log.i('All performance alerts cleared');
  }

  /// Dispose resources
  Future<void> dispose() async {
    stopMonitoring();
    await _alertController.close();
    await _metricsController.close();
    _metricsHistory.clear();
    _activeAlerts.clear();
  }
}

/// Performance metrics data class
class PerformanceMetrics {
  final DateTime timestamp;
  final String executionMode;
  final bool isExecuting;
  final int runningTasks;
  final int maxConcurrentTasks;
  final int totalJobsProcessed;
  final int totalJobsFailed;
  final double successRate;
  final double errorRate;
  final int availableWorkers;
  final int activeWorkers;

  PerformanceMetrics({
    required this.timestamp,
    required this.executionMode,
    required this.isExecuting,
    required this.runningTasks,
    required this.maxConcurrentTasks,
    required this.totalJobsProcessed,
    required this.totalJobsFailed,
    required this.successRate,
    required this.errorRate,
    required this.availableWorkers,
    required this.activeWorkers,
  });

  factory PerformanceMetrics.fromStats(Map<String, dynamic> stats, DateTime timestamp) {
    final successRateStr = stats['successRate'] as String? ?? '100.00';
    final successRate = double.tryParse(successRateStr) ?? 100.0;
    final errorRate = 100.0 - successRate;

    // Handle isolate pool stats
    final isolatePool = stats['isolatePool'] as Map<String, dynamic>?;
    final availableWorkers = isolatePool?['availableWorkers'] as int? ?? 0;
    final activeWorkers = isolatePool?['activeWorkers'] as int? ?? 0;

    return PerformanceMetrics(
      timestamp: timestamp,
      executionMode: stats['executionMode'] as String? ?? 'unknown',
      isExecuting: stats['isExecuting'] as bool? ?? false,
      runningTasks: stats['runningTasks'] as int? ?? 0,
      maxConcurrentTasks: stats['maxConcurrentTasks'] as int? ?? 0,
      totalJobsProcessed: stats['totalJobsProcessed'] as int? ?? 0,
      totalJobsFailed: stats['totalJobsFailed'] as int? ?? 0,
      successRate: successRate,
      errorRate: errorRate,
      availableWorkers: availableWorkers,
      activeWorkers: activeWorkers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'executionMode': executionMode,
      'isExecuting': isExecuting,
      'runningTasks': runningTasks,
      'maxConcurrentTasks': maxConcurrentTasks,
      'totalJobsProcessed': totalJobsProcessed,
      'totalJobsFailed': totalJobsFailed,
      'successRate': successRate,
      'errorRate': errorRate,
      'availableWorkers': availableWorkers,
      'activeWorkers': activeWorkers,
    };
  }
}

/// Performance alert data class
class PerformanceAlert {
  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final double value;
  final double threshold;
  final DateTime timestamp;

  PerformanceAlert({
    required this.type,
    required this.severity,
    required this.message,
    required this.value,
    required this.threshold,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'severity': severity.toString(),
      'message': message,
      'value': value,
      'threshold': threshold,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Performance summary data class
class PerformanceSummary {
  final double avgSuccessRate;
  final double avgErrorRate;
  final int totalJobsProcessed;
  final int totalJobsFailed;
  final int activeAlerts;
  final bool isHealthy;
  final String executionMode;
  final int metricsCollected;
  final bool monitoringActive;

  PerformanceSummary({
    required this.avgSuccessRate,
    required this.avgErrorRate,
    required this.totalJobsProcessed,
    required this.totalJobsFailed,
    required this.activeAlerts,
    required this.isHealthy,
    required this.executionMode,
    required this.metricsCollected,
    required this.monitoringActive,
  });

  factory PerformanceSummary.empty() {
    return PerformanceSummary(
      avgSuccessRate: 0,
      avgErrorRate: 0,
      totalJobsProcessed: 0,
      totalJobsFailed: 0,
      activeAlerts: 0,
      isHealthy: false,
      executionMode: 'unknown',
      metricsCollected: 0,
      monitoringActive: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avgSuccessRate': avgSuccessRate,
      'avgErrorRate': avgErrorRate,
      'totalJobsProcessed': totalJobsProcessed,
      'totalJobsFailed': totalJobsFailed,
      'activeAlerts': activeAlerts,
      'isHealthy': isHealthy,
      'executionMode': executionMode,
      'metricsCollected': metricsCollected,
      'monitoringActive': monitoringActive,
    };
  }
}

/// Alert types
enum AlertType {
  highErrorRate,
  lowSuccessRate,
  stuckExecution,
  noAvailableWorkers,
  migrationSuccess,
  migrationRollback,
  resourceExhaustion,
  performanceDegradation,
}

/// Alert severity levels
enum AlertSeverity {
  info,
  warning,
  critical,
}
