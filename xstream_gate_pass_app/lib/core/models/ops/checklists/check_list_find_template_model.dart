/// Represents a checklist template find response model
class CheckListFindTemplateModel {
  String? templateId;
  bool hasTemplate;
  bool isCompleted;
  String? checklistId;
  CheckListFindTemplateModel({
    this.templateId,
    this.hasTemplate = false,
    this.isCompleted = false,
    this.checklistId,
  });

  /// Getter to check if template ID is available
  bool get hasTemplateId => templateId?.isNotEmpty == true;

  /// Getter to check if the find operation was valid
  bool get isValid => hasTemplate == true && hasTemplateId;

  factory CheckListFindTemplateModel.fromJson(Map<String, dynamic> json) {
    return CheckListFindTemplateModel(
      templateId: json['templateId'],
      hasTemplate: json['hasTemplate'] ?? false,
      isCompleted: json['isCompleted'] ?? false,
      checklistId: json['checklistId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'templateId': templateId,
      'hasTemplate': hasTemplate,
      'isCompleted': isCompleted,
      'checklistId': checklistId,
    };
  }
}
