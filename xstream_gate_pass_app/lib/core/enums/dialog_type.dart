import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum GatePassBookingType {
  none(0, "Other", Icons.help_outline),
  breakBulk(1, "Break Bulk", FontAwesomeIcons.truckRampBox),
  containers(2, "Containers", FontAwesomeIcons.boxesPacking),
  staff(3, "Staff", FontAwesomeIcons.idBadge),
  visitor(4, "Visitor", Icons.person_outline);

  final int value;
  final String text;
  final IconData icon;
  const GatePassBookingType(this.value, this.text, this.icon);
}

enum DeliveryType {
  receive(0, "Receive", Icons.download),
  dispatch(1, "Dispatch", Icons.upload),
  other(2, "Other", Icons.help_outline);

  final int value;
  final String text;
  final IconData icon;
  const DeliveryType(this.value, this.text, this.icon);

  static DeliveryType fromValue(dynamic raw) {
    final int? val = raw is int ? raw : int.tryParse(raw.toString());
    return DeliveryType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => DeliveryType.other,
    );
  }
}

enum GatePassContainerType {
  none(0, "None"),
  empty(1, "Empty"),
  unpackFull(2, "Unpack Full"),
  storeFull(3, "Store Full");

  final int value;
  final String text;
  const GatePassContainerType(this.value, this.text);

  static GatePassContainerType fromValue(dynamic val) {
    final int? intVal = val is int ? val : int.tryParse(val.toString());
    return GatePassContainerType.values.firstWhere(
      (e) => e.value == intVal,
      orElse: () => GatePassContainerType.none,
    );
  }
}


enum ChecklistType {
  none(0, "None", Icons.help_outline),
  gatePassAccess(1, "Gate Pass Access", FontAwesomeIcons.dungeon),
  container(2, "Container", FontAwesomeIcons.boxesPacking),
  entry(4, "Entry", FontAwesomeIcons.doorOpen),
  exit(8, "Exit", FontAwesomeIcons.doorClosed),
  gatePassAccessReject (16, "Exit", FontAwesomeIcons.doorClosed),
  gatePassAccessEntry(5, "Gate Pass Access Entry", FontAwesomeIcons.signInAlt),
  gatePassAccessExit(9, "Gate Pass Access Exit", FontAwesomeIcons.signOutAlt);

  final int value;
  final String text;
  final IconData icon;
  const ChecklistType(this.value, this.text, this.icon);

  static ChecklistType fromValue(int value) {
    return ChecklistType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ChecklistType.none,
    );
  }
}
//ChecklistItemType
// YesNo = 1,
// Text = 2,
// Numeric = 3,
// MultipleChoice = 4,
// Date = 5,
// Photo = 6,

enum ChecklistItemType {
  none(0, "None"),
  yesNo(1, "Yes / No"),
  text(2, "Text"),
  numeric(3, "Numeric"),
  multipleChoice(4, "Multiple Choice"),
  date(5, "Date"),
  photo(6, "Photo");

  final int value;
  final String textValue;
  const ChecklistItemType(this.value, this.textValue);
}

