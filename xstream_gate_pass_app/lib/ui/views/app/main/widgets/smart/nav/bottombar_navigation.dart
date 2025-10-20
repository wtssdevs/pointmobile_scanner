import 'package:flutter/material.dart';

class MyBottomNavigationBar extends StatelessWidget {
  @override
  const MyBottomNavigationBar({
    Key? key,
    required this.onTapped,
    required this.currentTabIndex,
    required this.items,
  }) : super(key: key);
  final Function(int)? onTapped;
  final int currentTabIndex;
  final List<BottomNavigationBarItem> items;

  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      iconSize: 24,
      selectedItemColor: Colors.blue,
      items: items,
      onTap: onTapped,
      currentIndex: currentTabIndex,
    );
  }
}
