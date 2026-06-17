import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/models/cms/account/cms_current_login_information.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_panel_definition.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_item_code.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/inspection_action.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/inspection_damage.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/inspection_item.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/inspection_location.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_lookup_data_source.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';

class CmsInspectionLineEditorSheetModel extends BaseViewModel {
  final log = getLogger('CmsInspectionLineEditorSheetModel');
  final CmsSessionService _cmsSessionService = locator<CmsSessionService>();
  final CmsMasterFilesRepository _cmsMasterFilesRepository =
      locator<CmsMasterFilesRepository>();

  final TextEditingController qtyController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController labourQtyController = TextEditingController();
  final TextEditingController labourRateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool _hasInitialised = false;
  bool _showAdvancedFields = false;
  bool _locationWasAutoSelected = false;
  String? _validationMessage;
  int? _shippingLineId;
  late CmsInspectionLineEdit _line;
  late CmsLookupDataSource<InspectionLocation> locationDataSource;
  late CmsLookupDataSource<InspectionItem> itemDataSource;
  late CmsLookupDataSource<InspectionAction> actionDataSource;
  late CmsLookupDataSource<InspectionDamage> damageDataSource;
  late CmsLookupDataSource<CmsItemCode> partNumberDataSource;

  CmsInspectionLineEdit get line => _line;
  String? get validationMessage => _validationMessage;
  bool get showAdvancedFields => _showAdvancedFields;
  bool get hasPanelContext => panelLabel != null;
  String? get panelLabel => CmsInspectionPanels.labelForCode(_line.panelCode);
  String get panelContextHelper => _locationWasAutoSelected
      ? 'We prefilled the closest inspection location. Change it below if the damage needs a more specific code.'
      : 'We filtered the location list to this panel. Pick the exact inspection location below.';
  double get quantityValue =>
      _parseDouble(qtyController.text) ?? _line.qty ?? 1;
  String get estimatedSubtotalLabel =>
      _line.estimatedSubtotal.toStringAsFixed(2);

  Future<void> initialise({
    CmsInspectionLineEdit? line,
    int? shippingLineId,
    String? initialPanelCode,
    double? initialPinX,
    double? initialPinY,
    List<String>? initialLocationMatchTerms,
  }) async {
    if (_hasInitialised) {
      return;
    }

    _hasInitialised = true;
    _shippingLineId = shippingLineId;
    _line = line?.clone() ??
        CmsInspectionLineEdit(qty: 1, cost: 0, labourQty: 0, labourRate: 0);
    _showAdvancedFields = (_line.cost ?? 0) > 0 ||
        (_line.labourQty ?? 0) > 0 ||
        (_line.labourRate ?? 0) > 0;
    _bindControllers();

    final session = _cmsSessionService.getCached();
    final context = _contextFromSession(session);

    locationDataSource = CmsLookupDataSource<InspectionLocation>(
      repository: _cmsMasterFilesRepository,
      store: CmsMasterFileStores.locations,
      context: context,
      shippingLineId: shippingLineId,
      filterByShippingLine: true,
    );
    itemDataSource = CmsLookupDataSource<InspectionItem>(
      repository: _cmsMasterFilesRepository,
      store: CmsMasterFileStores.items,
      context: context,
      shippingLineId: shippingLineId,
      filterByShippingLine: true,
    );
    actionDataSource = CmsLookupDataSource<InspectionAction>(
      repository: _cmsMasterFilesRepository,
      store: CmsMasterFileStores.actions,
      context: context,
      shippingLineId: shippingLineId,
      filterByShippingLine: true,
    );
    damageDataSource = CmsLookupDataSource<InspectionDamage>(
      repository: _cmsMasterFilesRepository,
      store: CmsMasterFileStores.damages,
      context: context,
      shippingLineId: shippingLineId,
      filterByShippingLine: true,
    );
    partNumberDataSource = CmsLookupDataSource<CmsItemCode>(
      repository: _cmsMasterFilesRepository,
      store: CmsMasterFileStores.itemCodes,
      context: context,
    );

    await _applyInitialPanelContext(
      initialPanelCode: initialPanelCode,
      initialPinX: initialPinX,
      initialPinY: initialPinY,
      initialLocationMatchTerms: initialLocationMatchTerms,
    );

    rebuildUi();
  }

  String get locationHint => _hintFor(_line.inspectionLocationCode,
      _line.inspectionLocationName, 'Select location');
  String get itemHint => _hintFor(
      _line.inspectionItemCode, _line.inspectionItemName, 'Select item');
  String get actionHint => _hintFor(
      _line.inspectionActionCode, _line.inspectionActionName, 'Select action');
  String get damageHint => _hintFor(
      _line.inspectionDamageCode, _line.inspectionDamageName, 'Select damage');
  String get partNumberHint {
    final value = _line.partNumber?.trim();
    return value == null || value.isEmpty ? 'Select part number' : value;
  }

