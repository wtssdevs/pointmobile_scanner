import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/shared/listicons/gatepass_list_icon.dart';

class GateStatusChip extends StatelessWidget {
  const GateStatusChip({
    super.key,
    required this.gatePassStatus,
  });

  final GatePassStatus gatePassStatus;

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    String statusText;

    switch (gatePassStatus) {
      case GatePassStatus.pending:
        chipColor = Colors.lightBlue;
        statusText = GatePassStatus.pending.displayName;
        break;
      case GatePassStatus.atGate:
        chipColor = Colors.orange;
        statusText = GatePassStatus.atGate.displayName;
        break;
      case GatePassStatus.inYard:
        chipColor = Colors.red;
        statusText = GatePassStatus.inYard.displayName;
        break;
      case GatePassStatus.leftTheYard:
        chipColor = Colors.green;
        statusText = GatePassStatus.leftTheYard.displayName;
        break;
      default:
        chipColor = Colors.red;
        statusText = GatePassStatus.rejectedEntry.displayName;
    }

    return Chip(
      avatar: GatePassListIcon(statusId: gatePassStatus),
      // CircleAvatar(
      //   backgroundColor: chipColor,
      //   child: Text(
      //     statusText[0],
      //     style: const TextStyle(color: Colors.white),
      //   ),
      // ),
      backgroundColor: Colors.grey.withOpacity(0.3),
      label: Text(
        statusText,
        //style: TextStyle(color: chipColor),
      ),
    );
  }
}
