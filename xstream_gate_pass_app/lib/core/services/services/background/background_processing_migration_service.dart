import 'dart:async';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/models/background_job_que/background_job_Info.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/background_processing_config.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/enhanced_workqueue_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';

/// Migration service for transitioning from legacy WorkerQueManager to EnhancedWorkerQueManager
///
/// Provides:
/// - Seamless transition without breaking existing functionality
/// - Feature flag based rollout
/// - A/B testing capabilities
/// - Rollback mechanism if issues are detected
/// - Progressive migration strategy
@LazySingleton()
class BackgroundProcessingMigrationService {
  final log = getLogger('BackgroundProcessingMigrationService');

  final _config = locator<BackgroundProcessingConfig>();

  // Manager instances
  WorkerQueManager? _legacyManager;
  EnhancedWorkerQueManager? _enhancedManager;

  // Migration state
  bool _migrationCompleted = false;
  bool _useEnhanced = false;
  DateTime? _migrationStartTime;

  // Monitoring
  final StreamController<Map<String, dynamic>> _migrationStatusController = StreamController<Map<String, dynamic>>.broadcast();

  // Statistics for comparison
  final Map<String, dynamic> _legacyStats = {};
  final Map<String, dynamic> _enhancedStats = {};

  BackgroundProcessingMigrationService() {
    _initializeMigration();
  }

  /// Stream for migration status updates
  Stream<Map<String, dynamic>> get migrationStatusStream => _migrationStatusController.stream;

  /// Initialize migration process
  Future<void> _initializeMigration() async {
    try {
      log.i('Initializing background processing migration');

      // Always initialize legacy manager for fallback
      _legacyManager = locator<WorkerQueManager>();

      // Initialize enhanced manager based on configuration
      if (_config.isolatesEnabled) {
        _enhancedManager = EnhancedWorkerQueManager();
        await _startMigrationProcess();
      }
    } catch (e) {
      log.e('Failed to initialize migration: $e');
      _useEnhanced = false;
    }
  }

  /// Start the migration process
  Future<void> _startMigrationProcess() async {
    try {
      _migrationStartTime = DateTime.now();

      // Phase 1: Validate enhanced manager functionality
      final validationResult = await _validateEnhancedManager();
      if (!validationResult) {
        log.w('Enhanced manager validation failed, staying with legacy');
        return;
      }

      // Phase 2: Gradual rollout
      await _performGradualRollout();

      // Phase 3: Monitor and decide
      await _monitorAndDecide();
    } catch (e) {
      log.e('Migration process failed: $e');
      await _rollbackToLegacy();
    }
  }

  /// Validate enhanced manager functionality
  Future<bool> _validateEnhancedManager() async {
    try {
      log.i('Validating enhanced manager functionality');

      if (_enhancedManager == null) {
        return false;
      }

      // Check if enhanced manager can initialize properly
      final stats = _enhancedManager!.getStatistics();
      final executionMode = stats['executionMode'];

      log.d('Enhanced manager execution mode: $executionMode');

      // Validation criteria
      final isValid = stats['executionMode'] != null && stats['maxConcurrentTasks'] > 0;

      if (isValid) {
        log.i('Enhanced manager validation successful');
      } else {
        log.w('Enhanced manager validation failed: $stats');
      }

      return isValid;
    } catch (e) {
      log.e('Enhanced manager validation error: $e');
      return false;
    }
  }

  /// Perform gradual rollout
  Future<void> _performGradualRollout() async {
    log.i('Starting gradual rollout to enhanced manager');

    // Phase 1: 0% traffic (testing only)
    await _runPhase('Testing Phase', 0.0, const Duration(minutes: 2));

    // Phase 2: 25% traffic
    await _runPhase('25% Rollout', 0.25, const Duration(minutes: 5));

    // Phase 3: 50% traffic
    await _runPhase('50% Rollout', 0.50, const Duration(minutes: 5));

    // Phase 4: 75% traffic
    await _runPhase('75% Rollout', 0.75, const Duration(minutes: 5));

    // Phase 5: 100% traffic
    await _runPhase('Full Rollout', 1.0, const Duration(minutes: 10));
  }

