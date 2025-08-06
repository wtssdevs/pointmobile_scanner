import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.dialogs.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/enums/basic_dialog_status.dart';
import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/core/enums/filestore_type.dart';
import 'package:xstream_gate_pass_app/core/models/basefiles/filestore/filestore.dart';
import 'package:xstream_gate_pass_app/core/models/ops/checklists/check_list_model.dart';
import 'package:xstream_gate_pass_app/core/models/ops/checklists/check_list_response_model.dart';
import 'package:xstream_gate_pass_app/core/models/shared/filter_params_model.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/checklists/check_list_service_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/filestore/filestore_repository.dart';
import 'package:xstream_gate_pass_app/ui/views/shared/localization/app_view_base_helper.dart';

class CheckListViewModel extends BaseViewModel with AppViewBaseHelper {
  CheckListViewModel(this._filterParams);
  final log = getLogger('CheckListViewModel ');
  final _navigationService = locator<NavigationService>();
  final _checkListService = locator<CheckListServiceService>();
  final _dialogService = locator<DialogService>();
  final _fileStoreRepository = locator<FileStoreRepository>();

  Map<String, TextEditingController> controllerMap = Map();

  // Photo capture state
  Map<String, List<FileStore>> _questionPhotos = {};
  Map<String, List<FileStore>> get questionPhotos => _questionPhotos;

  FilterParams _filterParams;
  FilterParams get filterParams => _filterParams;

  bool _showBackToTopButton = true;
  bool get showBackToTopButton => _showBackToTopButton;

  // scroll controller
  final ScrollController _scrollController = ScrollController();
  ScrollController get scrollController => _scrollController;

  CheckList? _checkList;
  CheckList? get checkList => _checkList;

  get questionDoneCount => _checkList?.responses?.where((r) => r.hasResponse).length ?? 0;
  void onDispose() {
    controllerMap.forEach((_, controller) => controller.dispose());
    _scrollController.dispose(); // dispose the controller
  }

  Future<void> runStartupLogic() async {
//find and load the check list for this gatepass aceess
    _questionPhotos.clear();
    _filterParams.branchId = currentUser?.userBranches.first.id;

    await getCheckListForGatePass();
    if (_checkList?.responses != null) {
        for (var question in _checkList!.responses!) {
          question.response = null;
          question.booleanResponse = null;
          question.numericResponse = null;
          question.dateResponse = null;
          question.photoPath = null;
          question.photoPaths = null;
          question.isPassing = null;
        }
      }
    // Load photos for all questions that require them
    await _loadPhotosForAllQuestions();
  }

  Future<void> getCheckListForGatePass() async {
  setBusy(true);
  _checkList = await _checkListService.getEmptyChecklistForGatePass(
    _filterParams,
  );

  if (_checkList == null) {
    setBusy(false);
    _navigationService.back(); 
    return;
  }
  setBusy(false);
}

  Future<void> submitChecklist() async {
    setBusy(true);

    if (!canSubmit) {
      await _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        data: BasicDialogStatus.warning,
        title: "Checklist Incomplete",
        description: "Please complete all required fields before submitting",
        mainButtonTitle: "OK",
      );

      return;
    }

    // Create submission model
    final responseModel = CheckListResponseModel(
      checklistId: checkList?.id,
      responses: checkList?.responses,
      //notes: "Submitted via mobile app",
    );

    _checkList = await _checkListService.submitResponses(responseModel);

    if (_checkList == null) {
      _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        data: BasicDialogStatus.warning,
        title: "Error",
        description: "Failed to submit responses.,Please try again later",
        mainButtonTitle: "OK",
      );

