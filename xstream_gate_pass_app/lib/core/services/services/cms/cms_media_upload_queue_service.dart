import 'dart:io';

import 'package:image/image.dart' as image_tools;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_survey_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/media/cms_media_upload_item.dart';
import 'package:xstream_gate_pass_app/core/models/cms/survey/cms_mobile_survey_edit_dto.dart';
import 'package:xstream_gate_pass_app/core/services/database/sembast_store.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_file_store_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/guid_generator.dart';
import 'package:xstream_gate_pass_app/core/services/shared/media_service.dart';

@LazySingleton()
class CmsMediaUploadQueueService {
  final log = getLogger('CmsMediaUploadQueueService');

  final AppDatabase _appDatabase = locator<AppDatabase>();
  final MediaService _mediaService = locator<MediaService>();
  final CmsMobileFileStoreService _mobileFileStoreService = locator<CmsMobileFileStoreService>();
  final CmsSessionService _cmsSessionService = locator<CmsSessionService>();

  StoreRef<String, Map<String, dynamic>> get _store => stringMapStoreFactory.store(_storeName);

  Future<CmsMediaUploadItem?> captureInspectionLinePhoto({
    required int inspectionId,
    required CmsInspectionLineEdit line,
    bool fromGallery = false,
    String? sourcePath,
  }) async {
    if (inspectionId <= 0) {
      throw Exception('Save or start the inspection before attaching photos.');
    }

    final pickedPath = await _resolveSourcePath(
      fromGallery: fromGallery,
      sourcePath: sourcePath,
    );
    if (pickedPath == null) {
      return null;
    }

    final clientUploadId = Guid.newGuidAsString;
    if (line.id <= 0 && (line.clientKey == null || line.clientKey!.trim().isEmpty)) {
      line.clientKey = Guid.newGuidAsString;
    }

    final prepared = await _prepareLocalImage(
      sourcePath: pickedPath,
      ownerFolder: 'InspectionLine',
      rootId: inspectionId,
      referenceToken: line.id > 0 ? line.id.toString() : 'local_${line.clientKey ?? 'line'}',
      clientUploadId: clientUploadId,
    );

    final photo = CmsMediaUploadItem(
      ownerType: CmsMediaUploadOwnerType.inspectionLine,
      rootId: inspectionId,
      referenceId: line.id > 0 ? line.id : null,
      clientKey: line.clientKey,
      clientUploadId: clientUploadId,
      name: path.basenameWithoutExtension(prepared.path),
      documentFileName: path.basename(prepared.path),
      documentFileSize: prepared.size.toString(),
      documentFileType: prepared.contentType,
      localPath: prepared.path,
      capturedAtUtc: DateTime.now().toUtc(),
      createdAtUtc: DateTime.now().toUtc(),
      state: line.id > 0 ? CmsMediaUploadState.queued : CmsMediaUploadState.awaitingSave,
      uploadType: CmsMediaUploadItem.imageUploadType,
      uploadMethod: 4,
    );

    await upsert(photo);
    return photo;
  }

  Future<CmsMediaUploadItem?> captureSurveyPhoto({
    required CmsMobileSurveyEditDto survey,
    bool fromGallery = false,
    String? sourcePath,
  }) async {
    if (!survey.isSaved) {
      throw Exception('Save the survey before attaching photos.');
    }

    final referenceId = surveyUploadReferenceId(survey);
    if (referenceId == null || referenceId <= 0) {
      throw Exception('This survey does not have a saved container or gate pass reference for photo upload.');
    }

    final pickedPath = await _resolveSourcePath(
      fromGallery: fromGallery,
      sourcePath: sourcePath,
    );
    if (pickedPath == null) {
      return null;
    }

    final clientUploadId = Guid.newGuidAsString;
    final prepared = await _prepareLocalImage(
      sourcePath: pickedPath,
      ownerFolder: 'Survey',
      rootId: survey.id,
      referenceToken: referenceId.toString(),
      clientUploadId: clientUploadId,
    );

    final photo = CmsMediaUploadItem(
      ownerType: CmsMediaUploadOwnerType.survey,
      rootId: survey.id,
      referenceId: referenceId,
      clientUploadId: clientUploadId,
      name: path.basenameWithoutExtension(prepared.path),
      documentFileName: path.basename(prepared.path),
      documentFileSize: prepared.size.toString(),
      documentFileType: prepared.contentType,
      localPath: prepared.path,
      capturedAtUtc: DateTime.now().toUtc(),
      createdAtUtc: DateTime.now().toUtc(),
      state: CmsMediaUploadState.queued,
      surveyType: survey.surveyType,
      uploadType: CmsMediaUploadItem.imageUploadType,
      uploadMethod: _surveyUploadMethodValue(survey.surveyType),
    );

    await upsert(photo);
    return photo;
  }

