import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';

//sample json of new structure

// {
//   "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
//   "completionTime": "2025-07-02T09:06:34.797Z",
//   "status": 0,
//   "notes": "string",
//   "overrideReason": "string",
//   "gatePassAccessId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
//   "gatePassAccessNumber": "string",
//   "templateId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
//   "templateTitle": "string",
//   "checklistType": 1,
//   "officerId": 0,
//   "officerName": "string",
//   "overrideApproverId": 0,
//   "overrideApproverName": "string",
//   "isRecheck": true,
//   "previousChecklistId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
//   "concurrencyStamp": "string",
//   "responses": [
//     {
//       "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
//       "response": "string",
//       "booleanResponse": true,
//       "numericResponse": 0,
//       "dateResponse": "2025-07-02T09:06:34.797Z",
//       "photoPath": "string",
//       "photoPaths": [
//         {
//           "name": "string",
//           "value": "string"
//         }
//       ],
//       "comments": "string",
//       "isPassing": true,
//       "checklistId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
//       "checklistItemId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
//       "itemType": 1,
//       "responseAction": 0,
//       "question": "string",
//       "instructions": "string",
//       "groupName": "string",
//       "isRequired": true,
//       "isActive": true,
//       "displayOrder": 0,
//       "isCritical": true,
//       "questionOptions": [
//         {
//           "optionValue": "string"
//         }
//       ],
//       "expectedActionResponse": "string",
//       "requiresPhoto": true,
//       "checklistTemplateId": "3fa85f64-5717-4562-b3fc-2c963f66afa6"
//     }
//   ],
//   "creationTime": "2025-07-02T09:06:34.797Z",
//   "createdByUser": "string",
//   "lastModifiedByUser": "string",
//   "lastModificationTime": "2025-07-02T09:06:34.797Z"
// }

/// Represents a photo path with name and value
class PhotoPath {
  String? name;
  String? value;

  PhotoPath({
    this.name,
    this.value,
  });

  factory PhotoPath.fromJson(Map<String, dynamic> json) {
    return PhotoPath(
      name: json['name'],
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
    };
  }
}

/// Represents a question option for checklist items
class QuestionOption {
  String? optionValue;

  QuestionOption({
    this.optionValue,
  });

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      optionValue: json['optionValue'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'optionValue': optionValue,
    };
  }
}

// public enum ChecklistItemType
// {
//     YesNo = 1,
//     Text = 2,
//     Numeric = 3,
//     MultipleChoice = 4,
//     Date = 5,
//     Photo = 6,
//     Signature=7
// }

/// Represents a checklist response item
class ChecklistResponse {
  String? id;
  String? response;
  bool? booleanResponse;
  double? numericResponse;
  DateTime? dateResponse;
  String? photoPath;
  List<PhotoPath>? photoPaths;
  String? comments;
  bool? isPassing;
  String? checklistId;
  String? checklistItemId;
  //enum
  ChecklistItemType? itemType;
  int? responseAction;
  String? question;
  String? instructions;
  String? groupName;
  bool? isRequired;
  bool? isActive;
  int? displayOrder;
  bool? isCritical;
  List<QuestionOption>? questionOptions;
  String? expectedActionResponse;
  bool? requiresPhoto;
  String? checklistTemplateId;
  bool? hasTemplate;

