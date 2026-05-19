enum CmsInspectableStatusFilter {
  ready,
  inProgress,
  completed,
  all,
}

class CmsInspectionFilter {
  CmsInspectionFilter({
    required this.depotId,
    this.pageNumber = 1,
    this.pageSize = 20,
    this.searchValue = '',
    this.statusFilter = CmsInspectableStatusFilter.all,
    this.shippingLineId,
    this.includeCompleted = false,
    this.sort,
  });

  final int depotId;
  final int pageNumber;
  final int pageSize;
  final String searchValue;
  final CmsInspectableStatusFilter statusFilter;
  final int? shippingLineId;
  final bool includeCompleted;
  final String? sort;

  CmsInspectionFilter copyWith({
    int? depotId,
    int? pageNumber,
    int? pageSize,
    String? searchValue,
    CmsInspectableStatusFilter? statusFilter,
    int? shippingLineId,
    bool? clearShippingLineId,
    bool? includeCompleted,
    String? sort,
    bool? clearSort,
  }) {
    return CmsInspectionFilter(
      depotId: depotId ?? this.depotId,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      searchValue: searchValue ?? this.searchValue,
      statusFilter: statusFilter ?? this.statusFilter,
      shippingLineId: clearShippingLineId == true ? null : (shippingLineId ?? this.shippingLineId),
      includeCompleted: includeCompleted ?? this.includeCompleted,
      sort: clearSort == true ? null : (sort ?? this.sort),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'depotId': depotId,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'searchValue': searchValue,
      'statusFilter': statusFilter.index,
      'shippingLineId': shippingLineId,
      'includeCompleted': includeCompleted,
      'sort': sort,
    };
  }
}
