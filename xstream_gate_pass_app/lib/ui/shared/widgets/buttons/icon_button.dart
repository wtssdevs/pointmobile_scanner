import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class RaisedIconButton extends StatelessWidget {
  const RaisedIconButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isDisabled = false,
  });

  final Function onPressed;
  final IconData? icon;
  final String label;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: !isDisabled ? Colors.blueGrey[700] : Colors.grey,
              onPrimary: Colors.white,
              onSurface: Colors.grey,
              elevation: 5,
              padding: EdgeInsets.only(top: 4),
            ),
            onPressed: onPressed as void Function()?,
            child: Column(
              // Replace with a Row for horizontal icon + text
              children: <Widget>[
                icon != null
                    ? Icon(
                        icon,
                        size: 36,
                        color: Colors.white,
                      )
                    : SizedBox(
                        height: 36,
                        width: 36,
                      ),
                Center(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ),
      );
}
