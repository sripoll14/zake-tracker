import 'package:flutter/material.dart';

/// Guindilla dibujada con código (para los platos picantes).
class ChiliIcon extends StatelessWidget {
  const ChiliIcon({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ChiliPainter()),
    );
  }
}

class _ChiliPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Hoja virtual de 24 x 24.
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);

    final body = Path()
      ..moveTo(8.5, 7)
      ..cubicTo(4, 9, 3.5, 16.5, 9, 20)
      ..cubicTo(12.5, 22.2, 17.5, 22.4, 21.5, 21)
      ..cubicTo(16, 19.5, 12.8, 15.5, 12.6, 10.5)
      ..cubicTo(12.5, 8, 10.6, 6.2, 8.5, 7)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFFE5484D));

    // Brillo.
    final shine = Path()
      ..moveTo(7.6, 11)
      ..quadraticBezierTo(7.4, 15.5, 10.6, 18.2);
    canvas.drawPath(
      shine,
      Paint()
        ..color = const Color(0x99FFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );

    // Rabito y cáliz verdes.
    final green = Paint()..color = const Color(0xFF5E9E52);
    canvas.drawOval(Rect.fromCenter(center: const Offset(10, 7.2), width: 6.5, height: 3.6), green);
    final stem = Path()
      ..moveTo(10, 6.5)
      ..quadraticBezierTo(9.6, 3.2, 12.8, 2);
    canvas.drawPath(
      stem,
      Paint()
        ..color = const Color(0xFF5E9E52)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ChiliPainter oldDelegate) => false;
}
