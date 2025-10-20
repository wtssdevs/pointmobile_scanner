enum GatePassType {
  collection(0, "Collection"),
  delivery(1, "Delivery");

  // can use named parameters if you want
  const GatePassType(this.value, this.displayName);
  final int value;
  final String displayName;
}

extension GatePassStatusExtension on GatePassType {
  GatePassType mapToEnum(int jsonEnumValue) {
    for (var item in GatePassType.values) {
      if (item.value == jsonEnumValue) {
        return item;
      }
    }

    return GatePassType.delivery;
  }
}
