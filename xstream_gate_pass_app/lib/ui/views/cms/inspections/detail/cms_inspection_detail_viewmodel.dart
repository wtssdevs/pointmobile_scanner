import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:sembast/timestamp.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.bottomsheets.dart';
import 'package:xstream_gate_pass_app/app/app.dialogs.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/enums/bckground_job_type.dart';
import 'package:xstream_gate_pass_app/core/enums/basic_dialog_status.dart';
import 'package:xstream_gate_pass_app/core/models/background_job_que/background_job_Info.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_complete_inspection_input.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_photo.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_panel_definition.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_repair_date_input.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_inspection_line_photo_queue_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_inspections_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/guid_generator.dart';

class CmsInspectionDetailViewModel extends BaseViewModel {
  final log = getLogger('CmsInspectionDetailViewModel');
  final CmsMobileInspectionsService _mobileInspectionsService =
      locator<CmsMobileInspectionsService>();
  final CmsInspectionLinePhotoQueueService _linePhotoQueueService =
      locator<CmsInspectionLinePhotoQueueService>();
  final WorkerQueManager _workerQueManager = locator<WorkerQueManager>();
  final BottomSheetService _bottomSheetService = locator<BottomSheetService>();
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final TextEditingController commentsController = TextEditingController();

  CmsInspectionEdit? _inspection;
  String? _errorMessage;
  bool _hasLoaded = false;
  bool _shouldRefreshOnExit = false;
  String _cleanSnapshot = '';
  int? _lastInspectionId;
  int? _lastContainerId;
  Map<String, List<CmsInspectionLinePhoto>> _linePhotos = const {};

  CmsInspectionEdit? get inspection => _inspection;
  String? get errorMessage => _errorMessage;
  bool get hasInspection => _inspection != null;
  bool get hasUnsavedChanges => hasInspection && _snapshot() != _cleanSnapshot;
  bool get hasLineItems => (_inspection?.items.isNotEmpty ?? false);
  bool get canEdit => hasInspection && !isBusy;
  int get totalPanelCount => CmsInspectionPanels.values.length;

  int get coveredPanelCount {
    if (_inspection == null) {
      return 0;
    }

    final coveredPanels = <String>{};
    for (final line in _inspection!.items) {
      final panelCode = CmsInspectionPanels.fromLine(line)?.code;
      if (panelCode != null) {
        coveredPanels.add(panelCode);
      }
    }

    return coveredPanels.length;
  }

  String get coverageSummary =>
      '$coveredPanelCount / $totalPanelCount panels touched';

  int photoCountForLine(CmsInspectionLineEdit line) =>
      _linePhotos[_lineKey(line)]?.length ?? 0;

  bool isCapturingLinePhoto(int index) => busy('line-photo-$index');

  String? photoStatusForLine(CmsInspectionLineEdit line) {
    final photos =
        _linePhotos[_lineKey(line)] ?? const <CmsInspectionLinePhoto>[];
    if (photos.isEmpty) {
      return null;
    }

    final failedCount = photos
        .where((photo) => photo.state == CmsInspectionLinePhotoState.failed)
        .length;
    if (failedCount > 0) {
      return '$failedCount upload issue${failedCount == 1 ? '' : 's'}';
    }

    final awaitingSaveCount = photos
        .where(
            (photo) => photo.state == CmsInspectionLinePhotoState.awaitingSave)
        .length;
    if (awaitingSaveCount > 0) {
      return '$awaitingSaveCount waiting for save${awaitingSaveCount == 1 ? '' : 's'}';
    }

    final pendingCount = photos
        .where((photo) =>
            photo.state == CmsInspectionLinePhotoState.local ||
            photo.state == CmsInspectionLinePhotoState.queued)
        .length;
    if (pendingCount > 0) {
      return '$pendingCount pending upload${pendingCount == 1 ? '' : 's'}';
    }

    final uploadingCount = photos
        .where((photo) => photo.state == CmsInspectionLinePhotoState.uploading)
        .length;
    if (uploadingCount > 0) {
      return 'Uploading $uploadingCount';
    }

    return '${photos.length} uploaded';
  }

  String get schematicContainerLabel {
    final values = <String?>[
      _inspection?.containerSize,
      _inspection?.containterType,
      if (_inspection?.isRfContainer == true) 'RF',
    ]
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    return values.isEmpty ? headerTitle() : values.join(' • ');
  }

