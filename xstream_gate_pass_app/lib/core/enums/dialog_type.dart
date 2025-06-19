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
