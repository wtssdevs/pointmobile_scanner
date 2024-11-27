import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';

class BarcodeDisplayWidget extends StatefulWidget {
  final Stream<List<String>> barcodesStream;
  final ScrollController scrollController;

  final AnalysisController analysisController;

  const BarcodeDisplayWidget({
    // ignore: unused_element
    super.key,
    required this.barcodesStream,
    required this.scrollController,
    required this.analysisController,
  });

  @override
  State<BarcodeDisplayWidget> createState() => BarcodeDisplayWidgetState();
}

class BarcodeDisplayWidgetState extends State<BarcodeDisplayWidget> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.tealAccent.withOpacity(0.7),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              value: widget.analysisController.enabled,
              onChanged: (newValue) async {
                if (widget.analysisController.enabled == true) {
                  await widget.analysisController.stop();
                } else {
                  await widget.analysisController.start();
                }
                setState(() {});
              },
              title: const Text(
                "Enable barcode scan",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: StreamBuilder<List<String>>(
              stream: widget.barcodesStream,
              builder: (context, value) => !value.hasData
                  ? const SizedBox.expand()
                  : ListView.separated(
                      padding: const EdgeInsets.only(top: 8),
                      controller: widget.scrollController,
                      itemCount: value.data!.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 4),
                      itemBuilder: (context, index) => Text(value.data![index]),
                    ),
            ),
          ),
        ]),
      ),
    );
  }
}
