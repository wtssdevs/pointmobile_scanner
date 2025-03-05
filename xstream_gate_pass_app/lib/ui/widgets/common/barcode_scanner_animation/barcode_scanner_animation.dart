import 'dart:math';
import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';

class BarcodeScannerAnimation extends StatefulWidget {
  const BarcodeScannerAnimation({Key? key}) : super(key: key);

  @override
  State<BarcodeScannerAnimation> createState() => _BarcodeScannerAnimationState();
}

class _BarcodeScannerAnimationState extends State<BarcodeScannerAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: BarcodeScannerPainter(
            scanLinePosition: _animation.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class BarcodeScannerPainter extends CustomPainter {
  final double scanLinePosition;

  BarcodeScannerPainter({required this.scanLinePosition});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint borderPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Paint scanLinePaint = Paint()
      ..color = kcPrimaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Draw barcode frame
    final RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, borderPaint);

    // Draw barcode lines (to simulate a barcode pattern)
    final Paint barcodePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double barWidth = 3.0;
    const double spacing = 4.0;
    const double startY = 20.0;
    final double barHeight = size.height - 40.0;

    double currentX = 20.0;
    while (currentX < size.width - 20.0) {
      // Randomize bar heights a bit to look like a barcode
      final bool isFullHeight = Random().nextBool();
      final double height = isFullHeight ? barHeight : barHeight * 0.7;
      final double startOffset = isFullHeight ? 0 : (barHeight - height) / 2;

      canvas.drawLine(
        Offset(currentX, startY + startOffset),
        Offset(currentX, startY + startOffset + height),
        barcodePaint,
      );
      currentX += barWidth + spacing;
    }

    // Draw scan line (moving red line)
    final double scanLineY = startY + (barHeight * scanLinePosition);
    canvas.drawLine(
      Offset(10, scanLineY),
      Offset(size.width - 10, scanLineY),
      scanLinePaint,
    );

    // Add a slight glow effect to the scan line
    final Paint glowPaint = Paint()
      ..color = kcPrimaryColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    canvas.drawLine(
      Offset(10, scanLineY),
      Offset(size.width - 10, scanLineY),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant BarcodeScannerPainter oldDelegate) {
    return oldDelegate.scanLinePosition != scanLinePosition;
  }
}
