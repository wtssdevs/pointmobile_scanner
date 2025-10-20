/// Result of job processing in worker isolate
class JobResult {
  final String jobId;
  final bool success;
  final String? error;
  final Map<String, dynamic>? data;
  final DateTime completedAt;

  JobResult({
    required this.jobId,
    required this.success,
    this.error,
    this.data,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();

  /// Create successful result
  factory JobResult.success(String jobId, {Map<String, dynamic>? data}) {
    return JobResult(
      jobId: jobId,
      success: true,
      data: data,
    );
  }

  /// Create error result
  factory JobResult.error(String jobId, String error) {
    return JobResult(
      jobId: jobId,
      success: false,
      error: error,
    );
  }

  /// Create timeout result
  factory JobResult.timeout(String jobId, String message) {
    return JobResult(
      jobId: jobId,
      success: false,
      error: 'TIMEOUT: $message',
    );
  }

  /// Convert to JSON for isolate communication
  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'success': success,
      'error': error,
      'data': data,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  /// Create from JSON received from worker isolate
  factory JobResult.fromJson(Map<String, dynamic> json) {
    return JobResult(
      jobId: json['jobId'] as String,
      success: json['success'] as bool,
      error: json['error'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'JobResult(jobId: $jobId, success: $success, error: $error, completedAt: $completedAt)';
  }
}
