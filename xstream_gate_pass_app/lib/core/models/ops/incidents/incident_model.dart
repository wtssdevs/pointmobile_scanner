class Incident {
  String? id;
  String? number;
  String? message;
  bool? revolved;
  DateTime? refDateTime;
  String? gatePassAccessId;
  int? branchId;

  // Navigation property values for display
  String? gatePassNumber;
  String? branchName;

  Incident({
    this.id,
    this.number,
    this.message,
    this.revolved,
    this.refDateTime,
    this.gatePassAccessId,
    this.branchId,
    this.gatePassNumber,
    this.branchName,
  });

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'],
      number: json['number'],
      message: json['message'],
      revolved: json['revolved'],
      refDateTime: json['refDateTime'] != null ? DateTime.parse(json['refDateTime']) : null,
      gatePassAccessId: json['gatePassAccessId'],
      branchId: json['branchId'],
      gatePassNumber: json['gatePassNumber'],
      branchName: json['branchName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'message': message,
      'revolved': revolved,
      'refDateTime': refDateTime?.toIso8601String(),
      'gatePassAccessId': gatePassAccessId,
      'branchId': branchId,
      'gatePassNumber': gatePassNumber,
      'branchName': branchName,
    };
  }
}
