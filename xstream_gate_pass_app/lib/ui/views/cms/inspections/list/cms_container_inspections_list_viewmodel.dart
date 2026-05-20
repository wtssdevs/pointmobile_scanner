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
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

class CmsContainerInspectionsListViewModel extends BaseViewModel {
  final log = getLogger('CmsContainerInspectionsListViewModel');
  final CmsMobileInspectionsService _mobileInspectionsService =
      locator<CmsMobileInspectionsService>();
  final CmsSessionService _cmsSessionService = locator<CmsSessionService>();
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final PagingController<int, CmsInspectableContainer> pagingController =
      PagingController<int, CmsInspectableContainer>(
    firstPageKey: 1,
    invisibleItemsThreshold: 3,
  );

  CmsCurrentLoginInformation? _session;
  int _nextPage = 1;
  int _requestRevision = 0;
  final Set<int> _loadingPageKeys = <int>{};
  final Set<int> _loadedPageKeys = <int>{};
  bool _hasInitialised = false;
  bool _isSearchVisible = false;
  int? _selectedDepotId;
  int? _defaultDepotId;
  int? _stagedDepotId;
  String? _loadError;
  CmsInspectableStatusFilter _statusFilter = CmsInspectableStatusFilter.all;
  CmsInspectableStatusFilter _stagedStatusFilter =
      CmsInspectableStatusFilter.all;
  PagedList<CmsInspectableContainer> _pagedList =
      PagedList<CmsInspectableContainer>(
    totalCount: 0,
    items: <CmsInspectableContainer>[],
    pageNumber: 1,
    pageSize: 20,
    totalPages: 0,
  );

  List<CmsUserDepot> get depots =>
      _session?.userDepots
          .where((item) => item.id != null)
          .toList(growable: false) ??
      const [];
  int? get selectedDepotId => _selectedDepotId;
  int? get stagedDepotId => _stagedDepotId;
  CmsInspectableStatusFilter get statusFilter => _statusFilter;
  CmsInspectableStatusFilter get stagedStatusFilter => _stagedStatusFilter;
  String? get loadError => _loadError;
  bool get hasDepots => depots.isNotEmpty;
  bool get canLoadList => _selectedDepotId != null;
  bool get isSearchVisible => _isSearchVisible;
  bool get hasSearchText => searchController.text.trim().isNotEmpty;
  bool get isSearchActive => _isSearchVisible || hasSearchText;
  bool get hasFiltersApplied =>
      _statusFilter != CmsInspectableStatusFilter.all ||
      (_defaultDepotId != null && _selectedDepotId != _defaultDepotId);
  bool get hasStagedFiltersApplied =>
      _stagedStatusFilter != CmsInspectableStatusFilter.all ||
      (_defaultDepotId != null && _stagedDepotId != _defaultDepotId);
  int get activeFilterCount {
    var count = 0;
    if (_statusFilter != CmsInspectableStatusFilter.all) {
      count++;
    }
    if (_defaultDepotId != null && _selectedDepotId != _defaultDepotId) {
      count++;
    }
    return count;
  }

  String get selectedDepotDisplay => depotDisplayName(_selectedDepotId);
  String get stagedDepotDisplay => depotDisplayName(_stagedDepotId);
  String get statusFilterLabel => statusLabel(_statusFilter);
  String get stagedStatusFilterLabel => statusLabel(_stagedStatusFilter);
  String get listContextSummary {
    final parts = <String>[
      selectedDepotDisplay,
      statusFilterLabel,
    ];

    final searchValue = searchController.text.trim();
    if (searchValue.isNotEmpty) {
      parts.add('Search: $searchValue');
    }

    return parts.join(' • ');
  }

  Future<void> runStartupLogic() async {
    if (_hasInitialised) {
      return;
    }

    _hasInitialised = true;
    _session = _cmsSessionService.getCached() ??
        await _cmsSessionService.refreshFromServer(showLoader: false);
    _defaultDepotId = _resolveDefaultDepotId();
    _selectedDepotId = _defaultDepotId;
    _syncStagedFilters();
    pagingController.addPageRequestListener(fetchPage);

    if (_selectedDepotId == null) {
      _loadError = 'No CMS depots are available for this account.';
      rebuildUi();
      return;
    }

    refreshList();
    await fetchPage(_nextPage);
  }

  Future<void> fetchPage(int pageKey) async {
    if (_selectedDepotId == null) {
      return;
    }

    if (_loadingPageKeys.contains(pageKey) ||
        _loadedPageKeys.contains(pageKey)) {
      return;
    }

    final requestRevision = _requestRevision;
    _loadingPageKeys.add(pageKey);

    try {
      final page = await _mobileInspectionsService.getInspectableContainers(
        CmsInspectionFilter(
          depotId: _selectedDepotId!,
          pageNumber: pageKey,
          pageSize: _pagedList.pageSize,
          searchValue: searchController.text.trim(),
          statusFilter: _statusFilter,
          includeCompleted:
              _statusFilter == CmsInspectableStatusFilter.completed,
        ),
      );

      if (requestRevision != _requestRevision) {
        return;
      }

      _pagedList = page;
      _loadError = null;
      final previouslyFetchedItemsCount =
          pagingController.itemList?.length ?? 0;
      final isLastPage = _pagedList.isLastPage(previouslyFetchedItemsCount);

      if (isLastPage) {
        pagingController.appendLastPage(_pagedList.items);
      } else {
        _nextPage = pageKey + 1;
        pagingController.appendPage(_pagedList.items, _nextPage);
      }
      _loadedPageKeys.add(pageKey);
    } catch (error) {
      log.e('Failed to load inspectable containers', error);
      _loadError = error.toString();
      pagingController.error = error;
      rebuildUi();
    } finally {
      if (requestRevision == _requestRevision) {
        _loadingPageKeys.remove(pageKey);
      }
    }
  }

