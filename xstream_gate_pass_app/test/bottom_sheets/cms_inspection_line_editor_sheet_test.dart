import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/models/cms/account/cms_current_login_information.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_lookup_base.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';
import 'package:xstream_gate_pass_app/ui/bottom_sheets/cms_inspection_line_editor/cms_inspection_line_editor_sheet.dart';

import '../helpers/cms_test_data.dart';

void main() {
  tearDown(() async {
    await locator.reset();
  });

  void registerFakes() {
    locator.registerSingleton<CmsSessionService>(_FakeCmsSessionService());
    locator.registerSingleton<CmsMasterFilesRepository>(
        _FakeCmsMasterFilesRepository());
  }

  testWidgets('cancel returns the typed CMS inspection line sheet response',
      (tester) async {
    registerFakes();

    SheetResponse<dynamic>? capturedResponse;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CmsInspectionLineEditorSheet(
            request: SheetRequest<Map<String, dynamic>>(
              title: 'Inspection line',
              data: const <String, dynamic>{},
            ),
            completer: (response) => capturedResponse = response,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Cancel'));
    await tester.tap(find.text('Cancel'));

    expect(capturedResponse, isA<SheetResponse<CmsInspectionLineEdit?>>());
    expect(capturedResponse?.confirmed, isFalse);
  });

  group('advanced costing field (#804-2)', () {
    // Reveals the collapsed advanced costing section and returns a finder for
    // the Cost field. The labelText 'Cost' is a Text node inside the field's
    // InputDecoration, so the field is the TextField ancestor of that Text.
    Future<Finder> revealCostField(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CmsInspectionLineEditorSheet(
              request: SheetRequest<dynamic>(
                title: 'Add inspection line',
                data: const <String, dynamic>{'shippingLineId': 55},
              ),
              completer: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The advanced costing fields are hidden behind a toggle.
      final toggle = find.text('Show advanced costing');
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();

      final costField = find.ancestor(
        of: find.text('Cost'),
        matching: find.byType(TextField),
      );
      expect(costField, findsOneWidget);
      await tester.ensureVisible(costField);
      return costField;
    }

    testWidgets('starts blank (no zero-prefill)', (tester) async {
      registerFakes();

      final costField = await revealCostField(tester);
      final controller = tester.widget<TextField>(costField).controller;

      // #804-2: the field must start empty, not prefilled with '0' / '0.00'.
      expect(controller, isNotNull);
      expect(controller!.text, '');
    });

    testWidgets('typing "150" stays "150" (not "0.0150") — the #804 bug',
        (tester) async {
      registerFakes();

      final costField = await revealCostField(tester);
      final controller = tester.widget<TextField>(costField).controller!;

      // enterText runs the real inputFormatters, so this proves the bug fix
      // end-to-end rather than bypassing the formatter via controller.text.
      await tester.enterText(costField, '150');
      await tester.pump();

      expect(controller.text, '150');
    });

    testWidgets('caps at two decimal places ("12.345" -> "12.34")',
        (tester) async {
      registerFakes();

      final costField = await revealCostField(tester);
      final controller = tester.widget<TextField>(costField).controller!;

      await tester.enterText(costField, '12.345');
      await tester.pump();

      // The currency formatter (^\d*\.?\d{0,2}) rejects the 3rd decimal.
      expect(controller.text, '12.34');
    });

    testWidgets('rejects non-numeric input ("abc" -> "")', (tester) async {
      registerFakes();

      final costField = await revealCostField(tester);
      final controller = tester.widget<TextField>(costField).controller!;

      await tester.enterText(costField, 'abc');
      await tester.pump();

      expect(controller.text, '');
    });
  });
}

class _FakeCmsSessionService extends Fake implements CmsSessionService {
  @override
  CmsCurrentLoginInformation? getCached() => buildCmsSessionModel();
}

class _FakeCmsMasterFilesRepository extends Fake
    implements CmsMasterFilesRepository {
  @override
  Future<List<T>> getAll<T extends CmsInspectionLookupBase>(
    CmsMasterFileStore<T> store,
    CmsSyncContext context, {
    bool activeOnly = true,
    int? shippingLineId,
    bool filterByShippingLine = false,
  }) async =>
      <T>[];
}
