class CmsInspectionFilter {
  CmsInspectionFilter({
    required this.depotId,
    this.pageNumber = 1,
    this.pageSize = 20,
    this.searchValue = '',
    this.shippingLineId,
    this.sort,
  });

  final int depotId;
  final int pageNumber;
  final int pageSize;
  final String searchValue;
  final int? shippingLineId;
  final String? sort;

  CmsInspectionFilter copyWith({
    int? depotId,
    int? pageNumber,
    int? pageSize,
    String? searchValue,
    int? shippingLineId,
    bool? clearShippingLineId,
    String? sort,
    bool? clearSort,
  }) {
    return CmsInspectionFilter(
      depotId: depotId ?? this.depotId,
      pageNumber: pageNumber ?? this.pageNumber,
      pageSize: pageSize ?? this.pageSize,
      searchValue: searchValue ?? this.searchValue,
      shippingLineId: clearShippingLineId == true ? null : (shippingLineId ?? this.shippingLineId),
      sort: clearSort == true ? null : (sort ?? this.sort),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'depotId': depotId,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'searchValue': searchValue,
      'shippingLineId': shippingLineId,
      'sort': sort,
    };
  }
}
