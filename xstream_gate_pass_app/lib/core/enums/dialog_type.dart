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

enum ChecklistType {
  none(0, "None", Icons.help_outline),
  gatePassAccess(1, "Gate Pass Access", FontAwesomeIcons.dungeon),
  container(2, "Container", FontAwesomeIcons.boxesPacking);

  final int value;
  final String text;
  final IconData icon;
  const ChecklistType(this.value, this.text, this.icon);
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