  Future<void> selectLocation(int? id) async {
    final location = await _cmsMasterFilesRepository.getById(
        CmsMasterFileStores.locations, locationDataSource.context, id);
    _line.inspectionLocationId = location?.id;
    _line.inspectionLocationName = location?.name;
    _line.inspectionLocationCode = location?.code;
    _syncPanelMetadataFromLocation(location);
    _validationMessage = null;
    rebuildUi();
  }

  Future<void> selectItem(int? id) async {
    final item = await _cmsMasterFilesRepository.getById(
        CmsMasterFileStores.items, itemDataSource.context, id);
    _line.inspectionItemId = item?.id;
    _line.inspectionItemName = item?.name;
    _line.inspectionItemCode = item?.code;
    _validationMessage = null;
    rebuildUi();
  }

  Future<void> selectAction(int? id) async {
    final action = await _cmsMasterFilesRepository.getById(
        CmsMasterFileStores.actions, actionDataSource.context, id);
    _line.inspectionActionId = action?.id;
    _line.inspectionActionName = action?.name;
    _line.inspectionActionCode = action?.code;
    _validationMessage = null;
    rebuildUi();
  }

  Future<void> selectDamage(int? id) async {
    final damage = await _cmsMasterFilesRepository.getById(
        CmsMasterFileStores.damages, damageDataSource.context, id);
    _line.inspectionDamageId = damage?.id;
    _line.inspectionDamageName = damage?.name;
    _line.inspectionDamageCode = damage?.code;
    _validationMessage = null;
    rebuildUi();
  }

  Future<void> selectPartNumber(int? id) async {
    final itemCode = await _cmsMasterFilesRepository.getById(
        CmsMasterFileStores.itemCodes, partNumberDataSource.context, id);
    final code = itemCode?.code?.trim();
    _line.partNumber = code == null || code.isEmpty ? null : code;
    _validationMessage = null;
    rebuildUi();
  }

  void incrementQty() {
    _setQty(quantityValue + 1.0);
  }

  void decrementQty() {
    final nextValue = quantityValue <= 1 ? 1.0 : quantityValue - 1.0;
    _setQty(nextValue);
  }

  void toggleAdvancedFields() {
    _showAdvancedFields = !_showAdvancedFields;
    rebuildUi();
  }

  CmsInspectionLineEdit? buildResult() {
    _line.descriptionOne = descriptionController.text.trim();
    final partNumber = _line.partNumber?.trim();
    _line.partNumber =
        partNumber == null || partNumber.isEmpty ? null : partNumber;
    _line.qty = _parseDouble(qtyController.text);
    _line.cost = _parseDouble(costController.text);
    _line.labourQty = _parseDouble(labourQtyController.text);
    _line.labourRate = _parseDouble(labourRateController.text);
    _line.subTotal = _line.estimatedSubtotal;
    _line.total = _line.estimatedSubtotal;

    final matchedPanel = CmsInspectionPanels.matchLocation(
      code: _line.inspectionLocationCode,
      name: _line.inspectionLocationName,
    );
    if (matchedPanel != null) {
      _line.applyPanelMetadata(
        panelCode: _line.panelCode ?? matchedPanel.code,
        x: _line.panelX ?? matchedPanel.centerX,
        y: _line.panelY ?? matchedPanel.centerY,
      );
    }

    final validationMessage = _validate();
    if (validationMessage != null) {
      _validationMessage = validationMessage;
      rebuildUi();
      return null;
    }

    _validationMessage = null;
    return _line.clone();
  }

