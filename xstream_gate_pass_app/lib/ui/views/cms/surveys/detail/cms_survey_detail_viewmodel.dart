import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sembast/timestamp.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.dialogs.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/app/app.router.dart';
import 'package:xstream_gate_pass_app/core/enums/basic_dialog_status.dart';
import 'package:xstream_gate_pass_app/core/enums/bckground_job_type.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_survey_type.dart';
import 'package:xstream_gate_pass_app/core/models/background_job_que/background_job_Info.dart';
import 'package:xstream_gate_pass_app/core/models/cms/media/cms_media_upload_item.dart';
import 'package:xstream_gate_pass_app/core/models/cms/survey/cms_mobile_survey_edit_dto.dart';
import 'package:xstream_gate_pass_app/core/models/cms/survey/cms_mobile_survey_email_dto.dart';
import 'package:xstream_gate_pass_app/core/services/api/cms_error_translator.dart';
import 'package:xstream_gate_pass_app/core/services/services/background/workqueue_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_media_upload_queue_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_file_store_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_survey_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';

class CmsSurveyDetailViewModel extends BaseViewModel {
  final log = getLogger('CmsSurveyDetailViewModel');
  final CmsMobileSurveyService _surveyService = locator<CmsMobileSurveyService>();
  final CmsMediaUploadQueueService _mediaUploadQueueService = locator<CmsMediaUploadQueueService>();
  final CmsMobileFileStoreService _mobileFileStoreService = locator<CmsMobileFileStoreService>();
  final CmsSessionService _sessionService = locator<CmsSessionService>();
  final WorkerQueManager _workerQueManager = locator<WorkerQueManager>();
  final DialogService _dialogService = locator<DialogService>();
  final NavigationService _navigationService = locator<NavigationService>();

  final TextEditingController conductedByController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController containerNoController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  CmsMobileSurveyEditDto? _survey;
  CmsSurveyType _surveyType = CmsSurveyType.container;
  bool _hasInitialised = false;
  bool _isDirty = false;
  bool _shouldRefreshOnExit = false;
  bool _isHandlingBackNavigation = false;
  String? _loadError;
  String? _inlineMessage;
  List<CmsMediaUploadItem> _photos = const [];
  List<CmsMediaUploadItem> _attachments = const [];
  StreamSubscription<List<CmsMediaUploadItem>>? _photoSubscription;
  StreamSubscription<List<CmsMediaUploadItem>>? _attachmentSubscription;

  CmsMobileSurveyEditDto? get survey => _survey;
  CmsSurveyType get surveyType => _surveyType;
  bool get isNew => (_survey?.id ?? 0) == 0;
  bool get isDirty => _isDirty;
  bool get shouldRefreshOnExit => _shouldRefreshOnExit;
  String? get loadError => _loadError;
  String? get inlineMessage => _inlineMessage;
  String get title =>
      isNew ? 'New ${_surveyType.displayName.toLowerCase()} survey' : _survey?.containerNo ?? _survey?.name ?? 'Survey #${_survey?.id}';
  bool get canSendEmail => (_survey?.id ?? 0) > 0;
  bool get canDownloadReport => (_survey?.id ?? 0) > 0 && uploadReferenceId != null;
  List<CmsMediaUploadItem> get photos => _photos;
  List<CmsMediaUploadItem> get attachments => _attachments;
  bool get canAttachPhotos => (_survey?.isSaved ?? false) && uploadReferenceId != null;
  bool get canAttachDocuments => canAttachPhotos;
  int? get uploadReferenceId => _survey == null ? null : _mediaUploadQueueService.surveyUploadReferenceId(_survey!);
  bool get isPhotoBusy => busy('survey-photo');
  bool get isDocumentBusy => busy('survey-document');

  String get photoStatusSummary {
    if (_photos.isEmpty) {
      return 'No survey photos yet.';
    }

    final failed = _photos.where((photo) => photo.state == CmsMediaUploadState.failed).length;
    if (failed > 0) {
      return '$failed upload issue${failed == 1 ? '' : 's'}.';
    }

    final uploading = _photos.where((photo) => photo.state == CmsMediaUploadState.uploading).length;
    if (uploading > 0) {
      return 'Uploading $uploading photo${uploading == 1 ? '' : 's'}.';
    }

    final queued = _photos.where((photo) => photo.state == CmsMediaUploadState.queued).length;
    if (queued > 0) {
      return '$queued photo${queued == 1 ? '' : 's'} queued for background upload.';
    }

    return '${_photos.length} uploaded photo${_photos.length == 1 ? '' : 's'}.';
  }

