import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/models/cms/account/cms_current_login_information.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_condition_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspectable_container.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_lookup_base.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_start_inspection_input.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';
import 'package:xstream_gate_pass_app/ui/bottom_sheets/cms_inspection_start/cms_inspection_start_sheet.dart';

import '../helpers/cms_test_data.dart';

void main() {
  tearDown(() async {
    await locator.reset();
  });

  testWidgets('cancel returns the typed CMS inspection start sheet response', (tester) async {
    locator.registerSingleton<CmsSessionService>(_FakeCmsSessionService());
    locator.registerSingleton<CmsMasterFilesRepository>(
      _FakeCmsMasterFilesRepository(),
    );

    SheetResponse<dynamic>? capturedResponse;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CmsInspectionStartSheet(
            request: SheetRequest<CmsInspectableContainer>(
              title: 'Start Structural inspection',
              data: const CmsInspectableContainer(
                containerId: 501,
                containerNo: 'MSCU1234567',
                transactionNo: 'EMP-001',
                inspectionType: CmsInspectionType.structural,
                inspectionTypeName: 'Structural',
                canStartInspection: true,
                cardStatus: 'Ready',
              ),
            ),
            completer: (response) => capturedResponse = response,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Cancel'));
    await tester.tap(find.text('Cancel'));

    expect(capturedResponse, isA<SheetResponse<CmsStartInspectionInput>>());
    expect(capturedResponse?.confirmed, isFalse);
  });
}

class _FakeCmsSessionService extends Fake implements CmsSessionService {
  @override
  CmsCurrentLoginInformation? getCached() => buildCmsSessionModel();
}

class _FakeCmsMasterFilesRepository extends Fake implements CmsMasterFilesRepository {
  @override
  Future<List<T>> getAll<T extends CmsInspectionLookupBase>(
    CmsMasterFileStore<T> store,
    CmsSyncContext context, {
    bool activeOnly = true,
    int? shippingLineId,
    bool filterByShippingLine = false,
  }) async {
    if (store.storeBase == CmsMasterFileStores.conditionTypes.storeBase) {
      return <T>[
        const CmsConditionType(
          id: 1,
          name: 'UC',
          conditionDisplayName: 'Under Control',
        ) as T,
      ];
    }

    return <T>[];
  }
}
