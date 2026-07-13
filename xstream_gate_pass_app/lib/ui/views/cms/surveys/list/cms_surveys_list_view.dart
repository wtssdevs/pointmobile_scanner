import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_survey_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/survey/cms_mobile_survey_list_dto.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/surveys/list/cms_surveys_list_viewmodel.dart';

class CmsSurveysListView extends StatelessWidget {
  const CmsSurveysListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CmsSurveysListViewModel>.reactive(
      viewModelBuilder: () => CmsSurveysListViewModel(),
      onViewModelReady: (model) => model.runStartupLogic(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: model.isSearchVisible
              ? TextField(
                  controller: model.searchController,
                  focusNode: model.searchFocusNode,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Search surveys',
                    border: InputBorder.none,
                  ),
                  onChanged: model.onSearchTextChanged,
                  onSubmitted: (_) => model.submitSearch(),
                )
              : const Text('Container surveys'),
          actions: [
            if (model.isSearchActive)
              IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close_rounded),
                onPressed: model.closeSearch,
              )
            else
              IconButton(
                tooltip: 'Search',
                icon: const Icon(Icons.search_rounded),
                onPressed: model.toggleSearch,
              ),
            PopupMenuButton<CmsSurveyType?>(
              tooltip: 'Filter survey type',
              icon: Badge.count(
                isLabelVisible: model.activeFilterCount > 0,
                count: model.activeFilterCount,
                child: const Icon(Icons.filter_list_rounded),
              ),
              onSelected: model.selectSurveyType,
              itemBuilder: (context) => [
                const PopupMenuItem<CmsSurveyType?>(
                  value: null,
                  child: Text('All surveys'),
                ),
                ...CmsSurveyType.values.map(
                  (type) => PopupMenuItem<CmsSurveyType?>(
                    value: type,
                    child: Text(type.displayName),
                  ),
                ),
              ],
            ),
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: model.refreshList,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: kcPrimaryColor,
          onPressed: model.openNewSurvey,
          icon: const Icon(Icons.add_rounded),
          label: const Text('New survey'),
        ),
        body: RefreshIndicator(
          onRefresh: () async => model.refreshList(),
          child: Column(
            children: [
              _ListSummary(model: model),
              if (model.loadError != null)
                _InlineMessage(
                  icon: Icons.sync_problem_outlined,
                  message: model.loadError!,
                  backgroundColor: Colors.red.withOpacity(0.08),
                  foregroundColor: Colors.red[800]!,
                ),
              Expanded(
                child: PagedListView<int, CmsMobileSurveyListDto>.separated(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  pagingController: model.pagingController,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  builderDelegate: PagedChildBuilderDelegate<CmsMobileSurveyListDto>(
                    itemBuilder: (context, survey, index) => _SurveyCard(
                      survey: survey,
                      onTap: () => model.openSurvey(survey),
                    ),
                    noItemsFoundIndicatorBuilder: (context) => const _EmptyState(),
                    firstPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
                    newPageProgressIndicatorBuilder: (context) => const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    firstPageErrorIndicatorBuilder: (context) => _PageError(
                      onRetry: model.refreshList,
                    ),
                    newPageErrorIndicatorBuilder: (context) => _PageError(
                      onRetry: model.refreshList,
                    ),
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

class _ListSummary extends StatelessWidget {
  const _ListSummary({required this.model});

  final CmsSurveysListViewModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          Chip(
            avatar: const Icon(Icons.assignment_outlined, size: 18),
            label: Text(model.listContextSummary),
          ),
          if (model.surveyTypeFilter != null)
            ActionChip(
              label: const Text('Clear filter'),
              onPressed: () => model.selectSurveyType(null),
            ),
        ],
      ),
    );
  }
}

class _SurveyCard extends StatelessWidget {
  const _SurveyCard({required this.survey, required this.onTap});

  final CmsMobileSurveyListDto survey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = survey.surveyType == CmsSurveyType.gatePass ? Colors.deepOrange : kcPrimaryColor;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                          survey.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          survey.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _TypeBadge(label: survey.surveyType.displayName, color: color),
                ],
              ),
              if (survey.description != null && survey.description!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  survey.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[800]),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(Icons.schedule_rounded, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(survey.displayDate),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.chevron_right_rounded),
                    label: const Text('Open'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return 'No date';
    }
    final date = value.toLocal();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}-$month-$day $hour:$minute';
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
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
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: foregroundColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: foregroundColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(32, 96, 32, 32),
      children: [
        Icon(Icons.assignment_outlined, size: 56, color: Colors.grey[400]),
        const SizedBox(height: 16),
        const Text(
          'No surveys yet',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap New survey to capture a container or gate pass survey.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
    );
  }
}

class _PageError extends StatelessWidget {
  const _PageError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sync_problem_rounded, size: 44),
            const SizedBox(height: 12),
            const Text('Could not load surveys.'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
