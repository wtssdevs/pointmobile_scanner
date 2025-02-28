import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final String route;
  final String requiredPermission;
  //final GatePassStatus gatePassStatus;

  MenuItem(
      {required this.title,
      required this.icon,
      required this.route,
      required this.requiredPermission});
}