  Future<CmsMediaUploadItem?> captureSurveyDocument({
    required CmsMobileSurveyEditDto survey,
    required String sourcePath,
    String? fileName,
    String? mimeType,
  }) async {
    if (!survey.isSaved) {
      throw Exception('Save the survey before attaching documents.');
    }

    final referenceId = surveyUploadReferenceId(survey);
    if (referenceId == null || referenceId <= 0) {
      throw Exception('This survey does not have a saved container or gate pass reference for document upload.');
    }

    final clientUploadId = Guid.newGuidAsString;
    final prepared = await _prepareLocalDocument(
      sourcePath: sourcePath,
      ownerFolder: 'Survey',
      rootId: survey.id,
      referenceToken: referenceId.toString(),
      clientUploadId: clientUploadId,
      preferredFileName: fileName,
      pickedMimeType: mimeType,
    );

    final document = CmsMediaUploadItem(
      ownerType: CmsMediaUploadOwnerType.survey,
      rootId: survey.id,
      referenceId: referenceId,
      clientUploadId: clientUploadId,
      name: path.basenameWithoutExtension(prepared.path),
      documentFileName: path.basename(prepared.path),
      documentFileSize: prepared.size.toString(),
      documentFileType: prepared.contentType,
      localPath: prepared.path,
      capturedAtUtc: DateTime.now().toUtc(),
      createdAtUtc: DateTime.now().toUtc(),
      state: CmsMediaUploadState.queued,
      surveyType: survey.surveyType,
      uploadType: CmsMediaUploadItem.documentUploadType,
      uploadMethod: _surveyUploadMethodValue(survey.surveyType),
    );

    await upsert(document);
    return document;
  }

  Future<void> upsert(CmsMediaUploadItem item) async {
    await _store.record(item.clientUploadId).put(_appDatabase.db!, item.toJson());
  }

  Future<List<CmsMediaUploadItem>> getAll() async {
    final snapshots = await _store.find(_appDatabase.db!);
    return snapshots.map((snapshot) => CmsMediaUploadItem.fromJson(snapshot.value)).toList(growable: false);
  }

  Future<List<CmsMediaUploadItem>> getForInspectionLine(CmsInspectionLineEdit line) async {
    if (line.id > 0) {
      await _mergeRemoteInspectionLinePhotos(line);
    }

    final photos = await getAll();
    final lineClientKey = line.clientKey?.trim();
    final lineId = line.id;

    final filtered = photos.where((photo) {
      if (photo.ownerType != CmsMediaUploadOwnerType.inspectionLine) {
        return false;
      }

      if (lineId > 0 && photo.referenceId == lineId) {
        return true;
      }

      return lineClientKey != null && lineClientKey.isNotEmpty && photo.clientKey == lineClientKey;
    }).toList(growable: false);

    return _sortNewestFirst(filtered);
  }

  Future<List<CmsMediaUploadItem>> getForInspection(int inspectionId) async {
    final photos = await getAll();
    return _sortNewestFirst(
        photos.where((photo) => photo.ownerType == CmsMediaUploadOwnerType.inspectionLine && photo.rootId == inspectionId).toList(growable: false));
  }