  Future<void> runStartupLogic({
    int? inspectionId,
    int? containerId,
  }) async {
    if (_hasLoaded) {
      return;
    }

    _hasLoaded = true;
    _lastInspectionId = inspectionId;
    _lastContainerId = containerId;
    setBusy(true);

    try {
      final loaded = inspectionId != null
          ? await _mobileInspectionsService.getInspectionForEdit(inspectionId)
          : await _mobileInspectionsService.startInspection(containerId ?? 0);
      _applyInspection(loaded, markClean: true);
      await _refreshLinePhotos();
    } catch (error) {
      log.e('Failed to load CMS inspection detail', error);
      _errorMessage = error.toString();
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  Future<void> reload() async {
    _hasLoaded = false;
    await runStartupLogic(
      inspectionId: _lastInspectionId,
      containerId: _lastContainerId,
    );
  }

  void setInspectionDateTime(DateTime value) {
    if (_inspection == null) {
      return;
    }

    _inspection!.inspectionDateTime = value;
    rebuildUi();
  }

  void setInspectionDateTimeToNow() {
    setInspectionDateTime(DateTime.now());
  }

  void updateComments(String value) {
    if (_inspection == null) {
      return;
    }

    _inspection!.comments = value;
  }

  Future<void> addLine() async {
    await _openLineEditor();
  }

  Future<void> addLineFromPanel(CmsInspectionPanelTapDetails details) async {
    await _openLineEditor(
      initialPanelCode: details.code,
      initialPinX: details.x,
      initialPinY: details.y,
      title: 'Add ${details.label.toLowerCase()} damage',
      description:
          'We prefilled the tapped panel. You can still refine the exact inspection location below.',
    );
  }

  Future<void> editLine(int index) async {
    if (_inspection == null ||
        index < 0 ||
        index >= _inspection!.items.length) {
      return;
    }

    await _openLineEditor(index: index);
  }

  Future<void> duplicateLine(int index) async {
    if (_inspection == null ||
        index < 0 ||
        index >= _inspection!.items.length) {
      return;
    }

    final draftLine = _inspection!.items[index].clone()
      ..id = 0
      ..clientKey = Guid.newGuidAsString;
    await _openLineEditor(
      draftLine: draftLine,
      title: 'Duplicate inspection line',
      description:
          'Start from the copied damage line, then tweak what changed.',
    );
  }

  void deleteLine(int index) {
    if (_inspection == null ||
        index < 0 ||
        index >= _inspection!.items.length) {
      return;
    }

    _inspection!.items.removeAt(index);
    rebuildUi();
  }

  Future<void> saveDraft() async {
    if (_inspection == null) {
      return;
    }

    setBusy(true);
    _errorMessage = null;

    try {
      _inspection!.comments = commentsController.text;
      _ensureClientKeys();
      final saved =
          await _mobileInspectionsService.saveInspection(_inspection!.clone());
      await _linePhotoQueueService.remapSavedLines(saved);
      await _enqueuePhotoUpload(saved.id);
      _shouldRefreshOnExit = true;
      _applyInspection(saved, markClean: true);
      await _refreshLinePhotos();
    } catch (error) {
      log.e('Failed to save CMS inspection draft', error);
      _errorMessage = error.toString();
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  Future<void> completeInspection() async {
    if (_inspection == null) {
      return;
    }

    setBusy(true);
    _errorMessage = null;

    try {
      _inspection!.comments = commentsController.text;
      await _enqueuePhotoUpload(_inspection!.id);
      await _refreshLinePhotos();
      final completed = await _mobileInspectionsService.completeInspection(
        CmsCompleteInspectionInput(
          inspectionId: _inspection!.id,
          comments: _inspection!.comments,
          inspectionDateTime: _inspection!.inspectionDateTime,
        ),
      );

      _shouldRefreshOnExit = true;
      _applyInspection(completed, markClean: true);
      await _refreshLinePhotos();
      _navigationService.back(result: true);
    } catch (error) {
      log.e('Failed to complete CMS inspection', error);
      _errorMessage = error.toString();
      setBusy(false);
      rebuildUi();
      return;
    }
  }

  Future<void> setRepairStartNow() async {
    await _setRepairDatesNow(
      const CmsRepairDateInput(
        inspectionId: 0,
        setStart: true,
      ),
    );
  }

  Future<void> setRepairCompleteNow() async {
    await _setRepairDatesNow(
      const CmsRepairDateInput(
        inspectionId: 0,
        setComplete: true,
      ),
    );
  }

  Future<bool> onWillPop() async {
    if (hasUnsavedChanges) {
      final shouldDiscard = await _confirmDiscardChanges();
      if (!shouldDiscard) {
        return false;
      }
    }

    _navigationService.back(result: _shouldRefreshOnExit);
    return false;
  }

  String headerTitle() => _inspection?.containerNo ?? 'Inspection';

  String headerSubtitle() {
    final values = <String?>[
      _inspection?.transactionNo,
      _inspection?.shippingLineName,
      _inspection?.conditionName,
    ]
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    return values.isEmpty ? 'Container inspection detail' : values.join(' • ');
  }

  Future<void> captureLinePhoto(int index, {bool fromGallery = false}) async {
    if (_inspection == null ||
        index < 0 ||
        index >= _inspection!.items.length) {
      return;
    }
    if (isCapturingLinePhoto(index)) {
      return;
    }

    final line = _inspection!.items[index];
    _ensureClientKey(line);
    setBusyForObject('line-photo-$index', true);
    _errorMessage = null;

    try {
      final photo = await _linePhotoQueueService.capturePhotoForLine(
        inspectionId: _inspection!.id,
        line: line,
        fromGallery: fromGallery,
      );
      if (photo != null && line.id > 0) {
        await _enqueuePhotoUpload(_inspection!.id);
      }
      await _refreshLinePhotos();
    } catch (error) {
      log.e('Failed to capture CMS inspection line photo', error);
      _errorMessage = error.toString();
    } finally {
      setBusyForObject('line-photo-$index', false);
      rebuildUi();
    }
  }

  Future<void> _openLineEditor({
    int? index,
    CmsInspectionLineEdit? draftLine,
    String? initialPanelCode,
    double? initialPinX,
    double? initialPinY,
    String? title,
    String? description,
  }) async {
    if (_inspection == null) {
      return;
    }

    final response = await _bottomSheetService
        .showCustomSheet<CmsInspectionLineEdit?, Map<String, dynamic>>(
      variant: BottomSheetType.cmsInspectionLineEditor,
      title: title ??
          (index == null ? 'Add inspection line' : 'Edit inspection line'),
      description: description ??
          'Choose the inspection lookup values and capture the damaged component details.',
      barrierDismissible: false,
      isScrollControlled: true,
      data: {
        'line': draftLine ?? (index == null ? null : _inspection!.items[index]),
        'shippingLineId': _inspection!.shippingLineId,
        'initialPanelCode': initialPanelCode,
        'initialPinX': initialPinX,
        'initialPinY': initialPinY,
      },
    );

    if (response?.confirmed != true || response?.data == null) {
      return;
    }

    if (index == null) {
      final line = response!.data!;
      _ensureClientKey(line);
      _inspection!.items.add(line);
    } else {
      final line = response!.data!;
      _ensureClientKey(line);
      _inspection!.items[index] = line;
    }

    rebuildUi();
  }

  Future<void> _setRepairDatesNow(CmsRepairDateInput input) async {
    if (_inspection == null) {
      return;
    }

    setBusy(true);
    _errorMessage = null;

    try {
      final refreshed = await _mobileInspectionsService.setRepairDatesNow(
        CmsRepairDateInput(
          inspectionId: _inspection!.id,
          setStart: input.setStart,
          setComplete: input.setComplete,
        ),
      );
      _shouldRefreshOnExit = true;
      _applyInspection(refreshed, markClean: true);
    } catch (error) {
      log.e('Failed to update CMS inspection repair dates', error);
      _errorMessage = error.toString();
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  void _applyInspection(CmsInspectionEdit inspection,
      {required bool markClean}) {
    _inspection = inspection.clone();
    for (final line in _inspection!.items) {
      line.inspectionId ??= _inspection!.id;
    }
    commentsController.text = _inspection?.comments ?? '';
    _errorMessage = null;
    if (markClean) {
      _cleanSnapshot = _snapshot();
    }
  }

  Future<void> _refreshLinePhotos() async {
    if (_inspection == null) {
      _linePhotos = const {};
      return;
    }

    final nextPhotos = <String, List<CmsInspectionLinePhoto>>{};
    for (final line in _inspection!.items) {
      nextPhotos[_lineKey(line)] =
          await _linePhotoQueueService.getForLine(line);
    }

    _linePhotos = nextPhotos;
  }

  Future<void> _enqueuePhotoUpload(int inspectionId) async {
    if (inspectionId <= 0) {
      return;
    }

    final now = Timestamp.now();
    await _workerQueManager.enqueSingle(
      BackgroundJobInfo(
        id: '',
        jobArgs: inspectionId,
        lastTryTime: now,
        nextTryTime: now,
        creationTime: now,
        isAbandoned: false,
        jobType: BackgroundJobType.syncCmsInspectionLinePhotos.index,
      ),
    );
  }

  void _ensureClientKeys() {
    if (_inspection == null) {
      return;
    }

    for (final line in _inspection!.items) {
      _ensureClientKey(line);
    }
  }

  void _ensureClientKey(CmsInspectionLineEdit line) {
    if (line.id > 0) {
      return;
    }

    final existingClientKey = line.clientKey?.trim();
    if (existingClientKey == null || existingClientKey.isEmpty) {
      line.clientKey = Guid.newGuidAsString;
    }
  }

  String _lineKey(CmsInspectionLineEdit line) {
    if (line.id > 0) {
      return 'id:${line.id}';
    }

    return 'client:${line.clientKey ?? ''}';
  }

  String _snapshot() {
    if (_inspection == null) {
      return '';
    }

    _inspection!.comments = commentsController.text;
    return jsonEncode(_inspection!.toJson());
  }

  Future<bool> _confirmDiscardChanges() async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      data: BasicDialogStatus.warning,
      title: 'Discard inspection changes?',
      description:
          'You have unsaved inspection changes. Leave this screen and lose them?',
      mainButtonTitle: 'Discard',
      secondaryButtonTitle: 'Keep editing',
    );

    return response?.confirmed == true;
  }

  @override
  void dispose() {
    commentsController.dispose();
    super.dispose();
  }
}
