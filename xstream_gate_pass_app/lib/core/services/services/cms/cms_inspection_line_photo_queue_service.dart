import 'dart:io';

import 'package:image/image.dart' as image_tools;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_photo.dart';
import 'package:xstream_gate_pass_app/core/services/database/sembast_store.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_file_store_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/shared/guid_generator.dart';
import 'package:xstream_gate_pass_app/core/services/shared/media_service.dart';

@LazySingleton()
class CmsInspectionLinePhotoQueueService {
  final log = getLogger('CmsInspectionLinePhotoQueueService');

  final AppDatabase _appDatabase = locator<AppDatabase>();
  final MediaService _mediaService = locator<MediaService>();
  final CmsMobileFileStoreService _mobileFileStoreService =
      locator<CmsMobileFileStoreService>();
  final CmsSessionService _cmsSessionService = locator<CmsSessionService>();

  StoreRef<String, Map<String, dynamic>> get _store =>
      stringMapStoreFactory.store(_storeName);

  Future<CmsInspectionLinePhoto?> capturePhotoForLine({
    required int inspectionId,
    required CmsInspectionLineEdit line,
    bool fromGallery = false,
  }) async {
    final pickedFile = await _mediaService.getImage(fromGallery: fromGallery);
    if (pickedFile == null) {
      return null;
    }

    if (inspectionId <= 0) {
      throw Exception('Save or start the inspection before attaching photos.');
    }

    final clientUploadId = Guid.newGuidAsString;
    if (line.id <= 0 &&
        (line.clientKey == null || line.clientKey!.trim().isEmpty)) {
      line.clientKey = Guid.newGuidAsString;
    }

    final contentType = _contentTypeFor(pickedFile.path, pickedFile.mimeType);
    final copiedPath = await _copyToLocalPhotoFolder(
      sourcePath: pickedFile.path,
      inspectionId: inspectionId,
      inspectionLineId: line.id,
      clientKey: line.clientKey,
      clientUploadId: clientUploadId,
      contentType: contentType,
    );
    final prepared = await _stripMetadataForUpload(
      localPath: copiedPath,
      contentType: contentType,
    );
    final localPath = prepared.path;
    final file = File(localPath);
    final stat = await file.stat();
    if (stat.size > AppConst.CmsInspectionLinePhotoMaxBytes) {
      await file.delete().catchError((_) => file);
      throw Exception('Photo is larger than the 8 MB mobile upload limit.');
    }

    final photo = CmsInspectionLinePhoto(
      inspectionId: inspectionId,
      inspectionLineId: line.id > 0 ? line.id : null,
      clientKey: line.clientKey,
      clientUploadId: clientUploadId,
      name: path.basenameWithoutExtension(localPath),
      documentFileName: path.basename(localPath),
      documentFileSize: stat.size.toString(),
      documentFileType: prepared.contentType,
      localPath: localPath,
      capturedAtUtc: DateTime.now().toUtc(),
      state: line.id > 0
          ? CmsInspectionLinePhotoState.queued
          : CmsInspectionLinePhotoState.awaitingSave,
    );

    await upsert(photo);
    return photo;
  }

  Future<void> upsert(CmsInspectionLinePhoto photo) async {
    await _store
        .record(photo.clientUploadId)
        .put(_appDatabase.db!, photo.toJson());
  }

  Future<List<CmsInspectionLinePhoto>> getForLine(
      CmsInspectionLineEdit line) async {
    if (line.id > 0) {
      await _mergeRemoteLinePhotos(line);
    }

    final photos = await getAll();
    final lineClientKey = line.clientKey?.trim();
    final lineId = line.id;

    final filtered = photos.where((photo) {
      if (lineId > 0 && photo.inspectionLineId == lineId) {
        return true;
      }

      return lineClientKey != null &&
          lineClientKey.isNotEmpty &&
          photo.clientKey == lineClientKey;
    }).toList(growable: false);

    return _sortNewestFirst(filtered);
  }

  Future<List<CmsInspectionLinePhoto>> getForInspection(
      int inspectionId) async {
    final photos = await getAll();
    return _sortNewestFirst(photos
        .where((photo) => photo.inspectionId == inspectionId)
        .toList(growable: false));
  }

  Future<List<CmsInspectionLinePhoto>> getAll() async {
    final snapshots = await _store.find(_appDatabase.db!);
    return snapshots
        .map((snapshot) => CmsInspectionLinePhoto.fromJson(snapshot.value))
        .toList(growable: false);
  }