  String get attachmentStatusSummary {
    if (_attachments.isEmpty) {
      return 'No survey documents yet.';
    }

    final failed = _attachments.where((item) => item.state == CmsMediaUploadState.failed).length;
    if (failed > 0) {
      return '$failed document upload${failed == 1 ? '' : 's'} need attention.';
    }

    final uploading = _attachments.where((item) => item.state == CmsMediaUploadState.uploading).length;
    if (uploading > 0) {
      return 'Uploading $uploading document${uploading == 1 ? '' : 's'}.';
    }

    final queued = _attachments.where((item) => item.state == CmsMediaUploadState.queued).length;
    if (queued > 0) {
      return '$queued document${queued == 1 ? '' : 's'} queued for background upload.';
    }

    return '${_attachments.length} uploaded document${_attachments.length == 1 ? '' : 's'}.';
  }

  Future<void> runStartupLogic({
    required int surveyId,
    required CmsSurveyType surveyType,
  }) async {
    if (_hasInitialised) {
      return;
    }

    _hasInitialised = true;
    _surveyType = surveyType;
    _wireDirtyListeners();

    if (surveyId > 0) {
      await _loadSurvey(surveyId);
      return;
    }

    final session = _sessionService.getCached() ?? await _sessionService.refreshFromServer(showLoader: false);
    _survey = CmsMobileSurveyEditDto.empty(
      surveyType: surveyType,
      conductedBy: session?.user?.fullName ?? session?.user?.userName,
    );
    _applySurveyToControllers(markClean: true);
    rebuildUi();
  }

  Future<void> _loadSurvey(int surveyId) async {
    setBusy(true);
    _loadError = null;
    try {
      _survey = await _surveyService.getById(surveyId);
      if (_survey == null) {
        _loadError = 'Survey not found.';
        return;
      }

      _surveyType = _survey?.surveyType ?? _surveyType;
      _applySurveyToControllers(markClean: true);
      await _refreshMedia();
      _bindMediaStreams();
    } catch (error) {
      log.e('Failed to load CMS survey', error);
      _loadError = CmsErrorTranslator.messageFrom(error);
    } finally {
      setBusy(false);
    }
  }

  Future<void> save() async {
    final validation = _validate();
    if (validation != null) {
      _inlineMessage = validation;
      rebuildUi();
      return;
    }

    setBusy(true);
    _loadError = null;
    _inlineMessage = null;
    try {
      final input = (_survey ?? CmsMobileSurveyEditDto.empty(surveyType: _surveyType)).copyWith(
        surveyType: _surveyType,
        conductedBy: conductedByController.text.trim(),
        name: nameController.text.trim(),
        containerNo: containerNoController.text.trim(),
        description: descriptionController.text.trim(),
      );
      _survey = await _surveyService.addUpdate(input);
      _surveyType = _survey?.surveyType ?? _surveyType;
      _applySurveyToControllers(markClean: true);
      _shouldRefreshOnExit = true;
      await _refreshMedia();
      _bindMediaStreams();
      _inlineMessage = 'Survey saved. Attachments and photos are ready.';
    } catch (error) {
      log.e('Failed to save CMS survey', error);
      _loadError = CmsErrorTranslator.messageFrom(error);
    } finally {
      setBusy(false);
    }
  }

  Future<List<String>> previewRecipients() async {
    if (!canSendEmail) {
      return const [];
    }

    try {
      return await _surveyService.getEmailAddresses(_survey!.id);
    } catch (error) {
      log.e('Failed to load survey email recipients', error);
      _loadError = CmsErrorTranslator.messageFrom(error);
      rebuildUi();
      return const [];
    }
  }

