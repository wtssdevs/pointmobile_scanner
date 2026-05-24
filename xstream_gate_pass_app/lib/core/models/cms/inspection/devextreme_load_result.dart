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
    final rawMap = cmsParseMap(source);
    final resultMap = rawMap == null ? null : cmsParseMap(rawMap['result']);
    final recordsSource = rawMap?['data'] ??
        rawMap?['items'] ??
        resultMap?['data'] ??
        resultMap?['items'] ??
        rawMap?['result'] ??
        source;
    final records =
        cmsParseMapList(recordsSource).map(fromJson).toList(growable: false);

    return DevExtremeLoadResult<T>(
      data: records,
      totalCount: cmsParseInt(rawMap?['totalCount']) ??
          cmsParseInt(resultMap?['totalCount']) ??
          records.length,
    );
  }

  final List<T> data;
  final int totalCount;
}
