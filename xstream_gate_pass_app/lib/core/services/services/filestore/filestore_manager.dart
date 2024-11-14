import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/services/filestore/filestore_repository.dart';

@LazySingleton()
class FileStoreManager {
  final log = getLogger('FileStoreManager');
  final ApiManager _apiManager = locator<ApiManager>();
  final FileStoreRepository _fileStoreRepository =
      locator<FileStoreRepository>();

  Future<void> uploadImageToServer(String refId) async {
    var fileStore = await _fileStoreRepository.getByRefId(refId);

    if (fileStore != null) {
      await _apiManager.uploadLoadImages(fileStore);
      fileStore.upLoaded = true;
      await _fileStoreRepository.update(fileStore);
    }
  }

  Future<void> clearOld() async {
    await _fileStoreRepository.clearOldImages();
  }

  Future<void> deleteImagesOnServer(int stepId, String fileName) async {
    final Map<String, dynamic> queryParameters = <String, dynamic>{};
    queryParameters['searchValue'] = fileName;
    queryParameters['refreanceId'] = stepId;

    await _apiManager.post("/api/services/app/FileStore/StepImageDelete",
        data: queryParameters, showLoader: false);
  }
}