      _navigationService.back(result: false);
    } else {
      await _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        data: BasicDialogStatus.success,
        title: "Success",
        description: "Responses submitted successfully.",
        mainButtonTitle: "OK",
      );

      _navigationService.back(result: true);
    }
    setBusy(false);
  }

  String convertDateTimeToString(DateTime? picked) {
    if (picked != null) {
      String convertedDateTime = "${picked.year.toString()}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')} ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      return convertedDateTime;
    }
    return '';
  }

  Future<DateTime?> selectDate(BuildContext context, DateTime? currentDateTime) async {
    final now = DateTime.now();
    final firstDate = now.subtract(Duration(days: 365 * 5));
    final lastDate = now.add(Duration(days: 365 * 5));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDateTime ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDatePickerMode: DatePickerMode.day,
    );

    if (picked != null) {
      final TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentDateTime ?? now),
      );

      if (timePicked != null) {
        return DateTime(
          picked.year,
          picked.month,
          picked.day,
          timePicked.hour,
          timePicked.minute,
        );
      }
    }

    return picked;
  }

  TextEditingController getControllerOf(String name, String initValue) {
    var controller = controllerMap[name];
    if (controller == null) {
      controller = TextEditingController();
      controller.value = TextEditingValue(
        text: initValue,
        selection: TextSelection.collapsed(offset: initValue.length),
      );

      controllerMap[name] = controller;
    }
    return controller;
  }

  Future<void> scrollToTop({double? offSet}) async {
    int millisecondsAd = 500;
    if (offSet == null) {
      offSet = 0;
    } else {
      //we move htne mdmoe mdk nn l,sdlk  m
      millisecondsAd = 300;
    }

    await _scrollController.animateTo(offSet, duration: Duration(milliseconds: millisecondsAd), curve: Curves.linear);
  }

  void updateResponse(ChecklistResponse question, TextEditingController ctrnl, {dynamic value}) {
    // Update the response based on item type and provided value
    if (value != null) {
      switch (question.itemType) {
        case ChecklistItemType.text:
        case ChecklistItemType.multipleChoice:
          question.response = value.toString();
          ctrnl.text = value.toString();
          break;
        case ChecklistItemType.numeric:
          question.numericResponse = value is double ? value : double.tryParse(value.toString());
          ctrnl.text = question.numericResponse?.toString() ?? '';
          break;
        case ChecklistItemType.yesNo:
          question.booleanResponse = value is bool ? value : null;
          ctrnl.text = question.booleanResponse?.toString() ?? '';
          break;
        case ChecklistItemType.date:
          question.dateResponse = value is DateTime ? value : null;
          ctrnl.text = question.dateResponse != null ? convertDateTimeToString(question.dateResponse) : '';
          break;
        default:
          break;
      }
    } else {
      // Update from controller text
      switch (question.itemType) {
        case ChecklistItemType.text:
        case ChecklistItemType.multipleChoice:
          question.response = ctrnl.text.isNotEmpty ? ctrnl.text : null;
          break;
        case ChecklistItemType.numeric:
          question.numericResponse = double.tryParse(ctrnl.text);
          break;
        default:
          break;
      }
    }

    // Set isPassing based on business logic
    if (question.isCriticalResponse && !question.hasResponse) {
      question.isPassing = false;
    } else if (question.hasResponse) {
      question.isPassing = true;
    }

    rebuildUi();
  }

  bool get canSubmit {
    if (_checkList?.responses == null) return false;

    // Check if all required responses are completed
    final requiredResponses = _checkList!.responses!.where((r) => r.isRequiredResponse);
    final completedRequired = requiredResponses.where((r) => r.hasResponse);

    return completedRequired.length == requiredResponses.length;
  }

  double get completionPercentage {
    if (_checkList?.responses == null || _checkList!.responses!.isEmpty) return 0.0;

    final totalResponses = _checkList!.responses!.length;
    final completedResponses = questionDoneCount;

    return completedResponses / totalResponses;
  }

  // Validation methods
  String? validateResponse(ChecklistResponse question) {
    if (question.isRequiredResponse && !question.hasResponse) {
      return "This field is required";
    }

    switch (question.itemType) {
      case ChecklistItemType.text:
        if (question.isRequiredResponse && (question.response?.trim().isEmpty ?? true)) {
          return "Please enter a response";
        }
        break;
      case ChecklistItemType.numeric:
        if (question.isRequiredResponse && question.numericResponse == null) {
          return "Please enter a valid number";
        }
        break;
      case ChecklistItemType.yesNo:
        if (question.isRequiredResponse && question.booleanResponse == null) {
          return "Please select Yes or No";
        }
        break;
      case ChecklistItemType.date:
        if (question.isRequiredResponse && question.dateResponse == null) {
          return "Please select a date";
        }
        break;
      case ChecklistItemType.multipleChoice:
        if (question.isRequiredResponse && (question.response?.isEmpty ?? true)) {
          return "Please select an option";
        }
        break;
      default:
        break;
    }

    return null;
  }

  Map<String, String> get validationErrors {
    Map<String, String> errors = {};

    if (_checkList?.responses != null) {
      for (var response in _checkList!.responses!) {
        final error = validateResponse(response);
        if (error != null) {
          errors[response.id ?? ''] = error;
        }
      }
    }

    return errors;
  }


