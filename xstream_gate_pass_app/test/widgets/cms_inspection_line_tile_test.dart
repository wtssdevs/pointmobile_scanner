import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/detail/widgets/cms_inspection_line_tile.dart';

void main() {
  testWidgets('renders narrow damage line card without flex overflow',
      (tester) async {
    final line = CmsInspectionLineEdit(
      inspectionLocationName: 'BOTTOM',
      inspectionItemName: 'CONTROL BOX DOOR (BCA)',
      inspectionDamageName: 'DENT',
      inspectionActionName: 'REPAIR',
      qty: 1,
      cost: 0,
      labourQty: 0,
      labourRate: 0,
    )..applyPanelMetadata(panelCode: 'RFT');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 330,
              child: CmsInspectionLineTile(
                line: line,
                photoCount: 0,
                onAddPhoto: () {},
                onEdit: () {},
                onDuplicate: () {},
                onDelete: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('BOTTOM'), findsOneWidget);
    expect(find.byTooltip('Add photo'), findsOneWidget);
    expect(find.byTooltip('Edit line'), findsOneWidget);

    for (final tooltip in [
      'Add photo',
      'Edit line',
      'Duplicate line',
      'Delete line',
    ]) {
      final button = find.ancestor(
        of: find.byTooltip(tooltip),
        matching: find.byType(IconButton),
      );
      expect(button, findsOneWidget);
      final size = tester.getSize(button);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    }
  });
}
