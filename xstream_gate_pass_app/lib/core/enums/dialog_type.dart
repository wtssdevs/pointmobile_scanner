enum DialogType { basic }

enum GatePassBookingType {
  none(0, "Other"),
  breakBulk(1, "Break Bulk"),
  containers(2, "Containers"),

  staff(3, "Staff"),
  visitor(4, "Visitor");

  final int value;
  final String text;
  const GatePassBookingType(this.value, this.text);
}

enum DeliveryType {
  receive(0, "Receive"),
  dispatch(1, "Dispatch"),
  other(2, "Other");

  final int value;
  final String text;
  const DeliveryType(this.value, this.text);
}

enum GatePassContainerType {
  none(0, "None"),
  empty(1, "Empty"),
  unpackFull(2, "Unpack Full"),
  storeFull(3, "Store Full");

  final int value;
  final String text;
  const GatePassContainerType(this.value, this.text);
}
