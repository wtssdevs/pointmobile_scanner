import 'dart:convert';
import 'dart:math';
import 'package:sembast/timestamp.dart';
import 'package:xstream_gate_pass_app/core/enums/bckground_job_type.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class BackgroundJobInfo {
  BackgroundJobInfo(
      {required this.id,
      this.refTransactionId = "0",
      this.stopId = 0,
      required this.jobArgs,
      this.tryCount = 0,
      required this.lastTryTime,
      required this.nextTryTime,
      required this.creationTime,
      this.isAbandoned = false,
      this.errorMessage = "",
      required this.jobType});

  factory BackgroundJobInfo.fromJson(Map<String, dynamic> jsonRes) =>
      BackgroundJobInfo(
        id: asT<String>(jsonRes['id']) ?? "",
        jobArgs: asT<dynamic>(jsonRes['jobArgs']),
        tryCount: asT<int>(jsonRes['tryCount']) ?? 0,
        lastTryTime: Timestamp.tryAnyAsTimestamp((jsonRes['lastTryTime'])) ??
            Timestamp.fromDateTime(DateTime.now()),
        nextTryTime: Timestamp.tryAnyAsTimestamp((jsonRes['nextTryTime'])) ??
            Timestamp.fromDateTime(DateTime.now()),
        creationTime: Timestamp.tryAnyAsTimestamp((jsonRes['creationTime'])) ??
            Timestamp.fromDateTime(DateTime.now()),
        isAbandoned: asT<bool>(jsonRes['isAbandoned']) ?? true,
        jobType: asT<int>(jsonRes['jobType']) ?? 0,
        refTransactionId: asT<String>(jsonRes['refTransactionId']) ?? '',
        stopId: asT<int>(jsonRes['stopId']) ?? 0,
        errorMessage: asT<String>(jsonRes['errorMessage']) ?? "",
      );

  String id;
  dynamic jobArgs;
  int tryCount;
  Timestamp lastTryTime;
  Timestamp nextTryTime;
  Timestamp creationTime;
  bool isAbandoned;
  int jobType;
  String refTransactionId;
  int stopId;
  String errorMessage;

  @override
  String toString() {
    return jsonEncode(this);
  }

  bool get hasError => errorMessage.isNotEmpty;

  int calculateTryCount() {
    if (tryCount <= 24) {
      tryCount++;
      return tryCount;
    } else {
      isAbandoned = true;
      return tryCount;
    }
  }

  final int _defaultFirstWaitDuration = 60;
  final double _defaultWaitFactor = 2.0;
  final int _defaultTimeout = 172800;
  DateTime? calculateNextTryTime() {
    var nextWaitDuration = _defaultFirstWaitDuration *
        (pow(_defaultWaitFactor, tryCount - 1)).toInt();
    var nextTryDate =
        lastTryTime.toDateTime().add(Duration(seconds: nextWaitDuration));
    print("JOB:$id, Try COunt:$tryCount");
    var diff = nextTryDate.difference(creationTime.toDateTime());
    if (diff.inSeconds > _defaultTimeout) {
      return null;
    }

    return nextTryDate;
  }

  BackgroundJobType get getJobType {
    switch (jobType) {
      case 0:
        return BackgroundJobType.none;
      case 1:
        return BackgroundJobType.syncMasterfiles;
      case 2:
        return BackgroundJobType.syncImages;
      case 3:
        return BackgroundJobType.clearCache;
      case 4:
        return BackgroundJobType.emailLog;

      default:
        return BackgroundJobType.none;
    }
  }

  set setNewJobType(BackgroundJobType newJobType) {
    jobType = newJobType.index;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'jobArgs': jobArgs,
        'tryCount': tryCount,
        'lastTryTime': lastTryTime.toIso8601String(),
        'nextTryTime': lastTryTime.toIso8601String(),
        'creationTime': lastTryTime.toIso8601String(),
        'isAbandoned': isAbandoned,
        'jobType': jobType,
        'refTransactionId': refTransactionId,
        'stopId': stopId,
        'errorMessage': errorMessage,
      };
}
