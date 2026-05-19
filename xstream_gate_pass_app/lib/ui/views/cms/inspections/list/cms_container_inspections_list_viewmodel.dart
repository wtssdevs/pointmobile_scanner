import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/models/cms/account/cms_current_login_information.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspectable_container.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_filter.dart';
import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_inspections_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';

class CmsContainerInspectionsListViewModel extends BaseViewModel {
  final log = getLogger('CmsContainerInspectionsListViewModel');
  final CmsMobileInspectionsService _mobileInspectionsService = locator<CmsMobileInspectionsService>();
  final CmsSessionService _cmsSessionService = locator<CmsSessionService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final TextEditingController searchController = TextEditingController();
  final PagingController<int, CmsInspectableContainer> pagingController = PagingController<int, CmsInspectableContainer>(
    firstPageKey: 1,
    invisibleItemsThreshold: 3,
  );

  CmsCurrentLoginInformation? _session;
  int _nextPage = 1;
  bool _hasInitialised = false;
  int? _selectedDepotId;
  String? _loadError;
  CmsInspectableStatusFilter _statusFilter = CmsInspectableStatusFilter.all;
  PagedList<CmsInspectableContainer> _pagedList = PagedList<CmsInspectableContainer>(
    totalCount: 0,
    items: <CmsInspectableContainer>[],
    pageNumber: 1,
    pageSize: 20,
    totalPages: 0,
  );

  List<CmsUserDepot> get depots => _session?.userDepots.where((item) => item.id != null).toList(growable: false) ?? const [];
  int? get selectedDepotId => _selectedDepotId;
  CmsInspectableStatusFilter get statusFilter => _statusFilter;
  String? get loadError => _loadError;
  bool get hasDepots => depots.isNotEmpty;
  bool get canLoadList => _selectedDepotId != null;

  Future<void> runStartupLogic() async {
    if (_hasInitialised) {
      return;
    }

    _hasInitialised = true;
    _session = _cmsSessionService.getCached() ?? await _cmsSessionService.refreshFromServer(showLoader: false);
    _selectedDepotId = depots.isNotEmpty ? depots.first.id : null;
    pagingController.addPageRequestListener(fetchPage);

    if (_selectedDepotId == null) {
      _loadError = 'No CMS depots are available for this account.';
      rebuildUi();
      return;
    }

    fetchPage(_nextPage);
  }

  Future<void> fetchPage(int pageKey) async {
    if (_selectedDepotId == null) {
      return;
    }

    try {
      final page = await _mobileInspectionsService.getInspectableContainers(
        CmsInspectionFilter(
          depotId: _selectedDepotId!,
          pageNumber: pageKey,
          pageSize: _pagedList.pageSize,
          searchValue: searchController.text.trim(),
          statusFilter: _statusFilter,
          includeCompleted: _statusFilter == CmsInspectableStatusFilter.completed,
        ),
      );

      _pagedList = page;
      _loadError = null;
      final previouslyFetchedItemsCount = pagingController.itemList?.length ?? 0;
      final isLastPage = _pagedList.isLastPage(previouslyFetchedItemsCount);

      if (isLastPage) {
        pagingController.appendLastPage(_pagedList.items);
      } else {
        _nextPage = pageKey + 1;
        pagingController.appendPage(_pagedList.items, _nextPage);
      }
    } catch (error) {
      log.e('Failed to load inspectable containers', error);
      _loadError = error.toString();
      pagingController.error = error;
      rebuildUi();
    }
  }

  void changeDepot(int? value) {
    if (value == null || value == _selectedDepotId) {
      return;
    }

    _selectedDepotId = value;
    refreshList();
  }

  void selectStatus(CmsInspectableStatusFilter value) {
    if (_statusFilter == value) {
      return;
    }

    _statusFilter = value;
    refreshList();
  }

  void submitSearch() {
    refreshList();
  }

  void clearSearch() {
    if (searchController.text.isEmpty) {
      return;
    }

    searchController.clear();
    refreshList();
  }

  void refreshList() {
    _nextPage = 1;
    _loadError = null;
    pagingController.refresh();
  }

  Future<void> openInspection(CmsInspectableContainer container) async {
    if (!canOpen(container)) {
      return;
    }

    final result = await _navigationService.navigateToCmsInspectionDetailView(
      inspectionId: container.canResumeInspection ? container.inspectionId : null,
      containerId: container.canResumeInspection ? null : container.containerId,
    );

    if (result == true) {
      refreshList();
    }
  }

  bool canOpen(CmsInspectableContainer container) {
    return container.canStartInspection || (container.canResumeInspection && container.inspectionId != null);
  }

  String actionLabelFor(CmsInspectableContainer container) {
    if (container.canResumeInspection) {
      return 'Resume';
    }
    if (container.canStartInspection) {
      return 'Start';
    }
    return 'Completed';
  }

  @override
  void dispose() {
    searchController.dispose();
    pagingController.dispose();
    super.dispose();
  }
}
