import 'package:flutter/material.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/bottom_sheets/cms_inspection_line_editor/cms_inspection_line_editor_sheet_model.dart';

class CmsInspectionLineEditorSheet extends StatelessWidget {
  const CmsInspectionLineEditorSheet({
    super.key,
    required this.completer,
    required this.request,
  });

  final Function(SheetResponse)? completer;
  final SheetRequest request;

  @override
  Widget build(BuildContext context) {
    final requestData = request.data is Map
        ? Map<String, dynamic>.from(request.data as Map)
        : const <String, dynamic>{};
    final line = requestData['line'] as CmsInspectionLineEdit?;
    final shippingLineId = requestData['shippingLineId'] as int?;
    final initialPanelCode = requestData['initialPanelCode'] as String?;
    final initialPinX = requestData['initialPinX'] is num
        ? (requestData['initialPinX'] as num).toDouble()
        : null;
    final initialPinY = requestData['initialPinY'] is num
        ? (requestData['initialPinY'] as num).toDouble()
        : null;
    final initialLocationMatchTerms =
        requestData['initialLocationMatchTerms'] is Iterable
            ? (requestData['initialLocationMatchTerms'] as Iterable)
                .whereType<String>()
                .toList(growable: false)
            : null;

    return ViewModelBuilder<CmsInspectionLineEditorSheetModel>.reactive(
      viewModelBuilder: () => CmsInspectionLineEditorSheetModel(),
      onViewModelReady: (model) => model.initialise(
        line: line,
        shippingLineId: shippingLineId,
        initialPanelCode: initialPanelCode,
        initialPinX: initialPinX,
        initialPinY: initialPinY,
        initialLocationMatchTerms: initialLocationMatchTerms,
      ),
      builder: (context, model, child) => SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
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
                    request.title ?? 'Inspection line',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if ((request.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      request.description!,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (model.hasPanelContext) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kcPrimaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.touch_app_outlined,
                              color: kcPrimaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${model.panelLabel} selected from the container map',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: kcPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'We prefilled the nearest inspection location. Change it below if the damage needs a more specific code.',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _LookupField(
                    label: 'Location',
                    hint: model.locationHint,
                    requestItemCount: model.locationDataSource.pageSize,
                    onChanged: model.selectLocation,
                    paginatedRequest: model.locationDataSource.paginatedRequest,
                  ),
                  _LookupField(
                    label: 'Item',
                    hint: model.itemHint,
                    requestItemCount: model.itemDataSource.pageSize,
                    onChanged: model.selectItem,
                    paginatedRequest: model.itemDataSource.paginatedRequest,
                  ),
                  _LookupField(
                    label: 'Action',
                    hint: model.actionHint,
                    requestItemCount: model.actionDataSource.pageSize,
                    onChanged: model.selectAction,
                    paginatedRequest: model.actionDataSource.paginatedRequest,
                  ),
                  _LookupField(
                    label: 'Damage',
                    hint: model.damageHint,
                    requestItemCount: model.damageDataSource.pageSize,
                    onChanged: model.selectDamage,
                    paginatedRequest: model.damageDataSource.paginatedRequest,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QtyStepper(model: model),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryTile(
                          label: 'Est. subtotal',
                          value: model.estimatedSubtotalLabel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _LookupField(
                    label: 'Part number',
                    hint: model.partNumberHint,
                    requestItemCount: model.partNumberDataSource.pageSize,
                    onChanged: model.selectPartNumber,
                    paginatedRequest:
                        model.partNumberDataSource.paginatedRequest,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: model.descriptionController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Inspector note',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: model.toggleAdvancedFields,
                      icon: Icon(model.showAdvancedFields
                          ? Icons.expand_less
                          : Icons.tune_outlined),
                      label: Text(model.showAdvancedFields
                          ? 'Hide advanced costing'
                          : 'Show advanced costing'),
                    ),
                  ),
                  if (model.showAdvancedFields) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: model.costController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Cost',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: model.labourQtyController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Labour qty',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: model.labourRateController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Labour rate',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  if (model.validationMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        model.validationMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => completer?.call(
                            SheetResponse<CmsInspectionLineEdit?>(
                              confirmed: false,
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final result = model.buildResult();
                            if (result == null) {
                              return;
                            }

                            completer?.call(
                              SheetResponse<CmsInspectionLineEdit?>(
                                confirmed: true,
                                data: result,
                              ),
                            );
                          },
                          child: const Text('Save line'),
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

class _LookupField extends StatelessWidget {
  const _LookupField({
    required this.label,
    required this.hint,
    required this.requestItemCount,
    required this.onChanged,
    required this.paginatedRequest,
  });

  final String label;
  final String hint;
  final int requestItemCount;
  final Future<void> Function(int? value) onChanged;
  final Future<List<SearchableDropdownMenuItem<int>>> Function(
      int page, String? searchKey) paginatedRequest;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          SearchableDropdown<int>.paginated(
            hintText: Text(hint),
            requestItemCount: requestItemCount,
            paginatedRequest: (page, searchKey) =>
                paginatedRequest(page, searchKey),
            onChanged: (value) async {
              await onChanged(value);
            },
            margin: EdgeInsets.zero,
            backgroundDecoration: (child) => InputDecorator(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({required this.model});

  final CmsInspectionLineEditorSheetModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Qty',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton.outlined(
                onPressed: model.decrementQty,
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Text(
                  model.quantityValue % 1 == 0
                      ? model.quantityValue.toStringAsFixed(0)
                      : model.quantityValue.toStringAsFixed(2),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton.filled(
                onPressed: model.incrementQty,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