  Future<List<CmsMediaUploadItem>> getForSurvey(
    CmsMobileSurveyEditDto survey, {
    int? uploadType,
  }) async {
    final referenceId = surveyUploadReferenceId(survey);
    if (survey.isSaved && referenceId != null && referenceId > 0) {
      await _mergeRemoteSurveyMedia(survey, referenceId);
    }

    final media = await getAll();
    return _sortNewestFirst(media
        .where((photo) => _matchesFilters(
              photo,
              ownerType: CmsMediaUploadOwnerType.survey,
              rootId: survey.id,
              uploadType: uploadType,
            ))
        .toList(growable: false));
  }

  Stream<List<CmsMediaUploadItem>> watch({
    required CmsMediaUploadOwnerType ownerType,
    required int rootId,
    int? uploadType,
  }) {
    return _store.query().onSnapshots(_appDatabase.db!).map((snapshots) {
      final items = snapshots.map((snapshot) => CmsMediaUploadItem.fromJson(snapshot.value)).where((item) {
        return _matchesFilters(
          item,
          ownerType: ownerType,
          rootId: rootId,
          uploadType: uploadType,
        );
      }).toList(growable: false);
      return _sortNewestFirst(items);
    });
  }

  Future<int> pendingCount({
    CmsMediaUploadOwnerType? ownerType,
    int? rootId,
    int? uploadType,
  }) async {
    final items = await getAll();
    return items
        .where((item) => _matchesFilters(item, ownerType: ownerType, rootId: rootId, uploadType: uploadType) && _isPendingIndicator(item))
        .length;
  }

  Stream<int> watchGlobalPendingCount() {
    return _store.query().onSnapshots(_appDatabase.db!).map((snapshots) {
      final items = snapshots.map((snapshot) => CmsMediaUploadItem.fromJson(snapshot.value)).toList(growable: false);
      return items.where(_isPendingIndicator).length;
    });
  }

  Future<void> retry(String clientUploadId) async {
    final json = await _store.record(clientUploadId).get(_appDatabase.db!);
    if (json == null) {
      return;
    }

    final item = CmsMediaUploadItem.fromJson(json);
    await upsert(item.copyWith(
      state: CmsMediaUploadState.queued,
      errorMessage: '',
    ));
  }

  Future<void> remove(String clientUploadId) async {
    final json = await _store.record(clientUploadId).get(_appDatabase.db!);
    if (json == null) {
      return;
    }

    await deleteItem(CmsMediaUploadItem.fromJson(json));
  }

  Future<void> remapSavedInspectionLines(CmsInspectionEdit inspection) async {
    if (inspection.id <= 0) {
      return;
    }

    final savedLinesByClientKey = <String, CmsInspectionLineEdit>{};
    for (final line in inspection.items) {
      final clientKey = line.clientKey?.trim();
      if (line.id > 0 && clientKey != null && clientKey.isNotEmpty) {
        savedLinesByClientKey[clientKey] = line;
      }
    }

    if (savedLinesByClientKey.isEmpty) {
      return;
    }

    final photos = await getAll();
    for (final photo in photos) {
      if (photo.ownerType != CmsMediaUploadOwnerType.inspectionLine) {
        continue;
      }

      final clientKey = photo.clientKey?.trim();
      if (clientKey == null || clientKey.isEmpty) {
        continue;
      }

      final savedLine = savedLinesByClientKey[clientKey];
      if (savedLine == null || photo.referenceId == savedLine.id) {
        continue;
      }

      await upsert(
        photo.copyWith(
          rootId: inspection.id,
          referenceId: savedLine.id,
          state:
              photo.state == CmsMediaUploadState.awaitingSave || photo.state == CmsMediaUploadState.local ? CmsMediaUploadState.queued : photo.state,
          errorMessage: '',
        ),
      );
    }
  }

  Future<int> uploadPendingForInspection(int inspectionId) async {
    return uploadPending(
      ownerType: CmsMediaUploadOwnerType.inspectionLine,
      rootId: inspectionId,
    );
  }

  Future<int> uploadPendingForSurvey(int surveyId) async {
    return uploadPending(
      ownerType: CmsMediaUploadOwnerType.survey,
      rootId: surveyId,
    );
  }

