import 'dart:isolate';

/// Information about a worker isolate
class WorkerInfo {
  final String id;
  final Isolate isolate;
  final ReceivePort receivePort;
  final SendPort sendPort;

  bool _isBusy = false;
  bool _isHealthy = true;
  DateTime _lastActivity = DateTime.now();

  WorkerInfo({
    required this.id,
    required this.isolate,
    required this.receivePort,
    required this.sendPort,
  });

  /// Whether the worker is currently processing a job
  bool get isBusy => _isBusy;

  /// Whether the worker is healthy and available
  bool get isHealthy => _isHealthy;

  /// Last activity timestamp
  DateTime get lastActivity => _lastActivity;

  /// Mark worker as busy
  void markBusy() {
    _isBusy = true;
    _lastActivity = DateTime.now();
  }

  /// Mark worker as available
  void markAvailable() {
    _isBusy = false;
    _lastActivity = DateTime.now();
  }

  /// Mark worker as unhealthy
  void markUnhealthy() {
    _isHealthy = false;
    _lastActivity = DateTime.now();
  }

  /// Mark worker as healthy
  void markHealthy() {
    _isHealthy = true;
    _lastActivity = DateTime.now();
  }

  @override
  String toString() {
    return 'WorkerInfo(id: $id, isBusy: $_isBusy, isHealthy: $_isHealthy, lastActivity: $_lastActivity)';
  }
}
