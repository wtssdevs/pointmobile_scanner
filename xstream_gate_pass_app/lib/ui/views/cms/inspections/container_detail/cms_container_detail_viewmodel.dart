import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.bottomsheets.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_container_inspection_bundle.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_history_row.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_start_mode.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_start_inspection_input.dart';
import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/api/cms_error_translator.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_inspections_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/connection_service.dart';

class CmsContainerDetailViewModel extends BaseViewModel {
  final log = getLogger('CmsContainerDetailViewModel');
  final CmsMobileInspectionsService _mobileInspectionsService = locator<CmsMobileInspectionsService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  final ConnectionService _connectionService = locator<ConnectionService>();

  static const String _actionBusyKey = 'container-action';
  static const String _offlineActionMessage = 'Online required to start or resume an inspection.';

  int _containerId = 0;
  CmsContainerInspectionBundle? _bundle;
  String? _errorMessage;
  bool _hasLoaded = false;
  bool _shouldRefreshListOnExit = false;

  final PagingController<int, CmsInspectionHistoryRow> historyController = PagingController<int, CmsInspectionHistoryRow>(
    firstPageKey: 1,
    invisibleItemsThreshold: 3,
  );
  int _historyNextPage = 1;
  int _historyRevision = 0;
  final Set<int> _historyLoadingPageKeys = <int>{};
  final Set<int> _historyLoadedPageKeys = <int>{};
  PagedList<CmsInspectionHistoryRow> _historyPaged = PagedList<CmsInspectionHistoryRow>(
    totalCount: 0,
    items: <CmsInspectionHistoryRow>[],
    pageNumber: 1,
    pageSize: 20,
    totalPages: 0,
  );

  CmsContainerInspectionBundle? get bundle => _bundle;
  String? get errorMessage => _errorMessage;
  bool get hasBundle => _bundle != null;
  bool get isOffline => !_connectionService.hasConnection;
  bool get isPerformingAction => busy(_actionBusyKey);
  bool get canResume => _bundle?.canResumeInspection == true && _bundle?.resumeInspectionId != null;
  bool get canStart => _bundle?.canStartInspection == true;
  String get headerTitle => _bundle?.containerNo ?? 'Container';
  String get resumeActionLabel => 'Resume ${_bundle?.resumeInspectionTypeLabel ?? 'inspection'}';

  Future<void> runStartupLogic(int containerId) async {
    if (_hasLoaded) {
      return;
    }

    _hasLoaded = true;
    _containerId = containerId;
    historyController.addPageRequestListener(fetchHistoryPage);
    await _loadBundle();
  }

  Future<void> reloadBundle() => _loadBundle();

