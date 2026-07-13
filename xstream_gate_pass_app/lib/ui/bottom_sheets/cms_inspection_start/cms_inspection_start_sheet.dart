import 'package:flutter/material.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_container_inspection_bundle.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_start_mode.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_start_inspection_input.dart';
import 'package:xstream_gate_pass_app/ui/bottom_sheets/cms_inspection_start/cms_inspection_start_sheet_model.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';

class CmsInspectionStartSheet extends StatelessWidget {
  const CmsInspectionStartSheet({
    super.key,
    required this.completer,
    required this.request,
  });

  final Function(SheetResponse)? completer;
  final SheetRequest request;

  @override
  Widget build(BuildContext context) {
    final payload = request.data;
    final bundle = payload is Map && payload['bundle'] is CmsContainerInspectionBundle ? payload['bundle'] as CmsContainerInspectionBundle : null;
    final lockedMode = payload is Map && payload['lockedMode'] is CmsInspectionStartMode ? payload['lockedMode'] as CmsInspectionStartMode : null;

    return ViewModelBuilder<CmsInspectionStartSheetModel>.reactive(
      viewModelBuilder: () => CmsInspectionStartSheetModel(),
      onViewModelReady: (model) => model.initialise(bundle, lockedMode: lockedMode),
      builder: (context, model, child) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    request.title ?? 'Start inspection',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    request.description ?? 'Choose how this inspection should start, then confirm the condition.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  _ContainerContextCard(model: model),
                  const SizedBox(height: 16),
                  if (model.showModeTiles) ...[
                    const Text(
                      'Start mode',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: model.availableModes
                          .map(
                            (mode) => _StartModeTile(
                              mode: mode,
                              selected: model.selectedMode == mode,
                              onTap: () => model.selectMode(mode),
                            ),
                          )
                          .toList(growable: false),
                    ),
                    const SizedBox(height: 10),
                  ],
                  _InlineMessage(
                    icon: Icons.auto_awesome_outlined,
                    message: model.selectedModeDescription,
                    backgroundColor: Colors.blueGrey.withOpacity(0.08),
                    foregroundColor: Colors.blueGrey[800]!,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Condition',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  if (model.isBusy && !model.hasConditionChoices)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    SearchableDropdown<int>.paginated(
                      hintText: Text(model.conditionHint),
                      requestItemCount: model.conditionRequestItemCount,
                      paginatedRequest: model.paginatedConditionRequest,
                      onChanged: (value) async {
                        await model.selectCondition(value);
                      },
                      margin: EdgeInsets.zero,
                      backgroundDecoration: (child) => InputDecorator(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                        ),
                        child: child,
                      ),
                    ),
                  if (model.validationMessage != null) ...[
                    const SizedBox(height: 10),
                    _InlineMessage(
                      icon: Icons.warning_amber_rounded,
                      message: model.validationMessage!,
                      backgroundColor: Colors.amber.withOpacity(0.14),
                      foregroundColor: Colors.amber[900]!,
                    ),
                  ],
                  if (model.loadError != null) ...[
                    const SizedBox(height: 10),
                    _InlineMessage(
                      icon: Icons.sync_problem_outlined,
                      message: model.loadError!,
                      backgroundColor: Colors.red.withOpacity(0.08),
                      foregroundColor: Colors.red[800]!,
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => completer?.call(
                            SheetResponse<CmsStartInspectionInput>(
                              confirmed: false,
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: kcPrimaryColor,
                          ),
                          onPressed: model.canSubmit
                              ? () {
                                  final startInput = model.buildStartInput();
                                  if (startInput == null) {
                                    return;
                                  }

                                  completer?.call(
                                    SheetResponse<CmsStartInspectionInput>(
                                      confirmed: true,
                                      data: startInput,
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(model.submitLabel),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContainerContextCard extends StatelessWidget {
  const _ContainerContextCard({required this.model});

  final CmsInspectionStartSheetModel model;

  @override
  Widget build(BuildContext context) {
    final bundle = model.bundle;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bundle?.containerNo ?? 'Container',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      model.containerSummary,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _TypeBadge(
                label: bundle?.statusLabel ?? 'Empty',
                backgroundColor: (bundle?.canResumeInspection == true ? kcPrimaryColor : Colors.teal).withOpacity(0.14),
                foregroundColor: bundle?.canResumeInspection == true ? kcPrimaryColor : Colors.teal[800]!,
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (model.inspectionRows.isEmpty)
            Text(
              'No inspections have been started for this depot visit yet.',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Existing inspections',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ...model.inspectionRows.map(
                  (inspection) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _InspectionHistoryTile(inspection: inspection),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

}

class _StartModeTile extends StatelessWidget {
  const _StartModeTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final CmsInspectionStartMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accentColor = mode.isMechanicalOnly ? Colors.deepOrange : kcPrimaryColor;

    return SizedBox(
      width: 220,
      child: Material(
        color: selected ? accentColor.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? accentColor : Colors.grey.shade300,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      selected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: selected ? accentColor : Colors.grey[500],
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mode.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  mode.description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InspectionHistoryTile extends StatelessWidget {
  const _InspectionHistoryTile({required this.inspection});

  final CmsContainerInspectionRow inspection;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inspection.inspectionTypeLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  inspection.transactionNo ?? 'Transaction pending',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          _TypeBadge(
            label: inspection.statusLabel,
            backgroundColor: inspection.isCancelled
                ? Colors.grey.withOpacity(0.14)
                : (inspection.inspectionCompleted ? Colors.green.withOpacity(0.14) : kcPrimaryColor.withOpacity(0.14)),
            foregroundColor: inspection.isCancelled
                ? Colors.grey[700]!
                : (inspection.inspectionCompleted ? Colors.green[800]! : kcPrimaryColor),
          ),
        ],
      ),
    );
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({
    required this.icon,
    required this.message,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String message;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foregroundColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