  ChecklistResponse({
    this.id,
    this.response,
    this.booleanResponse,
    this.numericResponse,
    this.dateResponse,
    this.photoPath,
    this.photoPaths,
    this.comments,
    this.isPassing,
    this.checklistId,
    this.checklistItemId,
    this.itemType,
    this.responseAction,
    this.question,
    this.instructions,
    this.groupName,
    this.isRequired,
    this.isActive,
    this.displayOrder,
    this.isCritical,
    this.questionOptions,
    this.expectedActionResponse,
    this.requiresPhoto,
    this.checklistTemplateId,
    this.hasTemplate,
  });

//has a reponse been given for this question based on the type of question
  /// Getter to check if response has been given for this question
  /// Getter to check if response has been provided
  bool get hasResponse {
    switch (itemType) {
      case ChecklistItemType.yesNo:
        bool hasYesNoResponse = booleanResponse != null;
        
        // If this question requires a photo, check for photo too
        if (requiresPhoto == true) {
          bool hasRequiredPhoto = (photoPath?.isNotEmpty ?? false) || 
                                (photoPaths?.isNotEmpty ?? false);
          return hasYesNoResponse && hasRequiredPhoto;  // Both required
        }
        
        return hasYesNoResponse;  // Only Yes/No required
        
      case ChecklistItemType.text:
      case ChecklistItemType.multipleChoice:
        bool hasTextResponse = response?.isNotEmpty ?? false;
        
        if (requiresPhoto == true) {
          bool hasRequiredPhoto = (photoPath?.isNotEmpty ?? false) || 
                                (photoPaths?.isNotEmpty ?? false);
          return hasTextResponse && hasRequiredPhoto;
        }
        
        return hasTextResponse;
        
      case ChecklistItemType.photo:
        return (photoPath?.isNotEmpty ?? false) || 
              (photoPaths?.isNotEmpty ?? false);
              
      case ChecklistItemType.numeric:
        bool hasNumericResponse = numericResponse != null;
        
        if (requiresPhoto == true) {
          bool hasRequiredPhoto = (photoPath?.isNotEmpty ?? false) || 
                                (photoPaths?.isNotEmpty ?? false);
          return hasNumericResponse && hasRequiredPhoto;
        }
        
        return hasNumericResponse;
        
      case ChecklistItemType.date:
        bool hasDateResponse = dateResponse != null;
        
        if (requiresPhoto == true) {
          bool hasRequiredPhoto = (photoPath?.isNotEmpty ?? false) || 
                                (photoPaths?.isNotEmpty ?? false);
          return hasDateResponse && hasRequiredPhoto;
        }
        
        return hasDateResponse;
        
      default:
        return false;
    }
  }
  /// Getter to check if response has question options
  bool get hasQuestionOptions => questionOptions?.isNotEmpty == true;

  /// Getter to check if response is required
  bool get isRequiredResponse => isRequired == true;

  /// Getter to check if response is critical
  bool get isCriticalResponse => isCritical == true;

  /// Getter to check if response requires photo
  bool get requiresPhotoResponse => requiresPhoto == true;

  /// Getter to check if response has instructions
  bool get hasInstructions => instructions?.isNotEmpty == true;

  /// Getter to check if response has group name
  bool get hasGroupName => groupName?.isNotEmpty == true;

  /// Getter to check if item type is Yes/No
  bool get isYesNoType => itemType == ChecklistItemType.yesNo;

  /// Getter to check if item type is Text
  bool get isTextType => itemType == ChecklistItemType.text;

  /// Getter to check if item type is Numeric
  bool get isNumericType => itemType == ChecklistItemType.numeric;

  /// Getter to check if item type is Multiple Choice
  bool get isMultipleChoiceType => itemType == ChecklistItemType.multipleChoice;

  /// Getter to check if item type is Date
  bool get isDateType => itemType == ChecklistItemType.date;

  /// Getter to check if item type is Photo
  bool get isPhotoType => itemType == ChecklistItemType.photo;
 

