import 'package:flutter_test/flutter_test.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_inspection_state.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_container_inspection_bundle.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspectable_container.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_history_row.dart';

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

  group('CmsInspectionHistoryRow statusLabel', () {
    test('completed wins over a stale Pending state', () {
      final row = CmsInspectionHistoryRow.fromJson(<String, dynamic>{
        'id': 11,
        'inspectionCompleted': true,
        'state': CmsInspectionState.pending.value,
      });

      expect(row.inspectionCompleted, isTrue);
      expect(row.state, CmsInspectionState.pending);
      expect(row.statusLabel, 'Completed');
    });

    test('cancelled takes top priority even when completed', () {
      final row = CmsInspectionHistoryRow.fromJson(<String, dynamic>{
        'id': 12,
        'inspectionCompleted': true,
        'state': CmsInspectionState.cancelled.value,
      });

      expect(row.statusLabel, 'Cancelled');
    });

    test('in-progress state reports In progress', () {
      final row = CmsInspectionHistoryRow.fromJson(<String, dynamic>{
        'id': 13,
        'inspectionCompleted': false,
        'state': CmsInspectionState.inProgress.value,
      });

      expect(row.statusLabel, 'In progress');
    });

    test('falls back to In progress when not completed and state is null', () {
      final row = CmsInspectionHistoryRow.fromJson(<String, dynamic>{
        'id': 14,
        'inspectionCompleted': false,
      });

      expect(row.state, isNull);
      expect(row.statusLabel, 'In progress');
    });
  });

  group('CmsInspectableContainer last-inspection label', () {
    String? labelFor({required Map<String, dynamic> json}) {
      final container = CmsInspectableContainer.fromJson(<String, dynamic>{
        'containerId': 1,
        'containerNo': 'TEST1234567',
        'transactionNo': 'TXN1',
        'lastInspectionId': 99,
        ...json,
      });

      // _lastInspectionStatusLabel is private; assert via the public summary.
      return container.lastInspectionSummary;
    }

    test('completed wins over a stale Pending state', () {
      final summary = labelFor(json: <String, dynamic>{
        'lastInspectionCompleted': true,
        'lastInspectionState': CmsInspectionState.pending.value,
      });

      expect(summary, contains('Completed'));
      expect(summary, isNot(contains('Pending')));
    });

    test('cancelled takes top priority even when completed', () {
      final summary = labelFor(json: <String, dynamic>{
        'lastInspectionCompleted': true,
        'lastInspectionState': CmsInspectionState.cancelled.value,
      });

      expect(summary, contains('Cancelled'));
      expect(summary, isNot(contains('Completed')));
    });

    test('in-progress state reports In progress', () {
      final summary = labelFor(json: <String, dynamic>{
        'lastInspectionCompleted': false,
        'lastInspectionState': CmsInspectionState.inProgress.value,
      });

      expect(summary, contains('In progress'));
    });

    test('reports In progress when not completed and state is null', () {
      final summary = labelFor(json: <String, dynamic>{
        'lastInspectionCompleted': false,
      });

      expect(summary, contains('In progress'));
    });
  });
}
