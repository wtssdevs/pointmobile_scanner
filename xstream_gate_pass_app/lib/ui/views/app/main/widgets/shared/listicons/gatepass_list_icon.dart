import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GatePassListIcon extends StatelessWidget {
  const GatePassListIcon({Key? key, required this.statusId}) : super(key: key);
  final int statusId;
  @override
  Widget build(BuildContext context) {
    switch (statusId) {
      case 1: //GatePassStatus.AtGate:
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
      case 2: //GatePassStatus.InYard:
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
      case 3: //GatePassStatus.LeftTheYard:
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
      case 4: //GatePassStatus.RejectedEntry:
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
