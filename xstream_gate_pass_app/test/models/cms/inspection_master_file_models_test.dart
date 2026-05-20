import 'package:flutter_test/flutter_test.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_item_code.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/devextreme_load_result.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/inspection_action.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/inspection_item.dart';

import '../../helpers/cms_test_data.dart';

void main() {
  group('CMS inspection models -', () {
    test('parses numeric and date fields for inspection actions', () {
      final action = InspectionAction.fromJson(
        buildInspectionActionJson(1, labourRate: '12.5', cost: 4),
      );

      expect(action.id, 1);
      expect(action.labourRate, 12.5);
      expect(action.cost, 4);
      expect(action.creationTime, isNotNull);
      expect(action.lastModificationTime, isNotNull);
    });

    test('preserves shippingLineID and itemCodeId for inspection items', () {
      final item = InspectionItem.fromJson(
        buildInspectionItemJson(2, shippingLineId: 55),
      );

      expect(item.shippingLineId, 55);
      expect(item.itemCodeId, 502);
      expect(item.toJson()['shippingLineID'], 55);
    });

    test('parses item codes for local sync and lookup display', () {
      final itemCode = CmsItemCode.fromJson(
        buildItemCodeJson(
          12,
          code: 'PN-12',
          description: 'Door gasket',
          quantity: '2',
          unitPrice: '35.50',
          labourRate: 18,
          grossWeight: '1.25',
        ),
      );

      expect(itemCode.id, 12);
      expect(itemCode.code, 'PN-12');
      expect(itemCode.description, 'Door gasket');
      expect(itemCode.quantity, 2);
      expect(itemCode.unitPrice, 35.5);
      expect(itemCode.labourRate, 18);
      expect(itemCode.grossWeight, 1.25);
      expect(itemCode.displayName, 'PN-12 - Door gasket');
      expect(itemCode.toJson()['description'], 'Door gasket');
    });

    test('parses raw and wrapped DevExtreme load results', () {
      final raw = DevExtremeLoadResult<InspectionItem>.fromDynamic(
        {
          'data': [buildInspectionItemJson(1)],
          'totalCount': 1,
        },
        InspectionItem.fromJson,
      );
      final wrapped = DevExtremeLoadResult<InspectionItem>.fromDynamic(
        {
          'result': {
            'data': [buildInspectionItemJson(2)],
            'totalCount': 1,
          }
        },
        InspectionItem.fromJson,
      );

      expect(raw.totalCount, 1);
      expect(raw.data.single.id, 1);
      expect(wrapped.totalCount, 1);
      expect(wrapped.data.single.id, 2);
    });
  });
}