  Future<int> uploadPending({
    CmsMediaUploadOwnerType? ownerType,
    int? rootId,
  }) async {
    final pending = (await getAll()).where((item) {
      return _matchesFilters(item, ownerType: ownerType, rootId: rootId) && _isUploadCandidate(item);
    }).toList(growable: false);

    await _uploadInBatches(pending);

    final remaining = (await getAll()).where((item) {
      return _matchesFilters(item, ownerType: ownerType, rootId: rootId) && _isUploadCandidate(item);
    }).length;
    if (remaining > 0) {
      log.w('$remaining CMS media upload(s) remain queued or failed after this sync attempt.');
    }

    return remaining;
  }

  Future<CmsMediaUploadItem> uploadItem(CmsMediaUploadItem photo) async {
    if (photo.ownerType == CmsMediaUploadOwnerType.inspectionLine) {
      return _uploadInspectionLinePhoto(photo);
    }

    return _uploadSurveyMedia(photo);
  }

  Future<void> deleteItem(CmsMediaUploadItem photo) async {
    if (photo.documentId != null && photo.documentId! > 0) {
      if (photo.ownerType == CmsMediaUploadOwnerType.inspectionLine) {
        await _mobileFileStoreService.deleteInspectionLinePhoto(photo.documentId!);
      } else {
        await _mobileFileStoreService.deleteSurveyDocument(photo.documentId!);
      }
    }

    await _store.record(photo.clientUploadId).delete(_appDatabase.db!);
  }

  /// Removes only the local queue row for [clientUploadId] without calling the
  /// server delete endpoint (used when the backend cascade owns the server document).
  Future<void> removeLocalOnly(String clientUploadId) async {
    await _store.record(clientUploadId).delete(_appDatabase.db!);
  }

  int? surveyUploadReferenceId(CmsMobileSurveyEditDto survey) {
    if (survey.surveyType == CmsSurveyType.gatePass) {
      return survey.gatePassId;
    }

    return survey.containerId;
  }

  Future<void> _uploadInBatches(List<CmsMediaUploadItem> pending) async {
    for (var i = 0; i < pending.length; i += AppConst.CmsMediaUploadConcurrency) {
      final batch = pending.skip(i).take(AppConst.CmsMediaUploadConcurrency).toList(growable: false);
      await Future.wait(batch.map(_uploadMediaSafely));
    }
  }

  Future<CmsMediaUploadItem> _uploadInspectionLinePhoto(CmsMediaUploadItem photo) async {
    if (photo.rootId == null || photo.rootId! <= 0 || photo.referenceId == null || photo.referenceId! <= 0) {
      final awaitingSave = photo.copyWith(
        state: CmsMediaUploadState.awaitingSave,
        errorMessage: 'Waiting for the inspection line to be saved before upload.',
        attempts: photo.attempts + 1,
      );
      await upsert(awaitingSave);
      return awaitingSave;
    }

    final localPath = photo.localPath;
    if (localPath == null || localPath.isEmpty || !await File(localPath).exists()) {
      final failed = photo.copyWith(
        state: CmsMediaUploadState.failed,
        errorMessage: 'Local image file is missing.',
        attempts: photo.attempts + 1,
      );
      await upsert(failed);
      return failed;
    }

    await upsert(photo.copyWith(state: CmsMediaUploadState.uploading, errorMessage: ''));

    try {
      final uploaded = await _mobileFileStoreService.uploadInspectionLinePhoto(
        inspectionId: photo.rootId!,
        inspectionLineId: photo.referenceId!,
        filePath: localPath,
        documentFileName: photo.documentFileName ?? path.basename(localPath),
        contentType: photo.documentFileType ?? _contentTypeFor(localPath, null),
        clientUploadId: photo.clientUploadId,
        capturedAtUtc: photo.capturedAtUtc,
      );

      final completed = CmsMediaUploadItem.fromInspectionPhoto(uploaded).copyWith(
        rootId: photo.rootId,
        referenceId: photo.referenceId,
        clientKey: photo.clientKey,
        localPath: photo.localPath,
        capturedAtUtc: photo.capturedAtUtc,
        state: CmsMediaUploadState.uploaded,
        errorMessage: '',
        attempts: photo.attempts,
        createdAtUtc: photo.createdAtUtc,
      );
      await upsert(completed);
      return completed;
    } catch (error) {
      log.e('Failed to upload CMS inspection line photo', error);
      final failed = photo.copyWith(
        state: CmsMediaUploadState.failed,
        errorMessage: error.toString(),
        attempts: photo.attempts + 1,
      );
      await upsert(failed);
      return failed;
    }
  }

