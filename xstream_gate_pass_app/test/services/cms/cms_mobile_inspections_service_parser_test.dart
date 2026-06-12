import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_condition_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_filter.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_start_mode.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_type.dart';
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

    test('parses ABP-wrapped paged container summaries', () async {
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
                  'canStartInspection': true,
                },
                {
                  'containerId': 102,
                  'containerNo': 'MSCU7654321',
                  'transactionNo': 'EMP-002',
                  'resumeInspectionId': 77,
                  'resumeInspectionTypeName': 'Mechanical',
                  'canResumeInspection': true,
                  'lastInspectionId': 77,
                  'lastInspectionType': 1,
                  'lastInspectionTypeName': 'Mechanical',
                  'lastInspectionCompleted': false,
                  'lastInspectionState': 1,
                  'lastInspectionInspectedBy': 'Jane Inspector',
                  'lastInspectionConditionTypeName': 'AVWASH',
                  'lastInspectionIsCurrentVisit': true,
                  'isReefer': true,
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
      expect(page.items.first.canStartInspection, isTrue);
      expect(page.items.first.hasLastInspection, isFalse);
      expect(page.items.last.resumeInspectionId, 77);
      expect(page.items.last.resumeInspectionTypeLabel, 'Mechanical');
      expect(page.items.last.inspectionType, CmsInspectionType.mechanical);
      expect(page.items.last.hasLastInspection, isTrue);
      expect(page.items.last.lastInspectionType, CmsInspectionType.mechanical);
      expect(page.items.last.lastInspectionInspectedBy, 'Jane Inspector');
      expect(page.items.last.lastInspectionConditionTypeName, 'AVWASH');
      expect(page.items.last.lastInspectionIsCurrentVisit, isTrue);
      expect(page.items.last.isReefer, isTrue);
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
                'canStartInspection': true,
                'isReefer': true,
              },
            ],
          });

      final page = await service.getInspectableContainers(
        CmsInspectionFilter(depotId: 5, pageSize: 10),
      );

      expect(page.totalCount, 1);
      expect(page.totalPages, 1);
      expect(page.items.single.hasLastInspection, isFalse);
      expect(page.items.single.canStartInspection, isTrue);
    });

    test('parses container inspection bundle and hides placeholder rows',
        () async {
      when(cmsApiManager.post(
        AppConst.CmsGetContainerInspectionBundle,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async => {
            'result': {
              'containerId': 501,
              'containerNo': 'HLXU1234567',
              'transactionNo': 'EMP-501',
              'statusName': 'EMPTY',
              'statusDisplayName': 'Empty',
              'shippingLineCode': 'MSK',
              'shippingLineName': 'Maersk',
              'containerSize': '40',
              'containerType': 'HC',
              'containerIsoType': '45G1',
              'conditionTypeName': 'AV',
              'isReefer': true,
              'canStartInspection': true,
              'inspections': [
                {
                  'id': 900,
                  'inspectionType': 0,
                  'inspectionTypeName': 'Structural',
                  'transactionNo': 'INSP-900',
                  'inspectionCompleted': true,
                  'isPlaceholderStructural': true,
                },
                {
                  'id': 901,
                  'parentId': 900,
                  'inspectionType': 1,
                  'inspectionTypeName': 'Mechanical',
                  'transactionNo': 'INSP-901',
                  'inspectionCompleted': true,
                },
              ],
            },
          });

      final bundle = await service.getContainerInspections(501);

      expect(bundle.containerId, 501);
      expect(bundle.inspections.length, 2);
      expect(bundle.visibleInspections.length, 1);
      expect(bundle.visibleInspections.single.id, 901);
      expect(bundle.visibleInspections.single.inspectionType,
          CmsInspectionType.mechanical);
      expect(bundle.hasExistingInspections, isTrue);
      expect(bundle.statusLabel, 'Empty');
      expect(bundle.shippingLineCode, 'MSK');
      expect(bundle.containerType, 'HC');
      expect(bundle.containerIsoType, '45G1');
    });

    test('parses paged container inspection history rows', () async {
      when(cmsApiManager.post(
        AppConst.CmsGetContainerInspectionHistory,
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
                  'id': 910,
                  'inspectionType': 0,
                  'inspectionTypeName': 'Structural',
                  'transactionNo': 'INSP-910',
                  'inspectionCompleted': false,
                  'state': 1,
                  'inspectedBy': 'Jane Inspector',
                  'conditionTypeName': 'AV',
                  'isCurrentVisit': true,
                },
                {
                  'id': 905,
                  'inspectionType': 1,
                  'inspectionTypeName': 'Mechanical',
                  'transactionNo': 'INSP-905',
                  'inspectionCompleted': true,
                  'state': 2,
                  'isCurrentVisit': false,
                },
              ],
            },
          });

      final page = await service.getContainerInspectionHistory(
          containerId: 501, pageNumber: 1);

      expect(page.totalCount, 2);
      expect(page.items.length, 2);
      expect(page.items.first.id, 910);
      expect(page.items.first.typeLabel, 'Structural');
      expect(page.items.first.statusLabel, 'In progress');
      expect(page.items.first.isCurrentVisit, isTrue);
      expect(page.items.first.isOpen, isTrue);
      expect(page.items.last.statusLabel, 'Completed');
      expect(page.items.last.isOpen, isFalse);
    });

    test('maps inspection edit payload using inspection type name fallback',
        () async {
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
              'entryInspectionId': 91,
              'structuralInspectionId': 90,
              'mechanicalInspectionId': 91,
              'structuralTransactionNo': 'INSP-090',
              'mechanicalTransactionNo': 'INSP-091',
              'placeholderStructuralCreated': true,
            },
          });

      final result = await service.startInspection(
        const CmsStartInspectionInput(
          containerId: 501,
          mode: CmsInspectionStartMode.mechanicalOnly,
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
        'containerId': 501,
        'mode': 2,
        'conditionTypeId': 12,
      });
      expect(result.entryInspectionId, 91);
      expect(result.structuralInspectionId, 90);
      expect(result.mechanicalInspectionId, 91);
      expect(result.placeholderStructuralCreated, isTrue);
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
