import 'dart:convert';
import 'package:sembast/timestamp.dart';
import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class FileStore {
  FileStore(
      {required this.path,
      required this.tempPath,
      required this.desc,
      required this.fileName,
      this.upLoaded = false,
      required this.createdDateTime,
      this.latitude,
      this.longitude,
      this.id = "",
      this.thumbnailPath = "",
      this.imageAsBase64String = "",
      required this.refId,
      required this.referanceId,
      required this.filestoreType});

  factory FileStore.fromJson(Map<String, dynamic> jsonRes) => FileStore(
        path: asT<String>(jsonRes['path']) ?? "",
        desc: asT<String>(jsonRes['desc']) ?? "",
        tempPath: asT<String?>(jsonRes['tempPath']) ?? "",
        fileName: asT<String?>(jsonRes['fileName']) ?? "",
        thumbnailPath: asT<String?>(jsonRes['thumbnailPath']) ?? "",
        imageAsBase64String: asT<String?>(jsonRes['imageAsBase64String']) ?? "",
        upLoaded: asT<bool>(jsonRes['upLoaded']) ?? false,
        id: asT<String>(jsonRes['id']) ?? "",
        refId: asT<String>(jsonRes['refId']) ?? '',
        referanceId: asT<int>(jsonRes['referanceId']) ?? 0,
        latitude: asT<double?>(jsonRes['latitude']),
        longitude: asT<double?>(jsonRes['longitude']),
        filestoreType: asT<int>(jsonRes['filestoreType']) ?? 0,
        createdDateTime:
            Timestamp.tryAnyAsTimestamp((jsonRes['createdDateTime'])) ??
                Timestamp.fromDateTime(DateTime.now()),
      );

  String fileName;
  String desc;
  String tempPath;
  String thumbnailPath;
  String imageAsBase64String;
  String path;
  bool upLoaded;
  String id;
  Timestamp createdDateTime;
  String refId; //step
  int referanceId; //stop
  int filestoreType;
  double? latitude;
  double? longitude;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'path': path,
        'desc': desc,
        'tempPath': tempPath,
        'fileName': fileName,
        'thumbnailPath': thumbnailPath,
        'imageAsBase64String': imageAsBase64String,
        'upLoaded': upLoaded,
        'id': id,
        'refId': refId,
        'referanceId': referanceId,
        'latitude': latitude,
        'longitude': longitude,
        'filestoreType': filestoreType,
        'createdDateTime': createdDateTime.toIso8601String(),
      };
}
