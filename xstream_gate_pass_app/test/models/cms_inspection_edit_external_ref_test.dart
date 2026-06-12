import 'package:flutter_test/flutter_test.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_inspection_state.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_edit.dart';

void main() {
  group('CmsInspectionEdit externalRef + state -', () {
    test('round-trips externalRef, state, startDateTime, and endDateTime', () {
      final edit = CmsInspectionEdit(
        id: 91,
        externalRef: 'EXT-91',
        state: CmsInspectionState.inProgress,
        startDateTime: DateTime(2026, 5, 18, 8, 30),
        endDateTime: DateTime(2026, 5, 18, 9, 45),
      );

      final json = edit.toJson();
      expect(json['externalRef'], 'EXT-91');
      expect(json['state'], CmsInspectionState.inProgress.value);
      expect(json['startDateTime'],
          DateTime(2026, 5, 18, 8, 30).toIso8601String());
      expect(
          json['endDateTime'], DateTime(2026, 5, 18, 9, 45).toIso8601String());

      final parsed = CmsInspectionEdit.fromJson(json);
      expect(parsed.externalRef, 'EXT-91');
      expect(parsed.state, CmsInspectionState.inProgress);
      expect(parsed.startDateTime, DateTime(2026, 5, 18, 8, 30));
      expect(parsed.endDateTime, DateTime(2026, 5, 18, 9, 45));
    });

    test('parses the state from a backend name', () {
      final parsed =
          CmsInspectionEdit.fromJson(const {'id': 1, 'state': 'Cancelled'});

      expect(parsed.state, CmsInspectionState.cancelled);
      expect(parsed.state?.isCancelled, isTrue);
    });

    test('leaves the new fields null when missing', () {
      final parsed = CmsInspectionEdit.fromJson(const {'id': 1});

      expect(parsed.externalRef, isNull);
      expect(parsed.state, isNull);
      expect(parsed.startDateTime, isNull);
      expect(parsed.endDateTime, isNull);
    });

    test('clone preserves externalRef and state', () {
      final edit = CmsInspectionEdit(
        id: 5,
        externalRef: 'EXT-5',
        state: CmsInspectionState.complete,
      );

      final clone = edit.clone();

      expect(clone.externalRef, 'EXT-5');
      expect(clone.state, CmsInspectionState.complete);
    });
  });
}
