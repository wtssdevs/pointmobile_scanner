import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspectable_container.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_filter.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/exception_indicators/empty_list_indicator.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/exception_indicators/error_indicator.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/list/cms_container_inspections_list_viewmodel.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/list/widgets/cms_inspectable_container_card.dart';

class CmsContainerInspectionsListView extends StatelessWidget {
  const CmsContainerInspectionsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CmsContainerInspectionsListViewModel>.reactive(
      viewModelBuilder: () => CmsContainerInspectionsListViewModel(),
      onViewModelReady: (model) => SchedulerBinding.instance.addPostFrameCallback((_) {
        model.runStartupLogic();
      }),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Container Inspections'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _FilterPanel(model: model),
              if (!model.hasDepots)
                Expanded(
                  child: _EmptyState(
                    message: model.loadError ?? 'No CMS depots are available for this account yet.',
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    color: Colors.white,
                    backgroundColor: kcPrimaryColor,
                    onRefresh: () => Future.sync(model.refreshList),
                    child: PagedListView.separated(
                      pagingController: model.pagingController,
                      builderDelegate: PagedChildBuilderDelegate<CmsInspectableContainer>(
                        itemBuilder: (context, item, index) => CmsInspectableContainerCard(
                          container: item,
                          actionLabel: model.actionLabelFor(item),
                          canOpen: model.canOpen(item),
                          onTap: () => model.openInspection(item),
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
                          error: model.pagingController.error,
                          onTryAgain: model.refreshList,
                        ),
                        newPageErrorIndicatorBuilder: (context) => ErrorIndicator(
                          error: model.pagingController.error,
                          onTryAgain: model.refreshList,
                        ),
                        noItemsFoundIndicatorBuilder: (context) => EmptyListIndicator(
                          onTryAgain: model.refreshList,
                        ),
                      ),
                      separatorBuilder: (context, index) => const SizedBox(height: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({required this.model});

  final CmsContainerInspectionsListViewModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (model.depots.length > 1)
            DropdownButtonFormField<int>(
              value: model.selectedDepotId,
              decoration: const InputDecoration(
                labelText: 'Depot',
                border: OutlineInputBorder(),
              ),
              items: model.depots
                  .map(
                    (depot) => DropdownMenuItem<int>(
                      value: depot.id,
                      child: Text(depot.displayName ?? depot.depotCode ?? 'Depot ${depot.id}'),
                    ),
                  )
                  .toList(growable: false),
              onChanged: model.changeDepot,
            )
          else if (model.depots.isNotEmpty)
            Text(
              model.depots.first.displayName ?? model.depots.first.depotCode ?? 'Depot',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (model.depots.isNotEmpty) const SizedBox(height: 12),
          TextField(
            controller: model.searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => model.submitSearch(),
            decoration: InputDecoration(
              labelText: 'Search by container, transaction, shipping line, or status',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: model.searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: model.clearSearch,
                      icon: const Icon(Icons.clear),
                    ),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CmsInspectableStatusFilter.values
                .map(
                  (status) => ChoiceChip(
                    label: Text(_statusLabel(status)),
                    selected: model.statusFilter == status,
                    onSelected: (_) => model.selectStatus(status),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  String _statusLabel(CmsInspectableStatusFilter value) {
    switch (value) {
      case CmsInspectableStatusFilter.ready:
        return 'Ready';
      case CmsInspectableStatusFilter.inProgress:
        return 'In progress';
      case CmsInspectableStatusFilter.completed:
        return 'Completed';
      case CmsInspectableStatusFilter.all:
      default:
        return 'All';
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
