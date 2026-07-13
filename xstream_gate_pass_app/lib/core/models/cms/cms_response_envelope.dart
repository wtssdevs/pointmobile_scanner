import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';

class CmsResponseEnvelope {
  const CmsResponseEnvelope._();

  static Map<String, dynamic> unwrapMap(dynamic response) {
    final root = cmsParseMap(response);
    if (root == null) {
      return const <String, dynamic>{};
    }

    final result = cmsParseMap(root['result']);
    if (result != null) {
      return result;
    }

    final dataMap = cmsParseMap(root['data']);
    if (dataMap != null) {
      return dataMap;
    }

    return root;
  }

  static Map<String, dynamic> unwrapPaged(dynamic response) {
    final root = cmsParseMap(response);
    if (root == null) {
      return const <String, dynamic>{};
    }

    final result = cmsParseMap(root['result']);
    if (result != null) {
      return result;
    }

    final data = root['data'];
    if (data is List) {
      return {
        'items': data,
        'totalCount': cmsParseInt(root['totalCount']) ?? data.length,
      };
    }

    return root;
  }
}
