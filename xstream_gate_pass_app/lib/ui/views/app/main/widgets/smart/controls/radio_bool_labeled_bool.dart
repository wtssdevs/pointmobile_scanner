import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/box_text.dart';

class ListRadioBoolWithLabel extends StatelessWidget {
  final bool value;
  final String label;
  //final Function? onValueChanged;
  //final Function(Object?)? onValueChanged;
  final ValueChanged<Object?>? onValueChanged;
  const ListRadioBoolWithLabel({Key? key, required this.value, required this.label, required this.onValueChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 9.0),
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: const BorderRadius.all(
                  Radius.circular(12.0),
                ),
              ),
              child: RadioListTile(
                contentPadding: const EdgeInsets.all(0),
                value: false,
                groupValue: value,
                dense: true,
                title: BoxText.body(
                  "No",
                  color: Colors.red,
                  fontSize: 12,
                ),
                onChanged: onValueChanged,
                activeColor: Colors.red,
                selected: false,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: const BorderRadius.all(
                  Radius.circular(12.0),
                ),
              ),
              child: RadioListTile(
                value: true,
                groupValue: value,
                dense: true,
                title: BoxText.body(
                  "Yes",
                  color: Colors.green,
                  fontSize: 12,
                ),
                onChanged: onValueChanged,
                activeColor: Colors.green,
                selected: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
