import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';

/// Configuration service for background processing settings
///
/// Manages settings for isolate execution, performance tuning,
/// and feature flags for enterprise deployment
@LazySingleton()
class BackgroundProcessingConfig {
  final log = getLogger('BackgroundProcessingConfig');

  // Feature flags
  bool _isolatesEnabled = true;
  bool _fallbackToMainThread = true;
  bool _healthMonitoringEnabled = true;
  bool _advancedRetryLogicEnabled = true;

  // Performance settings
  int _minWorkerIsolates = 2;
  int _maxWorkerIsolates = 4;
  int _maxConcurrentJobs = 4;
  Duration _jobTimeout = const Duration(minutes: 10);
  Duration _workerIdleTimeout = const Duration(minutes: 5);
  Duration _healthCheckInterval = const Duration(minutes: 2);

  // Retry settings
  int _maxRetryAttempts = 24;
  Duration _baseRetryDelay = const Duration(seconds: 60);
  double _retryBackoffFactor = 2.0;
  Duration _maxJobAge = const Duration(days: 2);

  // Monitoring settings
  bool _statisticsEnabled = true;
  Duration _statsReportingInterval = const Duration(seconds: 30);

  BackgroundProcessingConfig() {
    _loadConfiguration();
  }

  // Feature flags getters
  bool get isolatesEnabled => _isolatesEnabled;
  bool get fallbackToMainThread => _fallbackToMainThread;
  bool get healthMonitoringEnabled => _healthMonitoringEnabled;
  bool get advancedRetryLogicEnabled => _advancedRetryLogicEnabled;

  // Performance settings getters
  int get minWorkerIsolates => _minWorkerIsolates;
  int get maxWorkerIsolates => _maxWorkerIsolates;
  int get maxConcurrentJobs => _maxConcurrentJobs;
  Duration get jobTimeout => _jobTimeout;
  Duration get workerIdleTimeout => _workerIdleTimeout;
  Duration get healthCheckInterval => _healthCheckInterval;

  // Retry settings getters
  int get maxRetryAttempts => _maxRetryAttempts;
  Duration get baseRetryDelay => _baseRetryDelay;
  double get retryBackoffFactor => _retryBackoffFactor;
  Duration get maxJobAge => _maxJobAge;

  // Monitoring settings getters
  bool get statisticsEnabled => _statisticsEnabled;
  Duration get statsReportingInterval => _statsReportingInterval;

  /// Load configuration from preferences or environment
  void _loadConfiguration() {
    try {
      // In a real implementation, load from SharedPreferences, environment variables,
      // or remote configuration service

      // For now, we'll use environment-based defaults
      _applyEnvironmentDefaults();

      log.i('Background processing configuration loaded');
      log.d('Isolates enabled: $_isolatesEnabled');
      log.d('Max worker isolates: $_maxWorkerIsolates');
      log.d('Max concurrent jobs: $_maxConcurrentJobs');
    } catch (e) {
      log.e('Failed to load configuration, using defaults: $e');
    }
  }

  /// Apply environment-specific defaults
  void _applyEnvironmentDefaults() {
    // Adjust settings based on debug vs release mode
    const bool isDebugMode = bool.fromEnvironment('dart.vm.product') == false;

    if (isDebugMode) {
      // More conservative settings for development
      _maxWorkerIsolates = 2;
      _maxConcurrentJobs = 2;
      _statsReportingInterval = const Duration(seconds: 15);
      _healthCheckInterval = const Duration(minutes: 1);
    } else {
      // Optimized settings for production
      _maxWorkerIsolates = 4;
      _maxConcurrentJobs = 4;
      _statsReportingInterval = const Duration(seconds: 30);
      _healthCheckInterval = const Duration(minutes: 2);
    }
  }