  void changeDepot(int? value) {
    if (value == null || value == _selectedDepotId) {
      return;
    }

    _selectedDepotId = value;
    _defaultDepotId = value;
    _localStorageService.setCmsDefaultInspectionDepotId(value);
    _syncStagedFilters();
    refreshList();
  }

  void selectStatus(CmsInspectableStatusFilter value) {
    if (_statusFilter == value) {
      return;
    }

    _statusFilter = value;
    _syncStagedFilters();
    refreshList();
  }

  void beginFilterEditing() {
    _syncStagedFilters();
    rebuildUi();
  }

  void changeStagedDepot(int? value) {
    if (value == null || value == _stagedDepotId) {
      return;
    }

    _stagedDepotId = value;
    rebuildUi();
  }

  void selectStagedStatus(CmsInspectableStatusFilter value) {
    if (_stagedStatusFilter == value) {
      return;
    }

    _stagedStatusFilter = value;
    rebuildUi();
  }

  void applyFilters() {
    var shouldRefresh = false;

    if (_stagedDepotId != null && _selectedDepotId != _stagedDepotId) {
      _selectedDepotId = _stagedDepotId;
      _defaultDepotId = _stagedDepotId;
      _localStorageService.setCmsDefaultInspectionDepotId(_stagedDepotId!);
      shouldRefresh = true;
    }

    if (_statusFilter != _stagedStatusFilter) {
      _statusFilter = _stagedStatusFilter;
      shouldRefresh = true;
    }

    if (shouldRefresh) {
      refreshList();
    } else {
      rebuildUi();
    }
  }

  void clearFilters() {
    final defaultDepotId = _resolveDefaultDepotId();
    final changed = _selectedDepotId != defaultDepotId ||
        _statusFilter != CmsInspectableStatusFilter.all;
    _defaultDepotId = defaultDepotId;
    _selectedDepotId = defaultDepotId;
    _statusFilter = CmsInspectableStatusFilter.all;
    _syncStagedFilters();

    if (changed) {
      refreshList();
    } else {
      rebuildUi();
    }
  }

  void toggleSearch() {
    if (_isSearchVisible) {
      closeSearch();
      return;
    }

    _isSearchVisible = true;
    rebuildUi();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => searchFocusNode.requestFocus());
  }

  void closeSearch() {
    if (!_isSearchVisible && !hasSearchText) {
      return;
    }

    _isSearchVisible = false;
    searchFocusNode.unfocus();
    if (hasSearchText) {
      searchController.clear();
      refreshList();
    } else {
      rebuildUi();
    }
  }

  void onSearchTextChanged(String value) {
    rebuildUi();
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
    _requestRevision++;
    _loadingPageKeys.clear();
    _loadedPageKeys.clear();
    _loadError = null;
    pagingController.refresh();
    rebuildUi();
  }

  Future<void> openInspection(CmsInspectableContainer container) async {
    if (!canOpen(container)) {
      return;
    }

    final result = await _navigationService.navigateToCmsInspectionDetailView(
      inspectionId:
          container.canResumeInspection ? container.inspectionId : null,
      containerId: container.canResumeInspection ? null : container.containerId,
    );

    if (result == true) {
      refreshList();
    }
  }

  bool canOpen(CmsInspectableContainer container) {
    return container.canStartInspection ||
        (container.canResumeInspection && container.inspectionId != null);
  }

  String actionLabelFor(CmsInspectableContainer container) {
    if (container.canResumeInspection && container.inspectionId != null) {
      return 'Resume';
    }
    if (container.canStartInspection) {
      return 'Start';
    }
    if (container.cardStatus.toLowerCase() == 'completed') {
      return 'Completed';
    }
    return 'Unavailable';
  }

  String depotDisplayName(int? depotId) {
    CmsUserDepot? match;
    for (final depot in depots) {
      if (depot.id == depotId) {
        match = depot;
        break;
      }
    }
    return match?.displayName ??
        match?.depotCode ??
        (depotId == null ? 'No depot' : 'Depot $depotId');
  }

  String statusLabel(CmsInspectableStatusFilter value) {
    switch (value) {
      case CmsInspectableStatusFilter.ready:
        return 'Ready';
      case CmsInspectableStatusFilter.inProgress:
        return 'In progress';
      case CmsInspectableStatusFilter.completed:
        return 'Completed';
      case CmsInspectableStatusFilter.all:
      default:
        return 'All statuses';
    }
  }

  int? _resolveDefaultDepotId() {
    if (depots.isEmpty) {
      return null;
    }

    final savedDepotId = _localStorageService.getCmsDefaultInspectionDepotId();
    if (savedDepotId != null && depots.any((item) => item.id == savedDepotId)) {
      return savedDepotId;
    }

    return depots.first.id;
  }

  void _syncStagedFilters() {
    _stagedDepotId = _selectedDepotId;
    _stagedStatusFilter = _statusFilter;
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    pagingController.dispose();
    super.dispose();
  }
}
