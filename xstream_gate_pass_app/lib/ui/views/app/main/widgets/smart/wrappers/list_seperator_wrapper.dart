import 'package:flutter/material.dart';

class ListDividerWrapper extends StatelessWidget {
  final Widget child;
  final double? size;
  const ListDividerWrapper({Key? key, required this.child, this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: Colors.grey.shade300, width: 0.5))),
      child: Center(child: child),
    );
  }
}
