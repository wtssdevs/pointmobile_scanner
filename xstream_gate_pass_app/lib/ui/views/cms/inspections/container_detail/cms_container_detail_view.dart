import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_container_inspection_bundle.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_history_row.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/exception_indicators/error_indicator.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/container_detail/cms_container_detail_viewmodel.dart';

class CmsContainerDetailView extends StatelessWidget {
  const CmsContainerDetailView({super.key, required this.containerId});

  final int containerId;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CmsContainerDetailViewModel>.reactive(
      viewModelBuilder: () => CmsContainerDetailViewModel(),
      onViewModelReady: (model) => SchedulerBinding.instance.addPostFrameCallback((_) {
        model.runStartupLogic(containerId);
      }),
      builder: (context, model, child) => PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) {
            return;
          }
          model.back();
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: Text(model.headerTitle),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: model.back,
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Container'),
                  Tab(text: 'Inspections'),
                ],
              ),
            ),
            body: SafeArea(child: _Body(model: model)),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.model});

  final CmsContainerDetailViewModel model;

  @override
  Widget build(BuildContext context) {
    if (model.bundle == null) {
      if (model.isBusy) {
        return const Center(child: CircularProgressIndicator());
      }

      return _BundleErrorState(
        message: model.errorMessage ?? 'This container could not be loaded.',
        onRetry: model.reloadBundle,
      );
    }

    return Column(
      children: [
        Expanded(
          child: TabBarView(
            children: [
              _ContainerTab(model: model),
              _HistoryTab(model: model),
            ],
          ),
        ),
        _ActionBar(model: model),
      ],
    );
  }
}

class _ContainerTab extends StatelessWidget {
  const _ContainerTab({required this.model});

  final CmsContainerDetailViewModel model;

  @override
  Widget build(BuildContext context) {
    final bundle = model.bundle!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderCard(bundle: bundle),
          if (model.errorMessage != null) ...[
            const SizedBox(height: 12),
            _MessageBanner(message: model.errorMessage!),
          ],
          const SizedBox(height: 12),
          _FactsCard(bundle: bundle),
          const SizedBox(height: 12),
          _CurrentVisitInspections(bundle: bundle),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.bundle});

  final CmsContainerInspectionBundle bundle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kcPrimaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  bundle.containerNo,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
              _Pill(
                label: bundle.statusLabel,
                background: Colors.white.withOpacity(0.18),
                foreground: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            bundle.transactionNo,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          if (bundle.isReefer) ...[
            const SizedBox(height: 12),
            _Pill(
              label: 'Reefer',
              background: Colors.white.withOpacity(0.18),
              foreground: Colors.white,
            ),
          ],
        ],
      ),
    );
  }
}

class _FactsCard extends StatelessWidget {
  const _FactsCard({required this.bundle});

  final CmsContainerInspectionBundle bundle;

