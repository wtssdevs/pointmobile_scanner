import 'package:xstream_gate_pass_app/core/models/background_job_que/background_job_Info.dart';

/// Message sent to worker isolate for job processing
class JobMessage {
  final String jobId;
  final BackgroundJobInfo jobInfo;
  final DateTime timestamp;

  JobMessage({
    required this.jobId,
    required this.jobInfo,
    required this.timestamp,
  });

  /// Convert to JSON for isolate communication
  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'jobInfo': jobInfo.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON received from main isolate
  factory JobMessage.fromJson(Map<String, dynamic> json) {
    return JobMessage(
      jobId: json['jobId'] as String,
      jobInfo:
          BackgroundJobInfo.fromJson(json['jobInfo'] as Map<String, dynamic>),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return 'JobMessage(jobId: $jobId, jobType: ${jobInfo.getJobType}, timestamp: $timestamp)';
  }
}
