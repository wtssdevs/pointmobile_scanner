import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_file_store_service.dart';

import '../../helpers/test_helpers.mocks.dart';

void main() {
  group('CmsMobileFileStoreService -', () {
    late MockCmsApiManager cmsApiManager;
    late CmsMobileFileStoreService service;

    setUp(() {
      cmsApiManager = MockCmsApiManager();
      service = CmsMobileFileStoreService(cmsApiManager);
    });

    test('parses ABP-wrapped line photo metadata list', () async {
      when(cmsApiManager.get(
        AppConst.cmsInspectionLinePhotosForLine(9001),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => {
            'result': [
              {
                'id': 501,
                'referanceID': 9001,
                'name': 'door dent.jpg',
                'documentFileName': '9001_11111111-1111-1111-1111-111111111111.jpg',
                'documentFileType': 'jpg',
                'documentFileSize': '0.42 MB',
                'clientUploadId': '11111111-1111-1111-1111-111111111111',
                'externalPath': '/api/mobile/inspections/files/download/501',
              }
            ]
          });

      final photos = await service.listInspectionLinePhotos(9001);

      expect(photos, hasLength(1));
      expect(photos.single.documentId, 501);
      expect(photos.single.inspectionLineId, 9001);
      expect(photos.single.clientUploadId, '11111111-1111-1111-1111-111111111111');
      expect(photos.single.externalPath, '/api/mobile/inspections/files/download/501');
    });
  });
}
