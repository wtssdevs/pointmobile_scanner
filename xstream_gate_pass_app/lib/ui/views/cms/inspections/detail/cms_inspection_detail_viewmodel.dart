import 'dart:collection';
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
import 'package:xstream_gate_pass_app/core/enums/cms_inspection_state.dart';
import 'package:xstream_gate_pass_app/core/models/background_job_que/background_job_Info.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_photo.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_panel_definition.dart';
import 'package:xstream_gate_pass_app/core/services/api/cms_error_translator.dart';
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
  bool _isHandlingBackNavigation = false;
  String _cleanSnapshot = '';
  int? _lastInspectionId;
  int? _lastContainerId;
  Map<String, List<CmsInspectionLinePhoto>> _linePhotos = const {};
  CmsInspectionPanelTapDetails? _selectedPanelTapDetails;

  static const double _majorCostThreshold = 500;

  CmsInspectionEdit? get inspection => _inspection;
  String? get errorMessage => _errorMessage;
  bool get hasInspection => _inspection != null;
  bool get hasUnsavedChanges => hasInspection && _snapshot() != _cleanSnapshot;
  bool get hasLineItems => (_inspection?.items.isNotEmpty ?? false);
  bool get isCancelled => _inspection?.state == CmsInspectionState.cancelled;
  bool get canEdit => hasInspection && !isBusy && !isCancelled;
  bool get canCancel =>
      hasInspection &&
      !isBusy &&
      !isCancelled &&
      _inspection?.inspectionCompleted != true &&
      (_inspection?.id ?? 0) > 0;
  int get totalPanelCount => CmsInspectionPanels.values.length;
  String? get selectedPanelCode => _selectedPanelTapDetails?.code;
  CmsInspectionPanelDefinition? get selectedPanel =>
      _selectedPanelTapDetails?.panel;
  bool get hasRequiredStartMetadata =>
      _inspection?.inspectionType != null &&
      _inspection?.conditionTypeId != null;

  String? get startMetadataWarning {
    if (!hasInspection || hasRequiredStartMetadata) {
      return null;
    }

    return 'This inspection is missing its inspection type or condition. Go back to the list and start it again from the correct inspection card.';
  }

  int get unclassifiedLineCount {
    if (_inspection == null) {
      return 0;
    }

    return _inspection!.items.where(lineNeedsClassification).length;
  }

  bool get hasUnclassifiedLines => unclassifiedLineCount > 0;

  String get unclassifiedLineWarning => unclassifiedLineCount == 1
      ? '1 quick-photo line still needs classification before this inspection can be saved or completed.'
      : '$unclassifiedLineCount quick-photo lines still need classification before this inspection can be saved or completed.';

  int get coveredPanelCount {
    if (_inspection == null) {
      return 0;
    }

    final coveredPanels = <String>{};
    for (final line in _inspection!.items) {
      final panel = CmsInspectionPanels.fromLine(line);
      if (panel?.isPrimary == true) {
        coveredPanels.add(panel!.code);
      }
    }

    return coveredPanels.length;
  }

  String get coverageSummary =>
      '$coveredPanelCount / $totalPanelCount panels touched';

  CmsPanelCoverage coverageFor(String panelCode) {
    if (_inspection == null) {
      return const CmsPanelCoverage.pending();
    }

    var lineCount = 0;
    var unclassifiedCount = 0;
    var hasMajor = false;

    for (final line in _inspection!.items) {
      final panel = CmsInspectionPanels.fromLine(line);
      if (panel?.code != panelCode) {
        continue;
      }

      lineCount++;
      if (lineNeedsClassification(line)) {
        unclassifiedCount++;
      }
      // HEURISTIC: replace with a real severity field once CMS exposes one.
      if ((line.cost ?? 0) >= _majorCostThreshold) {
        hasMajor = true;
      }
    }

    if (lineCount == 0) {
      return const CmsPanelCoverage.pending();
    }

    return CmsPanelCoverage(
      lineCount: lineCount,
      unclassifiedLineCount: unclassifiedCount,
      severity: hasMajor ? CmsPanelSeverity.major : CmsPanelSeverity.minor,
    );
  }

  bool lineNeedsClassification(CmsInspectionLineEdit line) =>
      !line.hasRequiredClassification;

  List<CmsInspectionHeaderFact> get containerHeaderFacts {
    final facts = <CmsInspectionHeaderFact>[];
    void addFact(String label, String? value) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) {
        return;
      }

      facts.add(CmsInspectionHeaderFact(label: label, value: trimmed));
    }

    addFact('Size', _inspection?.containerSize);
    addFact('Type', _inspection?.containterType);
    addFact('ISO', _inspection?.containerIsoType);
    if (_inspection?.isRfContainer == true) {
      facts.add(const CmsInspectionHeaderFact(label: 'RF', value: 'Yes'));
    }

    return facts;
  }

  String get inspectionStatusLabel {
    final state = _inspection?.state;
    if (state != null) {
      return state.label;
    }

    final status = _firstNonEmpty([_inspection?.displayStatus]);
    if (status != null) {
      return _formatStatus(status);
    }

    return _inspection?.inspectionCompleted == true
        ? 'Completed'
        : 'In progress';
  }

  String get inspectionTimingTitle {
    if (_inspection == null) {
      return 'Inspection timing';
    }

    if (_inspection!.inspectionCompleted) {
      return 'Completed at';
    }

    if (_inspection!.inspectionDateTime == null) {
      return 'Inspection started';
    }

    return 'Inspection in progress since';
  }

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
      if (inspectionId == null) {
        _errorMessage =
            'Start inspections from the list so you can choose the inspection type and condition first.';
        return;
      }

      final loaded =
          await _mobileInspectionsService.getInspectionForEdit(inspectionId);
      _applyInspection(loaded, markClean: true);
      await _refreshLinePhotos();
    } catch (error) {
      log.e('Failed to load CMS inspection detail', error);
      _errorMessage = CmsErrorTranslator.messageFrom(error);
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

  void selectPanelFromMap(CmsInspectionPanelTapDetails details) {
    _selectedPanelTapDetails = details;
    rebuildUi();
  }

  Future<void> addLineFromSelectedPanel() async {
    final details = _selectedPanelTapDetails;
    if (details == null) {
      return;
    }

    await addLineFromPanel(details);
  }

  Future<void> addLineFromPanel(CmsInspectionPanelTapDetails details) async {
    await _openLineEditor(
      initialPanelCode: details.code,
      initialPinX: details.x,
      initialPinY: details.y,
      initialLocationMatchTerms: details.locationMatchTerms,
      title: 'Add ${details.label.toLowerCase()} damage',
      description:
          'We prefilled the tapped panel. You can still refine the exact inspection location below.',
    );
  }

  Future<void> capturePhotoFromSelectedPanel() async {
    final details = _selectedPanelTapDetails;
    if (details == null) {
      return;
    }

    await captureLineFromPanel(details);
  }

  Future<void> captureLineFromPanel(
      CmsInspectionPanelTapDetails details) async {
    if (_inspection == null || isBusy) {
      return;
    }

    final draftLine = CmsInspectionLineEdit(
      id: 0,
      clientKey: Guid.newGuidAsString,
      inspectionId: _inspection!.id,
      qty: 1,
      cost: 0,
      labourQty: 0,
      labourRate: 0,
      inspectionLocationCode: details.panel.cedexPrefix,
      inspectionLocationName: details.fullLabel,
    )..applyPanelMetadata(
        panelCode: details.code,
        x: details.x,
        y: details.y,
      );

    final insertIndex = _inspection!.items.length;
    _inspection!.items.add(draftLine);
    rebuildUi();

    final captured = await captureLinePhoto(insertIndex);
    if (captured) {
      return;
    }

    if (insertIndex < _inspection!.items.length &&
        _inspection!.items[insertIndex].clientKey == draftLine.clientKey) {
      _inspection!.items.removeAt(insertIndex);
      await _refreshLinePhotos();
      rebuildUi();
    }
  }

  Future<void> editLine(int index) async {
    if (_inspection == null ||
        index < 0 ||
        index >= _inspection!.items.length) {
      return;
    }

    await _openLineEditor(index: index);
  }

  Future<void> editLineFromMarker(CmsInspectionLineEdit line) async {
    if (_inspection == null) {
      return;
    }

    final index = _inspection!.items.indexWhere((candidate) {
      if (line.id > 0 && candidate.id == line.id) {
        return true;
      }

      final lineClientKey = line.clientKey?.trim();
      return lineClientKey != null &&
          lineClientKey.isNotEmpty &&
          candidate.clientKey == lineClientKey;
    });

    if (index < 0) {
      return;
    }

    await editLine(index);
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

  Future<void> deleteLine(int index) async {
    if (_inspection == null ||
        index < 0 ||
        index >= _inspection!.items.length) {
      return;
    }

    final line = _inspection!.items[index];
    final photos = await _linePhotoQueueService.getForLine(line);
    for (final photo in photos) {
      await _removeLinePhotoRow(photo);
    }

    _inspection!.items.removeAt(index);
    await _refreshLinePhotos();
    rebuildUi();
  }

  Future<void> saveDraft() async {
    if (_inspection == null) {
      return;
    }

    if (!hasRequiredStartMetadata) {
      _errorMessage = startMetadataWarning;
      rebuildUi();
      return;
    }

    if (hasUnclassifiedLines) {
      _errorMessage = unclassifiedLineWarning;
      rebuildUi();
      return;
    }

    setBusy(true);
    _errorMessage = null;

    try {
      _inspection!.comments = commentsController.text;
      _ensureClientKeys();
      _ensureLineInspectionIds();
      final saved =
          await _mobileInspectionsService.saveInspection(_inspection!.clone());
      final mergedSaved = _restoreClientKeys(
        source: _inspection!,
        saved: saved,
      );
      await _linePhotoQueueService.remapSavedLines(mergedSaved);
      await _sweepOrphanedPhotos(mergedSaved);
      await _enqueuePhotoUpload(mergedSaved.id);
      _shouldRefreshOnExit = true;
      _applyInspection(mergedSaved, markClean: true);
      await _refreshLinePhotos();
    } catch (error) {
      log.e('Failed to save CMS inspection draft', error);
      _errorMessage = CmsErrorTranslator.messageFrom(error);
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  Future<void> completeInspection() async {
    if (_inspection == null) {
      return;
    }

    if (!hasRequiredStartMetadata) {
      _errorMessage = startMetadataWarning;
      rebuildUi();
      return;
    }

    if (hasUnclassifiedLines) {
      _errorMessage = unclassifiedLineWarning;
      rebuildUi();
      return;
    }

    final confirmed = await _confirmCompletion();
    if (!confirmed) {
      return;
    }

    setBusy(true);
    _errorMessage = null;

    try {
      _inspection!.comments = commentsController.text;
      _ensureClientKeys();
      _ensureLineInspectionIds();
      final completionPayload = _inspection!.clone()
        ..inspectionCompleted = true
        ..inspectionDateTime ??= DateTime.now();
      final completed =
          await _mobileInspectionsService.saveInspection(completionPayload);
      final mergedCompleted = _restoreClientKeys(
        source: _inspection!,
        saved: completed,
      );
      await _linePhotoQueueService.remapSavedLines(mergedCompleted);
      await _sweepOrphanedPhotos(mergedCompleted);
      await _enqueuePhotoUpload(mergedCompleted.id);
      await _refreshLinePhotos();

      _shouldRefreshOnExit = true;
      _applyInspection(mergedCompleted, markClean: true);
      await _refreshLinePhotos();
      _navigationService.back(result: true);
    } catch (error) {
      log.e('Failed to complete CMS inspection', error);
      _errorMessage = CmsErrorTranslator.messageFrom(error);
      setBusy(false);
      rebuildUi();
      return;
    }
  }

  /// Cancels an inspection started in error. Confirms first, then calls the CMS cancel
  /// endpoint and leaves the screen returning `true` so the container detail refreshes.
  ///
  /// Returns via [NavigationService.back] directly (like [completeInspection]) so the
  /// unsaved-changes [onWillPop] discard prompt does not also fire on the explicit
  /// destructive action.
  Future<void> cancelInspection() async {
    if (!canCancel) {
      return;
    }

    final confirmed = await _confirmCancel();
    if (!confirmed) {
      return;
    }

    setBusy(true);
    _errorMessage = null;

    try {
      await _mobileInspectionsService.cancelInspection(_inspection!.id);
      _shouldRefreshOnExit = true;
      _navigationService.back(result: true);
    } catch (error) {
      log.e('Failed to cancel CMS inspection', error);
      _errorMessage = CmsErrorTranslator.messageFrom(error);
      setBusy(false);
      rebuildUi();
    }
  }

  Future<bool> onWillPop() async {
    if (_isHandlingBackNavigation) {
      return false;
    }

    _isHandlingBackNavigation = true;

    if (hasUnsavedChanges) {
      final shouldDiscard = await _confirmDiscardChanges();
      if (!shouldDiscard) {
        _isHandlingBackNavigation = false;
        return false;
      }
    }

    await Future<void>.delayed(Duration.zero);
    _navigationService.back(result: _shouldRefreshOnExit);
    return false;
  }

  String headerTitle() => _inspection?.containerNo ?? 'Inspection';

  String headerSubtitle() {
    final values = <String?>[
      _inspection?.transactionNo,
      _inspection?.shippingLineName,
      _inspection?.inspectionTypeLabel,
    ]
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toList(growable: false);

    return values.isEmpty ? 'Container inspection detail' : values.join(' • ');
  }

  Future<bool> captureLinePhoto(int index, {bool fromGallery = false}) async {
    if (_inspection == null ||
        index < 0 ||
        index >= _inspection!.items.length) {
      return false;
    }
    if (isCapturingLinePhoto(index)) {
      return false;
    }

    final line = _inspection!.items[index];
    _ensureClientKey(line);
    setBusyForObject('line-photo-$index', true);
    _errorMessage = null;
    var capturedPhoto = false;

    try {
      final photo = await _linePhotoQueueService.capturePhotoForLine(
        inspectionId: _inspection!.id,
        line: line,
        fromGallery: fromGallery,
      );
      capturedPhoto = photo != null;
      if (photo != null && line.id > 0) {
        await _enqueuePhotoUpload(_inspection!.id);
      }
      await _refreshLinePhotos();
    } catch (error) {
      log.e('Failed to capture CMS inspection line photo', error);
      _errorMessage = CmsErrorTranslator.messageFrom(error);
    } finally {
      setBusyForObject('line-photo-$index', false);
      rebuildUi();
    }

    return capturedPhoto;
  }

  Future<void> _openLineEditor({
    int? index,
    CmsInspectionLineEdit? draftLine,
    String? initialPanelCode,
    double? initialPinX,
    double? initialPinY,
    List<String>? initialLocationMatchTerms,
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
        'initialLocationMatchTerms': initialLocationMatchTerms,
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

  void _applyInspection(CmsInspectionEdit inspection,
      {required bool markClean}) {
    _inspection = inspection.clone();
    _lastInspectionId = _inspection?.id;
    _lastContainerId = _inspection?.containerId;
    _defaultInspectionDateTime(_inspection!);
    for (final line in _inspection!.items) {
      line.inspectionId ??= _inspection!.id;
    }
    final selectedPanel = CmsInspectionPanels.byCode(selectedPanelCode);
    if (selectedPanel?.isPrimary != true) {
      _selectedPanelTapDetails = _firstPrimaryPanelTapDetails();
    }
    commentsController.text = _inspection?.comments ?? '';
    _errorMessage = null;
    if (markClean) {
      _cleanSnapshot = _snapshot();
    }
  }

  CmsInspectionPanelTapDetails? _firstPrimaryPanelTapDetails() {
    final inspection = _inspection;
    if (inspection == null) {
      return null;
    }

    for (final line in inspection.items) {
      final panel = CmsInspectionPanels.fromLine(line);
      if (panel?.isPrimary == true) {
        return CmsInspectionPanelTapDetails(
          panel: panel!,
          x: line.panelX ?? panel.centerX,
          y: line.panelY ?? panel.centerY,
        );
      }
    }

    return null;
  }

  void _defaultInspectionDateTime(CmsInspectionEdit inspection) {
    if (inspection.inspectionDateTime != null ||
        inspection.inspectionCompleted) {
      return;
    }

    inspection.inspectionDateTime = DateTime.now();
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

  Future<void> _sweepOrphanedPhotos(CmsInspectionEdit saved) async {
    final photos = await _linePhotoQueueService.getForInspection(saved.id);
    if (photos.isEmpty) {
      return;
    }

    final savedLineIds =
        saved.items.where((line) => line.id > 0).map((line) => line.id).toSet();
    final savedClientKeys = saved.items
        .map((line) => line.clientKey?.trim())
        .whereType<String>()
        .where((key) => key.isNotEmpty)
        .toSet();

    for (final photo in photos) {
      final matchesId = photo.inspectionLineId != null &&
          savedLineIds.contains(photo.inspectionLineId);
      final photoClientKey = photo.clientKey?.trim();
      final matchesClientKey = photoClientKey != null &&
          photoClientKey.isNotEmpty &&
          savedClientKeys.contains(photoClientKey);
      if (!matchesId && !matchesClientKey) {
        await _removeLinePhotoRow(photo);
      }
    }
  }

  Future<void> _removeLinePhotoRow(CmsInspectionLinePhoto photo) async {
    final isServerConfirmed =
        photo.state == CmsInspectionLinePhotoState.uploaded &&
            (photo.documentId ?? 0) > 0;
    if (isServerConfirmed) {
      await _linePhotoQueueService.removeLocalOnly(photo.clientUploadId);
    } else {
      await _linePhotoQueueService.deletePhoto(photo);
    }
  }

  Future<void> _enqueuePhotoUpload(int inspectionId) async {
    if (inspectionId <= 0) {
      return;
    }

    final photos = await _linePhotoQueueService.getForInspection(inspectionId);
    final hasPendingUpload = photos
        .any((photo) => photo.state != CmsInspectionLinePhotoState.uploaded);
    if (!hasPendingUpload) {
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

  /// Backend `InspectionItemsDto.InspectionId` is a non-nullable `long`; a line
  /// posted with `inspectionId: null` fails JSON deserialization with HTTP 400.
  /// Lines added in-session (panel tap or line editor) start null, so stamp the
  /// parent id (0 for a not-yet-saved inspection) before every save.
  void _ensureLineInspectionIds() {
    if (_inspection == null) {
      return;
    }

    final parentId = _inspection!.id;
    for (final line in _inspection!.items) {
      line.inspectionId ??= parentId;
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

  CmsInspectionEdit _restoreClientKeys({
    required CmsInspectionEdit source,
    required CmsInspectionEdit saved,
  }) {
    final merged = saved.clone();
    final sourceById = <int, CmsInspectionLineEdit>{};
    final sourceBySignature = <String, Queue<CmsInspectionLineEdit>>{};
    final unsavedSourceLines = Queue<CmsInspectionLineEdit>();

    for (final line in source.items) {
      final clientKey = line.clientKey?.trim();
      if (clientKey == null || clientKey.isEmpty) {
        continue;
      }

      if (line.id > 0) {
        sourceById[line.id] = line;
      } else {
        unsavedSourceLines.addLast(line);
      }

      final signature = _lineMatchSignature(line);
      (sourceBySignature[signature] ??= Queue<CmsInspectionLineEdit>())
          .addLast(line);
    }

    for (final line in merged.items) {
      final existingClientKey = line.clientKey?.trim();
      if (existingClientKey != null && existingClientKey.isNotEmpty) {
        continue;
      }

      CmsInspectionLineEdit? matchedLine;
      if (line.id > 0) {
        matchedLine = sourceById[line.id];
      }

      matchedLine ??= _dequeueMatchingSourceLine(
        sourceBySignature,
        _lineMatchSignature(line),
        preferId: line.id,
      );
      matchedLine ??= _dequeueFirstUnsavedLine(unsavedSourceLines);

      final matchedClientKey = matchedLine?.clientKey?.trim();
      if (matchedClientKey != null && matchedClientKey.isNotEmpty) {
        line.clientKey = matchedClientKey;
      }
    }

    return merged;
  }

  CmsInspectionLineEdit? _dequeueMatchingSourceLine(
    Map<String, Queue<CmsInspectionLineEdit>> sourceBySignature,
    String signature, {
    int preferId = 0,
  }) {
    final queue = sourceBySignature[signature];
    if (queue == null || queue.isEmpty) {
      return null;
    }

    while (queue.isNotEmpty) {
      final candidate = queue.removeFirst();
      final clientKey = candidate.clientKey?.trim();
      if (clientKey == null || clientKey.isEmpty) {
        continue;
      }

      if (preferId > 0 && candidate.id > 0 && candidate.id != preferId) {
        continue;
      }

      return candidate;
    }

    return null;
  }

  CmsInspectionLineEdit? _dequeueFirstUnsavedLine(
    Queue<CmsInspectionLineEdit> unsavedLines,
  ) {
    while (unsavedLines.isNotEmpty) {
      final candidate = unsavedLines.removeFirst();
      final clientKey = candidate.clientKey?.trim();
      if (clientKey != null && clientKey.isNotEmpty) {
        return candidate;
      }
    }

    return null;
  }

  String _lineMatchSignature(CmsInspectionLineEdit line) {
    return <String>[
      _normalizeText(line.inspectionLocationCode),
      _normalizeText(line.inspectionLocationName),
      _normalizeText(line.inspectionItemCode),
      _normalizeText(line.inspectionItemName),
      _normalizeText(line.inspectionActionCode),
      _normalizeText(line.inspectionActionName),
      _normalizeText(line.inspectionDamageCode),
      _normalizeText(line.inspectionDamageName),
      _normalizeText(line.descriptionOne),
      _normalizeText(line.descriptionTwo),
      _normalizeText(line.descriptionThree),
      _normalizeText(line.partNumber),
      _normalizeDecimal(line.qty),
      _normalizeDecimal(line.cost),
      _normalizeDecimal(line.labourQty),
      _normalizeDecimal(line.labourRate),
    ].join('|');
  }

  String _normalizeText(String? value) => value?.trim().toLowerCase() ?? '';

  String _normalizeDecimal(double? value) => (value ?? 0).toStringAsFixed(4);

  String _snapshot() {
    if (_inspection == null) {
      return '';
    }

    final map = _inspection!.toJson();
    map['comments'] = commentsController.text;
    return jsonEncode(map);
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

  Future<bool> _confirmCompletion() async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      data: BasicDialogStatus.warning,
      title: 'Complete inspection?',
      description:
          'Completing locks this inspection and sends it for quoting. This cannot be undone from the app.',
      mainButtonTitle: 'Complete',
      secondaryButtonTitle: 'Keep editing',
    );

    return response?.confirmed == true;
  }

  Future<bool> _confirmCancel() async {
    final response = await _dialogService.showCustomDialog(
      variant: DialogType.infoAlert,
      data: BasicDialogStatus.warning,
      title: 'Cancel inspection?',
      description:
          'This cancels the inspection and any open sub-inspections. This cannot be undone from the app.',
      mainButtonTitle: 'Cancel inspection',
      secondaryButtonTitle: 'Keep editing',
    );

    return response?.confirmed == true;
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        return trimmed;
      }
    }

    return null;
  }

  String _formatStatus(String value) {
    switch (value.trim().toLowerCase()) {
      case 'inprogress':
        return 'In progress';
      default:
        return value.trim();
    }
  }

  @override
  void dispose() {
    commentsController.dispose();
    super.dispose();
  }
}

class CmsInspectionHeaderFact {
  const CmsInspectionHeaderFact({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}
