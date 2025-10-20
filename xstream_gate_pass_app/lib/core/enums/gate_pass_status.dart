import 'package:flutter/material.dart';

enum GatePassStatus {
  pending(0, "Pending", "Pending", Colors.brown),
  atGate(1, "At Gate", "At Gate", Colors.orange),
  inYard(2, "In Yard", "In", Colors.red),
  leftTheYard(3, "Left The Yard", "Out", Colors.green),
  rejectedEntry(4, "Rejected Entry", "Rejected", Colors.red);

  // can use named parameters if you want
  const GatePassStatus(
      this.value, this.displayName, this.visitorName, this.color);
  final int value;
  final String displayName;
  final String visitorName;
  final Color color;
}

extension GatePassStatusExtension on GatePassStatus {
  GatePassStatus mapToEnum(int jsonEnumValue) {
    for (var item in GatePassStatus.values) {
      if (item.value == jsonEnumValue) {
        return item;
      }
    }

    return GatePassStatus.pending;
  }
}
