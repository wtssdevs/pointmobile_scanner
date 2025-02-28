class FilterParams {
  final String? searchQuery;
  final String? sortColumn;
  final String? sortDirection;
  int pageSize;
  int pageNumber;
  final String? transactionNo;
  final DateTime? startDate;
  final DateTime? endDate;
  String? voyageNo;
  String? vehicleRegNumber;
  String? containerNumber;

  FilterParams({
    this.searchQuery,
    this.sortColumn,
    this.sortDirection,
    this.pageSize = 10,
    this.pageNumber = 1,
    this.transactionNo,
    this.startDate,
    this.endDate,
    this.voyageNo,
    this.vehicleRegNumber,
    this.containerNumber,
  });
  void clear() {
    voyageNo = null;
    vehicleRegNumber = null;
    containerNumber = null;
  }

  Map<String, dynamic> toJson() {
    return {
      'searchQuery': searchQuery,
      'sortColumn': sortColumn,
      'sortDirection': sortDirection,
      'pageSize': pageSize,
      'pageNumber': pageNumber,
      'transactionNo': transactionNo,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'voyageNo': voyageNo,
      'department': vehicleRegNumber,
      'requestedBy': containerNumber,
    }..removeWhere((key, value) => value == null);
  }
}
