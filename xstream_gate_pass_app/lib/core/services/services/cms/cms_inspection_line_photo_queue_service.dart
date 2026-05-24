import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_photo.dart';
import 'package:xstream_gate_pass_app/core/models/cms/media/cms_media_upload_item.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_media_upload_queue_service.dart';

@LazySingleton()
class CmsInspectionLinePhotoQueueService {
  final log = getLogger('CmsInspectionLinePhotoQueueService');
  final CmsMediaUploadQueueService _mediaQueueService = locator<CmsMediaUploadQueueService>();

  Future<CmsInspectionLinePhoto?> capturePhotoForLine({
    required int inspectionId,
    required CmsInspectionLineEdit line,
    bool fromGallery = false,
  }) async {
    final item = await _mediaQueueService.captureInspectionLinePhoto(
      inspectionId: inspectionId,
      line: line,
      fromGallery: fromGallery,
    );
    return item?.toInspectionPhoto();
  }

  Future<void> upsert(CmsInspectionLinePhoto photo) async {
    await _mediaQueueService.upsert(CmsMediaUploadItem.fromInspectionPhoto(photo));
  }

  Future<List<CmsInspectionLinePhoto>> getForLine(CmsInspectionLineEdit line) async {
    final items = await _mediaQueueService.getForInspectionLine(line);
    return items.map((item) => item.toInspectionPhoto()).toList(growable: false);
  }

  Future<List<CmsInspectionLinePhoto>> getForInspection(int inspectionId) async {
    final items = await _mediaQueueService.getForInspection(inspectionId);
    return items.map((item) => item.toInspectionPhoto()).toList(growable: false);
  }

  Future<List<CmsInspectionLinePhoto>> getAll() async {
    final items = await _mediaQueueService.getAll();
    return items
        .where((item) => item.ownerType == CmsMediaUploadOwnerType.inspectionLine)
        .map((item) => item.toInspectionPhoto())
        .toList(growable: false);
  }

  Future<void> remapSavedLines(CmsInspectionEdit inspection) async {
    await _mediaQueueService.remapSavedInspectionLines(inspection);
  }

  Future<int> uploadPendingForInspection(int inspectionId) async {
    return _mediaQueueService.uploadPendingForInspection(inspectionId);
  }

  Future<CmsInspectionLinePhoto> uploadPhoto(CmsInspectionLinePhoto photo) async {
    final item = await _mediaQueueService.uploadItem(CmsMediaUploadItem.fromInspectionPhoto(photo));
    return item.toInspectionPhoto();
  }

  Future<void> deletePhoto(CmsInspectionLinePhoto photo) async {
    await _mediaQueueService.deleteItem(
      CmsMediaUploadItem.fromInspectionPhoto(photo),
    );
  }
}