  factory ChecklistResponse.fromJson(Map<String, dynamic> json) {
    return ChecklistResponse(
      id: json['id'],
      response: json['response'],
      booleanResponse: json['booleanResponse'],
      numericResponse: asT<double?>(json['numericResponse']),
      dateResponse: json['dateResponse'] != null ? DateTime.parse(json['dateResponse']) : null,
      photoPath: json['photoPath'],
      photoPaths: json['photoPaths'] != null ? (json['photoPaths'] as List).map((item) => PhotoPath.fromJson(item)).toList() : null,
      comments: json['comments'],
      isPassing: json['isPassing'],
      checklistId: json['checklistId'],
      checklistItemId: json['checklistItemId'],
      itemType: json['itemType'] != null ? ChecklistItemType.values.firstWhere((e) => e.value == asT<int>(json['itemType']), orElse: () => ChecklistItemType.none) : null,
      responseAction: asT<int>(json['responseAction']),
      question: json['question'],
      instructions: json['instructions'],
      groupName: json['groupName'],
      isRequired: json['isRequired'],
      isActive: json['isActive'],
      displayOrder: asT<int>(json['displayOrder']),
      isCritical: json['isCritical'],
      questionOptions: json['questionOptions'] != null ? (json['questionOptions'] as List).map((item) => QuestionOption.fromJson(item)).toList() : null,
      expectedActionResponse: json['expectedActionResponse'],
      requiresPhoto: json['requiresPhoto'],
      checklistTemplateId: json['checklistTemplateId'],
      hasTemplate: json['hasTemplate'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'response': response,
      'booleanResponse': booleanResponse,
      'numericResponse': numericResponse,
      'dateResponse': dateResponse?.toIso8601String(),
      'photoPath': photoPath,
      'photoPaths': photoPaths?.map((item) => item.toJson()).toList(),
      'comments': comments,
      'isPassing': isPassing,
      'checklistId': checklistId,
      'checklistItemId': checklistItemId,
      'itemType': itemType?.value,
      'responseAction': responseAction,
      'question': question,
      'instructions': instructions,
      'groupName': groupName,
      'isRequired': isRequired,
      'isActive': isActive,
      'displayOrder': displayOrder,
      'isCritical': isCritical,
      'questionOptions': questionOptions?.map((item) => item.toJson()).toList(),
      'expectedActionResponse': expectedActionResponse,
      'requiresPhoto': requiresPhoto,
      'checklistTemplateId': checklistTemplateId,
      'hasTemplate': hasTemplate
    };
  }
}

/// Represents a checklist model for gate pass application
class CheckList {
  String? id;
  DateTime? completionTime;
  int? status;
  String? notes;
  String? overrideReason;
  String? gatePassAccessId;
  String? gatePassAccessNumber;
  String? templateId;
  String? templateTitle;
  int? checklistType;
  int? officerId;
  String? officerName;
  int? overrideApproverId;
  String? overrideApproverName;
  bool? isRecheck;
  String? previousChecklistId;
  String? concurrencyStamp;
  List<ChecklistResponse>? responses;
  DateTime? creationTime;
  String? createdByUser;
  String? lastModifiedByUser;
  DateTime? lastModificationTime;
  bool? hasTempalte;

  CheckList({
    this.id,
    this.completionTime,
    this.status,
    this.notes,
    this.overrideReason,
    this.gatePassAccessId,
    this.gatePassAccessNumber,
    this.templateId,
    this.templateTitle,
    this.checklistType,
    this.officerId,
    this.officerName,
    this.overrideApproverId,
    this.overrideApproverName,
    this.isRecheck,
    this.previousChecklistId,
    this.concurrencyStamp,
    this.responses,
    this.creationTime,
    this.createdByUser,
    this.lastModifiedByUser,
    this.lastModificationTime,
  });

  /// Getter to check if checklist has any responses
  bool get hasResponses => responses?.isNotEmpty == true;

  /// Getter to check if checklist is completed
  bool get isCompleted => completionTime != null;

  /// Getter to check if checklist has override
  bool get hasOverride => overrideReason?.isNotEmpty == true && overrideApproverId != null;

  /// Getter to get total number of responses
  int get totalResponses => responses?.length ?? 0;

  /// Getter to get number of passing responses
  int get passingResponses => responses?.where((response) => response.isPassing == true).length ?? 0;

  /// Getter to get number of failing responses
  int get failingResponses => responses?.where((response) => response.isPassing == false).length ?? 0;

  /// Getter to get number of critical responses
  int get criticalResponses => responses?.where((response) => response.isCriticalResponse).length ?? 0;

  /// Getter to get number of required responses
  int get requiredResponses => responses?.where((response) => response.isRequiredResponse).length ?? 0;

