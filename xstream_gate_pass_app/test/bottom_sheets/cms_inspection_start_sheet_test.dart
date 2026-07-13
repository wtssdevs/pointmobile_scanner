import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/models/cms/account/cms_current_login_information.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_container_inspection_bundle.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_condition_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_lookup_base.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_start_mode.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_start_inspection_input.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';
import 'package:xstream_gate_pass_app/ui/bottom_sheets/cms_inspection_start/cms_inspection_start_sheet.dart';

import '../helpers/cms_test_data.dart';

void main() {
  const reeferBundle = CmsContainerInspectionBundle(
    containerId: 502,
    containerNo: 'MSCU7654321',
    transactionNo: 'EMP-002',
    canStartInspection: true,
    isReefer: true,
  );

  Widget buildSheet({
    required CmsContainerInspectionBundle bundle,
    CmsInspectionStartMode? lockedMode,
    void Function(SheetResponse)? completer,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CmsInspectionStartSheet(
          request: SheetRequest<dynamic>(
            title: 'Start inspection',
            data: <String, dynamic>{
              'bundle': bundle,
              'lockedMode': lockedMode,
            },
          ),
          completer: completer ?? (_) {},
        ),
      ),
    );
  }

  void registerFakes() {
    locator.registerSingleton<CmsSessionService>(_FakeCmsSessionService());
    locator.registerSingleton<CmsMasterFilesRepository>(
        _FakeCmsMasterFilesRepository());
  }

  tearDown(() async {
    await locator.reset();
  });

  testWidgets('cancel returns the typed CMS inspection start sheet response',
      (tester) async {
    registerFakes();
    SheetResponse<dynamic>? capturedResponse;

    await tester.pumpWidget(buildSheet(
      bundle: const CmsContainerInspectionBundle(
        containerId: 501,
        containerNo: 'MSCU1234567',
        transactionNo: 'EMP-001',
        canStartInspection: true,
        isReefer: true,
      ),
      completer: (response) => capturedResponse = response,
    ));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Cancel'));
    await tester.tap(find.text('Cancel'));

    expect(capturedResponse, isA<SheetResponse<CmsStartInspectionInput>>());
    expect(capturedResponse?.confirmed, isFalse);
  });

  testWidgets('reefer bundles show the mechanical start option and mode tiles',
      (tester) async {
    registerFakes();

    await tester.pumpWidget(buildSheet(bundle: reeferBundle));
    await tester.pumpAndSettle();

    expect(find.text('Start mode'), findsOneWidget);
    expect(find.text('Mechanical only'), findsOneWidget);
  });

  testWidgets('locked default mode hides the mode tiles', (tester) async {
    registerFakes();

    await tester.pumpWidget(buildSheet(
      bundle: reeferBundle,
      lockedMode: CmsInspectionStartMode.defaultMode,
    ));
    await tester.pumpAndSettle();

    expect(find.text('Start mode'), findsNothing);
    expect(find.text('Mechanical only'), findsNothing);
    expect(find.text(CmsInspectionStartMode.defaultMode.description),
        findsOneWidget);
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