  /// Update feature flag settings
  void updateFeatureFlags({
    bool? isolatesEnabled,
    bool? fallbackToMainThread,
    bool? healthMonitoringEnabled,
    bool? advancedRetryLogicEnabled,
  }) {
    if (isolatesEnabled != null) {
      _isolatesEnabled = isolatesEnabled;
      log.i('Isolates enabled: $_isolatesEnabled');
    }

    if (fallbackToMainThread != null) {
      _fallbackToMainThread = fallbackToMainThread;
      log.i('Fallback to main thread: $_fallbackToMainThread');
    }

    if (healthMonitoringEnabled != null) {
      _healthMonitoringEnabled = healthMonitoringEnabled;
      log.i('Health monitoring enabled: $_healthMonitoringEnabled');
    }

    if (advancedRetryLogicEnabled != null) {
      _advancedRetryLogicEnabled = advancedRetryLogicEnabled;
      log.i('Advanced retry logic enabled: $_advancedRetryLogicEnabled');
    }
  }

  /// Update performance settings
  void updatePerformanceSettings({
    int? minWorkerIsolates,
    int? maxWorkerIsolates,
    int? maxConcurrentJobs,
    Duration? jobTimeout,
    Duration? workerIdleTimeout,
    Duration? healthCheckInterval,
  }) {
    if (minWorkerIsolates != null && minWorkerIsolates > 0) {
      _minWorkerIsolates = minWorkerIsolates;
      log.i('Min worker isolates: $_minWorkerIsolates');
    }

    if (maxWorkerIsolates != null && maxWorkerIsolates >= _minWorkerIsolates) {
      _maxWorkerIsolates = maxWorkerIsolates;
      log.i('Max worker isolates: $_maxWorkerIsolates');
    }

    if (maxConcurrentJobs != null && maxConcurrentJobs > 0) {
      _maxConcurrentJobs = maxConcurrentJobs;
      log.i('Max concurrent jobs: $_maxConcurrentJobs');
    }

    if (jobTimeout != null) {
      _jobTimeout = jobTimeout;
      log.i('Job timeout: ${_jobTimeout.inMinutes} minutes');
    }

    if (workerIdleTimeout != null) {
      _workerIdleTimeout = workerIdleTimeout;
      log.i('Worker idle timeout: ${_workerIdleTimeout.inMinutes} minutes');
    }

    if (healthCheckInterval != null) {
      _healthCheckInterval = healthCheckInterval;
      log.i('Health check interval: ${_healthCheckInterval.inMinutes} minutes');
    }
  }

  /// Update retry settings
  void updateRetrySettings({
    int? maxRetryAttempts,
    Duration? baseRetryDelay,
    double? retryBackoffFactor,
    Duration? maxJobAge,
  }) {
    if (maxRetryAttempts != null && maxRetryAttempts > 0) {
      _maxRetryAttempts = maxRetryAttempts;
      log.i('Max retry attempts: $_maxRetryAttempts');
    }

    if (baseRetryDelay != null) {
      _baseRetryDelay = baseRetryDelay;
      log.i('Base retry delay: ${_baseRetryDelay.inSeconds} seconds');
    }

    if (retryBackoffFactor != null && retryBackoffFactor > 1.0) {
      _retryBackoffFactor = retryBackoffFactor;
      log.i('Retry backoff factor: $_retryBackoffFactor');
    }

    if (maxJobAge != null) {
      _maxJobAge = maxJobAge;
      log.i('Max job age: ${_maxJobAge.inDays} days');
    }
  }

  /// Get all configuration as map
  Map<String, dynamic> toMap() {
    return {
      'features': {
        'isolatesEnabled': _isolatesEnabled,
        'fallbackToMainThread': _fallbackToMainThread,
        'healthMonitoringEnabled': _healthMonitoringEnabled,
        'advancedRetryLogicEnabled': _advancedRetryLogicEnabled,
      },
      'performance': {
        'minWorkerIsolates': _minWorkerIsolates,
        'maxWorkerIsolates': _maxWorkerIsolates,
        'maxConcurrentJobs': _maxConcurrentJobs,
        'jobTimeoutMinutes': _jobTimeout.inMinutes,
        'workerIdleTimeoutMinutes': _workerIdleTimeout.inMinutes,
        'healthCheckIntervalMinutes': _healthCheckInterval.inMinutes,
      },
      'retry': {
        'maxRetryAttempts': _maxRetryAttempts,
        'baseRetryDelaySeconds': _baseRetryDelay.inSeconds,
        'retryBackoffFactor': _retryBackoffFactor,
        'maxJobAgeDays': _maxJobAge.inDays,
      },
      'monitoring': {
        'statisticsEnabled': _statisticsEnabled,
        'statsReportingIntervalSeconds': _statsReportingInterval.inSeconds,
      },
    };
  }