  Future<void> sendEmail() async {
    if (!canSendEmail) {
      _inlineMessage = 'Save the survey before sending email.';
      rebuildUi();
      return;
    }

    setBusy(true);
    _loadError = null;
    _inlineMessage = null;
    try {
      final recipients = await _surveyService.getEmailAddresses(_survey!.id);
      if (recipients.isEmpty) {
        _inlineMessage = 'No recipients on file for this survey.';
        return;
      }

      await _surveyService.sendEmail(
        CmsMobileSurveyEmailDto(
          id: _survey!.id,
          containerNo: _survey!.containerNo ?? containerNoController.text.trim(),
          shippingLineId: _survey!.shippingLineId,
        ),
      );
      _inlineMessage = 'Survey email sent to ${recipients.length} recipient${recipients.length == 1 ? '' : 's'}.';
    } catch (error) {
      log.e('Failed to send CMS survey email', error);
      _loadError = CmsErrorTranslator.messageFrom(error);
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  Future<String?> downloadReport() async {
    final survey = _survey;
    if (survey == null || !survey.isSaved) {
      _inlineMessage = 'Save the survey before downloading a report.';
      rebuildUi();
      return null;
    }

    final referenceId = survey.surveyType == CmsSurveyType.gatePass ? survey.gatePassId : survey.containerId;
    if (referenceId == null || referenceId <= 0) {
      _inlineMessage = 'This survey is missing the saved container or gate pass reference required for reports.';
      rebuildUi();
      return null;
    }

    setBusy(true);
    _loadError = null;
    _inlineMessage = null;
    try {
      final filePath = await _surveyService.downloadReport(
        surveyId: survey.id,
        surveyType: survey.surveyType,
        referenceId: referenceId,
      );
      _inlineMessage = 'Report downloaded.';
      return filePath;
    } catch (error) {
      log.e('Failed to download CMS survey report', error);
      _loadError = CmsErrorTranslator.messageFrom(error);
      return null;
    } finally {
      setBusy(false);
      rebuildUi();
    }
  }

  Future<void> capturePhoto() async {
    if (!canAttachPhotos || _survey == null) {
      _inlineMessage = isNew ? 'Save the survey before attaching photos.' : 'This survey is missing its upload reference.';
      rebuildUi();
      return;
    }

    setBusyForObject('survey-photo', true);
    _loadError = null;
    _inlineMessage = null;
    try {
      final capturedPath = await _navigationService.navigateTo(
        Routes.cmsMediaCameraCaptureView,
      ) as String?;
      if (capturedPath == null || capturedPath.trim().isEmpty) {
        return;
      }

      final photo = await _mediaUploadQueueService.captureSurveyPhoto(
        survey: _survey!,
        sourcePath: capturedPath,
      );
      if (photo != null) {
        await _enqueueMediaUpload(_survey!.id);
      }
      _inlineMessage = 'Photo queued for background upload.';
    } catch (error) {
      log.e('Failed to capture CMS survey photo', error);
      _loadError = CmsErrorTranslator.messageFrom(error);
    } finally {
      setBusyForObject('survey-photo', false);
      rebuildUi();
    }
  }

  Future<void> addPhotoFromGallery() async {
    if (!canAttachPhotos || _survey == null) {
      _inlineMessage = isNew ? 'Save the survey before attaching photos.' : 'This survey is missing its upload reference.';
      rebuildUi();
      return;
    }

    setBusyForObject('survey-photo', true);
    _loadError = null;
    _inlineMessage = null;
    try {
      final photo = await _mediaUploadQueueService.captureSurveyPhoto(
        survey: _survey!,
        fromGallery: true,
      );
      if (photo != null) {
        await _enqueueMediaUpload(_survey!.id);
        _inlineMessage = 'Photo queued for background upload.';
      }
    } catch (error) {
      log.e('Failed to select CMS survey photo', error);
      _loadError = CmsErrorTranslator.messageFrom(error);
    } finally {
      setBusyForObject('survey-photo', false);
      rebuildUi();
    }
  }

  Future<void> pickDocument() async {
    if (!canAttachDocuments || _survey == null) {
      _inlineMessage = isNew ? 'Save the survey before attaching documents.' : 'This survey is missing its upload reference.';
      rebuildUi();
      return;
    }

    setBusyForObject('survey-document', true);
    _loadError = null;
    _inlineMessage = null;
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt', 'jpg', 'jpeg', 'png', 'webp'],
      );
      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;
      final sourcePath = file.path;
      if (sourcePath == null || sourcePath.trim().isEmpty) {
        _inlineMessage = 'The selected document could not be read from local storage.';
        return;
      }

      await queueDocumentFromPath(
        sourcePath,
        fileName: file.name,
      );
      _inlineMessage = 'Document queued for background upload.';
    } catch (error) {
      log.e('Failed to select CMS survey document', error);
      _loadError = CmsErrorTranslator.messageFrom(error);
    } finally {
      setBusyForObject('survey-document', false);
      rebuildUi();
    }
  }