  Future<CmsMediaUploadItem> _uploadSurveyMedia(CmsMediaUploadItem photo) async {
    if (photo.rootId == null || photo.rootId! <= 0 || photo.referenceId == null || photo.referenceId! <= 0 || photo.surveyType == null) {
      final failed = photo.copyWith(
        state: CmsMediaUploadState.failed,
        errorMessage: 'Survey media is missing its saved survey reference.',
        attempts: photo.attempts + 1,
      );
      await upsert(failed);
      return failed;
    }

    final localPath = photo.localPath;
    if (localPath == null || localPath.isEmpty || !await File(localPath).exists()) {
      final failed = photo.copyWith(
        state: CmsMediaUploadState.failed,
        errorMessage: 'Local file is missing.',
        attempts: photo.attempts + 1,
      );
      await upsert(failed);
      return failed;
    }

    await upsert(photo.copyWith(state: CmsMediaUploadState.uploading, errorMessage: ''));

    try {
      final uploaded = photo.isDocument
          ? await _mobileFileStoreService.uploadSurveyDocument(
              surveyId: photo.rootId!,
              referenceId: photo.referenceId!,
              surveyType: photo.surveyType!,
              filePath: localPath,
              documentFileName: photo.documentFileName ?? path.basename(localPath),
              contentType: photo.documentFileType ?? _documentContentTypeFor(localPath, null),
              clientUploadId: photo.clientUploadId,
            )
          : await _mobileFileStoreService.uploadSurveyPhoto(
              surveyId: photo.rootId!,
              referenceId: photo.referenceId!,
              surveyType: photo.surveyType!,
              filePath: localPath,
              documentFileName: photo.documentFileName ?? path.basename(localPath),
              contentType: photo.documentFileType ?? _contentTypeFor(localPath, null),
              clientUploadId: photo.clientUploadId,
            );

      final completed = uploaded.copyWith(
        rootId: photo.rootId,
        referenceId: photo.referenceId,
        localPath: photo.localPath,
        capturedAtUtc: photo.capturedAtUtc,
        state: CmsMediaUploadState.uploaded,
        errorMessage: '',
        surveyType: photo.surveyType,
        uploadType: photo.uploadType,
        uploadMethod: photo.uploadMethod,
        attempts: photo.attempts,
        createdAtUtc: photo.createdAtUtc,
      );
      await upsert(completed);
      return completed;
    } catch (error) {
      log.e('Failed to upload CMS survey media', error);
      final failed = photo.copyWith(
        state: CmsMediaUploadState.failed,
        errorMessage: error.toString(),
        attempts: photo.attempts + 1,
      );
      await upsert(failed);
      return failed;
    }
  }

  Future<CmsMediaUploadItem> _uploadMediaSafely(CmsMediaUploadItem photo) async {
    try {
      return await uploadItem(photo);
    } catch (error) {
      log.e('Unexpected CMS media upload failure', error);
      final failed = photo.copyWith(
        state: CmsMediaUploadState.failed,
        errorMessage: error.toString(),
        attempts: photo.attempts + 1,
      );
      await upsert(failed);
      return failed;
    }
  }

