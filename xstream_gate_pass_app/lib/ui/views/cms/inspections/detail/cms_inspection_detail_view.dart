import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/detail/cms_inspection_detail_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/detail/widgets/cms_container_schematic_view.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/detail/widgets/cms_inspection_line_tile.dart';

class CmsInspectionDetailView extends StatelessWidget {
  const CmsInspectionDetailView({
    super.key,
    this.inspectionId,
    this.containerId,
  });

  final int? inspectionId;
  final int? containerId;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CmsInspectionDetailViewModel>.reactive(
      viewModelBuilder: () => CmsInspectionDetailViewModel(),
      onViewModelReady: (model) =>
          SchedulerBinding.instance.addPostFrameCallback((_) {
        model.runStartupLogic(
          inspectionId: inspectionId,
          containerId: containerId,
        );
      }),
      builder: (context, model, child) => PopScope(
        canPop: false,
        onPopInvoked: (didPop) async {
          if (didPop) {
            return;
          }

          await model.onWillPop();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(model.headerTitle()),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: model.onWillPop,
            ),
            actions: [
              if (model.hasInspection)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: _CoverageBadge(label: model.coverageSummary),
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: Stack(
              children: [
                if (!model.hasInspection && model.isBusy)
                  const Center(child: CircularProgressIndicator())
                else if (!model.hasInspection)
                  _ErrorState(
                    message: model.errorMessage ??
                        'The inspection could not be loaded.',
                    onRetry: model.reload,
                  )
                else
                  AbsorbPointer(
                    absorbing: model.isBusy,
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeaderCard(
                            title: model.headerTitle(),
                            subtitle: model.headerSubtitle(),
                            statusLabel: model.inspectionStatusLabel,
                            facts: model.containerHeaderFacts,
                          ),
                          const SizedBox(height: 12),
                          if (model.errorMessage != null)
                            _MessageBanner(message: model.errorMessage!),
                          _SectionCard(
                            title: model.inspectionTimingTitle,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model.inspection?.inspectionDateTime != null
                                      ? model.inspection!.inspectionDateTime!
                                          .toFormattedString()
                                      : 'Not set yet',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () => _pickInspectionDateTime(
                                          context, model),
                                      icon: const Icon(
                                          Icons.edit_calendar_outlined),
                                      label: const Text('Pick date & time'),
                                    ),
                                    TextButton.icon(
                                      onPressed:
                                          model.setInspectionDateTimeToNow,
                                      icon: const Icon(
                                          Icons.schedule_send_outlined),
                                      label: const Text('Set now'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          _SectionCard(
                            title: 'Inspection summary',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _LabeledValue(
                                  label: 'Inspection type',
                                  value:
                                      model.inspection?.inspectionTypeLabel ??
                                          'Not set',
                                ),
                                _LabeledValue(
                                    label: 'Shipping line',
                                    value: model.inspection?.shippingLineName ??
                                        'Not set'),
                              ],
                            ),
                          ),
                          _SectionCard(
                            title: 'Container condition',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  model.conditionLabel,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: OutlinedButton.icon(
                                    onPressed: model.canEditCondition
                                        ? model.changeCondition
                                        : null,
                                    icon: const Icon(Icons.edit_outlined),
                                    label: const Text('Change condition'),
                                  ),
                                ),
                                if (!model.hasConditionChoices)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      'Sync CMS master files to change the condition.',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600]),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (model.startMetadataWarning != null)
                            _MessageBanner(
                              message: model.startMetadataWarning!,
                            ),
                          if (model.hasUnclassifiedLines)
                            _MessageBanner(
                                message: model.unclassifiedLineWarning),
                          _SectionCard(
                            title: 'Container map',
                            contentPadding: const EdgeInsets.all(1),
                            childSpacing: 2,
                            child: CmsContainerSchematicView(
                              lines: model.inspection!.items,
                              containerLabel: model.schematicContainerLabel,
                              selectedPanelCode: model.selectedPanelCode,
                              coverageFor: model.coverageFor,
                              onPanelTap: model.selectPanelFromMap,
                              onPanelDoubleTap: model.addLineFromPanel,
                              onAddLineForSelectedPanel:
                                  model.addLineFromSelectedPanel,
                              onQuickPhotoForSelectedPanel:
                                  model.capturePhotoFromSelectedPanel,
                              onMarkerTap: model.editLineFromMarker,
                            ),
                          ),
                          _SectionCard(
                            title: 'Comments',
                            child: TextField(
                              controller: model.commentsController,
                              minLines: 3,
                              maxLines: 5,
                              onChanged: model.updateComments,
                              decoration: const InputDecoration(
                                hintText: 'Add inspection comments',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          _LineItemsSection(
                            model: model,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: !model.canEdit || model.startMetadataWarning != null
                                      ? null
                                      : model.saveDraft,
                                  icon: const Icon(Icons.save_outlined),
                                  label: const Text('Save draft'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.icon(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: kcPrimaryColor,
                                  ),
                                  onPressed: !model.canEdit ||
                                          model.hasUnclassifiedLines ||
                                          model.startMetadataWarning != null
                                      ? null
                                      : model.completeInspection,
                                  icon: const Icon(Icons.task_alt),
                                  label: const Text('Complete'),
                                ),
                              ),
                            ],
                          ),
                          if (!model.hasLineItems) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.green.shade700,
                                ),
                                onPressed: model.canCompleteAsAv
                                    ? model.completeAsAv
                                    : null,
                                icon: const Icon(Icons.verified_outlined),
                                label: const Text('Complete as AV'),
                              ),
                            ),
                            if (!model.isAvConditionAvailable)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'AV condition is not synced on this device.',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[600]),
                                ),
                              ),
                          ],
                          if (model.canCancel) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: model.cancelInspection,
                                icon: const Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.red,
                                ),
                                label: const Text(
                                  'Cancel inspection',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                if (model.hasInspection && model.isBusy)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickInspectionDateTime(
    BuildContext context,
    CmsInspectionDetailViewModel model,
  ) async {
    final initial = model.inspection?.inspectionDateTime ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null || !context.mounted) {
      return;
    }

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );

    if (time == null) {
      return;
    }

    model.setInspectionDateTime(
      DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      ),
    );
  }
}