  Future<void> queueDocumentFromPath(
    String sourcePath, {
    String? fileName,
  }) async {
    if (!canAttachDocuments || _survey == null) {
      _inlineMessage = isNew ? 'Save the survey before attaching documents.' : 'This survey is missing its upload reference.';
      rebuildUi();
      return;
    }

    final document = await _mediaUploadQueueService.captureSurveyDocument(
      survey: _survey!,
      sourcePath: sourcePath,
      fileName: fileName,
    );
    if (document != null) {
      await _enqueueMediaUpload(_survey!.id);
    }
  }

  Future<String?> downloadAttachment(CmsMediaUploadItem attachment) async {
    final localPath = attachment.localPath;
    if (localPath != null && localPath.trim().isNotEmpty && await File(localPath).exists()) {
      return localPath;
    }

    final documentId = attachment.documentId;
    if (documentId == null || documentId <= 0) {
      _inlineMessage = 'This document has not uploaded yet.';
      rebuildUi();
      return null;
    }

    setBusyForObject('survey-document', true);
    _loadError = null;
    _inlineMessage = null;
    try {
      return await _mobileFileStoreService.downloadDocument(
        documentId: documentId,
        fileName: attachment.documentFileName ?? attachment.name ?? 'survey-document-$documentId',
      );
    } catch (error) {
      log.e('Failed to download CMS survey attachment', error);
      _loadError = CmsErrorTranslator.messageFrom(error);
      return null;
    } finally {
      setBusyForObject('survey-document', false);
      rebuildUi();
    }
  }

  Future<void> retryPhotoUploads() async {
    final survey = _survey;
    if (survey == null || !survey.isSaved) {
      return;
    }

    await _enqueueMediaUpload(survey.id);
    _inlineMessage = 'Photo upload retry queued.';
    rebuildUi();
  }

  Future<void> retryItem(CmsMediaUploadItem item) async {
    final survey = _survey;
    if (survey == null || !survey.isSaved) {
      return;
    }

    await _mediaUploadQueueService.retry(item.clientUploadId);
    await _enqueueMediaUpload(survey.id);
    _inlineMessage = item.isDocument ? 'Document upload retry queued.' : 'Photo upload retry queued.';
    rebuildUi();
  }

  Future<void> deletePhoto(CmsMediaUploadItem photo) async {
    setBusyForObject('survey-photo', true);
    _loadError = null;
    try {
      await _mediaUploadQueueService.deleteItem(photo);
      _inlineMessage = 'Photo removed.';
    } catch (error) {
      log.e('Failed to delete CMS survey photo', error);
      _loadError = CmsErrorTranslator.messageFrom(error);
    } finally {
      setBusyForObject('survey-photo', false);
      rebuildUi();
    }
  }

  Future<void> deleteAttachment(CmsMediaUploadItem attachment) async {
    setBusyForObject('survey-document', true);
    _loadError = null;
    try {
      await _mediaUploadQueueService.deleteItem(attachment);
      _inlineMessage = 'Document removed.';
    } catch (error) {
      log.e('Failed to delete CMS survey attachment', error);
      _loadError = CmsErrorTranslator.messageFrom(error);
    } finally {
      setBusyForObject('survey-document', false);
      rebuildUi();
    }
  }

  Future<void> goBack() async {
    await onWillPop();
  }

