import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_panel_definition.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/inspections/detail/widgets/cms_container_schematic_view.dart';

void main() {
  testWidgets('renders the compact schematic without flex overflow',
      (tester) async {
    final originalOnError = FlutterError.onError;
    final flutterErrors = <FlutterErrorDetails>[];
    FlutterError.onError = flutterErrors.add;
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              child: CmsContainerSchematicView(
                containerLabel: 'MSCU1234567 • 40HQ refrigerated container',
                lines: [
                  CmsInspectionLineEdit(
                    id: 1,
                    inspectionLocationCode: 'RFT',
                    inspectionLocationName: 'Roof',
                    inspectionItemName: 'Panel',
                    inspectionActionName: 'Repair',
                    inspectionDamageName: 'Dent',
                  )..applyPanelMetadata(
                      panelCode: CmsInspectionPanels.roof.code,
                      x: 0.5,
                      y: 0.12,
                    ),
                ],
                onPanelTap: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final overflowErrors = flutterErrors.where(
      (error) => error.exceptionAsString().contains('RenderFlex overflowed'),
    );
    expect(overflowErrors, isEmpty);
  });
}
