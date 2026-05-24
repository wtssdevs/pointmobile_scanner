import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.bottomsheets.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_survey_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/survey/cms_mobile_survey_list_dto.dart';
import 'package:xstream_gate_pass_app/core/models/cms/survey/cms_mobile_survey_list_input.dart';
import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_survey_service.dart';

class CmsSurveysListViewModel extends BaseViewModel {
  final log = getLogger('CmsSurveysListViewModel');
  final CmsMobileSurveyService _surveyService = locator<CmsMobileSurveyService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final BottomSheetService _bottomSheetService = locator<BottomSheetService>();

  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final PagingController<int, CmsMobileSurveyListDto> pagingController = PagingController<int, CmsMobileSurveyListDto>(
    firstPageKey: 1,
    invisibleItemsThreshold: 4,
  );

  int _nextPage = 1;
  int _requestRevision = 0;
  final Set<int> _loadingPageKeys = <int>{};
  final Set<int> _loadedPageKeys = <int>{};
  Timer? _searchDebounce;
  bool _hasInitialised = false;
  bool _isSearchVisible = false;
  CmsSurveyType? _surveyTypeFilter;
  String? _loadError;
  PagedList<CmsMobileSurveyListDto> _pagedList = PagedList<CmsMobileSurveyListDto>(
    totalCount: 0,
    items: const <CmsMobileSurveyListDto>[],
    pageNumber: 1,
    pageSize: 25,
    totalPages: 0,
  );

  bool get isSearchVisible => _isSearchVisible;
  bool get hasSearchText => searchController.text.trim().isNotEmpty;
  bool get isSearchActive => _isSearchVisible || hasSearchText;
  CmsSurveyType? get surveyTypeFilter => _surveyTypeFilter;
  String? get loadError => _loadError;
  int get activeFilterCount => _surveyTypeFilter == null ? 0 : 1;
  String get listContextSummary {
    final parts = <String>[_surveyTypeFilter?.displayName ?? 'All surveys'];
    final search = searchController.text.trim();
    if (search.isNotEmpty) {
      parts.add('Search: $search');
    }
    return parts.join(' • ');
  }

  Future<void> runStartupLogic() async {
    if (_hasInitialised) {
      return;
    }

    _hasInitialised = true;
    pagingController.addPageRequestListener(fetchPage);
    refreshList();
    await fetchPage(_nextPage);
  }

  Future<void> fetchPage(int pageKey) async {
    if (_loadingPageKeys.contains(pageKey) || _loadedPageKeys.contains(pageKey)) {
      return;
    }

    final requestRevision = _requestRevision;
    _loadingPageKeys.add(pageKey);

    try {
      final page = await _surveyService.getList(
        CmsMobileSurveyListInput(
          pageNumber: pageKey,
          pageSize: _pagedList.pageSize,
          searchText: searchController.text.trim(),
          surveyType: _surveyTypeFilter,
        ),
      );

      if (requestRevision != _requestRevision) {
        return;
      }

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
      _loadedPageKeys.add(pageKey);
    } catch (error) {
      log.e('Failed to load CMS surveys', error);
      _loadError = error.toString();
      pagingController.error = error;
      rebuildUi();
    } finally {
      if (requestRevision == _requestRevision) {
        _loadingPageKeys.remove(pageKey);
      }
    }
  }

  void toggleSearch() {
    if (_isSearchVisible) {
      closeSearch();
      return;
    }

    _isSearchVisible = true;
    rebuildUi();
    WidgetsBinding.instance.addPostFrameCallback((_) => searchFocusNode.requestFocus());
  }

  void closeSearch() {
    _searchDebounce?.cancel();
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
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), refreshList);
    rebuildUi();
  }

  void submitSearch() {
    _searchDebounce?.cancel();
    refreshList();
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    if (searchController.text.isEmpty) {
      return;
    }

    searchController.clear();
    refreshList();
  }

  void selectSurveyType(CmsSurveyType? value) {
    if (_surveyTypeFilter == value) {
      return;
    }

    _surveyTypeFilter = value;
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

  Future<void> openSurvey(CmsMobileSurveyListDto survey) async {
    final result = await _navigationService.navigateToCmsSurveyDetailView(
      surveyId: survey.id,
      surveyType: survey.surveyType,
    );
    if (result == true) {
      refreshList();
    }
  }

  Future<void> openNewSurvey() async {
    final response = await _bottomSheetService.showCustomSheet<CmsSurveyType, void>(
      variant: BottomSheetType.cmsSurveyTypePicker,
      title: 'New survey',
      description: 'Pick the survey type. Survey and inspection rules stay separate.',
      isScrollControlled: true,
    );

    if (response?.confirmed != true || response?.data == null) {
      return;
    }

    final result = await _navigationService.navigateToCmsSurveyDetailView(
      surveyId: 0,
      surveyType: response!.data!,
    );
    if (result == true) {
      refreshList();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    searchFocusNode.dispose();
    pagingController.dispose();
    super.dispose();
  }
}
