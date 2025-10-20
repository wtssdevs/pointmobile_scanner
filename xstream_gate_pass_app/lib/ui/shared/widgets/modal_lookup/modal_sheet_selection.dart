import 'package:flutter/material.dart';

import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/widgets/smart/search/search_app_bar.dart';

class ModalSheetSelection<T> extends StatefulWidget {
  final List<T> dropDownList;
  T? selectedItem;
  final Function onDropDownItemClick;
  final bool isVisible;
  final Function(bool)? onTapped;
  final TextEditingController filterController = TextEditingController();
  List<T> filteredItems = [];
  final Widget? dropDownIcon;
  ModalSheetSelection(
      {Key? key,
      this.dropDownIcon,
      required this.dropDownList,
      required this.onDropDownItemClick,
      this.selectedItem,
      this.onTapped,
      this.isVisible = true})
      : super(key: key);

  @override
  _ModalSheetSelectionState createState() => _ModalSheetSelectionState();
}

class _ModalSheetSelectionState extends State<ModalSheetSelection> {
  @override
  void initState() {
    super.initState();
    setState(() {
      widget.filteredItems = widget.dropDownList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.isVisible
        ? GestureDetector(
            onTap: () async {
              setState(() {
                widget.filteredItems = widget.dropDownList;
              });
              await showModal(context, widget.selectedItem);
              if (widget.onTapped != null) {
                widget.onTapped!(widget.selectedItem == null ? false : true);
              }
            },
            child: Card(
              elevation: 6,
              color: Colors.white,
              margin: const EdgeInsets.only(
                  top: 4.0, left: 4.0, right: 4.0, bottom: 0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
              ),
              child: Container(
                // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                padding: const EdgeInsets.all(8),
                height: 50,
                child: Row(
                  children: <Widget>[
                    Flexible(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(right: 5),
                          color: Colors.transparent,
                          // child: TripStopStateIcon(
                          //   status: widget.selectedItem?.name ?? "",
                          //   showText: null,
                          // ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          widget.selectedItem != null
                              ? (widget.selectedItem!.displayName ?? "")
                              : "Select Value...",
                          textScaleFactor:
                              MediaQuery.of(context).textScaleFactor > 1.5
                                  ? 1.5
                                  : MediaQuery.of(context).textScaleFactor,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      flex: 3,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(right: 5),
                          color: Colors.transparent,
                          child: widget.dropDownIcon,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Future<void> showModal(context, dynamic selecteditem) async {
    double searchWidth =
        getDeviceType(MediaQuery.of(context)) == DeviceScreenType.tablet
            ? MediaQuery.of(context).size.width * 0.8
            : MediaQuery.of(context).size.width * 0.8;
    var sheetRespone = await showModalBottomSheet(
      context: context,
      elevation: 6,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true, //this makes it full screen

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2, left: 2, right: 2),
                    child: Row(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(5.0, 5.0, 0.0, 5.0),
                          child: IconButton(
                            onPressed: () async {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.black,
                              size: 26,
                            ),
                          ),
                        ),
                        SearchAppBar(
                          controller: widget.filterController,
                          searchWidth: searchWidth,
                          onChanged: (value) {
                            setState(() {
                              widget.filteredItems = widget.dropDownList
                                  .where((u) =>
                                      (u.name
                                          .toLowerCase()
                                          .contains(value.toLowerCase())) ||
                                      (u.code
                                          .toLowerCase()
                                          .contains(value.toLowerCase())))
                                  .toList();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.center,
                    child: ListView.separated(
                      itemCount: widget.filteredItems.length,
                      separatorBuilder: (context, int) {
                        return const Divider();
                      },
                      itemBuilder: (context, index) {
                        var item = widget.filteredItems[index];
                        return ListTile(
                          selected: selecteditem != null
                              ? selecteditem.id == item.id
                              : false,
                          selectedTileColor: Colors.blue.withOpacity(0.85),
                          dense: true,
                          title: Text(
                            item?.displayName ?? "",
                            maxLines: 3,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w700),
                          ),
                          onTap: () {
                            setState(() {
                              widget.selectedItem = item;
                            });
                            widget.onDropDownItemClick(item);
                            Navigator.of(context).pop();
                          },
                        );
                        // GestureDetector(
                        //     child: Text(item.name ?? ""),
                        //     onTap: () {

                        //     });
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );

    //after sheet closes
  }
}
