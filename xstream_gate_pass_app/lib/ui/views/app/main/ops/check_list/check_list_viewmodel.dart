import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.dialogs.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/enums/basic_dialog_status.dart';
import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/core/models/ops/checklists/check_list_model.dart';
import 'package:xstream_gate_pass_app/core/models/ops/checklists/check_list_response_modal.dart';
import 'package:xstream_gate_pass_app/core/models/shared/filter_params_model.dart';
import 'package:xstream_gate_pass_app/core/services/services/ops/checklists/check_list_service_service.dart';
import 'package:xstream_gate_pass_app/ui/views/shared/localization/app_view_base_helper.dart';

class CheckListViewModel extends BaseViewModel with AppViewBaseHelper {
  CheckListViewModel(this._filterParams);
  final log = getLogger('CheckListViewModel ');
  final _navigationService = locator<NavigationService>();
  final _checkListService = locator<CheckListServiceService>();
  final _dialogService = locator<DialogService>();

  Map<String, TextEditingController> controllerMap = Map();

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
    _filterParams.branchId = currentUser?.userBranches.first.id;

    await getCheckListForGatePass();
  }

  Future<void> getCheckListForGatePass() async {
    setBusy(true);
    _checkList = await _checkListService.getEmptyChecklistForGatePass(
      _filterParams,
    );

    if (_checkList == null) {
      _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        data: BasicDialogStatus.warning,
        title: "Error",
        description: "Failed to load checklist.,Please try again later",
        mainButtonTitle: "OK",
      );
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
    } else {
      var r = await _dialogService.showCustomDialog(
        variant: DialogType.infoAlert,
        data: BasicDialogStatus.success,
        title: "Success",
        description: "Responses submitted successfully.",
        mainButtonTitle: "OK",
      );

      if (r?.confirmed == true) {
        // Navigate back or to another view
        _navigationService.back();
      }
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

  bool get hasValidationErrors => validationErrors.isNotEmpty;
}