// Photo capture methods
bool get hasValidationErrors => validationErrors.isNotEmpty;

// Photo capture methods
Future<void> capturePhotoForQuestion(ChecklistResponse question) async {
  if (question.checklistItemId == null) return;

  // Check camera permission
  var cameraStatus = await Permission.camera.status;
  if (!cameraStatus.isGranted) {
    await Permission.camera.request();
  }

  // DEBUG: Check what gate pass ID we're using
  log.d("DEBUG CAPTURE: _filterParams.gatePassAccessId: ${_filterParams.gatePassAccessId}");
  log.d("DEBUG CAPTURE: question.checklistItemId: ${question.checklistItemId}");

  // Create consistent reference ID for photo storage
  final photoRefId = '${_filterParams.gatePassAccessId}_${question.checklistItemId}';
  
 log.d("DEBUG CAPTURE: Using photoRefId for capture: $photoRefId");

  // Navigate to camera capture view
  var cameraResponse = await _navigationService.navigateTo(
    Routes.cameraCaptureView,
    arguments: CameraCaptureViewArguments(
      refId: photoRefId,  // Use combined ID
      referanceId: 0,
      fileStoreType: FileStoreType.checklistQuestionImage,
    ),
  );

  log.d("DEBUG CAPTURE: Camera capture completed, refreshing photos...");

  // Refresh photos after capture
  await _refreshPhotosForQuestion(question);
  
  // Update the response after photo capture
  final photos = getPhotosForQuestion(question);
  log.d("DEBUG CAPTURE: Photos found after capture: ${photos.length}");
  
  if (photos.isNotEmpty) {
    question.photoPath = photos.first.path;
    // Create PhotoPath objects using the class from the model
    question.photoPaths = photos.map((photo) => PhotoPath(
      name: photo.fileName ?? '',
      value: photo.path ?? ''
    )).toList();
    question.isPassing = question.hasResponse;
    
    log.d("DEBUG CAPTURE: Updated question photoPath: '${question.photoPath}'");
    log.d("DEBUG CAPTURE: Updated question photoPaths: ${question.photoPaths?.length}");
    log.d("DEBUG CAPTURE: Question isPassing: ${question.isPassing}");
    log.d("DEBUG CAPTURE: Question hasResponse after update: ${question.hasResponse}");
    
    rebuildUi();
  } else {
    log.d("DEBUG CAPTURE: No photos found after capture!");
  }
}

