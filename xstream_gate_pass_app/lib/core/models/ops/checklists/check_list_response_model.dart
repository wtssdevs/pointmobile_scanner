import 'package:xstream_gate_pass_app/core/models/ops/checklists/check_list_model.dart';

/// Represents a checklist response submission model
class CheckListResponseModel {
  String? checklistId;
  List<ChecklistResponse>? responses;
  String? notes;

  CheckListResponseModel({
    this.checklistId,
    this.responses,
    this.notes,
  });

  /// Getter to check if response model has any responses
  bool get hasResponses => responses?.isNotEmpty == true;

  /// Getter to get total number of responses
  int get totalResponses => responses?.length ?? 0;

  /// Getter to get number of passing responses
  int get passingResponses => responses?.where((response) => response.isPassing == true).length ?? 0;

  /// Getter to get number of failing responses
  int get failingResponses => responses?.where((response) => response.isPassing == false).length ?? 0;

  /// Getter to check if all responses are passing
  bool get allResponsesPassing => totalResponses > 0 && failingResponses == 0;

  /// Getter to check if any responses are failing
  bool get hasFailingResponses => failingResponses > 0;

  /// Getter to check if response model has notes
  bool get hasNotes => notes?.isNotEmpty == true;

  factory CheckListResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckListResponseModel(
      checklistId: json['checklistId'],
      responses: json['responses'] != null ? (json['responses'] as List).map((item) => ChecklistResponse.fromJson(item)).toList() : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};
    data['checklistId'] = checklistId;
    data['responses'] = responses?.map((item) => item.toJson()).toList();
    data['notes'] = notes;
    return data;
  }
}