  /// Getter to get number of responses requiring photos
  int get responsesRequiringPhotos => responses?.where((response) => response.requiresPhotoResponse).length ?? 0;

  /// Getter to check if all critical responses are passing
  bool get allCriticalResponsesPassing {
    final critical = responses?.where((response) => response.isCriticalResponse).toList() ?? [];
    return critical.isNotEmpty && critical.every((response) => response.isPassing == true);
  }

  /// Getter to check if all required responses are completed
  bool get allRequiredResponsesCompleted {
    final required = responses?.where((response) => response.isRequiredResponse).toList() ?? [];
    return required.every((response) => response.response?.isNotEmpty == true || response.booleanResponse != null || response.numericResponse != null || response.dateResponse != null);
  }

  /// Getter to get responses by item type
  List<ChecklistResponse> getResponsesByItemType(ChecklistItemType itemType) {
    return responses?.where((response) => response.itemType == itemType).toList() ?? [];
  }

  /// Getter to get number of Yes/No responses
  int get yesNoResponses => responses?.where((response) => response.isYesNoType).length ?? 0;

  /// Getter to get number of Text responses
  int get textResponses => responses?.where((response) => response.isTextType).length ?? 0;

  /// Getter to get number of Numeric responses
  int get numericResponses => responses?.where((response) => response.isNumericType).length ?? 0;

  /// Getter to get number of Multiple Choice responses
  int get multipleChoiceResponses => responses?.where((response) => response.isMultipleChoiceType).length ?? 0;

  /// Getter to get number of Date responses
  int get dateResponses => responses?.where((response) => response.isDateType).length ?? 0;

  /// Getter to get number of Photo responses
  int get photoResponses => responses?.where((response) => response.isPhotoType).length ?? 0;

  factory CheckList.fromJson(Map<String, dynamic> json) {
    return CheckList(
      id: json['id'],
      completionTime: json['completionTime'] != null ? DateTime.parse(json['completionTime']) : null,
      status: asT<int>(json['status']),
      notes: json['notes'],
      overrideReason: json['overrideReason'],
      gatePassAccessId: json['gatePassAccessId'],
      gatePassAccessNumber: json['gatePassAccessNumber'],
      templateId: json['templateId'],
      templateTitle: json['templateTitle'],
      checklistType: asT<int>(json['checklistType']),
      officerId: asT<int>(json['officerId']),
      officerName: json['officerName'],
      overrideApproverId: asT<int>(json['overrideApproverId']),
      overrideApproverName: json['overrideApproverName'],
      isRecheck: json['isRecheck'],
      previousChecklistId: json['previousChecklistId'],
      concurrencyStamp: json['concurrencyStamp'],
      responses: json['responses'] != null ? (json['responses'] as List).map((item) => ChecklistResponse.fromJson(item)).toList() : null,
      creationTime: json['creationTime'] != null ? DateTime.parse(json['creationTime']) : null,
      createdByUser: json['createdByUser'],
      lastModifiedByUser: json['lastModifiedByUser'],
      lastModificationTime: json['lastModificationTime'] != null ? DateTime.parse(json['lastModificationTime']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'completionTime': completionTime?.toIso8601String(),
      'status': status,
      'notes': notes,
      'overrideReason': overrideReason,
      'gatePassAccessId': gatePassAccessId,
      'gatePassAccessNumber': gatePassAccessNumber,
      'templateId': templateId,
      'templateTitle': templateTitle,
      'checklistType': checklistType,
      'officerId': officerId,
      'officerName': officerName,
      'overrideApproverId': overrideApproverId,
      'overrideApproverName': overrideApproverName,
      'isRecheck': isRecheck,
      'previousChecklistId': previousChecklistId,
      'concurrencyStamp': concurrencyStamp,
      'responses': responses?.map((item) => item.toJson()).toList(),
      'creationTime': creationTime?.toIso8601String(),
      'createdByUser': createdByUser,
      'lastModifiedByUser': lastModifiedByUser,
      'lastModificationTime': lastModificationTime?.toIso8601String(),
    };
  }
}
