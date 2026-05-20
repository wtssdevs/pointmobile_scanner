import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/models/cms/account/cms_current_login_information.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_line_edit.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/ui/bottom_sheets/cms_inspection_line_editor/cms_inspection_line_editor_sheet.dart';

import '../helpers/cms_test_data.dart';

void main() {
  tearDown(() async {
    await locator.reset();
  });

  testWidgets('cancel returns the typed CMS inspection line sheet response',
      (tester) async {
    locator.registerSingleton<CmsSessionService>(_FakeCmsSessionService());
    locator.registerSingleton<CmsMasterFilesRepository>(
        _FakeCmsMasterFilesRepository());

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
}

class _FakeCmsSessionService extends Fake implements CmsSessionService {
  @override
  CmsCurrentLoginInformation? getCached() => buildCmsSessionModel();
}

class _FakeCmsMasterFilesRepository extends Fake
    implements CmsMasterFilesRepository {}