  @override
  void dispose() {
    qtyController.dispose();
    costController.dispose();
    labourQtyController.dispose();
    labourRateController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _bindControllers() {
    qtyController.text = (_line.qty ?? 1).toString();
    costController.text = (_line.cost ?? 0).toString();
    labourQtyController.text = (_line.labourQty ?? 0).toString();
    labourRateController.text = (_line.labourRate ?? 0).toString();
    descriptionController.text = _line.descriptionOne ?? '';
  }

  CmsSyncContext _contextFromSession(CmsCurrentLoginInformation? session) {
    return CmsSyncContext(
      tenantId: session?.tenant?.id ?? 0,
      userId: session?.user?.id ?? 0,
    );
  }

  String _hintFor(String? code, String? name, String fallback) {
    final display = [code, name]
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .join(' - ');
    return display.isEmpty ? fallback : display;
  }

  Future<void> _applyInitialPanelContext({
    String? initialPanelCode,
    double? initialPinX,
    double? initialPinY,
    List<String>? initialLocationMatchTerms,
  }) async {
    final panel =
        CmsInspectionPanels.byCode(initialPanelCode ?? _line.panelCode);
    if (panel == null) {
      return;
    }

    _line.applyPanelMetadata(
      panelCode: panel.code,
      x: initialPinX ?? _line.panelX ?? panel.centerX,
      y: initialPinY ?? _line.panelY ?? panel.centerY,
    );

    if (_line.inspectionLocationId != null) {
      return;
    }

    final resolution = await _resolvePanelLocation(
      preferredTerms: initialLocationMatchTerms,
    );

    final matchedLocation = resolution.location;
    if (matchedLocation != null) {
      // Single confident match -> auto-select it.
      _line.inspectionLocationId = matchedLocation.id;
      _line.inspectionLocationName = matchedLocation.name;
      _line.inspectionLocationCode = matchedLocation.code;
      _locationWasAutoSelected = true;
      return;
    }

    // 0 or several candidates -> don't guess. Seed the location dropdown's
    // search so it opens pre-filtered to this panel; the inspector confirms.
    locationDataSource.seedSearchTerm = resolution.seedTerm;
  }

  /// Resolves how the tapped panel's [preferredTerms] drive the location field:
  /// exactly one matching location is auto-selected; several matches only seed
  /// the dropdown search (so it opens pre-filtered) and leave the choice to the
  /// inspector; no match leaves both untouched. The loose panel-code reverse
  /// match is deliberately NOT used to auto-select, to avoid silent mis-matches.
  Future<_PanelLocationResolution> _resolvePanelLocation({
    List<String>? preferredTerms,
  }) async {
    final normalizedPreferredTerms = (preferredTerms ?? const <String>[])
        .map(_normalizeSearch)
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    if (normalizedPreferredTerms.isEmpty) {
      return const _PanelLocationResolution();
    }

    final locations = await _cmsMasterFilesRepository.getAll(
      CmsMasterFileStores.locations,
      locationDataSource.context,
      shippingLineId: _shippingLineId,
      filterByShippingLine: true,
    );
    if (locations.isEmpty) {
      return const _PanelLocationResolution();
    }

    final preferredMatches = locations
        .where((location) =>
            _locationMatchesAnyTerm(location, normalizedPreferredTerms))
        .toList(growable: false);
    if (preferredMatches.length == 1) {
      return _PanelLocationResolution(location: preferredMatches.first);
    }
    if (preferredMatches.length > 1) {
      return _PanelLocationResolution(
        seedTerm: _seedTermFor(normalizedPreferredTerms, locations),
      );
    }

    return const _PanelLocationResolution();
  }

  bool _locationMatchesAnyTerm(
    InspectionLocation location,
    List<String> normalizedTerms,
  ) {
    if (normalizedTerms.isEmpty) {
      return false;
    }

    final candidateTerms = [
      location.code,
      location.altCode,
      location.name,
    ].map(_normalizeSearch).where((value) => value.isNotEmpty);

    return candidateTerms.any(
      (candidate) => normalizedTerms.any(
        (term) => candidate == term || candidate.contains(term),
      ),
    );
  }

  /// First preferred term that matches at least one location, so the seeded
  /// dropdown search never opens on an empty list.
  String? _seedTermFor(
    List<String> normalizedTerms,
    List<InspectionLocation> locations,
  ) {
    for (final term in normalizedTerms) {
      final matches = locations
          .any((location) => _locationMatchesAnyTerm(location, [term]));
      if (matches) {
        return term;
      }
    }

    return null;
  }

  void _syncPanelMetadataFromLocation(InspectionLocation? location) {
    final matchedPanel = CmsInspectionPanels.matchLocation(
      code: location?.code,
      altCode: location?.altCode,
      name: location?.name,
    );
    if (matchedPanel == null) {
      return;
    }

    _line.applyPanelMetadata(
      panelCode: matchedPanel.code,
      x: _line.panelX ?? matchedPanel.centerX,
      y: _line.panelY ?? matchedPanel.centerY,
    );
  }

  void _setQty(double value) {
    final normalizedValue = value < 1 ? 1 : value;
    qtyController.text = normalizedValue % 1 == 0
        ? normalizedValue.toStringAsFixed(0)
        : normalizedValue.toStringAsFixed(2);
    _validationMessage = null;
    rebuildUi();
  }

  double? _parseDouble(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    return double.tryParse(value.trim());
  }

  String _normalizeSearch(String? value) {
    return (value ?? '')
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }

  String? _validate() {
    if (_line.inspectionLocationId == null) {
      return 'Location is required.';
    }
    if (_line.inspectionItemId == null) {
      return 'Item is required.';
    }
    if (_line.inspectionActionId == null) {
      return 'Action is required.';
    }
    if (_line.inspectionDamageId == null) {
      return 'Damage is required.';
    }
    if ((_line.qty ?? 0) <= 0) {
      return 'Quantity must be greater than zero.';
    }
    if ((_line.cost ?? 0) < 0) {
      return 'Cost cannot be negative.';
    }
    if ((_line.labourQty ?? 0) < 0) {
      return 'Labour quantity cannot be negative.';
    }
    if ((_line.labourRate ?? 0) < 0) {
      return 'Labour rate cannot be negative.';
    }

    return null;
  }
}

class _PanelLocationResolution {
  const _PanelLocationResolution({this.location, this.seedTerm});

  /// Single confident match to auto-select, or null when ambiguous/none.
  final InspectionLocation? location;

  /// Term to pre-filter the location dropdown when not auto-selecting.
  final String? seedTerm;
}
