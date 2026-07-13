import 'package:flutter_test/flutter_test.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_item_code.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/inspection_item.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/inspection_location.dart';
import 'package:xstream_gate_pass_app/core/services/database/sembast_store.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_lookup_data_source.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';

void main() {
  group('CmsLookupDataSource -', () {
    late Database database;
    late CmsMasterFilesRepository repository;
    late CmsLookupDataSource<InspectionLocation> dataSource;
    const context = CmsSyncContext(tenantId: 7, userId: 42);

    setUp(() async {
      await locator.reset();
      database = await databaseFactoryMemory.openDatabase(
        'cms_lookup_data_source_${DateTime.now().microsecondsSinceEpoch}',
      );
      locator.registerSingleton<AppDatabase>(_FakeAppDatabase(database));
      repository = CmsMasterFilesRepository();
      dataSource = CmsLookupDataSource<InspectionLocation>(
        repository: repository,
        store: CmsMasterFileStores.locations,
        context: context,
        pageSize: 2,
      );

      await repository.upsertMany(
        CmsMasterFileStores.locations,
        const [
          InspectionLocation(
              id: 1, tenantId: 7, code: 'AA', name: 'Alpha Roof'),
          InspectionLocation(
              id: 2, tenantId: 7, code: 'AB', name: 'Alpha Side'),
          InspectionLocation(
              id: 3, tenantId: 7, code: 'BA', name: 'Beta Floor'),
        ],
        context,
      );
    });

    tearDown(() async {
      await database.close();
      await locator.reset();
    });

    test('returns paged dropdown items from local lookup search', () async {
      final pageOne = await dataSource.paginatedRequest(1, 'Alpha');
      final pageTwo = await dataSource.paginatedRequest(2, 'Alpha');

      expect(pageOne.length, 2);
      expect(pageOne.first.value, 1);
      expect(pageOne.first.label, 'AA - Alpha Roof');
      expect(pageTwo, isEmpty);
    });

    test('loads the selected item by id', () async {
      final selected = await dataSource.getSelectedItem(3);

      expect(selected, isA<SearchableDropdownMenuItem<int>>());
      expect(selected?.value, 3);
      expect(selected?.label, 'BA - Beta Floor');
    });

    test('returns item-code lookup items from local sync storage', () async {
      await repository.upsertMany(
        CmsMasterFileStores.itemCodes,
        const [
          CmsItemCode(
              id: 10, tenantId: 7, code: 'PN-10', description: 'Roof patch'),
          CmsItemCode(
              id: 11, tenantId: 7, code: 'PN-11', description: 'Door seal'),
        ],
        context,
      );
      final itemCodeDataSource = CmsLookupDataSource<CmsItemCode>(
        repository: repository,
        store: CmsMasterFileStores.itemCodes,
        context: context,
      );

      final results = await itemCodeDataSource.paginatedRequest(1, 'door');

      expect(results.single.value, 11);
      expect(results.single.label, 'PN-11 - Door seal');
    });
  });

  // Documents the inspection-line lookup filter: only ACTIVE rows are offered,
  // and global (null shipping-line) rows pull through for any shipping line.
  // So an active global row appears, an inactive row does not (it must be
  // activated in the CMS admin), and rows for a different shipping line never
  // appear.
  group('CmsLookupDataSource shipping-line + active filtering -', () {
    late Database database;
    late CmsMasterFilesRepository repository;
    const context = CmsSyncContext(tenantId: 7, userId: 42);
    const requestedShippingLineId = 5;

    setUp(() async {
      await locator.reset();
      database = await databaseFactoryMemory.openDatabase(
        'cms_lookup_active_${DateTime.now().microsecondsSinceEpoch}',
      );
      locator.registerSingleton<AppDatabase>(_FakeAppDatabase(database));
      repository = CmsMasterFilesRepository();

      await repository.upsertMany(
        CmsMasterFileStores.items,
        const [
          // Inactive global — hidden (must be activated in CMS admin to appear).
          InspectionItem(
              id: 1, tenantId: 7, code: 'GI', name: 'Global Inactive',
              isActive: false),
          // Active global (null shipping line) — pulls through for any line.
          InspectionItem(
              id: 2, tenantId: 7, code: 'GA', name: 'Global Active',
              isActive: true),
          // Active, specific to the requested shipping line.
          InspectionItem(
              id: 3, tenantId: 7, code: 'SP', name: 'Specific Active',
              isActive: true, shippingLineId: requestedShippingLineId),
          // Active, but for a different shipping line — must never appear.
          InspectionItem(
              id: 4, tenantId: 7, code: 'OT', name: 'Other Line',
              isActive: true, shippingLineId: 99),
        ],
        context,
      );
    });

    tearDown(() async {
      await database.close();
      await locator.reset();
    });

    test(
        'offers active rows for the shipping line plus active globals, hiding '
        'inactive rows and other shipping lines', () async {
      final dataSource = CmsLookupDataSource<InspectionItem>(
        repository: repository,
        store: CmsMasterFileStores.items,
        context: context,
        shippingLineId: requestedShippingLineId,
        filterByShippingLine: true,
      );

      final results = await dataSource.paginatedRequest(1, '');
      final ids = results.map((e) => e.value).toList()..sort();

      expect(ids, [2, 3]); // active global + active specific
      expect(ids, isNot(contains(1))); // inactive global hidden
      expect(ids, isNot(contains(4))); // other shipping line hidden
    });
  });
}

class _FakeAppDatabase extends AppDatabase {
  _FakeAppDatabase(this.database);

  final Database database;

  @override
  Database? get db => database;
}