  Future<void> _mergeRemoteInspectionLinePhotos(CmsInspectionLineEdit line) async {
    try {
      final remotePhotos = await _mobileFileStoreService.listInspectionLinePhotos(line.id);
      for (final remotePhoto in remotePhotos) {
        if (remotePhoto.clientUploadId.trim().isEmpty) {
          continue;
        }

        final existing = await _store.record(remotePhoto.clientUploadId).get(_appDatabase.db!);
        final localPhoto = existing == null ? null : CmsMediaUploadItem.fromJson(existing);
        await upsert(
          CmsMediaUploadItem.fromInspectionPhoto(remotePhoto).copyWith(
            rootId: line.inspectionId ?? localPhoto?.rootId,
            referenceId: line.id,
            clientKey: line.clientKey ?? localPhoto?.clientKey,
            localPath: localPhoto?.localPath,
            state: CmsMediaUploadState.uploaded,
            errorMessage: '',
          ),
        );
      }
    } catch (error) {
      log.w('Unable to refresh remote CMS inspection line photos for line ${line.id}: $error');
    }
  }

  Future<void> _mergeRemoteSurveyMedia(
    CmsMobileSurveyEditDto survey,
    int referenceId,
  ) async {
    try {
      final remoteMedia = await _mobileFileStoreService.listSurveyMedia(
        surveyId: survey.id,
        referenceId: referenceId,
        surveyType: survey.surveyType,
      );
      for (final remoteItem in remoteMedia) {
        final localItem = await _findLocalSurveyMediaForRemote(remoteItem);
        await upsert(
          remoteItem.copyWith(
            clientUploadId: localItem?.clientUploadId,
            rootId: survey.id,
            referenceId: referenceId,
            localPath: localItem?.localPath,
            state: CmsMediaUploadState.uploaded,
            errorMessage: '',
            surveyType: survey.surveyType,
            uploadMethod: _surveyUploadMethodValue(survey.surveyType),
          ),
        );
      }
    } catch (error) {
      log.w('Unable to refresh remote CMS survey media for ${survey.id}: $error');
    }
  }

  Future<CmsMediaUploadItem?> _findLocalSurveyMediaForRemote(CmsMediaUploadItem remotePhoto) async {
    final existing = await _store.record(remotePhoto.clientUploadId).get(_appDatabase.db!);
    if (existing != null) {
      return CmsMediaUploadItem.fromJson(existing);
    }

    final documentId = remotePhoto.documentId;
    if (documentId == null) {
      return null;
    }

    final photos = await getAll();
    for (final photo in photos) {
      if (photo.ownerType == CmsMediaUploadOwnerType.survey && photo.documentId == documentId) {
        return photo;
      }
    }

    return null;
  }

  bool _isInspectionUploadCandidate(CmsMediaUploadItem photo) {
    return photo.referenceId != null && photo.referenceId! > 0 && photo.isPendingUpload;
  }

  bool _isUploadCandidate(CmsMediaUploadItem item) {
    if (!item.isPendingUpload) {
      return false;
    }

    if (item.ownerType == CmsMediaUploadOwnerType.inspectionLine) {
      return _isInspectionUploadCandidate(item);
    }

    return item.rootId != null && item.rootId! > 0 && item.referenceId != null && item.referenceId! > 0 && item.surveyType != null;
  }

  bool _isPendingIndicator(CmsMediaUploadItem item) {
    return item.state == CmsMediaUploadState.queued || item.state == CmsMediaUploadState.failed || item.state == CmsMediaUploadState.uploading;
  }

  bool _matchesFilters(
    CmsMediaUploadItem item, {
    CmsMediaUploadOwnerType? ownerType,
    int? rootId,
    int? uploadType,
  }) {
    if (ownerType != null && item.ownerType != ownerType) {
      return false;
    }

    if (rootId != null && item.rootId != rootId) {
      return false;
    }

    if (uploadType != null && (item.uploadType ?? CmsMediaUploadItem.imageUploadType) != uploadType) {
      return false;
    }

    return true;
  }

  Future<String?> _resolveSourcePath({
    required bool fromGallery,
    String? sourcePath,
  }) async {
    if (sourcePath != null && sourcePath.trim().isNotEmpty) {
      return sourcePath;
    }

    final pickedFile = await _mediaService.getImage(fromGallery: fromGallery);
    return pickedFile?.path;
  }

