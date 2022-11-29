enum BackgroundJobType {
  none(0, displayName: "None"),
  syncMasterfiles(1, displayName: "Sync Master files"),
  syncImages(2, displayName: "GatePass Images"),
  clearCache(3, displayName: "Clear Cache"),
  emailLog(4, displayName: "Email Log");

  const BackgroundJobType(
    int value, {
    required this.displayName,
  });
  final String displayName;
}

extension BackgroundJobTypeExtension on BackgroundJobType {
  BackgroundJobType mapToEnum(int jsonEnumValue) {
    for (var item in BackgroundJobType.values) {
      if (item.index == jsonEnumValue) {
        return item;
      }
    }

    return BackgroundJobType.none;
  }
}
