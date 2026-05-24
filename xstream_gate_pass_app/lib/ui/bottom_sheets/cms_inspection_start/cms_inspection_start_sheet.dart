import 'package:flutter/material.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspectable_container.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_start_inspection_input.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_type.dart';
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
    final container = request.data is CmsInspectableContainer ? request.data as CmsInspectableContainer : null;

    return ViewModelBuilder<CmsInspectionStartSheetModel>.reactive(
      viewModelBuilder: () => CmsInspectionStartSheetModel(),
      onViewModelReady: (model) => model.initialise(container),
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
                    request.description ?? 'Choose the inspection condition before you open the inspection detail.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 16),
                  _ContainerContextCard(model: model),
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
                  if (model.currentConditionLabel != null) ...[
                    const SizedBox(height: 10),
                    _InlineMessage(
                      icon: Icons.info_outline,
                      message: 'Current container condition: ${model.currentConditionLabel}',
                      backgroundColor: Colors.blueGrey.withOpacity(0.08),
                      foregroundColor: Colors.blueGrey[800]!,
                    ),
                  ],
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
                          onPressed: model.hasBlockingError
                              ? null
                              : () {
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
                                },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text('Start ${model.inspectionTypeLabel}'),
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
    final container = model.container;
    final inspectionType = container?.inspectionType;
    final typeColor = _typeColor(inspectionType);

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
                      container?.containerNo ?? 'Container',
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
                label: model.inspectionTypeLabel,
                backgroundColor: typeColor.withOpacity(0.12),
                foregroundColor: typeColor,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.fact_check_outlined, color: typeColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Inspection type is locked to the container you selected.',
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _typeColor(CmsInspectionType? type) {
    switch (type) {
      case CmsInspectionType.mechanical:
        return Colors.deepOrange;
      case CmsInspectionType.structural:
      default:
        return Colors.indigo;
    }
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