  Future<_PreparedCmsMedia> _prepareLocalImage({
    required String sourcePath,
    required String ownerFolder,
    required int rootId,
    required String referenceToken,
    required String clientUploadId,
  }) async {
    final contentType = _contentTypeFor(sourcePath, null);
    final copiedPath = await _copyToLocalMediaFolder(
      sourcePath: sourcePath,
      ownerFolder: ownerFolder,
      rootId: rootId,
      referenceToken: referenceToken,
      clientUploadId: clientUploadId,
      contentType: contentType,
    );
    final prepared = await _stripMetadataForUpload(
      localPath: copiedPath,
      contentType: contentType,
    );
    final file = File(prepared.path);
    final stat = await file.stat();
    if (stat.size > AppConst.CmsMediaUploadMaxBytes) {
      await file.delete().catchError((_) => file);
      throw Exception('Photo is larger than the 8 MB mobile upload limit.');
    }

    return prepared.copyWith(size: stat.size);
  }

  Future<_PreparedCmsMedia> _prepareLocalDocument({
    required String sourcePath,
    required String ownerFolder,
    required int rootId,
    required String referenceToken,
    required String clientUploadId,
    String? preferredFileName,
    String? pickedMimeType,
  }) async {
    final contentType = _documentContentTypeFor(sourcePath, pickedMimeType);
    final copiedPath = await _copyToLocalMediaFolder(
      sourcePath: sourcePath,
      ownerFolder: ownerFolder,
      rootId: rootId,
      referenceToken: referenceToken,
      clientUploadId: clientUploadId,
      contentType: contentType,
      preferredFileName: preferredFileName,
    );
    final file = File(copiedPath);
    final stat = await file.stat();
    if (stat.size > AppConst.CmsMediaDocumentMaxBytes) {
      await file.delete().catchError((_) => file);
      throw Exception('Document is larger than the 25 MB mobile upload limit.');
    }

    return _PreparedCmsMedia(
      path: copiedPath,
      contentType: contentType,
      size: stat.size,
    );
  }

  Future<String> _copyToLocalMediaFolder({
    required String sourcePath,
    required String ownerFolder,
    required int rootId,
    required String referenceToken,
    required String clientUploadId,
    required String contentType,
    String? preferredFileName,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw Exception('Selected file no longer exists.');
    }

    final root = await getApplicationDocumentsDirectory();
    final photoDirectory = Directory(
      path.join(root.path, 'CMSMediaUploads', ownerFolder, rootId.toString()),
    );
    await photoDirectory.create(recursive: true);

    final safeBaseName = preferredFileName == null || preferredFileName.trim().isEmpty
        ? '${referenceToken}_$clientUploadId'
        : '${path.basenameWithoutExtension(preferredFileName)}_$clientUploadId';
    final fileName = '$safeBaseName${_extensionForContentType(contentType, preferredFileName ?? sourcePath)}';
    final destinationPath = path.join(photoDirectory.path, fileName);
    await source.copy(destinationPath);
    return destinationPath;
  }

  Future<_PreparedCmsMedia> _stripMetadataForUpload({
    required String localPath,
    required String contentType,
  }) async {
    final file = File(localPath);
    final bytes = await file.readAsBytes();
    final decoded = image_tools.decodeImage(bytes);
    if (decoded == null) {
      await file.delete().catchError((_) => file);
      throw const CmsMediaPhotoFormatException('Selected image could not be decoded. Please capture a JPEG, PNG, or WEBP photo.');
    }

    final normalized = _resizeForUpload(decoded);

    final normalizedPath = path.setExtension(localPath, '.jpg');
    final strippedBytes = image_tools.encodeJpg(normalized, quality: 85);
    await File(normalizedPath).writeAsBytes(strippedBytes, flush: true);

    if (normalizedPath != localPath) {
      await file.delete().catchError((_) => file);
    }

    return _PreparedCmsMedia(
      path: normalizedPath,
      contentType: 'image/jpeg',
      size: strippedBytes.length,
    );
  }

