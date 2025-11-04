import 'dart:io';
import 'package:flutter/material.dart';

class PhotoPreviewWidget extends StatelessWidget {
  const PhotoPreviewWidget({
    Key? key,
    required this.imagePath,
    required this.onTap,
    this.badgeText = 'Photo Captured',
  }) : super(key: key);

  final String imagePath;
  final VoidCallback onTap;
  final String badgeText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green, width: 2),
            image: DecorationImage(
              image: FileImage(File(imagePath)),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}