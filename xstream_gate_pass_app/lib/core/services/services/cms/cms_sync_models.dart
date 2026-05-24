import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_condition_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_lookup_base.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_item_code.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/inspection_action.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/inspection_damage.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/inspection_item.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/inspection_location.dart';

class CmsSyncContext {
  const CmsSyncContext({
    required this.tenantId,
    required this.userId,
  });

  final int tenantId;
  final int userId;

  String storeNameFor(String storeBase) => '${storeBase}_${tenantId}_$userId';

  bool matches(CmsSyncContext other) {
    return tenantId == other.tenantId && userId == other.userId;
  }
}

class CmsStoreSyncMeta {
  CmsStoreSyncMeta({
    required this.storeBase,
    required this.storeLabel,
    required this.tenantId,
    required this.userId,
    this.lastAttemptAt,
    this.lastSuccessfulSyncAt,
    this.lastError,
    this.itemCount = 0,
    this.serverTotalCount = 0,
  });

  factory CmsStoreSyncMeta.fromJson(Map<String, dynamic> json) {
    return CmsStoreSyncMeta(
      storeBase: cmsParseString(json['storeBase']) ?? '',
      storeLabel: cmsParseString(json['storeLabel']) ?? '',
      tenantId: cmsParseInt(json['tenantId']) ?? 0,
      userId: cmsParseInt(json['userId']) ?? 0,
      lastAttemptAt: cmsParseDateTime(json['lastAttemptAt']),
      lastSuccessfulSyncAt: cmsParseDateTime(json['lastSuccessfulSyncAt']),
      lastError: cmsParseString(json['lastError']),
      itemCount: cmsParseInt(json['itemCount']) ?? 0,
      serverTotalCount: cmsParseInt(json['serverTotalCount']) ?? 0,
    );
  }

  final String storeBase;
  final String storeLabel;
  final int tenantId;
  final int userId;
  final DateTime? lastAttemptAt;
  final DateTime? lastSuccessfulSyncAt;
  final String? lastError;
  final int itemCount;
  final int serverTotalCount;

  CmsStoreSyncMeta copyWith({
    String? storeBase,
    String? storeLabel,
    int? tenantId,
    int? userId,
    DateTime? lastAttemptAt,
    DateTime? lastSuccessfulSyncAt,
    String? lastError,
    int? itemCount,
    int? serverTotalCount,
    bool clearLastError = false,
  }) {
    return CmsStoreSyncMeta(
      storeBase: storeBase ?? this.storeBase,
      storeLabel: storeLabel ?? this.storeLabel,
      tenantId: tenantId ?? this.tenantId,
      userId: userId ?? this.userId,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastSuccessfulSyncAt: lastSuccessfulSyncAt ?? this.lastSuccessfulSyncAt,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
      itemCount: itemCount ?? this.itemCount,
      serverTotalCount: serverTotalCount ?? this.serverTotalCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeBase': storeBase,
      'storeLabel': storeLabel,
      'tenantId': tenantId,
      'userId': userId,
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
      'lastSuccessfulSyncAt': lastSuccessfulSyncAt?.toIso8601String(),
      'lastError': lastError,
      'itemCount': itemCount,
      'serverTotalCount': serverTotalCount,
    };
  }
}

class CmsSyncProgress {
  const CmsSyncProgress({
    required this.storeBase,
    required this.storeLabel,
    this.pageIndex,
    this.pageCount,
    this.message,
    this.error,
    this.inProgress = false,
    this.completed = false,
    this.failed = false,
  });

  final String storeBase;
  final String storeLabel;
  final int? pageIndex;
  final int? pageCount;
  final String? message;
  final String? error;
  final bool inProgress;
  final bool completed;
  final bool failed;
}

class CmsSyncResult {
  const CmsSyncResult({
    required this.success,
    this.alreadyRunning = false,
    this.skipped = false,
    this.cancelled = false,
    this.message = '',
    this.storeErrors = const {},
  });

  factory CmsSyncResult.success({
    String message = '',
    Map<String, String> storeErrors = const {},
  }) {
    return CmsSyncResult(
      success: true,
      message: message,
      storeErrors: storeErrors,
    );
  }

  factory CmsSyncResult.failure(String message, {Map<String, String> storeErrors = const {}}) {
    return CmsSyncResult(
      success: false,
      message: message,
      storeErrors: storeErrors,
    );
  }

  factory CmsSyncResult.alreadyRunning([String message = 'Sync already running']) {
    return CmsSyncResult(
      success: false,
      alreadyRunning: true,
      message: message,
    );
  }

