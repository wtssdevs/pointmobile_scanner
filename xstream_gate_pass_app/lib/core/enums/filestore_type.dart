enum FileStoreType {
  none(0),
  logo(1),
  image(2),
  icon(4),
  document(8),
  video(16),

  // Types
  gatePassAccess(32),
  tenant(64),

  // Combinations
  gateBookingImage(34), // 32 | 2 (gatePassAccess | image)
  gateBookingDocument(40), // 32 | 8 (gatePassAccess | document)
  gateBookingVideo(48), // 32 | 16 (gatePassAccess | video)
  tenantLogo(65); // 64 | 1 (tenant | logo)

  final int value;
  const FileStoreType(this.value);

  // Helper method to check if this enum contains a specific flag
  bool hasFlag(FileStoreType flag) {
    return (value & flag.value) == flag.value;
  }

  // Helper method to combine flags
  static FileStoreType combine(List<FileStoreType> flags) {
    int combinedValue = 0;
    for (var flag in flags) {
      combinedValue |= flag.value;
    }

    // Find the enum with the matching value or return none
    return FileStoreType.values.firstWhere(
      (type) => type.value == combinedValue,
      orElse: () => FileStoreType.none,
    );
  }

  // Helper method for custom combinations not predefined in the enum
  static int combineValues(List<FileStoreType> flags) {
    int combinedValue = 0;
    for (var flag in flags) {
      combinedValue |= flag.value;
    }
    return combinedValue;
  }
}
