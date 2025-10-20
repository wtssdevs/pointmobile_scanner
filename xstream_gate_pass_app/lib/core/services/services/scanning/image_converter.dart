import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ImageConverter {
  /// Converts raw grayscale bitmap data to a Flutter-compatible image
  static Future<Uint8List?> convertDriversLicenseImage(
      Uint8List imageData, int width, int height) async {
    try {
      // Create an ImageData object with the raw pixels
      final Uint8List rgbaData = _grayscaleToRgba(imageData, width, height);

      // Use Flutter's decodeImageFromPixels to create an image from the RGBA data
      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        rgbaData,
        width,
        height,
        ui.PixelFormat.rgba8888,
        completer.complete,
      );
      final image = await completer.future;

      // Convert to PNG format
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error converting license image: $e');
      return null;
    }
  }

  /// Convert grayscale data to RGBA format required by Flutter
  static Uint8List _grayscaleToRgba(
      Uint8List grayscaleData, int width, int height) {
    // Create RGBA data (4 bytes per pixel)
    final rgbaData = Uint8List(width * height * 4);

    int rgbaIndex = 0;
    for (int i = 0; i < grayscaleData.length; i++) {
      // For each grayscale byte, create an RGBA pixel
      final pixel = grayscaleData[i];

      // Set RGB channels to the same value to create grayscale
      rgbaData[rgbaIndex++] = pixel; // R
      rgbaData[rgbaIndex++] = pixel; // G
      rgbaData[rgbaIndex++] = pixel; // B
      rgbaData[rgbaIndex++] = 255; // A (fully opaque)
    }

    return rgbaData;
  }
}
