import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/enums/filestore_type.dart';
import 'package:xstream_gate_pass_app/core/models/basefiles/filestore/filestore.dart';
import 'package:xstream_gate_pass_app/core/services/services/filestore/filestore_repository.dart';
import 'package:xstream_gate_pass_app/ui/views/shared/localization/app_view_base_helper.dart';

class ImagesViewerListViewModel extends BaseViewModel with AppViewBaseHelper {
  final String gatePassId;
  ImagesViewerListViewModel({required this.gatePassId});
  List<FileStore> _fileStoreItems = <FileStore>[];
  List<FileStore> get fileStoreItems => _fileStoreItems;
  final _fileStoreRepository = locator<FileStoreRepository>();

  Future<void> loadFileStoreImages() async {
    _fileStoreItems = await _fileStoreRepository.getAll(
        gatePassId, FileStoreType.gatePassAccessDriverLicenceImage, 100);
  }

  Future<void> runStartupLogic() async {
    await loadFileStoreImages();
    rebuildUi();
  }
}