  Future<bool> onWillPop() async {
    if (_isHandlingBackNavigation) {
      return false;
    }

    _isHandlingBackNavigation = true;
    try {
      if (_isDirty) {
        final response = await _dialogService.showCustomDialog(
          variant: DialogType.infoAlert,
          data: BasicDialogStatus.warning,
          title: 'Leave survey?',
          description: 'You have unsaved survey changes. Save before leaving, or discard them?',
          mainButtonTitle: 'Save',
          secondaryButtonTitle: 'Discard',
        );

        if (response == null) {
          return false;
        }

        if (response.confirmed == true) {
          await save();
          if (_isDirty) {
            return false;
          }
        }
      }

      _navigationService.back(result: _shouldRefreshOnExit ? true : null);
      return false;
    } finally {
      _isHandlingBackNavigation = false;
    }
  }

  void clearMessage() {
    _inlineMessage = null;
    rebuildUi();
  }

  void setInlineMessage(String message) {
    _inlineMessage = message;
    rebuildUi();
  }

  String? _validate() {
    if (conductedByController.text.trim().isEmpty) {
      return 'Conducted by is required.';
    }
    if (nameController.text.trim().isEmpty) {
      return 'Name / title is required.';
    }
    if (descriptionController.text.trim().isEmpty) {
      return 'Survey details are required.';
    }
    if (_surveyType == CmsSurveyType.gatePass && ((_survey?.gatePassId ?? 0) <= 0)) {
      return 'Gate pass survey picking is not available in this slice yet. Open an existing gate pass survey instead.';
    }
    return null;
  }

  void _wireDirtyListeners() {
    void markDirty() {
      if (!_hasInitialised || _survey == null || _isDirty) {
        return;
      }
      _isDirty = true;
      rebuildUi();
    }

    conductedByController.addListener(markDirty);
    nameController.addListener(markDirty);
    containerNoController.addListener(markDirty);
    descriptionController.addListener(markDirty);
  }

  void _applySurveyToControllers({required bool markClean}) {
    final survey = _survey;
    conductedByController.text = survey?.conductedBy ?? '';
    nameController.text = survey?.name ?? '';
    containerNoController.text = survey?.containerNo ?? '';
    descriptionController.text = survey?.description ?? '';
    if (markClean) {
      _isDirty = false;
    }
  }

  Future<void> _refreshMedia() async {
    final survey = _survey;
    if (survey == null || !survey.isSaved) {
      _photos = const [];
      _attachments = const [];
      return;
    }

    _photos = await _mediaUploadQueueService.getForSurvey(
      survey,
      uploadType: CmsMediaUploadItem.imageUploadType,
    );
    _attachments = await _mediaUploadQueueService.getForSurvey(
      survey,
      uploadType: CmsMediaUploadItem.documentUploadType,
    );
  }

  void _bindMediaStreams() {
    _photoSubscription?.cancel();
    _attachmentSubscription?.cancel();

    final survey = _survey;
    if (survey == null || !survey.isSaved) {
      return;
    }

    _photoSubscription = _mediaUploadQueueService
        .watch(
      ownerType: CmsMediaUploadOwnerType.survey,
      rootId: survey.id,
      uploadType: CmsMediaUploadItem.imageUploadType,
    )
        .listen((items) {
      _photos = items;
      rebuildUi();
    });

    _attachmentSubscription = _mediaUploadQueueService
        .watch(
      ownerType: CmsMediaUploadOwnerType.survey,
      rootId: survey.id,
      uploadType: CmsMediaUploadItem.documentUploadType,
    )
        .listen((items) {
      _attachments = items;
      rebuildUi();
    });
  }

  Future<void> _enqueueMediaUpload(int surveyId) async {
    if (surveyId <= 0) {
      return;
    }

    final now = Timestamp.now();
    await _workerQueManager.enqueSingle(
      BackgroundJobInfo(
        id: '',
        jobArgs: jsonEncode({
          'ownerType': 'survey',
          'rootId': surveyId,
        }),
        lastTryTime: now,
        nextTryTime: now,
        creationTime: now,
        isAbandoned: false,
        jobType: BackgroundJobType.syncCmsMediaUploads.index,
      ),
    );
  }

  @override
  void dispose() {
    _photoSubscription?.cancel();
    _attachmentSubscription?.cancel();
    conductedByController.dispose();
    nameController.dispose();
    containerNoController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
