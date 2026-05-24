import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_condition_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_filter.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_start_inspection_input.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/devextreme_load_result.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_inspections_service.dart';

import '../../helpers/test_helpers.mocks.dart';

void main() {
  group('CmsMobileInspectionsService -', () {
    late MockCmsApiManager cmsApiManager;
    late CmsMobileInspectionsService service;

    setUp(() {
      cmsApiManager = MockCmsApiManager();
      service = CmsMobileInspectionsService(cmsApiManager);
    });

    test('parses ABP-wrapped paged list response', () async {
      when(cmsApiManager.post(
        AppConst.CmsGetInspectableContainers,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => {
            'result': {
              'totalCount': 2,
              'items': [
                {
                  'containerId': 101,
                  'containerNo': 'MSCU1234567',
                  'transactionNo': 'EMP-001',
                  'inspectionType': 0,
                  'inspectionTypeName': 'Structural',
                  'canStartInspection': true,
                  'cardStatus': 'Ready',
                },
                {
                  'containerId': 102,
                  'containerNo': 'MSCU7654321',
                  'transactionNo': 'EMP-002',
                  'inspectionId': 77,
                  'parentInspectionId': 70,
                  'inspectionType': 1,
                  'inspectionTypeName': 'Mechanical',
                  'canResumeInspection': true,
                  'cardStatus': 'InProgress',
                },
              ],
            },
          });

      final page = await service.getInspectableContainers(
        CmsInspectionFilter(depotId: 99),
      );

      expect(page.totalCount, 2);
      expect(page.items.length, 2);
      expect(page.items.first.containerNo, 'MSCU1234567');
      expect(page.items.first.inspectionType, CmsInspectionType.structural);
      expect(page.items.last.inspectionId, 77);
      expect(page.items.last.inspectionType, CmsInspectionType.mechanical);
      expect(page.items.last.parentInspectionId, 70);
    });

    test('parses raw paged list response', () async {
      when(cmsApiManager.post(
        AppConst.CmsGetInspectableContainers,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => {
            'totalCount': 1,
            'items': [
              {
                'containerId': 201,
                'containerNo': 'OOLU1234567',
                'transactionNo': 'EMP-201',
                'inspectionCompleted': true,
                'cardStatus': 'Completed',
              },
            ],
          });

      final page = await service.getInspectableContainers(
        CmsInspectionFilter(depotId: 5, pageSize: 10),
      );

      expect(page.totalCount, 1);
      expect(page.totalPages, 1);
      expect(page.items.single.isCompleted, isTrue);
    });

    test('falls back to DevExtreme-style data and totalCount shape', () async {
      when(cmsApiManager.post(
        AppConst.CmsGetInspectableContainers,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => {
            'data': [
              {
                'containerId': 301,
                'containerNo': 'TGHU1234567',
                'transactionNo': 'EMP-301',
                'cardStatus': 'Ready',
              },
            ],
            'totalCount': 1,
          });

      final page = await service.getInspectableContainers(
        CmsInspectionFilter(depotId: 1),
      );

      expect(page.items.single.containerId, 301);
      expect(page.totalCount, 1);
    });

    test('maps inspection edit payload with lines', () async {
      when(cmsApiManager.post(
        AppConst.CmsGetInspectionForEdit,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => {
            'result': {
              'id': 88,
              'containerId': 501,
              'containerNo': 'HLXU1234567',
              'containerSize': '40',
              'containerType': 'HC',
              'containerIsoType': '45G1',
              'inspectionDateTime': '2026-05-18T08:30:00Z',
              'conditionTypeId': 12,
              'conditionDisplayName': 'Under Control',
              'inspectionType': 0,
              'inspectionTypeName': 'Structural',
              'items': [
                {
                  'id': 9001,
                  'inspectionId': 88,
                  'inspectionLocationId': 3,
                  'inspectionLocationName': 'Roof',
                  'inspectionItemId': 4,
                  'inspectionItemName': 'Panel',
                  'inspectionActionId': 5,
                  'inspectionActionName': 'Repair',
                  'inspectionDamageId': 6,
                  'inspectionDamageName': 'Dent',
                  'qty': 2,
                  'cost': 10.5,
                  'labourQty': 1,
                  'labourRate': 50,
                },
              ],
            },
          });

      final edit = await service.getInspectionForEdit(88);

      expect(edit.id, 88);
      expect(edit.containerId, 501);
      expect(edit.containerSize, '40');
      expect(edit.containterType, 'HC');
      expect(edit.containerIsoType, '45G1');
      expect(edit.inspectionType, CmsInspectionType.structural);
      expect(edit.inspectionTypeLabel, 'Structural');
      expect(edit.conditionDisplayName, 'Under Control');
      expect(edit.conditionLabel, 'Under Control');
      expect(edit.items.length, 1);
      expect(edit.items.single.inspectionActionName, 'Repair');
      expect(edit.items.single.estimatedSubtotal, 71);
    });

    test('posts typed start payload and parses returned inspection metadata',
        () async {
      when(cmsApiManager.post(
        AppConst.CmsStartInspectionForContainer,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => {
            'result': {
              'id': 91,
              'containerId': 501,
              'containerNo': 'HLXU1234567',
              'conditionTypeId': 12,
              'conditionName': 'UC',
              'conditionDisplayName': 'Under Control',
              'inspectionType': 0,
              'inspectionTypeName': 'Structural',
              'items': [],
            },
          });

      final edit = await service.startInspection(
        const CmsStartInspectionInput(
          id: 501,
          inspectionType: CmsInspectionType.structural,
          conditionTypeId: 12,
          conditionName: 'UC',
          conditionDisplayName: 'Under Control',
        ),
      );

      final verification = verify(cmsApiManager.post(
        AppConst.CmsStartInspectionForContainer,
        data: captureAnyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      ));
      verification.called(1);
      final payload = verification.captured.single as Map<String, dynamic>;

      expect(payload, {
        'id': 501,
        'inspectionType': 0,
        'conditionTypeId': 12,
      });
      expect(edit.id, 91);
      expect(edit.inspectionType, CmsInspectionType.structural);
      expect(edit.conditionDisplayName, 'Under Control');
    });

    test('parses ABP result lists for condition sync responses', () {
      final loadResult = DevExtremeLoadResult<CmsConditionType>.fromDynamic(
        {
          'result': [
            {
              'id': 1,
              'name': 'UC',
              'displayName': 'Under Control',
            },
            {
              'id': 2,
              'name': 'AVWASH',
              'displayName': 'Available Wash',
            },
          ],
        },
        CmsConditionType.fromJson,
      );

      expect(loadResult.totalCount, 2);
      expect(loadResult.data.length, 2);
      expect(loadResult.data.first.name, 'UC');
      expect(loadResult.data.first.displayName, 'Under Control');
      expect(loadResult.data.last.displayName, 'Available Wash');
    });
  });
}
