import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _cancel() {
    completer?.call(
      SheetResponse<CmsInspectionLineEdit?>(confirmed: false),
    );
  }

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
      builder: (context, model, child) => AnimatedPadding(
        // Lift the whole sheet above the keyboard. While the keyboard is open
        // the sheet also expands to the full remaining height (heightFactor
        // 1.0 instead of 0.92): the centred 0.92 box otherwise squashes the
        // scrollable body, scrolling the focused field out of view so you
        // can't see what you're typing.
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: FractionallySizedBox(
          heightFactor:
              MediaQuery.viewInsetsOf(context).bottom > 0 ? 1.0 : 0.92,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // ---- pinned header: drag handle, title, close ----
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
                  child: Column(
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
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              request.title ?? 'Inspection line',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close',
                            onPressed: _cancel,
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // ---- scrollable body ----
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((request.description ?? '').isNotEmpty) ...[
                          Text(
                            request.description!,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 16),
                        ],
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        model.panelContextHelper,
                                        style:
                                            TextStyle(color: Colors.grey[700]),
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
                          paginatedRequest:
                              model.locationDataSource.paginatedRequest,
                        ),
                        _LookupField(
                          label: 'Item',
                          hint: model.itemHint,
                          requestItemCount: model.itemDataSource.pageSize,
                          onChanged: model.selectItem,
                          paginatedRequest:
                              model.itemDataSource.paginatedRequest,
                        ),
                        _LookupField(
                          label: 'Action',
                          hint: model.actionHint,
                          requestItemCount: model.actionDataSource.pageSize,
                          onChanged: model.selectAction,
                          paginatedRequest:
                              model.actionDataSource.paginatedRequest,
                        ),
                        _LookupField(
                          label: 'Damage',
                          hint: model.damageHint,
                          requestItemCount: model.damageDataSource.pageSize,
                          onChanged: model.selectDamage,
                          paginatedRequest:
                              model.damageDataSource.paginatedRequest,
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
                          scrollPadding: const EdgeInsets.only(bottom: 140),
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
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: _currencyFormatters,
                                  scrollPadding:
                                      const EdgeInsets.only(bottom: 140),
                                  onTap: () => _selectAll(model.costController),
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
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: _currencyFormatters,
                                  scrollPadding:
                                      const EdgeInsets.only(bottom: 140),
                                  onTap: () =>
                                      _selectAll(model.labourQtyController),
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
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: _currencyFormatters,
                            scrollPadding: const EdgeInsets.only(bottom: 140),
                            onTap: () => _selectAll(model.labourRateController),
                            decoration: const InputDecoration(
                              labelText: 'Labour rate',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // ---- pinned footer: validation + actions ----
                _ActionBar(
                  model: model,
                  onCancel: _cancel,
                  onSave: () {
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Currency inputs accept digits and at most two decimal places. This stops
/// the editor from accepting junk and keeps the parsed value sane (issue #804).
final List<TextInputFormatter> _currencyFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
];

/// Selects the whole field on focus so re-editing a prefilled cost replaces it
/// instead of appending — the inspector taps in and types a fresh number.
void _selectAll(TextEditingController controller) {
  controller.selection = TextSelection(
    baseOffset: 0,
    extentOffset: controller.text.length,
  );
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.model,
    required this.onCancel,
    required this.onSave,
  });

  final CmsInspectionLineEditorSheetModel model;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (model.validationMessage != null) ...[
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
                const SizedBox(height: 12),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: onSave,
                      child: const Text('Save line'),
                    ),
                  ),
                ],
              ),
            ],
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