  Future<void> _loadBundle() async {
    if (isOffline) {
      _errorMessage = CmsErrorTranslator.offlineMessage;
      rebuildUi();
      return;
    }

    setBusy(true);
    _errorMessage = null;

    try {
      _bundle = await _mobileInspectionsService.getContainerInspections(_containerId);
    } catch (error) {
      log.e('Failed to load container inspection bundle', error);
      _errorMessage = CmsErrorTranslator.messageFrom(error);
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  Future<void> fetchHistoryPage(int pageKey) async {
    if (_historyLoadingPageKeys.contains(pageKey) || _historyLoadedPageKeys.contains(pageKey)) {
      return;
    }

    if (isOffline) {
      historyController.error = CmsErrorTranslator.offlineMessage;
      rebuildUi();
      return;
    }

    final requestRevision = _historyRevision;
    _historyLoadingPageKeys.add(pageKey);

    try {
      final page = await _mobileInspectionsService.getContainerInspectionHistory(
        containerId: _containerId,
        pageNumber: pageKey,
        pageSize: _historyPaged.pageSize,
      );

      if (requestRevision != _historyRevision) {
        return;
      }

      _historyPaged = page;
      final previouslyFetchedItemsCount = historyController.itemList?.length ?? 0;
      final isLastPage = _historyPaged.isLastPage(previouslyFetchedItemsCount);

      if (isLastPage) {
        historyController.appendLastPage(_historyPaged.items);
      } else {
        _historyNextPage = pageKey + 1;
        historyController.appendPage(_historyPaged.items, _historyNextPage);
      }
      _historyLoadedPageKeys.add(pageKey);
    } catch (error) {
      log.e('Failed to load container inspection history', error);
      historyController.error = error;
      rebuildUi();
    } finally {
      if (requestRevision == _historyRevision) {
        _historyLoadingPageKeys.remove(pageKey);
      }
    }
  }

  void _refreshHistory() {
    _historyNextPage = 1;
    _historyRevision++;
    _historyLoadingPageKeys.clear();
    _historyLoadedPageKeys.clear();
    historyController.refresh();
  }

  Future<void> resumeInspection() async {
    if (isPerformingAction || !canResume) {
      return;
    }

    if (isOffline) {
      _showActionOfflineMessage();
      return;
    }

    setBusyForObject(_actionBusyKey, true);
    try {
      final navResult = await _navigationService.navigateToCmsInspectionDetailView(
        inspectionId: _bundle!.resumeInspectionId!,
        containerId: null,
      );
      _shouldRefreshListOnExit = true;
      if (navResult == true) {
        await _loadBundle();
        _refreshHistory();
      }
    } finally {
      setBusyForObject(_actionBusyKey, false);
    }
  }

  Future<void> startInspection() => _startInspectionFlow(lockedMode: null);

  Future<void> autoStartInspection() => _startInspectionFlow(lockedMode: CmsInspectionStartMode.defaultMode);

  Future<void> _startInspectionFlow({CmsInspectionStartMode? lockedMode}) async {
    if (isPerformingAction || !canStart) {
      return;
    }

    if (isOffline) {
      _showActionOfflineMessage();
      return;
    }

    final bundle = _bundle;
    if (bundle == null) {
      return;
    }

    setBusyForObject(_actionBusyKey, true);
    try {
      final response = await _bottomSheetService.showCustomSheet<CmsStartInspectionInput, Map<String, dynamic>>(
        variant: BottomSheetType.cmsInspectionStart,
        title: 'Start inspection',
        description: 'Choose how the next inspection should start, then confirm the condition.',
        barrierDismissible: false,
        isScrollControlled: true,
        data: <String, dynamic>{
          'bundle': bundle,
          'lockedMode': lockedMode,
        },
      );

      if (response?.confirmed != true || response?.data == null) {
        return;
      }

      try {
        final result = await _mobileInspectionsService.startInspection(response!.data!);
        await _navigationService.navigateToCmsInspectionDetailView(
          inspectionId: result.entryInspectionId,
          containerId: null,
        );
        _shouldRefreshListOnExit = true;
        await _loadBundle();
        _refreshHistory();
      } catch (error) {
        log.e('Failed to start CMS inspection', error);
        _errorMessage = CmsErrorTranslator.messageFrom(error);
        await _loadBundle();
        rebuildUi();
      }
    } finally {
      setBusyForObject(_actionBusyKey, false);
    }
  }

  Future<void> openHistoryRow(CmsInspectionHistoryRow row) async {
    if (!row.isOpen || isPerformingAction) {
      return;
    }

    if (isOffline) {
      _showActionOfflineMessage();
      return;
    }

    setBusyForObject(_actionBusyKey, true);
    try {
      final navResult = await _navigationService.navigateToCmsInspectionDetailView(
        inspectionId: row.id,
        containerId: null,
      );
      _shouldRefreshListOnExit = true;
      if (navResult == true) {
        await _loadBundle();
        _refreshHistory();
      }
    } finally {
      setBusyForObject(_actionBusyKey, false);
    }
  }

  void _showActionOfflineMessage() {
    _errorMessage = _offlineActionMessage;
    rebuildUi();
  }

  void back() {
    _navigationService.back(result: _shouldRefreshListOnExit);
  }

  @override
  void dispose() {
    historyController.dispose();
    super.dispose();
  }
}
