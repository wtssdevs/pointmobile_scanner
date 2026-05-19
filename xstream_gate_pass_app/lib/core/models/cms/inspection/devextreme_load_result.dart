import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';

class DevExtremeLoadResult<T> {
  DevExtremeLoadResult({
    required this.data,
    required this.totalCount,
  });

  factory DevExtremeLoadResult.fromDynamic(
    dynamic source,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final rawMap = cmsParseMap(source) ?? const <String, dynamic>{};
    final payload = cmsParseMap(rawMap['result'])?['data'] != null && rawMap['data'] == null ? cmsParseMap(rawMap['result']) ?? rawMap : rawMap;

    final records = cmsParseMapList(payload['data']).map(fromJson).toList(growable: false);

    return DevExtremeLoadResult<T>(
      data: records,
      totalCount: cmsParseInt(payload['totalCount']) ?? records.length,
    );
  }

  final List<T> data;
  final int totalCount;
}
