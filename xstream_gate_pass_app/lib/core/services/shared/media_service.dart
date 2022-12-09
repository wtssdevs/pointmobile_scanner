import 'dart:io';
import 'dart:typed_data';

import 'package:add_to_gallery/add_to_gallery.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app_config/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:camera/camera.dart';

@LazySingleton()
class MediaService {
  final log = getLogger('EnvironmentService');
  List<CameraDescription> _cameras = <CameraDescription>[];
  List<CameraDescription> get cameras => _cameras;

  Future<void> int() async {
    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }
    } on CameraException catch (e) {
      log.e(e.code, e.description);
    }
  }

  Future getStoragePermissions() async {
    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }
  }

  Future<XFile?> getImage({required bool fromGallery}) async {
    await getStoragePermissions();
    return await ImagePicker().pickImage(source: fromGallery ? ImageSource.gallery : ImageSource.camera, maxHeight: 1280, maxWidth: 960, imageQuality: 90);
  }

  Future<List<XFile>?> pickMultiImages() async {
    await getStoragePermissions();
    return await ImagePicker().pickMultiImage(maxHeight: 1280, maxWidth: 960, imageQuality: 90);
  }

  Future<XFile?> getImageAsThumbnail({required bool fromGallery}) async {
    await getStoragePermissions();
    return await ImagePicker().pickImage(imageQuality: 80, source: fromGallery ? ImageSource.gallery : ImageSource.camera);
  }

  Future<XFile?> saveFileToLocal(XFile? pickedFile) async {
    // Step 2: Check for valid file
    if (pickedFile == null) return null;

    Directory dir = await getApplicationDocumentsDirectory();
    // Step 3: Get directory where we can duplicate selected file.

    final String path = dir.path;

    // 4. Create a File from PickedFile so you can save the file locally
    // This is a new/additional step.
    final fileName = basename(pickedFile.path);
    XFile tmpFile = XFile(pickedFile.path);

    // 5. Get the path to the apps directory so we can save the file to it.

    // final String fileExtension = extension(pickedFile.path); // e.g. '.jpg'

    // 6. Save the file by copying it to the new location on the device.

    await tmpFile.saveTo('$path/$fileName');

    return tmpFile;
  }

  Future<String?> imageSave(Uint8List imageAsBytes) async {
    final Directory extDir = await getTemporaryDirectory();
    final testDir = await Directory('${extDir.path}/TMS_Images').create(recursive: true);
    var fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String filePath = '${testDir.path}/$fileName';

    File(filePath).writeAsBytesSync(imageAsBytes);

    final file = File(filePath);

    File addToGalleryFile = await AddToGallery.addToGallery(
      originalFile: file,
      albumName: AppConst.App_Gallery_Album,
      deleteOriginalFile: true,
    );

    return addToGalleryFile.path;
  }
}
