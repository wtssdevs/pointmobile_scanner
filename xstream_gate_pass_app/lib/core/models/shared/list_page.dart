import 'package:xstream_gate_pass_app/core/utils/helper.dart';

/// Represents each page returned by a paginated endpoint.
class PagedList<T> {
  PagedList(
      {required this.totalCount,
      required this.items,
      required this.pageNumber,
      required this.pageSize,
      required this.totalPages,
      this.itemRequestThreshold = 15});

  int totalCount;
  int totalPages;

  int pageNumber;
  int itemRequestThreshold;

  // This is Take
  int pageSize;
  List<T> items;

  bool isLastPage(int previouslyFetchedItemsCount) {
    final newItemsCount = items.length;
    final totalFetchedItemsCount = previouslyFetchedItemsCount + newItemsCount;
    return totalFetchedItemsCount == totalCount;
  }

  //    items = await source.Skip((pageNumber - 1) * pageSize).Take(pageSize).ToListAsync();
  int getSkipCount() {
    return (pageNumber - 1) * pageSize;
  }

  factory PagedList.fromJsonWithItems(Map<String, dynamic> jsonRes, List<T> items) => PagedList(
        totalCount: asT<int>(jsonRes["totalCount"]) ?? 0,
        totalPages: asT<int>(jsonRes["totalPages"]) ?? 0,
        pageNumber: asT<int>(jsonRes['currentPage']) ?? 0,
        items: items,
        pageSize: asT<int>(jsonRes['pageSize']) ?? 0,
      );
}