  String _contentTypeFor(String filePath, String? pickedMimeType) {
    final normalizedMime = pickedMimeType?.split(';').first.trim().toLowerCase();
    if (normalizedMime == 'image/heic' || normalizedMime == 'image/heif') {
      throw const CmsMediaPhotoFormatException('HEIC/HEIF photos are not supported. Please capture or select JPEG, PNG, or WEBP.');
    }

    if (normalizedMime == 'image/jpeg' || normalizedMime == 'image/png' || normalizedMime == 'image/webp') {
      return normalizedMime!;
    }

    switch (path.extension(filePath).toLowerCase()) {
      case '.heic':
      case '.heif':
        throw const CmsMediaPhotoFormatException('HEIC/HEIF photos are not supported. Please capture or select JPEG, PNG, or WEBP.');
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      default:
        throw const CmsMediaPhotoFormatException('Unsupported photo type. Please capture or select JPEG, PNG, or WEBP.');
    }
  }

  String _documentContentTypeFor(String filePath, String? pickedMimeType) {
    final normalizedMime = pickedMimeType?.split(';').first.trim().toLowerCase();
    if (normalizedMime != null && normalizedMime.isNotEmpty) {
      switch (normalizedMime) {
        case 'application/pdf':
        case 'application/msword':
        case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        case 'application/vnd.ms-excel':
        case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
        case 'text/plain':
        case 'image/jpeg':
        case 'image/png':
        case 'image/webp':
          return normalizedMime;
      }
    }

    switch (path.extension(filePath).toLowerCase()) {
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.xls':
        return 'application/vnd.ms-excel';
      case '.xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case '.txt':
        return 'text/plain';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      default:
        throw Exception('Unsupported document type. Please select PDF, Word, Excel, text, or image files.');
    }
  }

  String _extensionForContentType(String contentType, String sourcePath) {
    switch (contentType.toLowerCase()) {
      case 'image/png':
        return '.png';
      case 'image/webp':
        return '.webp';
      case 'application/pdf':
        return '.pdf';
      case 'application/msword':
        return '.doc';
      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        return '.docx';
      case 'application/vnd.ms-excel':
        return '.xls';
      case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
        return '.xlsx';
      case 'text/plain':
        return '.txt';
      default:
        final extension = path.extension(sourcePath).toLowerCase();
        if (extension.isNotEmpty) {
          return extension;
        }
        return '.bin';
    }
  }

  image_tools.Image _resizeForUpload(image_tools.Image image) {
    const maxLongEdge = 1920;
    if (image.width <= maxLongEdge && image.height <= maxLongEdge) {
      return image;
    }

    if (image.width >= image.height) {
      return image_tools.copyResize(image, width: maxLongEdge);
    }

    return image_tools.copyResize(image, height: maxLongEdge);
  }

  int _surveyUploadMethodValue(CmsSurveyType surveyType) {
    return surveyType == CmsSurveyType.gatePass ? 2 : 3;
  }

  List<CmsMediaUploadItem> _sortNewestFirst(List<CmsMediaUploadItem> photos) {
    return photos
      ..sort((left, right) {
        final leftDate = left.capturedAtUtc ?? DateTime.fromMillisecondsSinceEpoch(0);
        final rightDate = right.capturedAtUtc ?? DateTime.fromMillisecondsSinceEpoch(0);
        return rightDate.compareTo(leftDate);
      });
  }

  String get _storeName {
    final session = _cmsSessionService.getCached();
    final tenantId = session?.tenant?.id ?? 0;
    final userId = session?.user?.id ?? 0;
    return '${AppConst.DB_CmsMediaUploads}_${tenantId}_$userId';
  }
}

class CmsMediaPhotoFormatException implements Exception {
  const CmsMediaPhotoFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _PreparedCmsMedia {
  const _PreparedCmsMedia({
    required this.path,
    required this.contentType,
    required this.size,
  });

  final String path;
  final String contentType;
  final int size;

  _PreparedCmsMedia copyWith({int? size}) {
    return _PreparedCmsMedia(
      path: path,
      contentType: contentType,
      size: size ?? this.size,
    );
  }
}
