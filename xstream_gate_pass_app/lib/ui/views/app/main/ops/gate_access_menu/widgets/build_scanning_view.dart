import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/core/enums/barcode_scan_type.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';
import 'package:xstream_gate_pass_app/ui/widgets/common/barcode_scanner_animation/barcode_scanner_animation.dart';

class BuildScanningView extends StatelessWidget {
  final BarcodeScanType barcodeScanType;
  const BuildScanningView({super.key, required this.barcodeScanType});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //create animated barcode scanning indicator
            const SizedBox(
              height: 60,
              width: 90,
              child: BarcodeScannerAnimation(),
            ),

            verticalSpaceSmall,
            Text(
              barcodeScanType == BarcodeScanType.driversCard
                  ? 'Scan Driver\'s License Card...'
                  : 'Scan Vehicle License Disc...',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            verticalSpaceTiny,
            Text(
              'Please select what to scan and hold the barcode in front of the scanner',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