  @override
  Widget build(BuildContext context) {
    final facts = <List<String>>[
      ['Size', bundle.containerSize ?? ''],
      ['Type', bundle.containerType ?? ''],
      ['ISO', bundle.containerIsoType ?? ''],
      ['Shipping line', bundle.shippingLineLabel ?? ''],
      ['Condition', bundle.conditionTypeName ?? ''],
      [
        'Depot arrival',
        bundle.depotArrivalDateTime != null ? bundle.depotArrivalDateTime!.toFormattedString() : '',
      ],
    ].where((fact) => fact[1].trim().isNotEmpty).toList(growable: false);

    return _Card(
      title: 'Container',
      child: facts.isEmpty
          ? Text('No additional container details available.', style: TextStyle(color: Colors.grey[700]))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: facts
                  .map(
                    (fact) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              fact[0],
                              style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600),
                            ),
                          ),
                          Expanded(child: Text(fact[1])),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class _CurrentVisitInspections extends StatelessWidget {
  const _CurrentVisitInspections({required this.bundle});

  final CmsContainerInspectionBundle bundle;

  @override
  Widget build(BuildContext context) {
    final rows = bundle.visibleInspections;

    return _Card(
      title: 'Current visit inspections',
      child: rows.isEmpty
          ? Text('No inspections started for this depot visit yet.', style: TextStyle(color: Colors.grey[700]))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows
                  .map(
                    (row) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(row.inspectionTypeLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(
                                    row.transactionNo ?? 'Transaction pending',
                                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            _Pill(
                              label: row.statusLabel,
                              background: (row.inspectionCompleted ? Colors.green : kcPrimaryColor).withOpacity(0.14),
                              foreground: row.inspectionCompleted ? Colors.green[800]! : kcPrimaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.model});

  final CmsContainerDetailViewModel model;

  @override
  Widget build(BuildContext context) {
    return PagedListView<int, CmsInspectionHistoryRow>(
      pagingController: model.historyController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      builderDelegate: PagedChildBuilderDelegate<CmsInspectionHistoryRow>(
        itemBuilder: (context, item, index) => _HistoryCard(
          row: item,
          onTap: item.isOpen ? () => model.openHistoryRow(item) : null,
        ),
        firstPageProgressIndicatorBuilder: (context) => const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
        newPageProgressIndicatorBuilder: (context) => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
        firstPageErrorIndicatorBuilder: (context) => ErrorIndicator(
          error: model.historyController.error,
          onTryAgain: () => model.historyController.refresh(),
        ),
        newPageErrorIndicatorBuilder: (context) => ErrorIndicator(
          error: model.historyController.error,
          onTryAgain: () => model.historyController.refresh(),
        ),
        noItemsFoundIndicatorBuilder: (context) => const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No inspections yet for this container.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.row, this.onTap});

  final CmsInspectionHistoryRow row;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final muted = row.isPlaceholderStructural;
    final secondLine = <String>[
      if (row.dateLine.isNotEmpty) row.dateLine,
      if (row.byLine.isNotEmpty) row.byLine,
      if ((row.conditionTypeName?.trim() ?? '').isNotEmpty) row.conditionTypeName!.trim(),
    ].join(' • ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: muted ? Colors.grey[100] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      row.typeLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: muted ? Colors.grey[600] : Colors.black87,
                      ),
                    ),
                  ),
                  _Pill(
                    label: row.statusLabel,
                    background: (row.inspectionCompleted ? Colors.green : kcPrimaryColor).withOpacity(0.14),
                    foreground: row.inspectionCompleted ? Colors.green[800]! : kcPrimaryColor,
                  ),
                ],
              ),
              if ((row.transactionNo?.trim() ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  row.transactionNo!.trim(),
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
              if (secondLine.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  secondLine,
                  style: TextStyle(color: Colors.grey[700], fontSize: 12),
                ),
              ],
              if (!row.isCurrentVisit) ...[
                const SizedBox(height: 6),
                Text(
                  'Previous visit',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({required this.model});

  final CmsContainerDetailViewModel model;

  @override
  Widget build(BuildContext context) {
    final busy = model.isPerformingAction;

    Widget content;
    if (model.canResume) {
      content = SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: kcPrimaryColor),
          onPressed: busy ? null : model.resumeInspection,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(model.resumeActionLabel),
        ),
      );
    } else if (model.canStart) {
      content = Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: kcPrimaryColor),
              onPressed: busy ? null : model.startInspection,
              icon: const Icon(Icons.add_task_rounded),
              label: const Text('Start inspection'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: busy ? null : model.autoStartInspection,
              icon: const Icon(Icons.auto_awesome_outlined),
              label: const Text('Auto inspect'),
            ),
          ),
        ],
      );
    } else {
      content = Text(
        'This container can\'t be inspected right now.',
        style: TextStyle(color: Colors.grey[700], fontSize: 13),
      );
    }

    return Material(
      color: Colors.white,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: content,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.background, required this.foreground});

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.w700),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(message, style: TextStyle(color: Colors.orange[900])),
    );
  }
}

class _BundleErrorState extends StatelessWidget {
  const _BundleErrorState({required this.message, required this.onRetry});

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
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
