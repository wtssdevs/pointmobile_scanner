import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/models/cms/account/cms_current_login_information.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_panel_definition.dart';
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
  final CmsMasterFilesRepository _cmsMasterFilesRepository = locator<CmsMasterFilesRepository>();

  final TextEditingController qtyController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController labourQtyController = TextEditingController();
  final TextEditingController labourRateController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController partNumberController = TextEditingController();

  bool _hasInitialised = false;
  bool _showAdvancedFields = false;
  String? _validationMessage;
  late CmsInspectionLineEdit _line;
  late CmsLookupDataSource<InspectionLocation> locationDataSource;
  late CmsLookupDataSource<InspectionItem> itemDataSource;
  late CmsLookupDataSource<InspectionAction> actionDataSource;
  late CmsLookupDataSource<InspectionDamage> damageDataSource;

  CmsInspectionLineEdit get line => _line;
  String? get validationMessage => _validationMessage;
  bool get showAdvancedFields => _showAdvancedFields;
  bool get hasPanelContext => panelLabel != null;
  String? get panelLabel => CmsInspectionPanels.labelForCode(_line.panelCode);
  double get quantityValue => _parseDouble(qtyController.text) ?? _line.qty ?? 1;
  String get estimatedSubtotalLabel => _line.estimatedSubtotal.toStringAsFixed(2);

  Future<void> initialise({
    CmsInspectionLineEdit? line,
    int? shippingLineId,
    String? initialPanelCode,
    double? initialPinX,
    double? initialPinY,
  }) async {
    if (_hasInitialised) {
      return;
    }

    _hasInitialised = true;
    _line = line?.clone() ?? CmsInspectionLineEdit(qty: 1, cost: 0, labourQty: 0, labourRate: 0);
    _showAdvancedFields = (_line.cost ?? 0) > 0 || (_line.labourQty ?? 0) > 0 || (_line.labourRate ?? 0) > 0;
    _bindControllers();

    final session = _cmsSessionService.getCached();
    final context = _contextFromSession(session);

    locationDataSource = CmsLookupDataSource<InspectionLocation>(
      repository: _cmsMasterFilesRepository,
      store: CmsMasterFileStores.locations,
      context: context,
    );
    itemDataSource = CmsLookupDataSource<InspectionItem>(
      repository: _cmsMasterFilesRepository,
      store: CmsMasterFileStores.items,
      context: context,
      shippingLineId: shippingLineId,
    );
    actionDataSource = CmsLookupDataSource<InspectionAction>(
      repository: _cmsMasterFilesRepository,
      store: CmsMasterFileStores.actions,
      context: context,
      shippingLineId: shippingLineId,
    );
    damageDataSource = CmsLookupDataSource<InspectionDamage>(
      repository: _cmsMasterFilesRepository,
      store: CmsMasterFileStores.damages,
      context: context,
      shippingLineId: shippingLineId,
    );

    await _applyInitialPanelContext(
      initialPanelCode: initialPanelCode,
      initialPinX: initialPinX,
      initialPinY: initialPinY,
    );

    rebuildUi();
  }

  String get locationHint => _hintFor(_line.inspectionLocationCode, _line.inspectionLocationName, 'Select location');
  String get itemHint => _hintFor(_line.inspectionItemCode, _line.inspectionItemName, 'Select item');
  String get actionHint => _hintFor(_line.inspectionActionCode, _line.inspectionActionName, 'Select action');
  String get damageHint => _hintFor(_line.inspectionDamageCode, _line.inspectionDamageName, 'Select damage');

  Future<void> selectLocation(int? id) async {
    final location = await _cmsMasterFilesRepository.getById(CmsMasterFileStores.locations, locationDataSource.context, id);
    _line.inspectionLocationId = location?.id;
    _line.inspectionLocationName = location?.name;
    _line.inspectionLocationCode = location?.code;
    _syncPanelMetadataFromLocation(location);
    _validationMessage = null;
    rebuildUi();
  }

  Future<void> selectItem(int? id) async {
    final item = await _cmsMasterFilesRepository.getById(CmsMasterFileStores.items, itemDataSource.context, id);
    _line.inspectionItemId = item?.id;
    _line.inspectionItemName = item?.name;
    _line.inspectionItemCode = item?.code;
    _validationMessage = null;
    rebuildUi();
  }

  Future<void> selectAction(int? id) async {
    final action = await _cmsMasterFilesRepository.getById(CmsMasterFileStores.actions, actionDataSource.context, id);
    _line.inspectionActionId = action?.id;
    _line.inspectionActionName = action?.name;
    _line.inspectionActionCode = action?.code;
    _validationMessage = null;
    rebuildUi();
  }

  Future<void> selectDamage(int? id) async {
    final damage = await _cmsMasterFilesRepository.getById(CmsMasterFileStores.damages, damageDataSource.context, id);
    _line.inspectionDamageId = damage?.id;
    _line.inspectionDamageName = damage?.name;
    _line.inspectionDamageCode = damage?.code;
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
    _line.partNumber = partNumberController.text.trim();
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
    partNumberController.dispose();
    super.dispose();
  }

  void _bindControllers() {
    qtyController.text = (_line.qty ?? 1).toString();
    costController.text = (_line.cost ?? 0).toString();
    labourQtyController.text = (_line.labourQty ?? 0).toString();
    labourRateController.text = (_line.labourRate ?? 0).toString();
    descriptionController.text = _line.descriptionOne ?? '';
    partNumberController.text = _line.partNumber ?? '';
  }

  CmsSyncContext _contextFromSession(CmsCurrentLoginInformation? session) {
    return CmsSyncContext(
      tenantId: session?.tenant?.id ?? 0,
      userId: session?.user?.id ?? 0,
    );
  }

  String _hintFor(String? code, String? name, String fallback) {
    final display = [code, name].whereType<String>().where((item) => item.isNotEmpty).join(' - ');
    return display.isEmpty ? fallback : display;
  }

  Future<void> _applyInitialPanelContext({
    String? initialPanelCode,
    double? initialPinX,
    double? initialPinY,
  }) async {
    final panel = CmsInspectionPanels.byCode(initialPanelCode ?? _line.panelCode);
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

    final matchedLocation = await _findLocationForPanel(panel);
    if (matchedLocation == null) {
      return;
    }

    _line.inspectionLocationId = matchedLocation.id;
    _line.inspectionLocationName = matchedLocation.name;
    _line.inspectionLocationCode = matchedLocation.code;
  }

  Future<InspectionLocation?> _findLocationForPanel(CmsInspectionPanelDefinition panel) async {
    final locations = await _cmsMasterFilesRepository.getAll(
      CmsMasterFileStores.locations,
      locationDataSource.context,
    );

    for (final location in locations) {
      final matchedPanel = CmsInspectionPanels.matchLocation(
        code: location.code,
        altCode: location.altCode,
        name: location.name,
      );
      if (matchedPanel?.code == panel.code) {
        return location;
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
    qtyController.text = normalizedValue % 1 == 0 ? normalizedValue.toStringAsFixed(0) : normalizedValue.toStringAsFixed(2);
    _validationMessage = null;
    rebuildUi();
  }

  double? _parseDouble(String value) {
    if (value.trim().isEmpty) {
      return null;
    }

    return double.tryParse(value.trim());
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
