import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/services/database/sembast_store.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/inspection_location.dart';

void main() {
  group('CmsMasterFilesRepository -', () {
    late Database database;
    late CmsMasterFilesRepository repository;
    const context = CmsSyncContext(tenantId: 7, userId: 42);

    setUp(() async {
      await locator.reset();
      database = await databaseFactoryMemory.openDatabase(
        'cms_master_files_repo_${DateTime.now().microsecondsSinceEpoch}',
      );
      locator.registerSingleton<AppDatabase>(_FakeAppDatabase(database));
      repository = CmsMasterFilesRepository();
    });

    tearDown(() async {
      await database.close();
      await locator.reset();
    });

    test('upserts, filters, and isolates data by tenant/user store', () async {
      await repository.upsertMany(
        CmsMasterFileStores.locations,
        const [
          InspectionLocation(
            id: 1,
            tenantId: 7,
            code: 'A',
            name: 'Alpha',
            isActive: true,
            shippingLineId: null,
          ),
          InspectionLocation(
            id: 2,
            tenantId: 7,
            code: 'B',
            name: 'Beta',
            isActive: false,
            shippingLineId: 55,
          ),
          InspectionLocation(
            id: 3,
            tenantId: 7,
            code: 'C',
            name: 'Charlie',
            isActive: true,
            shippingLineId: 55,
          ),
        ],
        context,
      );

      final activeItems = await repository.getAll(
        CmsMasterFileStores.locations,
        context,
      );
      final shippingLineItems = await repository.getAll(
        CmsMasterFileStores.locations,
        context,
        shippingLineId: 55,
      );
      final otherContextIds = await repository.getIds(
        CmsMasterFileStores.locations,
        const CmsSyncContext(tenantId: 8, userId: 42),
      );

      expect(activeItems.map((item) => item.id), [1, 3]);
      expect(shippingLineItems.map((item) => item.id), [1, 3]);
      expect(otherContextIds, isEmpty);
    });

    test('deleteByIds only affects the targeted store', () async {
      await repository.upsertMany(
        CmsMasterFileStores.locations,
        const [
          InspectionLocation(id: 10, tenantId: 7, code: 'X', name: 'X'),
          InspectionLocation(id: 11, tenantId: 7, code: 'Y', name: 'Y'),
        ],
        context,
      );

      await repository.deleteByIds(
        CmsMasterFileStores.locations,
        context,
        {10},
      );

      final ids = await repository.getIds(CmsMasterFileStores.locations, context);
      expect(ids, {11});
    });
  });
}

class _FakeAppDatabase extends AppDatabase {
  _FakeAppDatabase(this.database);

  final Database database;

  @override
  Database? get db => database;
}
