import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/core/models/account/AuthenticateResultModel.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_condition_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/inspection_location.dart';
import 'package:xstream_gate_pass_app/core/services/api/cms_api_manager.dart';
import 'package:xstream_gate_pass_app/core/services/database/sembast_store.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_sync_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_session_service.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';
import 'package:xstream_gate_pass_app/core/services/shared/local_storage_service.dart';

import '../../helpers/cms_test_data.dart';
import '../../helpers/test_helpers.mocks.dart';

void main() {
  group('CmsMasterFilesSyncService -', () {
    late Database database;
    late CmsMasterFilesRepository repository;
    late CmsMasterFilesSyncService service;
    late MockCmsApiManager cmsApiManager;
    late MockCmsSessionService cmsSessionService;
    late MockLocalStorageService localStorageService;
    final session = buildCmsSessionModel();
    const context = CmsSyncContext(tenantId: 7, userId: 42);

    setUp(() async {
      await locator.reset();
      database = await databaseFactoryMemory.openDatabase(
        'cms_master_files_sync_${DateTime.now().microsecondsSinceEpoch}',
      );
      locator.registerSingleton<AppDatabase>(_FakeAppDatabase(database));
      repository = CmsMasterFilesRepository();
      locator.registerSingleton<CmsMasterFilesRepository>(repository);

      cmsApiManager = MockCmsApiManager();
      cmsSessionService = MockCmsSessionService();
      localStorageService = MockLocalStorageService();
      locator.registerSingleton<CmsApiManager>(cmsApiManager);
      locator.registerSingleton<CmsSessionService>(cmsSessionService);
      locator.registerSingleton<LocalStorageService>(localStorageService);

      when(cmsSessionService.getCached()).thenReturn(session);
      when(localStorageService.getAuthTokenForPortal(AuthPortal.cms)).thenReturn(
        AuthenticateResultModel(accessToken: 'token', tenantId: 7, userId: 42),
      );
      when(localStorageService.getTenantIdForPortal(AuthPortal.cms)).thenReturn(7);

      service = CmsMasterFilesSyncService();
    });

    tearDown(() async {
      await database.close();
      await locator.reset();
    });

    test('pages a store and prunes stale rows after complete success', () async {
      await repository.upsertMany(
        CmsMasterFileStores.locations,
        const [
          InspectionLocation(id: 9999, tenantId: 7, code: 'OLD', name: 'Old'),
        ],
        context,
      );

      final requestedOffsets = <int>[];
      when(cmsApiManager.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((invocation) async {
        final parameters = invocation.namedArguments[#queryParameters] as Map<String, dynamic>?;
        final skip = parameters?['skip'] as int? ?? 0;
        final take = parameters?['take'] as int? ?? 500;
        requestedOffsets.add(skip);
        return {
          'data': buildInspectionLocationPage(skip: skip, take: take, total: 1001),
          'totalCount': 1001,
        };
      });

      final result = await service.syncStore(
        CmsMasterFileStores.locations,
        force: true,
      );

      final ids = await repository.getIds(CmsMasterFileStores.locations, context);
      final meta = await repository.getMeta(CmsMasterFileStores.locations, context);

      expect(result.success, isTrue);
      expect(requestedOffsets, [0, 500, 1000]);
      expect(ids.contains(9999), isFalse);
      expect(ids.length, 1001);
      expect(meta?.lastSuccessfulSyncAt, isNotNull);
      expect(meta?.serverTotalCount, 1001);
    });

    test('uses POST for condition types and skips paging query params', () async {
      Map<String, dynamic>? capturedQueryParameters;
      dynamic capturedData;

      when(cmsApiManager.post(
        CmsMasterFileStores.conditionTypes.endpoint,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((invocation) async {
        capturedData = invocation.namedArguments[#data];
        capturedQueryParameters = invocation.namedArguments[#queryParameters] as Map<String, dynamic>?;

        return {
          'result': [
            {
              'id': 1,
              'name': 'UC',
              'displayName': 'Under Control',
            },
            {
              'id': 2,
              'name': 'AVWASH',
              'displayName': 'Available Wash',
            },
          ],
        };
      });

      final result = await service.syncStore(
        CmsMasterFileStores.conditionTypes,
        force: true,
      );

      final ids = await repository.getIds(CmsMasterFileStores.conditionTypes, context);
      final firstCondition = await repository.getById(
        CmsMasterFileStores.conditionTypes,
        context,
        1,
      );

      expect(result.success, isTrue);
      expect(capturedData, isNull);
      expect(capturedQueryParameters, isNull);
      expect(ids, {1, 2});
      expect(firstCondition, isA<CmsConditionType>());
      expect(firstCondition?.displayName, 'Under Control');

      verify(cmsApiManager.post(
        CmsMasterFileStores.conditionTypes.endpoint,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onSendProgress: anyNamed('onSendProgress'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: false,
      )).called(1);

      verifyNever(cmsApiManager.get(
        CmsMasterFileStores.conditionTypes.endpoint,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      ));
    });

    test('does not prune stale rows when a later page fails', () async {
      await repository.upsertMany(
        CmsMasterFileStores.locations,
        const [
          InspectionLocation(id: 9999, tenantId: 7, code: 'OLD', name: 'Old'),
        ],
        context,
      );

      when(cmsApiManager.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((invocation) async {
        final parameters = invocation.namedArguments[#queryParameters] as Map<String, dynamic>?;
        final skip = parameters?['skip'] as int? ?? 0;
        final take = parameters?['take'] as int? ?? 500;
        if (skip == 500) {
          throw Exception('page 2 failed');
        }
        return {
          'data': buildInspectionLocationPage(skip: skip, take: take, total: 501),
          'totalCount': 501,
        };
      });

      final result = await service.syncStore(
        CmsMasterFileStores.locations,
        force: true,
      );

      final ids = await repository.getIds(CmsMasterFileStores.locations, context);
      final meta = await repository.getMeta(CmsMasterFileStores.locations, context);

      expect(result.success, isFalse);
      expect(ids.contains(9999), isTrue);
      expect(meta?.lastSuccessfulSyncAt, isNull);
      expect(meta?.lastError, isNotNull);
    });

    test('returns alreadyRunning when another sync is in flight', () async {
      final completer = Completer<void>();
      when(cmsApiManager.get(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
        cancelToken: anyNamed('cancelToken'),
        onReceiveProgress: anyNamed('onReceiveProgress'),
        showLoader: anyNamed('showLoader'),
      )).thenAnswer((_) async {
        await completer.future;
        return {
          'data': const <Map<String, dynamic>>[],
          'totalCount': 0,
        };
      });

      final first = service.syncAll(force: true);
      final second = await service.syncAll(force: true);
      completer.complete();
      await first;

      expect(second.alreadyRunning, isTrue);
    });
  });
}

class _FakeAppDatabase extends AppDatabase {
  _FakeAppDatabase(this.database);

  final Database database;

  @override
  Database? get db => database;
}