  /// Load configuration from map (for remote config)
  void fromMap(Map<String, dynamic> config) {
    try {
      final features = config['features'] as Map<String, dynamic>?;
      if (features != null) {
        _isolatesEnabled =
            features['isolatesEnabled'] as bool? ?? _isolatesEnabled;
        _fallbackToMainThread =
            features['fallbackToMainThread'] as bool? ?? _fallbackToMainThread;
        _healthMonitoringEnabled =
            features['healthMonitoringEnabled'] as bool? ??
                _healthMonitoringEnabled;
        _advancedRetryLogicEnabled =
            features['advancedRetryLogicEnabled'] as bool? ??
                _advancedRetryLogicEnabled;
      }

      final performance = config['performance'] as Map<String, dynamic>?;
      if (performance != null) {
        _minWorkerIsolates =
            performance['minWorkerIsolates'] as int? ?? _minWorkerIsolates;
        _maxWorkerIsolates =
            performance['maxWorkerIsolates'] as int? ?? _maxWorkerIsolates;
        _maxConcurrentJobs =
            performance['maxConcurrentJobs'] as int? ?? _maxConcurrentJobs;

        final jobTimeoutMinutes = performance['jobTimeoutMinutes'] as int?;
        if (jobTimeoutMinutes != null) {
          _jobTimeout = Duration(minutes: jobTimeoutMinutes);
        }

        final workerIdleTimeoutMinutes =
            performance['workerIdleTimeoutMinutes'] as int?;
        if (workerIdleTimeoutMinutes != null) {
          _workerIdleTimeout = Duration(minutes: workerIdleTimeoutMinutes);
        }

        final healthCheckIntervalMinutes =
            performance['healthCheckIntervalMinutes'] as int?;
        if (healthCheckIntervalMinutes != null) {
          _healthCheckInterval = Duration(minutes: healthCheckIntervalMinutes);
        }
      }

      final retry = config['retry'] as Map<String, dynamic>?;
      if (retry != null) {
        _maxRetryAttempts =
            retry['maxRetryAttempts'] as int? ?? _maxRetryAttempts;
        _retryBackoffFactor =
            (retry['retryBackoffFactor'] as num?)?.toDouble() ??
                _retryBackoffFactor;

        final baseRetryDelaySeconds = retry['baseRetryDelaySeconds'] as int?;
        if (baseRetryDelaySeconds != null) {
          _baseRetryDelay = Duration(seconds: baseRetryDelaySeconds);
        }

        final maxJobAgeDays = retry['maxJobAgeDays'] as int?;
        if (maxJobAgeDays != null) {
          _maxJobAge = Duration(days: maxJobAgeDays);
        }
      }

      final monitoring = config['monitoring'] as Map<String, dynamic>?;
      if (monitoring != null) {
        _statisticsEnabled =
            monitoring['statisticsEnabled'] as bool? ?? _statisticsEnabled;

        final statsReportingIntervalSeconds =
            monitoring['statsReportingIntervalSeconds'] as int?;
        if (statsReportingIntervalSeconds != null) {
          _statsReportingInterval =
              Duration(seconds: statsReportingIntervalSeconds);
        }
      }

      log.i('Configuration loaded from map successfully');
    } catch (e) {
      log.e('Failed to load configuration from map: $e');
    }
  }

  /// Reset to default configuration
  void resetToDefaults() {
    _isolatesEnabled = true;
    _fallbackToMainThread = true;
    _healthMonitoringEnabled = true;
    _advancedRetryLogicEnabled = true;

    _minWorkerIsolates = 2;
    _maxWorkerIsolates = 4;
    _maxConcurrentJobs = 4;
    _jobTimeout = const Duration(minutes: 10);
    _workerIdleTimeout = const Duration(minutes: 5);
    _healthCheckInterval = const Duration(minutes: 2);

    _maxRetryAttempts = 24;
    _baseRetryDelay = const Duration(seconds: 60);
    _retryBackoffFactor = 2.0;
    _maxJobAge = const Duration(days: 2);

    _statisticsEnabled = true;
    _statsReportingInterval = const Duration(seconds: 30);

    log.i('Configuration reset to defaults');
  }
}
