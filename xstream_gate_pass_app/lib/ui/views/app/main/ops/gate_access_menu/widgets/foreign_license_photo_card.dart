import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/core/models/basefiles/filestore/filestore.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/ui_helpers.dart';

class ForeignLicensePhotoCard extends StatelessWidget {
  final Function? onTap;
  final Function? onViewAllImages;
  final double width;
  final bool isPhotoTaken;
  final bool isVisible;
  final FileStore? fileStore;
  final List<Widget> infoList;

  const ForeignLicensePhotoCard({
    super.key,
    required this.width,
    required this.isPhotoTaken,
    this.onTap,
    this.onViewAllImages,
    this.isVisible = true,
    this.fileStore,
    required this.infoList,
  });
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Column(
        children: [
          verticalSpaceSmall,
          Container(
            width: width,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPhotoTaken ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isPhotoTaken ? Colors.green : Colors.orange,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                // Header row with title, button, and icons (no gesture detector here)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Foreign License Photo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // View All Images button
                    if (onViewAllImages != null)
                      InkWell(
                        onTap: () => onViewAllImages!(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.photo_library,
                                color: Colors.blue,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'View All',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.camera_alt,
                      color: isPhotoTaken ? Colors.green : Colors.orange,
                      size: 32,
                    ),
                    Icon(
                      isPhotoTaken ? Icons.check_circle : Icons.camera_enhance,
                      color: isPhotoTaken ? Colors.green : Colors.orange,
                      size: 38,
                    ),
                  ],
                ),
                verticalSpaceSmall, // Content area with gesture detector for main action

                ...infoList,
                verticalSpaceSmall,
                GestureDetector(
                  onTap: onTap as void Function()?,
                  child: Column(
                    children: [
                      if (isPhotoTaken) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check, color: Colors.green, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Photo Captured Successfully',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (fileStore != null) ...[
//show the actual photo image here if available

                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Container(
                              //width 90% of sreen width
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: 250,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                            image: FileImage(
                                              File(fileStore!.path),
                                            ),
                                            fit: BoxFit.fill),
                                      ),
                                      alignment: Alignment.center,
                                    ),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Row(
                                        children: [
                                          fileStore!.upLoaded
                                              ? const Icon(
                                                  Icons.checklist,
                                                  color: Colors.green,
                                                )
                                              : const Icon(
                                                  Icons.pending,
                                                  color: Colors.orange,
                                                ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                  image: FileImage(
                                    File(fileStore!.path),
                                  ),
                                  fit: BoxFit.fill),
                            ),
                            alignment: Alignment.center,
                          ),

                          verticalSpaceSmall,
                          Text(
                            'Photo: ${fileStore!.tempPath!.split('/').last}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning, color: Colors.orange, size: 16),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Photo Required for Foreign License',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        verticalSpaceSmall,
                        // Placeholder license card image
                        Container(
                          height: 80,
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300, width: 1),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blue.shade50,
                                Colors.blue.shade100,
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Card background pattern
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: LicenseCardPainter(),
                                ),
                              ),
                              // Card content
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    // Photo placeholder
                                    Container(
                                      width: 50,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: Colors.grey.shade400),
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey.shade500,
                                        size: 30,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // License info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            height: 8,
                                            width: 120,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          Container(
                                            height: 6,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                          Container(
                                            height: 6,
                                            width: 100,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Tap to capture overlay
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.black.withOpacity(0.1),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Tap to capture license photo',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ], // Close the else block
                    ], // Close GestureDetector Column children
                  ), // Close GestureDetector Column
                ), // Close GestureDetector
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for license card background pattern
class LicenseCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw subtle background lines to simulate license card pattern
    for (int i = 0; i < 5; i++) {
      final y = (size.height / 6) * (i + 1);
      canvas.drawLine(
        Offset(60, y),
        Offset(size.width - 10, y),
        paint,
      );
    }

    // Draw a subtle border around the card
    final borderPaint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