class _LineItemsSection extends StatelessWidget {
  const _LineItemsSection({required this.model});

  final CmsInspectionDetailViewModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Line Items',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: model.addLine,
                icon: const Icon(Icons.add),
                label: const Text('Add line'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (model.hasLineItems)
            Column(
              children: List.generate(
                model.inspection!.items.length,
                (index) => CmsInspectionLineTile(
                  line: model.inspection!.items[index],
                  requiresClassification: model.lineNeedsClassification(
                    model.inspection!.items[index],
                  ),
                  photoCount:
                      model.photoCountForLine(model.inspection!.items[index]),
                  photoStatus:
                      model.photoStatusForLine(model.inspection!.items[index]),
                  isPhotoBusy: model.isCapturingLinePhoto(index),
                  onAddPhoto: () => model.captureLinePhoto(index),
                  onEdit: () => model.editLine(index),
                  onDuplicate: () => model.duplicateLine(index),
                  onDelete: () => model.deleteLine(index),
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No line items added yet. Tap the container map or use Add line to start.',
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.statusLabel,
    required this.facts,
  });

  final String title;
  final String subtitle;
  final String statusLabel;
  final List<CmsInspectionHeaderFact> facts;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kcPrimaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kcPrimaryColor.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _HeaderStatusChip(label: statusLabel),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          if (facts.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: facts
                  .map(
                    (fact) => _HeaderFactChip(
                      label: fact.label,
                      value: fact.value,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderStatusChip extends StatelessWidget {
  const _HeaderStatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white30),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeaderFactChip extends StatelessWidget {
  const _HeaderFactChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 120),
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.contentPadding = const EdgeInsets.all(16),
    this.childSpacing = 12,
  });

  final String title;
  final Widget child;
  final EdgeInsetsGeometry contentPadding;
  final double childSpacing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: contentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: childSpacing),
            child,
          ],
        ),
      ),
    );
  }
}

class _LabeledValue extends StatelessWidget {
  const _LabeledValue({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: TextStyle(color: Colors.orange[900]),
      ),
    );
  }
}

class _CoverageBadge extends StatelessWidget {
  const _CoverageBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
