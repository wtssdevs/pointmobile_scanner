import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_condition_type.dart';
import 'package:xstream_gate_pass_app/ui/bottom_sheets/cms_condition_picker/cms_condition_picker_sheet_model.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';

class CmsConditionPickerSheet extends StatelessWidget {
  const CmsConditionPickerSheet({
    super.key,
    required this.completer,
    required this.request,
  });

  final Function(SheetResponse)? completer;
  final SheetRequest request;

  @override
  Widget build(BuildContext context) {
    final data = request.data is Map
        ? Map<String, dynamic>.from(request.data as Map)
        : const <String, dynamic>{};
    final conditions = (data['conditions'] as List?)
            ?.whereType<CmsConditionType>()
            .toList(growable: false) ??
        const <CmsConditionType>[];
    final selectedConditionId = data['selectedConditionId'] as int?;

    return ViewModelBuilder<CmsConditionPickerSheetModel>.reactive(
      viewModelBuilder: () => CmsConditionPickerSheetModel(),
      onViewModelReady: (model) =>
          model.initialise(conditions, selectedConditionId),
      // NOTE: no viewInsets padding here — Stacked's GetX Get.bottomSheet
      // already insets the sheet by the keyboard height, so adding it again
      // double-counts and leaves a keyboard-height gap. Expand to full height
      // while the keyboard is open so the search field + list stay reachable.
      builder: (context, model, child) => FractionallySizedBox(
        heightFactor: MediaQuery.viewInsetsOf(context).bottom > 0 ? 1.0 : 0.85,
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
                const SizedBox(height: 10),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Select condition',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => completer?.call(
                            SheetResponse<CmsConditionType>(confirmed: false)),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    onChanged: model.search,
                    decoration: const InputDecoration(
                      hintText: 'Search condition',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: model.visibleConditions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final condition = model.visibleConditions[index];
                      final isSelected =
                          condition.id == model.selectedConditionId;
                      return ListTile(
                        title: Text(condition.displayName),
                        subtitle: (condition.code ?? '').trim().isEmpty
                            ? null
                            : Text(condition.code!.trim()),
                        trailing: isSelected
                            ? const Icon(Icons.check, color: kcPrimaryColor)
                            : null,
                        onTap: () => completer?.call(
                          SheetResponse<CmsConditionType>(
                            confirmed: true,
                            data: condition,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
