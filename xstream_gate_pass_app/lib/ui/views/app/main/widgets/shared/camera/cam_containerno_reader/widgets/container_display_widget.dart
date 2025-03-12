import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/core/models/basefiles/containers/container_info_extratced_model.dart';
import 'package:xstream_gate_pass_app/ui/shared/widgets/box_button.dart';

class ContainerDisplayWidget extends StatefulWidget {
  final Stream<List<ContainerInfo>> barcodesStream;
  final ScrollController scrollController;
  final AnalysisController analysisController;
  // Callback for when a container is selected
  final Function(ContainerInfo)? onContainerSelected;

  const ContainerDisplayWidget({
    Key? key,
    required this.barcodesStream,
    required this.scrollController,
    required this.analysisController,
    this.onContainerSelected,
  }) : super(key: key);

  @override
  State<ContainerDisplayWidget> createState() => ContainerWidgetState();
}

class ContainerWidgetState extends State<ContainerDisplayWidget> {
  // Track selected container index
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.7),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Detected Containers",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  // Toggle scan button
                  Switch(
                    value: widget.analysisController.enabled,
                    onChanged: (newValue) async {
                      if (widget.analysisController.enabled == true) {
                        await widget.analysisController.stop();
                      } else {
                        await widget.analysisController.start();
                      }
                      setState(() {});
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Container list
            Container(
              height: 200, // Increased height for better visibility
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder<List<ContainerInfo>>(
                stream: widget.barcodesStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No containers detected yet.\nPoint camera at container number.",
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    controller: widget.scrollController,
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 2),
                    itemBuilder: (context, index) {
                      var item = snapshot.data![index];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.all(2),
                        title: Text(
                          item.containerNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(item.isoType),
                        trailing: ElevatedButton(
                          onPressed: () {
                            //use this container
                            if (widget.onContainerSelected != null) {
                              widget.onContainerSelected!(item);
                              //Navigator.pop(context, item);
                            }
                          },
                          child: const Text("Use"),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  // ElevatedButton(
                  //   onPressed: _selectedIndex != null
                  //       ? () {
                  //           // Get selected container and return it
                  //           StreamBuilder<List<ContainerInfo>>(
                  //             stream: widget.barcodesStream,
                  //             builder: (context, snapshot) {
                  //               if (snapshot.hasData && _selectedIndex! < snapshot.data!.length) {
                  //                 Navigator.pop(context, snapshot.data![_selectedIndex!]);
                  //               }
                  //               return const SizedBox();
                  //             },
                  //           );
                  //         }
                  //       : null,
                  //   child: const Text("Select Container"),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build individual container item
  Widget _buildContainerItem(ContainerInfo container, int index) {
    return Card(
      elevation: _selectedIndex == index ? 4 : 1,
      color: _selectedIndex == index ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });

          // If direct selection is enabled, pop immediately
          if (widget.onContainerSelected != null) {
            widget.onContainerSelected!(container);
            Navigator.pop(context, container);
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Container Number (bold)
              Text(
                container.containerNumber,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),

              // ISO Type and Description
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      container.isoType,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      container.isoTypeDescription,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Selection indicator
              if (_selectedIndex == index)
                Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
