import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GatePassListIcon extends StatelessWidget {
  const GatePassListIcon({Key? key, required this.statusId}) : super(key: key);
  final int statusId;
  @override
  Widget build(BuildContext context) {
    switch (statusId) {
      case 1: //GatePassStatus.AtGate:
        return const FittedBox(
          fit: BoxFit.fill,
          child: FaIcon(
            FontAwesomeIcons.hand,
            color: Colors.orange,
          ),
        );
      case 2: //GatePassStatus.InYard:
        return const FittedBox(
          fit: BoxFit.fill,
          child: FaIcon(
            FontAwesomeIcons.arrowsDownToLine,
            color: Colors.yellow,
          ),
        );
      case 3: //GatePassStatus.LeftTheYard:
        return const FittedBox(
          fit: BoxFit.fill,
          child: FaIcon(
            FontAwesomeIcons.arrowsUpToLine,
            color: Colors.green,
          ),
        );
      case 4: //GatePassStatus.RejectedEntry:
        return const FittedBox(
          fit: BoxFit.fill,
          child: FaIcon(
            FontAwesomeIcons.ban,
            color: Colors.red,
          ),
        );
      default:
        return const FittedBox(
          fit: BoxFit.fill,
          child: Icon(
            Icons.pending,
            size: 42,
            color: Colors.black,
          ),
        );
    }
  }
}
