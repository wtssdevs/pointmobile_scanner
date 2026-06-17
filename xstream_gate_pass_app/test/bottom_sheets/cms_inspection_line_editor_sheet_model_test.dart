import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/models/cms/account/cms_current_login_information.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_panel_definition.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_item_code.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/inspection_location.dart';
import 'package:xstream_gate_pass_app/core/services/database/sembast_store.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';
import 'package:xstream_gate_pass_app/ui/bottom_sheets/cms_inspection_line_editor/cms_inspection_line_editor_sheet_model.dart';

import '../helpers/cms_test_data.dart';

void main() {
  group('CmsInspectionLineEditorSheetModel -', () {
    late Database database;
    late CmsMasterFilesRepository repository;
    const context = CmsSyncContext(tenantId: 7, userId: 42);

    setUp(() async {
      await locator.reset();
      database = await databaseFactoryMemory.openDatabase(
        'cms_line_editor_model_${DateTime.now().microsecondsSinceEpoch}',
      );
      locator.registerSingleton<AppDatabase>(_FakeAppDatabase(database));
      repository = CmsMasterFilesRepository();
      locator.registerSingleton<CmsMasterFilesRepository>(repository);
      locator.registerSingleton<CmsSessionService>(_FakeCmsSessionService());
    });

    tearDown(() async {
      await database.close();
      await locator.reset();
    });

    test('scopes classification lookups by selected shipping line', () async {
      final model = CmsInspectionLineEditorSheetModel();

      await model.initialise(shippingLineId: 55);

      expect(model.locationDataSource.shippingLineId, 55);
      expect(model.locationDataSource.filterByShippingLine, isTrue);
      expect(model.itemDataSource.shippingLineId, 55);
      expect(model.itemDataSource.filterByShippingLine, isTrue);
      expect(model.actionDataSource.shippingLineId, 55);
      expect(model.actionDataSource.filterByShippingLine, isTrue);
      expect(model.damageDataSource.shippingLineId, 55);
      expect(model.damageDataSource.filterByShippingLine, isTrue);
      expect(model.partNumberDataSource.filterByShippingLine, isFalse);

      model.dispose();
    });

    test('selects part number from synced item-code lookup', () async {
      await repository.upsertMany(
        CmsMasterFileStores.itemCodes,
        const [
          CmsItemCode(
            id: 10,
            tenantId: 7,
            code: 'PN-10',
            description: 'Door seal',
          ),
        ],
        context,
      );
      final model = CmsInspectionLineEditorSheetModel();
      await model.initialise(shippingLineId: 55);

      await model.selectPartNumber(10);

      expect(model.line.partNumber, 'PN-10');
      expect(model.partNumberHint, 'PN-10');

      await model.selectPartNumber(null);
      expect(model.line.partNumber, isNull);

      model.dispose();
    });

    Future<void> seedLocations(List<InspectionLocation> locations) {
      return repository.upsertMany(
        CmsMasterFileStores.locations,
        locations,
        context,
      );
    }

    InspectionLocation location(
      int id, {
      required String name,
      required String code,
    }) {
      return InspectionLocation.fromJson(
        buildInspectionLocationJson(id,
            name: name, code: code, shippingLineId: 55),
      );
    }

    test('auto-selects the only location matching the tapped panel', () async {
      await seedLocations([location(7, name: 'ROOF', code: 'RFT')]);
      final model = CmsInspectionLineEditorSheetModel();

      await model.initialise(
        shippingLineId: 55,
        initialPanelCode: CmsInspectionPanels.roof.code,
        initialLocationMatchTerms: const ['ROOF'],
      );

      expect(model.line.inspectionLocationId, 7);
      expect(model.line.inspectionLocationName, 'ROOF');
      expect(model.locationDataSource.seedSearchTerm, isNull);
      expect(model.panelContextHelper, contains('prefilled'));

      model.dispose();
    });

    test('seeds the location search instead of guessing when ambiguous',
        () async {
      await seedLocations([
        location(1, name: 'ROOF FRONT', code: 'RF1'),
        location(2, name: 'ROOF REAR', code: 'RF2'),
      ]);
      final model = CmsInspectionLineEditorSheetModel();

      await model.initialise(
        shippingLineId: 55,
        initialPanelCode: CmsInspectionPanels.roof.code,
        initialLocationMatchTerms: const ['ROOF'],
      );

      expect(model.line.inspectionLocationId, isNull);
      expect(model.locationDataSource.seedSearchTerm, 'roof');
      expect(model.panelContextHelper, contains('filtered'));

      model.dispose();
    });

    test('leaves location and seed untouched when nothing matches', () async {
      await seedLocations([location(3, name: 'GASKET', code: 'GSK')]);
      final model = CmsInspectionLineEditorSheetModel();

      await model.initialise(
        shippingLineId: 55,
        initialPanelCode: CmsInspectionPanels.roof.code,
        initialLocationMatchTerms: const ['ROOF'],
      );

      expect(model.line.inspectionLocationId, isNull);
      expect(model.locationDataSource.seedSearchTerm, isNull);

      model.dispose();
    });
  });
}

class _FakeAppDatabase extends AppDatabase {
  _FakeAppDatabase(this.database);

  final Database database;

  @override
  Database? get db => database;
}

class _FakeCmsSessionService extends Fake implements CmsSessionService {
  @override
  CmsCurrentLoginInformation? getCached() => buildCmsSessionModel();
}
