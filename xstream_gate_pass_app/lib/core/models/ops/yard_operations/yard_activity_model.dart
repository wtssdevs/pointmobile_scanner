enum YardScanOutcome {
  recorded,
  confirmationRequired,
  alreadyRecorded,
  activitySkipped,
  invalidToken,
  revokedToken,
  activityNotApplicable,
  gatePassIneligible,
  unauthorized,
  concurrentStateChange,
  validationFailure,
  serverFailure;

  static YardScanOutcome parse(String? value) => YardScanOutcome.values
      .firstWhere((item) => item.name.toLowerCase() == value?.toLowerCase(),
          orElse: () => YardScanOutcome.serverFailure);
}

class YardScanResult {
  final YardScanOutcome outcome;
  final String? acknowledgement;
  final List<String> missingActivities;
  final String? effectiveAt;
  final String? effectiveTimeText;
  YardScanResult.fromJson(Map<String, dynamic> json)
      : outcome = YardScanOutcome.parse(json['outcome'] as String?),
        acknowledgement = json['acknowledgement'] as String?,
        missingActivities =
            (json['missingActivities'] as List? ?? []).cast<String>(),
        effectiveAt = json['effectiveAt'] as String?,
        effectiveTimeText = json['effectiveTimeText'] as String?;
}

class YardGatePass {
  final String id;
  final String vehicle;
  final String transaction;
  YardGatePass.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        vehicle = json['vehicleRegNumber'] as String? ?? '',
        transaction = json['transactionNo'] as String? ?? '';
}

class YardTimelineActivity {
  final String name;
  final int status;
  final bool missing;
  final String? originalDisplay;
  final String? effectiveDisplay;
  final bool corrected;
  final bool manuallyAdded;
  YardTimelineActivity.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String? ?? '',
        status = json['status'] as int? ?? 0,
        missing = json['missing'] == true,
        originalDisplay = json['originalDisplay'] as String?,
        effectiveDisplay = json['effectiveDisplay'] as String?,
        corrected = json['isCorrected'] == true,
        manuallyAdded = json['recordSource'] == 'Manager';
  String get statusText => ['Pending', 'Completed', 'Skipped'][status];
}
