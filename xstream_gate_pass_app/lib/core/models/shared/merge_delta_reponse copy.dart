class MergeDeltaResponse<T> {
  MergeDeltaResponse({
    required this.added,
    required this.deleted,
    required this.changed,
    required this.same,
    required this.all,
  });

  List<T> added;
  List<T> deleted;
  List<T> changed;
  List<T> same;
  List<T> all;
}
