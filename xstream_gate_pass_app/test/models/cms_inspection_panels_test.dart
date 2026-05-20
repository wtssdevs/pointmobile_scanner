import 'package:flutter_test/flutter_test.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_panel_definition.dart';

void main() {
  group('CmsInspectionPanels unfolded net -', () {
    test('renders six primary IICL surfaces and keeps fallback panels hidden',
        () {
      expect(CmsInspectionPanels.values.map((panel) => panel.code), [
        'RFT',
        'FNT',
        'LSD',
        'DOR',
        'FLR',
        'RSD',
      ]);
      expect(CmsInspectionPanels.values, hasLength(6));
      expect(CmsInspectionPanels.byCode('INT')?.isPrimary, isFalse);
      expect(CmsInspectionPanels.byCode('T'), CmsInspectionPanels.roof);
      expect(CmsInspectionPanels.byCode('D'), CmsInspectionPanels.rear);
    });

    test('normalizes reference SVG coordinates into tap regions', () {
      expect(CmsInspectionPanels.roof.left, closeTo(92 / 380, 0.0001));
      expect(CmsInspectionPanels.roof.top, closeTo(10 / 252, 0.0001));
      expect(CmsInspectionPanels.floor.height, closeTo(38 / 252, 0.0001));
      expect(CmsInspectionPanels.rightSide.top, closeTo(163 / 252, 0.0001));
    });

    test('resolves rear door sub-regions using smallest matching target', () {
      expect(CmsInspectionPanels.rear.subRegionAt(0.46, 0.50)?.code, 'DLR');
      expect(CmsInspectionPanels.rear.subRegionAt(0.06, 0.50)?.code, 'DHN');
      expect(CmsInspectionPanels.rear.subRegionAt(0.30, 0.50)?.code, 'DLF');
      expect(CmsInspectionPanels.rear.subRegionAt(0.70, 0.50)?.code, 'DRD');
      expect(CmsInspectionPanels.rear.subRegionAt(0.50, 0.04)?.code, 'DHB');
      expect(CmsInspectionPanels.rear.subRegionAt(0.50, 0.94)?.code, 'DSL');
    });

    test('matches legacy and CEDEX-style location values to primary panels',
        () {
      expect(
        CmsInspectionPanels.matchLocation(code: 'RFT', name: 'Roof')?.code,
        'RFT',
      );
      expect(
        CmsInspectionPanels.matchLocation(code: 'RFT')?.code,
        'RFT',
      );
      expect(
        CmsInspectionPanels.matchLocation(code: 'L123', name: 'Left side panel')
            ?.code,
        'LSD',
      );
      expect(
        CmsInspectionPanels.matchLocation(code: 'DOR', name: 'Door panel')
            ?.code,
        'DOR',
      );
    });
  });
}
