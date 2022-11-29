enum GatePassStatus {
  none(0, "Idle"),
  atGate(1, "At Gate"),
  inYard(2, "In Yard"),
  leftTheYard(3, "Left The Yard"),
  rejectedEntry(4, "Rejected Entry");

  // can use named parameters if you want
  const GatePassStatus(this.value, this.displayName);
  final int value;
  final String displayName;
}

extension GatePassStatusExtension on GatePassStatus {
  GatePassStatus mapToEnum(int jsonEnumValue) {
    for (var item in GatePassStatus.values) {
      if (item.value == jsonEnumValue) {
        return item;
      }
    }

    return GatePassStatus.none;
  }
}