Future<void> _refreshPhotosForQuestion(ChecklistResponse question) async {
  if (question.checklistItemId == null) return;

  // DEBUG: Check the exact IDs being used for retrieval
  log.d("DEBUG REFRESH: _filterParams.gatePassAccessId: ${_filterParams.gatePassAccessId}");
  log.d("DEBUG REFRESH: question.checklistItemId: ${question.checklistItemId}");

  // Use the same combined reference ID for retrieval
  final photoRefId = '${_filterParams.gatePassAccessId}_${question.checklistItemId}';
  
  log.d("DEBUG REFRESH: Using photoRefId for retrieval: $photoRefId");

  final photos = await _fileStoreRepository.getAll(
    photoRefId,  // Use combined ID for retrieval too
    FileStoreType.checklistQuestionImage,
    100,
  );

  log.d("DEBUG REFRESH: _refreshPhotosForQuestion found ${photos.length} photos");
  
  if (photos.isNotEmpty) {
    for (var i = 0; i < photos.length; i++) {
      log.d("DEBUG REFRESH: Photo $i - fileName: ${photos[i].fileName}, path: ${photos[i].path}");
    }
  }

  _questionPhotos[question.checklistItemId!] = photos;
  notifyListeners();
}

List<FileStore> getPhotosForQuestion(ChecklistResponse question) {
  if (question.checklistItemId == null) return [];
  final photos = _questionPhotos[question.checklistItemId!] ?? [];
  log.d("DEBUG GET: getPhotosForQuestion returning ${photos.length} photos for question ${question.checklistItemId}");
  return photos;
}

bool hasPhotosForQuestion(ChecklistResponse question) {
  final hasPhotos = getPhotosForQuestion(question).isNotEmpty;
  log.d("DEBUG HAS: hasPhotosForQuestion: $hasPhotos for question ${question.checklistItemId}");
  return hasPhotos;
}

Future<void> deletePhotoForQuestion(ChecklistResponse question, FileStore photo) async {
  if (question.checklistItemId == null) return;

  log.d("DEBUG DELETE: Deleting photo ${photo.fileName} for question ${question.checklistItemId}");

  await _fileStoreRepository.delete(photo);
  await _refreshPhotosForQuestion(question);
  
  // Update the question response after deletion
  final photos = getPhotosForQuestion(question);
  if (photos.isEmpty) {
    question.photoPath = null;
    question.photoPaths = null;
    question.isPassing = question.hasResponse;
    log.d("DEBUG DELETE: No photos remaining, cleared photo fields");
    rebuildUi();
  }
}

Future<void> viewAllPhotosForQuestion(ChecklistResponse question) async {
  if (question.checklistItemId == null) return;

  // Use consistent reference ID for viewing
  final photoRefId = '${_filterParams.gatePassAccessId}_${question.checklistItemId}';

  log.d("DEBUG VIEW: Opening photo viewer with photoRefId: $photoRefId");

  await _navigationService.navigateTo(
    Routes.imagesViewerListView,
    arguments: ImagesViewerListViewArguments(
      gatePassId: photoRefId,  // Use combined ID
    ),
  );
}

Future<void> _loadPhotosForAllQuestions() async {
  if (_checkList?.responses == null) return;

  log.d("DEBUG LOAD: Loading photos for all questions...");
  log.d("DEBUG LOAD: _filterParams.gatePassAccessId: ${_filterParams.gatePassAccessId}");

  for (var question in _checkList!.responses!) {
    if (question.requiresPhoto == true) {
      log.d("DEBUG LOAD: Loading photos for question ${question.checklistItemId}");
      await _refreshPhotosForQuestion(question);
      
      // Update question response state if photos exist
      final photos = getPhotosForQuestion(question);
      if (photos.isNotEmpty && question.photoPath == null) {
        question.photoPath = photos.first.path;
        question.photoPaths = photos.map((photo) => PhotoPath(
          name: photo.fileName ?? '',
          value: photo.path ?? ''
        )).toList();
        question.isPassing = question.hasResponse;
        
        log.d("DEBUG LOAD: Updated existing photo data for question ${question.checklistItemId}");
        log.d("DEBUG LOAD: photoPath: ${question.photoPath}");
        log.d("DEBUG LOAD: photoPaths count: ${question.photoPaths?.length}");
        log.d("DEBUG LOAD: isPassing: ${question.isPassing}");
      }
    }
  }
  
  rebuildUi();
}
}