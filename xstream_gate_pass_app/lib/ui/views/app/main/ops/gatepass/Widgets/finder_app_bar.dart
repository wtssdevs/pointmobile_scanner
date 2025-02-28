import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FinderAppBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final double searchWidth;
  final String placeholder;
  final Icon searchIcon;
  const FinderAppBar({
    Key? key,
    required this.controller,
    this.onChanged,
    required this.searchWidth,
    this.placeholder = 'Search',
    this.searchIcon = const Icon(
      Icons.search,
      size: 18,
      color: Colors.black,
    ),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 2),
      height: 38,
      width: searchWidth,
      child: CupertinoTextField(
        cursorColor: Colors.black,
        clearButtonMode: OverlayVisibilityMode.editing,
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.text,
        onTap: () async {},
        placeholder: placeholder,
        placeholderStyle: const TextStyle(
          color: Color(0xffC4C6CC),
          fontSize: 14.0,
          fontFamily: 'Brutal',
        ),
        prefix: Padding(
          padding: const EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 5.0),
          child: searchIcon,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                offset: const Offset(1.1, 1.1),
                blurRadius: 9.0),
          ],
        ),
      ),
    );
  }
}
