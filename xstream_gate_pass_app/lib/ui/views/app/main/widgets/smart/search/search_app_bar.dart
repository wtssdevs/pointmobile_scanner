import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String)? onChanged;
  final double searchWidth;
  const SearchAppBar({Key? key, required this.controller, this.onChanged, required this.searchWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 2),
      height: 32,
      width: searchWidth,
      child: CupertinoTextField(
        cursorColor: Colors.black,
        clearButtonMode: OverlayVisibilityMode.editing,
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.text,
        onTap: () async {},
        placeholder: 'Search',
        placeholderStyle: const TextStyle(
          color: Color(0xffC4C6CC),
          fontSize: 14.0,
          fontFamily: 'Brutal',
        ),
        prefix: const Padding(
          padding: EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 5.0),
          child: Icon(
            Icons.search,
            size: 18,
            color: Colors.black,
          ),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.grey.withOpacity(0.5), offset: const Offset(1.1, 1.1), blurRadius: 9.0),
          ],
        ),
      ),
    );
  }
}
