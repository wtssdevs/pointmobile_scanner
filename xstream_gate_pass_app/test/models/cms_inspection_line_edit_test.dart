import 'package:flutter_test/flutter_test.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_panel_code.dart';

void main() {
  group('CmsInspectionLineEdit panel metadata -', () {
    test('stores panel metadata in descriptionThree and exposes parsed values',
        () {
      final line = CmsInspectionLineEdit(descriptionOne: 'Dent near seam');

      line.applyPanelMetadata(
        panelCode: 'lsd',
        x: 0.4187,
        y: 0.2154,
      );

      expect(line.descriptionOne, 'Dent near seam');
      expect(line.descriptionThree, 'PANEL:LSD|X:0.419|Y:0.215');
      expect(line.panelCode, 'LSD');
      expect(line.panelX, closeTo(0.419, 0.0001));
      expect(line.panelY, closeTo(0.215, 0.0001));
    });

    test('clears panel metadata without touching normal description text', () {
      final line = CmsInspectionLineEdit(
        descriptionOne: 'Inspector note',
        descriptionThree: 'PANEL:RFT|X:0.500|Y:0.120',
      );

      line.clearPanelMetadata();

      expect(line.descriptionOne, 'Inspector note');
      expect(line.descriptionThree, isNull);
      expect(line.panelCode, isNull);
      expect(line.panelX, isNull);
      expect(line.panelY, isNull);
    });

    test(
        'round-trips transient clientKey without storing it in descriptionThree',
        () {
      final line = CmsInspectionLineEdit(
        clientKey: 'client-line-1',
        descriptionThree: 'PANEL:RSD|X:0.120|Y:0.340',
      );

      final json = line.toJson();
      final parsed = CmsInspectionLineEdit.fromJson(json);

      expect(json['clientKey'], 'client-line-1');
      expect(parsed.clientKey, 'client-line-1');
      expect(parsed.descriptionThree, 'PANEL:RSD|X:0.120|Y:0.340');
      expect(parsed.descriptionThree, isNot(contains('client-line-1')));
    });

    test('round-trips the externalRef field', () {
      final line = CmsInspectionLineEdit(
        externalRef: 'EXT-LINE-1',
        descriptionOne: 'Dent near seam',
      );

      final json = line.toJson();
      final parsed = CmsInspectionLineEdit.fromJson(json);

      expect(json['externalRef'], 'EXT-LINE-1');
      expect(parsed.externalRef, 'EXT-LINE-1');
    });
  });

  group('CmsInspectionPanelCode -', () {
    test('maps stable panel codes to SVG ids and seed filters', () {
      final rightSide = CmsInspectionPanelCode.fromCode('rsd');

      expect(rightSide, CmsInspectionPanelCode.rightSide);
      expect(rightSide!.svgElementId, 'panel_RSD');
      expect(rightSide.cedexPrefix, 'R');
      expect(rightSide.matchesLocation(code: 'RX1N', name: 'Right side panel'),
          isTrue);
      expect(rightSide.matchesLocation(code: 'LXXX', name: 'Left side panel'),
          isFalse);
    });
  });
}