  factory CmsSyncResult.skipped([String message = 'Sync skipped']) {
    return CmsSyncResult(
      success: true,
      skipped: true,
      message: message,
    );
  }

  factory CmsSyncResult.cancelled([String message = 'Sync cancelled']) {
    return CmsSyncResult(
      success: false,
      cancelled: true,
      message: message,
    );
  }

  final bool success;
  final bool alreadyRunning;
  final bool skipped;
  final bool cancelled;
  final String message;
  final Map<String, String> storeErrors;
}

enum CmsSyncHttpMethod {
  get,
  post,
}

class CmsMasterFileStore<T extends CmsInspectionLookupBase> {
  const CmsMasterFileStore({
    required this.storeBase,
    required this.displayName,
    required this.endpoint,
    required this.fromJson,
    required this.toJson,
    this.httpMethod = CmsSyncHttpMethod.get,
    this.usePagedQueryParameters = true,
  });

  final String storeBase;
  final String displayName;
  final String endpoint;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T entity) toJson;
  final CmsSyncHttpMethod httpMethod;
  final bool usePagedQueryParameters;

  CmsMasterFileStore<CmsInspectionLookupBase> asBaseStore() {
    return CmsMasterFileStore<CmsInspectionLookupBase>(
      storeBase: storeBase,
      displayName: displayName,
      endpoint: endpoint,
      fromJson: (json) => fromJson(json),
      toJson: (entity) => entity.toJson(),
      httpMethod: httpMethod,
      usePagedQueryParameters: usePagedQueryParameters,
    );
  }
}

class CmsMasterFileStores {
  static const locations = CmsMasterFileStore<InspectionLocation>(
    storeBase: AppConst.DB_CmsInspectionLocations,
    displayName: 'Locations',
    endpoint: AppConst.CmsGetAllInspectionLocationsPagedEdit,
    fromJson: InspectionLocation.fromJson,
    toJson: _locationToJson,
  );

  static const actions = CmsMasterFileStore<InspectionAction>(
    storeBase: AppConst.DB_CmsInspectionActions,
    displayName: 'Actions',
    endpoint: AppConst.CmsGetAllInspectionActionsPagedEdit,
    fromJson: InspectionAction.fromJson,
    toJson: _actionToJson,
  );

  static const damages = CmsMasterFileStore<InspectionDamage>(
    storeBase: AppConst.DB_CmsInspectionDamages,
    displayName: 'Damages',
    endpoint: AppConst.CmsGetAllInspectionDamagesPagedEdit,
    fromJson: InspectionDamage.fromJson,
    toJson: _damageToJson,
  );

  static const items = CmsMasterFileStore<InspectionItem>(
    storeBase: AppConst.DB_CmsInspectionItems,
    displayName: 'Items',
    endpoint: AppConst.CmsGetAllInspectionItemsPagedEdit,
    fromJson: InspectionItem.fromJson,
    toJson: _itemToJson,
  );

  static const itemCodes = CmsMasterFileStore<CmsItemCode>(
    storeBase: AppConst.DB_CmsItemCodes,
    displayName: 'Item Codes',
    endpoint: AppConst.CmsGetAllItemCodesPagedEdit,
    fromJson: CmsItemCode.fromJson,
    toJson: _itemCodeToJson,
  );

  static const conditionTypes = CmsMasterFileStore<CmsConditionType>(
    storeBase: AppConst.DB_CmsConditionTypes,
    displayName: 'Condition Types',
    endpoint: AppConst.CmsGetConditionTypes,
    fromJson: CmsConditionType.fromJson,
    toJson: _conditionTypeToJson,
    httpMethod: CmsSyncHttpMethod.post,
    usePagedQueryParameters: false,
  );

  static final all = <CmsMasterFileStore<CmsInspectionLookupBase>>[
    locations.asBaseStore(),
    actions.asBaseStore(),
    damages.asBaseStore(),
    items.asBaseStore(),
    itemCodes.asBaseStore(),
    conditionTypes.asBaseStore(),
  ];

  static Map<String, dynamic> _locationToJson(InspectionLocation entity) => entity.toJson();
  static Map<String, dynamic> _actionToJson(InspectionAction entity) => entity.toJson();
  static Map<String, dynamic> _damageToJson(InspectionDamage entity) => entity.toJson();
  static Map<String, dynamic> _itemToJson(InspectionItem entity) => entity.toJson();
  static Map<String, dynamic> _itemCodeToJson(CmsItemCode entity) => entity.toJson();
  static Map<String, dynamic> _conditionTypeToJson(CmsConditionType entity) => entity.toJson();
}
