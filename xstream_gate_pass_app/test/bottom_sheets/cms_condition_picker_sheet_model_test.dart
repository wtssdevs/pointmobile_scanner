import 'package:flutter_test/flutter_test.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_condition_type.dart';
import 'package:xstream_gate_pass_app/ui/bottom_sheets/cms_condition_picker/cms_condition_picker_sheet_model.dart';

void main() {
  const conditions = [
    CmsConditionType(id: 1, code: 'AV', name: 'Available'),
    CmsConditionType(id: 10, code: 'UC', name: 'Under Control'),
    CmsConditionType(id: 2, code: 'AV WASH', name: 'Available after wash'),
  ];

  group('CmsConditionPickerSheetModel -', () {
    test('exposes all conditions and the current selection by default', () {
      final model = CmsConditionPickerSheetModel()..initialise(conditions, 10);

      expect(model.visibleConditions, hasLength(3));
      expect(model.selectedConditionId, 10);
    });

    test('search filters by code and display name (case-insensitive)', () {
      final model = CmsConditionPickerSheetModel()..initialise(conditions, null);

      model.search('wash');
      expect(model.visibleConditions.map((c) => c.id), [2]);

      model.search('AV');
      expect(model.visibleConditions.map((c) => c.id), unorderedEquals([1, 2]));

      model.search('   ');
      expect(model.visibleConditions, hasLength(3));
    });
  });
}
