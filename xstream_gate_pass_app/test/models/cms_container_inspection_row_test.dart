import 'package:flutter_test/flutter_test.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_inspection_state.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_container_inspection_bundle.dart';

void main() {
  group('CmsContainerInspectionRow', () {
    test('parses state and reports Cancelled status', () {
      final row = CmsContainerInspectionRow.fromJson(<String, dynamic>{
        'id': 5,
        'inspectionType': 0,
        'inspectionCompleted': false,
        'state': CmsInspectionState.cancelled.value,
      });

      expect(row.state, CmsInspectionState.cancelled);
      expect(row.isCancelled, isTrue);
      expect(row.statusLabel, 'Cancelled');
    });

    test('open inspection reports In progress', () {
      final row = CmsContainerInspectionRow.fromJson(<String, dynamic>{
        'id': 6,
        'inspectionType': 0,
        'inspectionCompleted': false,
        'state': CmsInspectionState.inProgress.value,
      });

      expect(row.isCancelled, isFalse);
      expect(row.statusLabel, 'In progress');
    });

    test('completed inspection reports Completed even with null state', () {
      final row = CmsContainerInspectionRow.fromJson(<String, dynamic>{
        'id': 7,
        'inspectionType': 0,
        'inspectionCompleted': true,
      });

      expect(row.state, isNull);
      expect(row.statusLabel, 'Completed');
    });
  });
}
