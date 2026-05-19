import 'package:flutter/widgets.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_lookup_base.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_master_files_repository.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_sync_models.dart';

class CmsLookupDataSource<T extends CmsInspectionLookupBase> {
  CmsLookupDataSource({
    required this.repository,
    required this.store,
    required this.context,
    this.pageSize = 20,
    this.activeOnly = true,
    this.shippingLineId,
    SearchableDropdownMenuItem<int> Function(T entity)? itemBuilder,
  }) : _itemBuilder = itemBuilder ?? _defaultItemBuilder;

  final CmsMasterFilesRepository repository;
  final CmsMasterFileStore<T> store;
  final CmsSyncContext context;
  final int pageSize;
  final bool activeOnly;
  final int? shippingLineId;
  final SearchableDropdownMenuItem<int> Function(T entity) _itemBuilder;

  Future<List<SearchableDropdownMenuItem<int>>> paginatedRequest(
    int page,
    String? searchKey,
  ) async {
    final safePage = page <= 0 ? 1 : page;
    final items = await repository.search(
      store,
      context,
      searchTerm: searchKey ?? '',
      skip: (safePage - 1) * pageSize,
      take: pageSize,
      activeOnly: activeOnly,
      shippingLineId: shippingLineId,
    );

    return items.where((entity) => entity.id != null).map(_itemBuilder).toList(growable: false);
  }

  Future<SearchableDropdownMenuItem<int>?> getSelectedItem(int? id) async {
    final entity = await repository.getById(store, context, id);
    if (entity == null || entity.id == null) {
      return null;
    }

    return _itemBuilder(entity);
  }

  static SearchableDropdownMenuItem<int> _defaultItemBuilder(
    CmsInspectionLookupBase entity,
  ) {
    final label = entity.displayName.isNotEmpty ? entity.displayName : (entity.name ?? '');
    return SearchableDropdownMenuItem<int>(
      value: entity.id!,
      label: label,
      child: Text(label),
    );
  }
}
