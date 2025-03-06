import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';

class VisitorStatusIcon extends StatelessWidget {
  final GatePassStatus gatePassStatus;
  const VisitorStatusIcon({super.key, required this.gatePassStatus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: gatePassStatus.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        gatePassStatus.visitorName,
        style: TextStyle(
          color: gatePassStatus.color,
          fontSize: 12,
        ),
      ),
    );
  }
}
