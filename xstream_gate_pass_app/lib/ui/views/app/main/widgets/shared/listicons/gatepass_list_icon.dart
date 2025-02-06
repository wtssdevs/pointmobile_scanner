import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';

class GatePassListIcon extends StatelessWidget {
  const GatePassListIcon({Key? key, required this.statusId}) : super(key: key);
  final GatePassStatus statusId;
  @override
  Widget build(BuildContext context) {
    switch (statusId) {
      case GatePassStatus.pending:
        return CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: const FittedBox(
            fit: BoxFit.fill,
            child: FaIcon(
              FontAwesomeIcons.ellipsis,
              color: Colors.orange,
            ),
          ),
        );
      case GatePassStatus.atGate:
        return CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: const FittedBox(
            fit: BoxFit.fill,
            child: FaIcon(
              FontAwesomeIcons.hand,
              color: Colors.orange,
            ),
          ),
        );
      case GatePassStatus.inYard:
        return CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: const FittedBox(
            fit: BoxFit.fill,
            child: FaIcon(
              FontAwesomeIcons.arrowsDownToLine,
              color: Colors.blue,
            ),
          ),
        );
      case GatePassStatus.leftTheYard:
        return CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: const FittedBox(
            fit: BoxFit.fill,
            child: FaIcon(
              FontAwesomeIcons.arrowsUpToLine,
              color: Colors.green,
            ),
          ),
        );
      case GatePassStatus.rejectedEntry:
        return CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: const FittedBox(
            fit: BoxFit.fill,
            child: FaIcon(
              FontAwesomeIcons.ban,
              color: Colors.red,
            ),
          ),
        );
      default:
        return CircleAvatar(
          backgroundColor: Colors.grey[300],
          child: const FittedBox(
            fit: BoxFit.fill,
            child: Icon(
              Icons.pending,
              size: 42,
              color: Colors.black,
            ),
          ),
        );
    }
  }
}
