import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspectable_container.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/exception_indicators/empty_list_indicator.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/exception_indicators/error_indicator.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/list/cms_container_inspections_list_viewmodel.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/list/widgets/cms_inspectable_container_card.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/list/widgets/cms_inspections_filter_drawer.dart';

class CmsContainerInspectionsListView extends StatelessWidget {
  const CmsContainerInspectionsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CmsContainerInspectionsListViewModel>.reactive(
      viewModelBuilder: () => CmsContainerInspectionsListViewModel(),
      onViewModelReady: (model) =>
          SchedulerBinding.instance.addPostFrameCallback((_) {
        model.runStartupLogic();
      }),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Container Inspections'),
          actions: [
            IconButton(
              onPressed: model.toggleSearch,
              icon: Icon(model.isSearchVisible
                  ? Icons.search_off_rounded
                  : Icons.search_rounded),
              tooltip:
                  model.isSearchVisible ? 'Hide search' : 'Search inspections',
            ),
            Builder(
              builder: (context) => IconButton(
                onPressed: model.hasDepots
                    ? () {
                        model.beginFilterEditing();
                        Scaffold.of(context).openEndDrawer();
                      }
                    : null,
                icon: _FilterIcon(count: model.activeFilterCount),
                tooltip: 'Filter inspections',
              ),
            ),
          ],
        ),
        endDrawer: CmsInspectionsFilterDrawer(model: model),
        body: SafeArea(
          child: Column(
            children: [
              _SearchPanel(model: model),
              if (model.hasDepots) _ListContextBar(model: model),
              if (model.hasDepots && model.loadError != null)
                _ListErrorBanner(message: model.loadError!),
              if (!model.hasDepots)
                Expanded(
                  child: _EmptyState(
                    message: model.loadError ??
                        'No CMS depots are available for this account yet.',
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    color: Colors.white,
                    backgroundColor: kcPrimaryColor,
                    onRefresh: () => Future.sync(model.refreshList),
                    child: PagedListView.separated(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      pagingController: model.pagingController,
                      builderDelegate:
                          PagedChildBuilderDelegate<CmsInspectableContainer>(
                        itemBuilder: (context, item, index) =>
                            CmsInspectableContainerCard(
                          container: item,
                          actionLabel: model.actionLabelFor(item),
                          onTap: () => model.openContainer(item),
                        ),
                        firstPageProgressIndicatorBuilder: (context) =>
                            const Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        newPageProgressIndicatorBuilder: (context) =>
                            const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        firstPageErrorIndicatorBuilder: (context) =>
                            ErrorIndicator(
                          error: model.pagingController.error,
                          onTryAgain: model.refreshList,
                        ),
                        newPageErrorIndicatorBuilder: (context) =>
                            ErrorIndicator(
                          error: model.pagingController.error,
                          onTryAgain: model.refreshList,
                        ),
                        noItemsFoundIndicatorBuilder: (context) =>
                            EmptyListIndicator(
                          onTryAgain: model.refreshList,
                        ),
                      ),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 2),
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

class _FilterIcon extends StatelessWidget {
  const _FilterIcon({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const Icon(Icons.tune_rounded);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.tune_rounded),
        Positioned(
          right: -6,
          top: -6,
          child: Container(
            height: 18,
            width: 18,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({required this.model});

  final CmsContainerInspectionsListViewModel model;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: model.isSearchVisible
          ? Container(
              key: const ValueKey('cms-search-panel'),
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              padding: const EdgeInsets.all(14),
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
              child: TextField(
                controller: model.searchController,
                focusNode: model.searchFocusNode,
                textInputAction: TextInputAction.search,
                onChanged: model.onSearchTextChanged,
                onSubmitted: (_) => model.submitSearch(),
                decoration: InputDecoration(
                  hintText: 'Container, transaction, line, or status',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: model.hasSearchText
                      ? IconButton(
                          onPressed: model.clearSearch,
                          icon: const Icon(Icons.clear_rounded),
                          tooltip: 'Clear search',
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(key: ValueKey('cms-search-hidden')),
    );
  }
}

class _ListContextBar extends StatelessWidget {
  const _ListContextBar({required this.model});

  final CmsContainerInspectionsListViewModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.filter_alt_outlined,
              color: Colors.blueGrey[700], size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              model.listContextSummary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[700],
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

class _ListErrorBanner extends StatelessWidget {
  const _ListErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red[800], size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red[800],
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
