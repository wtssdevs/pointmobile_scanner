import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/core/models/ops/checklists/check_list_model.dart';
import 'package:xstream_gate_pass_app/core/models/shared/filter_params_model.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_text.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/text_fields/input_field.dart';

import 'check_list_viewmodel.dart';

class CheckListView extends StackedView<CheckListViewModel> {
  final FilterParams filterParams;
  const CheckListView({Key? key, required this.filterParams}) : super(key: key);

  Widget buildcard(ChecklistResponse question, int index, CheckListViewModel model, BuildContext context) {
    var ctrnInitValue = _getInitialValue(question, model);
    final ctrnl = model.getControllerOf(question.id!, ctrnInitValue);
    final validationError = model.validateResponse(question);

    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionHeader(question, index, validationError),
          _buildQuestionInputSection(question, ctrnl, model, context, validationError),
          if (validationError != null) _buildValidationError(validationError),
          verticalSpaceSmall,
        ],
      ),
    );
  }

  String _getInitialValue(ChecklistResponse question, CheckListViewModel model) {
    switch (question.itemType) {
      case ChecklistItemType.text:
        return question.response ?? "";
      case ChecklistItemType.numeric:
        return question.numericResponse?.toString() ?? "";
      case ChecklistItemType.yesNo:
        return question.booleanResponse?.toString() ?? "";
      case ChecklistItemType.date:
        return question.dateResponse != null ? model.convertDateTimeToString(question.dateResponse!) : "";
      case ChecklistItemType.multipleChoice:
        return question.response ?? "";
      default:
        return "";
    }
  }

  Widget _buildQuestionHeader(ChecklistResponse question, int index, String? validationError) {
    return Container(
      decoration: BoxDecoration(
        color: _getHeaderColor(question, validationError),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4.0),
          topRight: Radius.circular(4.0),
        ),
      ),
      child: ListTile(
        title: AppText.bodyListheading(
          "(${index + 1}). ${question.question ?? ""}",
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (question.groupName?.isNotEmpty == true)
              AppText.body(
                question.groupName!,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            if (question.instructions?.isNotEmpty == true)
              AppText.body(
                question.instructions!,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            _buildRequiredIndicator(question),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (question.isCriticalResponse) const Icon(Icons.warning, color: Colors.amber, size: 20),
            _buildStatusIcon(question, validationError),
          ],
        ),
      ),
    );
  }

  Color _getHeaderColor(ChecklistResponse question, String? validationError) {
    if (validationError != null) return Colors.blue.shade600.withOpacity(0.8);
    if (question.hasResponse) return Colors.green.shade600;
    if (question.isRequiredResponse) return Colors.orange.shade600;
    return Colors.blue.shade600;
  }

  Widget _buildStatusIcon(ChecklistResponse question, String? validationError) {
    if (validationError != null) {
      return const Icon(Icons.error, size: 28, color: Colors.white);
    }
    if (question.hasResponse) {
      return const Icon(Icons.check_circle, size: 28, color: Colors.white);
    }
    return const Icon(Icons.radio_button_unchecked, size: 28, color: Colors.white70);
  }

  Widget _buildPhotoRequiredIndicator(ChecklistResponse question, CheckListViewModel model, BuildContext context) {
    if (question.requiresPhoto != true) return const SizedBox.shrink();

    final photos = model.getPhotosForQuestion(question);
    final hasPhotos = photos.isNotEmpty;
    final width = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          verticalSpaceSmall,
          Container(
            width: width,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasPhotos ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasPhotos ? Colors.green : Colors.orange,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                // Header row with title, button, and icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Photo Required for Question',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // View All Images button
                    if (hasPhotos)
                      InkWell(
                        onTap: () => model.viewAllPhotosForQuestion(question),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.photo_library,
                                color: Colors.blue,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'View All',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.camera_alt,
                      color: hasPhotos ? Colors.green : Colors.orange,
                      size: 28,
                    ),
                    Icon(
                      hasPhotos ? Icons.check_circle : Icons.camera_enhance,
                      color: hasPhotos ? Colors.green : Colors.orange,
                      size: 32,
                    ),
                  ],
                ),
                verticalSpaceSmall,

                // Photo count indicator
                if (photos.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${photos.length} photo${photos.length > 1 ? 's' : ''} captured',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                verticalSpaceSmall,

                // Content area with gesture detector for main action
                GestureDetector(
                  onTap: () => model.capturePhotoForQuestion(question),
                  child: Column(
                    children: [
                      if (hasPhotos) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check, color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Photo${photos.length > 1 ? 's' : ''} Captured Successfully',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Show first photo preview
                        if (photos.isNotEmpty && photos.first.path.isNotEmpty) ...[
                          verticalSpaceSmall,
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: 200,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: FileImage(File(photos.first.path)),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        margin: const EdgeInsets.all(8),
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Icon(
                                          photos.first.upLoaded ? Icons.check_circle : Icons.pending,
                                          color: photos.first.upLoaded ? Colors.green : Colors.orange,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          verticalSpaceSmall,
                          Text(
                            'File: ${photos.first.fileName.split('/').last}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Photo Required for This Question',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        verticalSpaceSmall,
                        // Placeholder photo capture area
                        Container(
                          height: 100,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300, width: 1),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.grey.shade50,
                                Colors.grey.shade100,
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Photo placeholder content
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    // Camera icon placeholder
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade400),
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.grey.shade500,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Instructions
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Take Photo',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Tap to capture a photo for this question',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Tap to capture overlay
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.orange.withOpacity(0.05),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.touch_app,
                                      color: Colors.orange,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredIndicator(ChecklistResponse question) {
    if (question.isRequiredResponse) {
      return Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AppText.body(
          "Required",
          fontSize: 10,
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildQuestionInputSection(
    ChecklistResponse question,
    TextEditingController ctrnl,
    CheckListViewModel model,
    BuildContext context,
    String? validationError,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildQuestionTypeIndicator(question),
          verticalSpaceSmall,
          _buildInputWidget(question, ctrnl, model, context),
          _buildPhotoRequiredIndicator(question, model, context),
        ],
      ),
    );
  }

  Widget _buildQuestionTypeIndicator(ChecklistResponse question) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getTypeIcon(question.itemType),
          horizontalSpaceSmall,
          AppText.body(
            _getTypeLabel(question.itemType),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Icon _getTypeIcon(ChecklistItemType? itemType) {
    switch (itemType) {
      case ChecklistItemType.text:
        return const Icon(Icons.text_fields, size: 16, color: Colors.blue);
      case ChecklistItemType.numeric:
        return const Icon(Icons.numbers, size: 16, color: Colors.green);
      case ChecklistItemType.yesNo:
        return const Icon(Icons.toggle_on, size: 16, color: Colors.orange);
      case ChecklistItemType.date:
        return const Icon(Icons.calendar_today, size: 16, color: Colors.purple);
      case ChecklistItemType.multipleChoice:
        return const Icon(Icons.list, size: 16, color: Colors.teal);
      default:
        return const Icon(Icons.help, size: 16, color: Colors.grey);
    }
  }

  String _getTypeLabel(ChecklistItemType? itemType) {
    switch (itemType) {
      case ChecklistItemType.text:
        return "Text Input";
      case ChecklistItemType.numeric:
        return "Number";
      case ChecklistItemType.yesNo:
        return "Yes/No";
      case ChecklistItemType.date:
        return "Date & Time";
      case ChecklistItemType.multipleChoice:
        return "Multiple Choice";
      default:
        return "Unknown";
    }
  }

  Widget _buildInputWidget(
    ChecklistResponse question,
    TextEditingController ctrnl,
    CheckListViewModel model,
    BuildContext context,
  ) {
    switch (question.itemType) {
      case ChecklistItemType.text:
        return _buildTextInput(question, ctrnl, model, context);
      case ChecklistItemType.numeric:
        return _buildNumericInput(question, ctrnl, model, context);
      case ChecklistItemType.yesNo:
        return _buildYesNoInput(question, ctrnl, model, context);
      case ChecklistItemType.date:
        return _buildDateInput(question, ctrnl, model, context);
      case ChecklistItemType.multipleChoice:
        return _buildMultipleChoiceInput(question, ctrnl, model, context);
      default:
        return AppText.body("Unsupported question type", color: Colors.red);
    }
  }

  Widget _buildValidationError(String error) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 16),
          horizontalSpaceSmall,
          Expanded(
            child: AppText.body(
              error,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInput(
    ChecklistResponse question,
    TextEditingController ctrnl,
    CheckListViewModel model,
    BuildContext context,
  ) {
    return Column(
      children: [
        // Quick select options for text input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
            color: Colors.blue.shade50,
          ),
          child: DropdownButton<String>(
            isDense: true,
            hint: const Text("Quick Select"),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
            underline: const SizedBox(),
            isExpanded: true,
            items: <String>['OK', 'Not OK', 'N/A', 'Pending'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (selectedValue) {
              if (selectedValue != null) {
                model.updateResponse(question, ctrnl, value: selectedValue);
              }
            },
          ),
        ),
        verticalSpaceSmall,
        InputField(
          placeholder: "Enter your response here",
          controller: ctrnl,
          textInputAction: TextInputAction.done,
          textInputType: TextInputType.text,
          suffixIcon: ctrnl.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    ctrnl.clear();
                    model.updateResponse(question, ctrnl, value: "");
                  },
                  icon: const Icon(Icons.clear, color: Colors.grey),
                )
              : null,
          onChanged: (value) {
            model.updateResponse(question, ctrnl);
          },
          enterPressed: () {
            FocusScope.of(context).unfocus();
          },
        ),
      ],
    );
  }

  Widget _buildNumericInput(
    ChecklistResponse question,
    TextEditingController ctrnl,
    CheckListViewModel model,
    BuildContext context,
  ) {
    return InputField(
      placeholder: "Enter a number",
      controller: ctrnl,
      textInputAction: TextInputAction.done,
      textInputType: const TextInputType.numberWithOptions(decimal: true),
      formatter: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      suffixIcon: ctrnl.text.isNotEmpty
          ? IconButton(
              onPressed: () {
                ctrnl.clear();
                model.updateResponse(question, ctrnl, value: null);
              },
              icon: const Icon(Icons.clear, color: Colors.grey),
            )
          : null,
      onChanged: (value) {
        model.updateResponse(question, ctrnl);
      },
      enterPressed: () {
        FocusScope.of(context).unfocus();
      },
    );
  }

  Widget _buildYesNoInput(
    ChecklistResponse question,
    TextEditingController ctrnl,
    CheckListViewModel model,
    BuildContext context,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: question.booleanResponse == false ? Colors.red.shade50 : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(11),
                  bottomLeft: Radius.circular(11),
                ),
              ),
              child: RadioListTile<bool>(
                value: false,
                groupValue: question.booleanResponse,
                title: AppText.body("No", fontSize: 16),
                activeColor: Colors.red,
                onChanged: (value) {
                  model.updateResponse(question, ctrnl, value: value);
                },
              ),
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: question.booleanResponse == true ? Colors.green.shade50 : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(11),
                  bottomRight: Radius.circular(11),
                ),
              ),
              child: RadioListTile<bool>(
                value: true,
                groupValue: question.booleanResponse,
                title: AppText.body("Yes", fontSize: 16),
                activeColor: Colors.green,
                onChanged: (value) {
                  model.updateResponse(question, ctrnl, value: value);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInput(
    ChecklistResponse question,
    TextEditingController ctrnl,
    CheckListViewModel model,
    BuildContext context,
  ) {
    return Column(
      children: [
        InputField(
          placeholder: "Select date and time",
          controller: ctrnl,
          textInputAction: TextInputAction.done,
          textInputType: TextInputType.none,
          suffixIcon: IconButton(
            onPressed: () async {
              final selectedDate = await model.selectDate(context, question.dateResponse);
              if (selectedDate != null) {
                model.updateResponse(question, ctrnl, value: selectedDate);
              }
            },
            icon: const Icon(Icons.calendar_today, color: Colors.blue),
          ),
          onTap: () async {
            final selectedDate = await model.selectDate(context, question.dateResponse);
            if (selectedDate != null) {
              model.updateResponse(question, ctrnl, value: selectedDate);
            }
          },
        ),
        if (question.dateResponse != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                horizontalSpaceSmall,
                AppText.body(
                  "Selected: ${model.convertDateTimeToString(question.dateResponse!)}",
                  fontSize: 12,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMultipleChoiceInput(
    ChecklistResponse question,
    TextEditingController ctrnl,
    CheckListViewModel model,
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
        color: Colors.blue.shade50,
      ),
      child: DropdownButton<String>(
        isDense: true,
        hint: const Text("Select an option"),
        value: question.response,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
        underline: const SizedBox(),
        isExpanded: true,
        items: question.questionOptions?.map((QuestionOption option) {
              return DropdownMenuItem<String>(
                value: option.optionValue,
                child: Text(option.optionValue ?? ''),
              );
            }).toList() ??
            [],
        onChanged: (selectedValue) {
          if (selectedValue != null) {
            model.updateResponse(question, ctrnl, value: selectedValue);
          }
        },
      ),
    );
  }

  @override
  Widget builder(
    BuildContext context,
    CheckListViewModel viewModel,
    Widget? child,
  ) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (viewModel.canSubmit)
              FloatingActionButton.extended(
                heroTag: "submit",
                backgroundColor: Colors.green,
                onPressed: () => viewModel.submitChecklist(),
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text("Submit", style: TextStyle(color: Colors.white)),
              ),
            verticalSpaceSmall,
            if (viewModel.showBackToTopButton)
              FloatingActionButton(
                heroTag: "scrollTop",
                backgroundColor: Colors.white,
                mini: true,
                onPressed: viewModel.scrollToTop,
                child: const Icon(Icons.arrow_upward),
              ),
          ],
        ),
        appBar: AppBar(
          elevation: 6,
          title: AppText.appBarTitle(viewModel.checkList?.templateTitle ?? "Checklist"),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: _getProgressColor(viewModel.completionPercentage),
                    radius: 20,
                    child: AppText.body(
                      "${(viewModel.completionPercentage * 100).round()}%",
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppText.body(
                    "${viewModel.questionDoneCount}/${viewModel.checkList?.responses?.length ?? 0}",
                    fontSize: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildProgressIndicator(viewModel),
            if (viewModel.hasValidationErrors) _buildValidationSummary(viewModel),
            Expanded(
              child: CustomScrollView(
                controller: viewModel.scrollController,
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        var item = viewModel.checkList?.responses?[index];
                        return item != null ? buildcard(item, index, viewModel, context) : const SizedBox.shrink();
                      },
                      childCount: viewModel.checkList?.responses?.length ?? 0,
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100), // Space for FAB
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 1.0) return Colors.green;
    if (percentage >= 0.7) return Colors.orange;
    return Colors.red;
  }

  Widget _buildProgressIndicator(CheckListViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.body("Progress", fontWeight: FontWeight.bold),
              AppText.body(
                "${(viewModel.completionPercentage * 100).round()}% Complete",
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          verticalSpaceSmall,
          LinearProgressIndicator(
            value: viewModel.completionPercentage,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(viewModel.completionPercentage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationSummary(CheckListViewModel viewModel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red.shade600),
          horizontalSpaceSmall,
          Expanded(
            child: AppText.body(
              "${viewModel.validationErrors.length} field(s) require attention",
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onDispose(CheckListViewModel viewModel) async {
    viewModel.onDispose();
  }

  @override
  void onViewModelReady(CheckListViewModel viewModel) => SchedulerBinding.instance.addPostFrameCallback(
        (timeStamp) => viewModel.runStartupLogic(),
      );

  @override
  CheckListViewModel viewModelBuilder(BuildContext context) => CheckListViewModel(filterParams);
}
