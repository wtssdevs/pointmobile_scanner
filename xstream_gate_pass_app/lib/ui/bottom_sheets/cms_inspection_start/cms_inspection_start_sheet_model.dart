import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_condition_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspectable_container.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_start_inspection_input.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_lookup_data_source.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';

class CmsInspectionStartSheetModel extends BaseViewModel {
  final CmsMasterFilesRepository _repository =
      locator<CmsMasterFilesRepository>();
  final CmsSessionService _cmsSessionService = locator<CmsSessionService>();

  CmsInspectableContainer? _container;
  CmsSyncContext? _syncContext;
  CmsLookupDataSource<CmsConditionType>? _conditionDataSource;
  CmsConditionType? _selectedCondition;
  String? _loadError;
  String? _validationMessage;
  int _conditionCount = 0;
  bool _hasInitialised = false;

  CmsInspectableContainer? get container => _container;
  String? get loadError => _loadError;
  String? get validationMessage => _validationMessage;
  bool get hasBlockingError => _loadError != null;
  bool get hasConditionChoices => _conditionCount > 0;
  String get inspectionTypeLabel =>
      _container?.inspectionTypeLabel ?? 'Inspection';
  String get conditionHint =>
      _selectedCondition?.displayName ?? 'Choose condition';
  int get conditionRequestItemCount => _conditionDataSource?.pageSize ?? 20;
  bool get canSubmit =>
      !isBusy &&
      !hasBlockingError &&
      _container?.inspectionType != null &&
      _selectedCondition?.id != null;

  String? get currentConditionLabel {
    final label = _container?.conditionLabel.trim();
    if (label == null ||
        label.isEmpty ||
        label.toLowerCase() == 'condition pending') {
      return null;
    }

    return label;
  }

  String get containerSummary {
    final values = <String?>[
      _container?.transactionNo,
      _container?.shippingLineName,
    ]
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    return values.isEmpty
        ? 'Choose the start condition below.'
        : values.join(' • ');
  }

  Future<void> initialise(CmsInspectableContainer? container) async {
    if (_hasInitialised) {
      return;
    }

    _hasInitialised = true;
    _container = container;

    if (container == null) {
      _loadError = 'The selected inspection card could not be loaded.';
      rebuildUi();
      return;
    }

    if (container.inspectionType == null) {
      _loadError =
          'This inspection card is missing its inspection type. Refresh the list and try again.';
      rebuildUi();
      return;
    }

    setBusy(true);

    try {
      final session = _cmsSessionService.getCached() ??
          await _cmsSessionService.refreshFromServer(showLoader: false);
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
        _loadError =
            'Condition types are not synced on this device yet. Run CMS sync and try again.';
      }
    } catch (error) {
      _loadError = error.toString();
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
    final container = _container;
    final inspectionType = container?.inspectionType;
    final conditionId = _selectedCondition?.id;

    if (container == null || inspectionType == null) {
      _validationMessage =
          'This inspection card is missing a valid inspection type.';
      rebuildUi();
      return null;
    }

    if (conditionId == null) {
      _validationMessage =
          'Choose a condition before you start the ${inspectionType.label.toLowerCase()} inspection.';
      rebuildUi();
      return null;
    }

    return CmsStartInspectionInput(
      id: container.containerId,
      inspectionType: inspectionType,
      conditionTypeId: conditionId,
      conditionName: _selectedCondition?.name,
      conditionDisplayName: _selectedCondition?.displayName,
    );
  }
}