  Future<void> remapSavedLines(CmsInspectionEdit inspection) async {
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
      final clientKey = photo.clientKey?.trim();
      if (clientKey == null || clientKey.isEmpty) {
        continue;
      }

      final savedLine = savedLinesByClientKey[clientKey];
      if (savedLine == null || photo.inspectionLineId == savedLine.id) {
        continue;
      }

      await upsert(
        photo.copyWith(
          inspectionId: inspection.id,
          inspectionLineId: savedLine.id,
          state: photo.state == CmsInspectionLinePhotoState.awaitingSave ||
                  photo.state == CmsInspectionLinePhotoState.local
              ? CmsInspectionLinePhotoState.queued
              : photo.state,
          errorMessage: '',
        ),
      );
    }
  }

  Future<int> uploadPendingForInspection(int inspectionId) async {
    final pending = (await getForInspection(inspectionId))
        .where(_isUploadCandidate)
        .toList(growable: false);

    for (var i = 0;
        i < pending.length;
        i += AppConst.CmsInspectionLinePhotoUploadConcurrency) {
      final batch = pending
          .skip(i)
          .take(AppConst.CmsInspectionLinePhotoUploadConcurrency)
          .toList(growable: false);
      await Future.wait(batch.map(_uploadPhotoSafely));
    }

    final remaining =
        (await getForInspection(inspectionId)).where(_isUploadCandidate).length;
    if (remaining > 0) {
      log.w(
          '$remaining CMS inspection line photo upload(s) remain queued or failed after this sync attempt.');
    }

    return remaining;
  }

  Future<CmsInspectionLinePhoto> uploadPhoto(
      CmsInspectionLinePhoto photo) async {
    if (photo.inspectionId == null ||
        photo.inspectionId! <= 0 ||
        photo.inspectionLineId == null ||
        photo.inspectionLineId! <= 0) {
      final awaitingSave = photo.copyWith(
        state: CmsInspectionLinePhotoState.awaitingSave,
        errorMessage:
            'Waiting for the inspection line to be saved before upload.',
      );
      await upsert(awaitingSave);
      return awaitingSave;
    }

    final localPath = photo.localPath;
    if (localPath == null ||
        localPath.isEmpty ||
        !await File(localPath).exists()) {
      final failed = photo.copyWith(
        state: CmsInspectionLinePhotoState.failed,
        errorMessage: 'Local image file is missing.',
      );
      await upsert(failed);
      return failed;
    }

    await upsert(photo.copyWith(
        state: CmsInspectionLinePhotoState.uploading, errorMessage: ''));

    try {
      final uploaded = await _mobileFileStoreService.uploadInspectionLinePhoto(
        inspectionId: photo.inspectionId!,
        inspectionLineId: photo.inspectionLineId!,
        filePath: localPath,
        documentFileName: photo.documentFileName ?? path.basename(localPath),
        contentType: photo.documentFileType ?? _contentTypeFor(localPath, null),
        clientUploadId: photo.clientUploadId,
        capturedAtUtc: photo.capturedAtUtc,
      );

      final completed = uploaded.copyWith(
        inspectionId: photo.inspectionId,
        inspectionLineId: photo.inspectionLineId,
        clientKey: photo.clientKey,
        localPath: photo.localPath,
        capturedAtUtc: photo.capturedAtUtc,
        state: CmsInspectionLinePhotoState.uploaded,
        errorMessage: '',
      );
      await upsert(completed);
      return completed;
    } catch (error) {
      log.e('Failed to upload CMS inspection line photo', error);
      final failed = photo.copyWith(
        state: CmsInspectionLinePhotoState.failed,
        errorMessage: error.toString(),
      );
      await upsert(failed);
      return failed;
    }
  }

  Future<CmsInspectionLinePhoto> _uploadPhotoSafely(
      CmsInspectionLinePhoto photo) async {
    try {
      return await uploadPhoto(photo);
    } catch (error) {
      log.e('Unexpected CMS inspection line photo upload failure', error);
      final failed = photo.copyWith(
        state: CmsInspectionLinePhotoState.failed,
        errorMessage: error.toString(),
      );
      await upsert(failed);
      return failed;
    }
  }

  Future<void> deletePhoto(CmsInspectionLinePhoto photo) async {
    if (photo.documentId != null && photo.documentId! > 0) {
      await _mobileFileStoreService
          .deleteInspectionLinePhoto(photo.documentId!);
    }

    await _store.record(photo.clientUploadId).delete(_appDatabase.db!);
  }

  Future<void> _mergeRemoteLinePhotos(CmsInspectionLineEdit line) async {
    try {
      final remotePhotos =
          await _mobileFileStoreService.listInspectionLinePhotos(line.id);
      for (final remotePhoto in remotePhotos) {
        if (remotePhoto.clientUploadId.trim().isEmpty) {
          continue;
        }

        final existing = await _store
            .record(remotePhoto.clientUploadId)
            .get(_appDatabase.db!);
        final localPhoto =
            existing == null ? null : CmsInspectionLinePhoto.fromJson(existing);
        await upsert(
          remotePhoto.copyWith(
            inspectionId: line.inspectionId ?? localPhoto?.inspectionId,
            inspectionLineId: line.id,
            clientKey: line.clientKey ?? localPhoto?.clientKey,
            localPath: localPhoto?.localPath,
            state: CmsInspectionLinePhotoState.uploaded,
            errorMessage: '',
          ),
        );
      }
    } catch (error) {
      log.w(
          'Unable to refresh remote CMS inspection line photos for line ${line.id}: $error');
    }
  }

  bool _isUploadCandidate(CmsInspectionLinePhoto photo) {
    return photo.inspectionLineId != null &&
        photo.inspectionLineId! > 0 &&
        (photo.state == CmsInspectionLinePhotoState.queued ||
            photo.state == CmsInspectionLinePhotoState.failed);
  }

  Future<String> _copyToLocalPhotoFolder({
    required String sourcePath,
    required int inspectionId,
    required int inspectionLineId,
    required String? clientKey,
    required String clientUploadId,
    required String contentType,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw Exception('Selected image file no longer exists.');
    }

    final root = await getApplicationDocumentsDirectory();
    final photoDirectory = Directory(
        path.join(root.path, 'CMSInspectionPhotos', inspectionId.toString()));
    await photoDirectory.create(recursive: true);

    final lineToken = inspectionLineId > 0
        ? inspectionLineId.toString()
        : 'local_${clientKey ?? 'line'}';
    final fileName =
        '${lineToken}_$clientUploadId${_extensionForContentType(contentType, sourcePath)}';
    final destinationPath = path.join(photoDirectory.path, fileName);
    await source.copy(destinationPath);
    return destinationPath;
  }

  Future<_PreparedInspectionPhoto> _stripMetadataForUpload({
    required String localPath,
    required String contentType,
  }) async {
    final file = File(localPath);
    final bytes = await file.readAsBytes();
    final decoded = image_tools.decodeImage(bytes);
    if (decoded == null) {
      await file.delete().catchError((_) => file);
      throw const CmsInspectionPhotoFormatException(
          'Selected image could not be decoded. Please capture a JPEG, PNG, or WEBP photo.');
    }

    final normalizedPath = path.setExtension(localPath, '.jpg');
    final strippedBytes = image_tools.encodeJpg(decoded, quality: 90);
    await File(normalizedPath).writeAsBytes(strippedBytes, flush: true);

    if (normalizedPath != localPath) {
      await file.delete().catchError((_) => file);
    }

    return _PreparedInspectionPhoto(
      path: normalizedPath,
      contentType: 'image/jpeg',
    );
  }

  String _contentTypeFor(String filePath, String? pickedMimeType) {
    final normalizedMime =
        pickedMimeType?.split(';').first.trim().toLowerCase();
    if (normalizedMime == 'image/heic' || normalizedMime == 'image/heif') {
      throw const CmsInspectionPhotoFormatException(
          'HEIC/HEIF photos are not supported for inspection uploads. Please capture or select JPEG, PNG, or WEBP.');
    }

    if (normalizedMime == 'image/jpeg' ||
        normalizedMime == 'image/png' ||
        normalizedMime == 'image/webp') {
      return normalizedMime!;
    }

    switch (path.extension(filePath).toLowerCase()) {
      case '.heic':
      case '.heif':
        throw const CmsInspectionPhotoFormatException(
            'HEIC/HEIF photos are not supported for inspection uploads. Please capture or select JPEG, PNG, or WEBP.');
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      default:
        throw const CmsInspectionPhotoFormatException(
            'Unsupported inspection photo type. Please capture or select JPEG, PNG, or WEBP.');
    }
  }

  String _extensionForContentType(String contentType, String sourcePath) {
    switch (contentType.toLowerCase()) {
      case 'image/png':
        return '.png';
      case 'image/webp':
        return '.webp';
      default:
        return path.extension(sourcePath).toLowerCase() == '.jpeg'
            ? '.jpeg'
            : '.jpg';
    }
  }

  List<CmsInspectionLinePhoto> _sortNewestFirst(
      List<CmsInspectionLinePhoto> photos) {
    return photos
      ..sort((left, right) {
        final leftDate =
            left.capturedAtUtc ?? DateTime.fromMillisecondsSinceEpoch(0);
        final rightDate =
            right.capturedAtUtc ?? DateTime.fromMillisecondsSinceEpoch(0);
        return rightDate.compareTo(leftDate);
      });
  }

  String get _storeName {
    final session = _cmsSessionService.getCached();
    final tenantId = session?.tenant?.id ?? 0;
    final userId = session?.user?.id ?? 0;
    return '${AppConst.DB_CmsInspectionLinePhotos}_${tenantId}_$userId';
  }
}

class CmsInspectionPhotoFormatException implements Exception {
  const CmsInspectionPhotoFormatException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _PreparedInspectionPhoto {
  const _PreparedInspectionPhoto({
    required this.path,
    required this.contentType,
  });

  final String path;
  final String contentType;
}