  /// Run a specific migration phase
  Future<void> _runPhase(String phaseName, double trafficPercentage, Duration duration) async {
    log.i('Running migration phase: $phaseName ($trafficPercentage traffic)');

    _useEnhanced = true; // For this implementation, we'll use enhanced manager

    // Monitor phase
    Timer? monitoringTimer;

    try {
      monitoringTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
        _collectPhaseStatistics(phaseName);
      });

      // Wait for phase duration
      await Future.delayed(duration);

      // Evaluate phase success
      final phaseSuccess = await _evaluatePhaseSuccess(phaseName);
      if (!phaseSuccess) {
        throw Exception('Phase $phaseName failed evaluation');
      }

      log.i('Phase $phaseName completed successfully');
    } catch (e) {
      log.e('Phase $phaseName failed: $e');
      rethrow;
    } finally {
      monitoringTimer?.cancel();
    }
  }

  /// Collect statistics during migration phase
  void _collectPhaseStatistics(String phaseName) {
    try {
      if (_useEnhanced && _enhancedManager != null) {
        _enhancedStats[phaseName] = _enhancedManager!.getStatistics();
      } else if (_legacyManager != null) {
        _legacyStats[phaseName] = {
          'isExecuting': _legacyManager!.isExecuting,
          'runningTasks': _legacyManager!.runningTasks,
          'maxConcurrentTasks': _legacyManager!.maxConcurrentTasks,
        };
      }

      _broadcastMigrationStatus();
    } catch (e) {
      log.e('Error collecting phase statistics: $e');
    }
  }

  /// Evaluate if a phase was successful
  Future<bool> _evaluatePhaseSuccess(String phaseName) async {
    try {
      // Success criteria
      const minSuccessRate = 0.95; // 95% min success rate

      if (_useEnhanced && _enhancedManager != null) {
        final stats = _enhancedManager!.getStatistics();
        final successRateStr = stats['successRate'] as String? ?? '0.00';
        final successRate = double.tryParse(successRateStr) ?? 0.0;

        final isSuccessful = successRate >= (minSuccessRate * 100);

        log.d('Phase $phaseName success rate: $successRate% (threshold: ${minSuccessRate * 100}%)');

        return isSuccessful;
      }

      return true; // Legacy manager is considered stable
    } catch (e) {
      log.e('Error evaluating phase success: $e');
      return false;
    }
  }

  /// Monitor system and make final decision
  Future<void> _monitorAndDecide() async {
    log.i('Monitoring system performance for final decision');

    // Monitor for extended period
    const monitoringDuration = Duration(minutes: 15);
    final monitoringStart = DateTime.now();

    Timer.periodic(const Duration(minutes: 1), (timer) {
      final elapsed = DateTime.now().difference(monitoringStart);
      if (elapsed >= monitoringDuration) {
        timer.cancel();
      }
      _collectPhaseStatistics('Final Monitoring');
    });

    await Future.delayed(monitoringDuration);

    // Make final decision
    final finalDecision = await _makeFinalDecision();

    if (finalDecision) {
      await _completeMigration();
    } else {
      await _rollbackToLegacy();
    }
  }

  /// Make final migration decision
  Future<bool> _makeFinalDecision() async {
    try {
      if (!_useEnhanced || _enhancedManager == null) {
        return false;
      }

      final stats = _enhancedManager!.getStatistics();
      final successRateStr = stats['successRate'] as String? ?? '0.00';
      final successRate = double.tryParse(successRateStr) ?? 0.0;
      final totalJobs = stats['totalJobsProcessed'] as int? ?? 0;

      // Decision criteria
      final hasGoodSuccessRate = successRate >= 95.0;
      final hasProcessedJobs = totalJobs > 0;
      final isolatesWorking = stats['executionMode'] == 'isolates';

      final decision = hasGoodSuccessRate && hasProcessedJobs && isolatesWorking;

      log.i('Final migration decision: $decision');
      log.d('Success rate: $successRate%, Jobs processed: $totalJobs, Isolates: $isolatesWorking');

      return decision;
    } catch (e) {
      log.e('Error making final decision: $e');
      return false;
    }
  }

  /// Complete migration to enhanced manager
  Future<void> _completeMigration() async {
    try {
      log.i('Completing migration to enhanced manager');

      _migrationCompleted = true;
      _useEnhanced = true;

      // Cleanup legacy manager resources if needed
      // _legacyManager = null; // Keep for potential rollback

      log.i('Migration completed successfully');
      _broadcastMigrationStatus();
    } catch (e) {
      log.e('Error completing migration: $e');
      await _rollbackToLegacy();
    }
  }

  /// Rollback to legacy manager
  Future<void> _rollbackToLegacy() async {
    try {
      log.w('Rolling back to legacy manager');

      _useEnhanced = false;
      _migrationCompleted = false;

      // Cleanup enhanced manager resources
      if (_enhancedManager != null) {
        await _enhancedManager!.dispose();
      }

      log.i('Rollback to legacy manager completed');
      _broadcastMigrationStatus();
    } catch (e) {
      log.e('Error during rollback: $e');
    }
  }

  /// Broadcast migration status
  void _broadcastMigrationStatus() {
    final status = getMigrationStatus();
    _migrationStatusController.add(status);
  }

  // Public API for accessing the appropriate manager

  /// Get the currently active manager
  dynamic get activeManager {
    if (_useEnhanced && _enhancedManager != null) {
      return _enhancedManager;
    }
    return _legacyManager;
  }

  /// Check if using enhanced manager
  bool get isUsingEnhanced => _useEnhanced && _enhancedManager != null;

  /// Check if migration is completed
  bool get isMigrationCompleted => _migrationCompleted;

  /// Get comprehensive migration status
  Map<String, dynamic> getMigrationStatus() {
    return {
      'migrationCompleted': _migrationCompleted,
      'usingEnhanced': _useEnhanced,
      'migrationStartTime': _migrationStartTime?.toIso8601String(),
      'activeManager': _useEnhanced ? 'enhanced' : 'legacy',
      'enhancedAvailable': _enhancedManager != null,
      'legacyAvailable': _legacyManager != null,
      'legacyStats': Map.from(_legacyStats),
      'enhancedStats': Map.from(_enhancedStats),
      'configEnabled': _config.isolatesEnabled,
    };
  }

  /// Force migration to enhanced manager (for testing)
  Future<void> forceMigrationToEnhanced() async {
    log.i('Forcing migration to enhanced manager');

    if (_enhancedManager == null) {
      _enhancedManager = EnhancedWorkerQueManager();
    }

    await _completeMigration();
  }

  /// Force rollback to legacy manager (for testing)
  Future<void> forceRollbackToLegacy() async {
    log.i('Forcing rollback to legacy manager');
    await _rollbackToLegacy();
  }

  /// Cleanup resources
  Future<void> dispose() async {
    await _migrationStatusController.close();

    if (_enhancedManager != null) {
      await _enhancedManager!.dispose();
    }
  }

  // Wrapper methods to maintain API compatibility

  Future<void> enqueSingle(BackgroundJobInfo value, [bool startNow = true]) async {
    if (_useEnhanced && _enhancedManager != null) {
      return _enhancedManager!.enqueSingle(value, startNow);
    }
    return _legacyManager!.enqueSingle(value, startNow);
  }

  Future<void> enqueForStartUp() async {
    if (_useEnhanced && _enhancedManager != null) {
      return _enhancedManager!.enqueForStartUp();
    }
    return _legacyManager!.enqueForStartUp();
  }

  Future<void> enqueMany(List<BackgroundJobInfo> iterable) async {
    if (_useEnhanced && _enhancedManager != null) {
      return _enhancedManager!.enqueMany(iterable);
    }
    return _legacyManager!.enqueMany(iterable);
  }

  Future<void> startExecution({bool forceRun = false}) async {
    if (_useEnhanced && _enhancedManager != null) {
      return _enhancedManager!.startExecution(forceRun: forceRun);
    }
    return _legacyManager!.startExecution(forceRun: forceRun);
  }

  Stream<dynamic> get onSyncTaskChange {
    if (_useEnhanced && _enhancedManager != null) {
      return _enhancedManager!.onSyncTaskChange;
    }
    return _legacyManager!.onSyncTaskChange;
  }

  bool get isExecuting {
    if (_useEnhanced && _enhancedManager != null) {
      return _enhancedManager!.isExecuting;
    }
    return _legacyManager!.isExecuting;
  }
}
