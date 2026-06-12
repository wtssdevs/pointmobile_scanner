import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_condition_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_container_inspection_bundle.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_start_mode.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_start_inspection_input.dart';
import 'package:xstream_gate_pass_app/core/services/api/cms_error_translator.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_lookup_data_source.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';

class CmsInspectionStartSheetModel extends BaseViewModel {
  final CmsMasterFilesRepository _repository = locator<CmsMasterFilesRepository>();
  final CmsSessionService _cmsSessionService = locator<CmsSessionService>();

  CmsContainerInspectionBundle? _bundle;
  CmsSyncContext? _syncContext;
  CmsLookupDataSource<CmsConditionType>? _conditionDataSource;
  CmsConditionType? _selectedCondition;
  CmsInspectionStartMode _selectedMode = CmsInspectionStartMode.defaultMode;
  bool _modeLocked = false;
  String? _loadError;
  String? _validationMessage;
  int _conditionCount = 0;
  bool _hasInitialised = false;

  CmsContainerInspectionBundle? get bundle => _bundle;
  String? get loadError => _loadError;
  String? get validationMessage => _validationMessage;
  bool get hasBlockingError => _loadError != null;
  bool get hasConditionChoices => _conditionCount > 0;
  CmsInspectionStartMode get selectedMode => _selectedMode;
  List<CmsInspectionStartMode> get availableModes => <CmsInspectionStartMode>[
        CmsInspectionStartMode.defaultMode,
        CmsInspectionStartMode.structuralOnly,
        if (_bundle?.isReefer == true) CmsInspectionStartMode.mechanicalOnly,
      ];
  List<CmsContainerInspectionRow> get inspectionRows => _bundle?.visibleInspections ?? const <CmsContainerInspectionRow>[];
  String get inspectionTypeLabel => selectedMode.label;
  String get conditionHint => _selectedCondition?.displayName ?? 'Choose condition';
  int get conditionRequestItemCount => _conditionDataSource?.pageSize ?? 20;
  bool get canSubmit => !isBusy && !hasBlockingError && _bundle != null && _bundle!.canStartInspection && _selectedCondition?.id != null;

  bool get isModeLocked => _modeLocked;
  bool get showModeTiles => !_modeLocked;

  String get containerSummary {
    final containerTypeLine = [_bundle?.containerSize, _bundle?.containerType]
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join('/');
    final values = <String?>[
      _bundle?.transactionNo,
      _bundle?.shippingLineCode,
      containerTypeLine.isEmpty ? null : containerTypeLine,
    ].whereType<String>().map((value) => value.trim()).where((value) => value.isNotEmpty).toList(growable: false);

    return values.isEmpty ? 'Choose the start condition below.' : values.join(' • ');
  }

  String get selectedModeDescription => selectedMode.description;

  String get submitLabel => 'Start ${selectedMode.ctaLabel}';

  Future<void> initialise(CmsContainerInspectionBundle? bundle, {CmsInspectionStartMode? lockedMode}) async {
    if (_hasInitialised) {
      return;
    }

    _hasInitialised = true;
    _bundle = bundle;

    if (bundle == null) {
      _loadError = 'The selected inspection card could not be loaded.';
      rebuildUi();
      return;
    }

    if (!bundle.canStartInspection) {
      _loadError = 'This container already has an open inspection. Resume it from the list instead of starting a new one.';
      rebuildUi();
      return;
    }

    if (lockedMode != null && (lockedMode != CmsInspectionStartMode.mechanicalOnly || bundle.isReefer)) {
      _selectedMode = lockedMode;
      _modeLocked = true;
    }

    setBusy(true);

    try {
      final session = _cmsSessionService.getCached() ?? await _cmsSessionService.refreshFromServer(showLoader: false);
      final tenantId = session?.tenant?.id;
      final userId = session?.user?.id;

      if (tenantId == null || userId == null) {
        _loadError = 'Your CMS session is unavailable. Please sign in again.';
        return;
      }

      final syncContext = CmsSyncContext(
        tenantId: tenantId,
        userId: userId,
      );
      _syncContext = syncContext;
      _conditionDataSource = CmsLookupDataSource<CmsConditionType>(
        repository: _repository,
        store: CmsMasterFileStores.conditionTypes,
        context: syncContext,
        activeOnly: true,
      );

      final conditions = await _repository.getAll(
        CmsMasterFileStores.conditionTypes,
        syncContext,
        activeOnly: true,
      );
      _conditionCount = conditions.length;

      if (conditions.isEmpty) {
        _loadError = 'Condition types are not synced on this device yet. Run CMS sync and try again.';
      }
    } catch (error) {
      _loadError = CmsErrorTranslator.messageFrom(error);
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  Future<List<SearchableDropdownMenuItem<int>>> paginatedConditionRequest(
    int page,
    String? searchKey,
  ) async {
    final dataSource = _conditionDataSource;
    if (dataSource == null) {
      return const <SearchableDropdownMenuItem<int>>[];
    }

    return dataSource.paginatedRequest(page, searchKey);
  }

  void selectMode(CmsInspectionStartMode mode) {
    if (_modeLocked || _selectedMode == mode) {
      return;
    }

    _selectedMode = mode;
    _validationMessage = null;
    rebuildUi();
  }

  Future<void> selectCondition(int? value) async {
    final syncContext = _syncContext;
    if (syncContext == null || value == null) {
      _selectedCondition = null;
      rebuildUi();
      return;
    }

    _selectedCondition = await _repository.getById(
      CmsMasterFileStores.conditionTypes,
      syncContext,
      value,
    );
    _validationMessage = null;
    rebuildUi();
  }

  CmsStartInspectionInput? buildStartInput() {
    final bundle = _bundle;
    final conditionId = _selectedCondition?.id;

    if (bundle == null) {
      _validationMessage = 'This inspection card is missing the selected container bundle.';
      rebuildUi();
      return null;
    }

    if (conditionId == null) {
      _validationMessage = 'Choose a condition before you start the ${selectedMode.ctaLabel}.';
      rebuildUi();
      return null;
    }

    return CmsStartInspectionInput(
      containerId: bundle.containerId,
      mode: selectedMode,
      conditionTypeId: conditionId,
      conditionName: _selectedCondition?.name,
      conditionDisplayName: _selectedCondition?.displayName,
    );
  }
}
