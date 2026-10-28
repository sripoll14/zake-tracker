import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/dish.dart';
import '../theme/app_theme.dart';

/// Dibujo de un plato, hecho con código (CustomPainter) en lugar de fotos.
///
/// Ventajas: no ocupa espacio, se ve nítido a cualquier tamaño, se adapta
/// al color de cada plato y evita usar fotos con derechos de autor.
class DishArtView extends StatelessWidget {
  const DishArtView({super.key, required this.dish, this.size = 64});

  final Dish dish;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(size / 4),
      ),
      padding: EdgeInsets.all(size * 0.1),
      child: CustomPaint(painter: DishPainter(dish.art, Color(dish.color))),
    );
  }
}

class DishPainter extends CustomPainter {
  DishPainter(this.art, this.color);

  final DishArt art;
  final Color color;

  static const _rice = Color(0xFFF6EFE7);
  static const _nori = Color(0xFF1E2B22);
  static const _noriLight = Color(0xFF2F4A3A);
  static const _plate = Color(0xFFE9E1D8);
  static const _leaf = Color(0xFF5E9E52);
  static const _bowl = Color(0xFF8A2E2E);

  Paint _p(Color c) => Paint()
    ..color = c
    ..isAntiAlias = true;

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  Color get _light => Color.lerp(color, Colors.white, 0.45)!;
  Color get _dark => Color.lerp(color, Colors.black, 0.35)!;

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujamos sobre una "hoja" virtual de 100 x 80 y la escalamos.
    final s = math.min(size.width / 100, size.height / 80);
    canvas.save();
    canvas.translate((size.width - 100 * s) / 2, (size.height - 80 * s) / 2);
    canvas.scale(s);
    switch (art) {
      case DishArt.nigiri:
        _nigiri(canvas);
      case DishArt.gunkan:
        _gunkan(canvas);
      case DishArt.maki:
        _maki(canvas);
      case DishArt.uramaki:
        _uramaki(canvas);
      case DishArt.temaki:
        _temaki(canvas);
      case DishArt.sashimi:
        _sashimi(canvas);
      case DishArt.bowl:
        _bowlDish(canvas);
      case DishArt.noodles:
        _noodles(canvas);
      case DishArt.dumpling:
        _dumpling(canvas);
      case DishArt.bao:
        _bao(canvas);
      case DishArt.skewer:
        _skewer(canvas);
      case DishArt.tempura:
        _tempura(canvas);
      case DishArt.salad:
        _salad(canvas);
      case DishArt.plate:
        _plateDish(canvas);
      case DishArt.shellfish:
        _shellfish(canvas);
      case DishArt.drink:
        _drink(canvas);
      case DishArt.dessert:
        _dessert(canvas);
    }
    canvas.restore();
  }

  void _nigiri(Canvas c) {
    c.drawOval(Rect.fromCenter(center: const Offset(50, 54), width: 78, height: 30), _p(_rice));
    final fish = Path()
      ..moveTo(8, 48)
      ..quadraticBezierTo(50, 8, 92, 42)
      ..quadraticBezierTo(92, 54, 50, 54)
      ..quadraticBezierTo(8, 54, 8, 48)
      ..close();
    c.drawPath(fish, _p(color));
    final st = _stroke(_light, 3);
    c.drawLine(const Offset(30, 30), const Offset(38, 50), st);
    c.drawLine(const Offset(48, 25), const Offset(54, 50), st);
    c.drawLine(const Offset(66, 28), const Offset(70, 48), st);
  }

  void _gunkan(Canvas c) {
    c.drawRRect(RRect.fromLTRBR(24, 32, 76, 74, const Radius.circular(12)), _p(_nori));
    c.drawRect(const Rect.fromLTRB(24, 48, 76, 54), _p(_noriLight));
    c.drawOval(Rect.fromCenter(center: const Offset(50, 32), width: 54, height: 16), _p(_rice));
    c.drawOval(Rect.fromCenter(center: const Offset(50, 25), width: 44, height: 22), _p(color));
    for (final o in const [Offset(42, 21), Offset(52, 18), Offset(58, 26), Offset(46, 28)]) {
      c.drawCircle(o, 2.4, _p(_dark));
    }
  }

  void _maki(Canvas c) {
    for (final center in const [Offset(34, 46), Offset(68, 42)]) {
      c.drawCircle(center, 24, _p(_nori));
      c.drawCircle(center, 19, _p(_rice));
      c.drawCircle(center, 8, _p(color));
    }
  }

  void _uramaki(Canvas c) {
    for (final center in const [Offset(34, 46), Offset(68, 42)]) {
      c.drawCircle(center, 24, _p(_rice));
      for (var i = 0; i < 12; i++) {
        final a = i * math.pi / 6;
        c.drawCircle(center + Offset(math.cos(a) * 19, math.sin(a) * 19), 2.6, _p(color));
      }
      c.drawCircle(center, 13, _p(_nori));
      c.drawCircle(center, 9, _p(color));
      c.drawCircle(center + const Offset(3, 3), 4, _p(const Color(0xFF9CC46B)));
    }
  }

  void _temaki(Canvas c) {
    final cone = Path()
      ..moveTo(18, 24)
      ..lineTo(84, 30)
      ..lineTo(42, 78)
      ..close();
    c.drawPath(cone, _p(_nori));
    c.drawOval(Rect.fromCenter(center: const Offset(51, 26), width: 66, height: 18), _p(_rice));
    c.drawOval(Rect.fromCenter(center: const Offset(46, 20), width: 30, height: 16), _p(color));
    c.drawOval(Rect.fromCenter(center: const Offset(66, 22), width: 18, height: 12), _p(const Color(0xFF9CC46B)));
  }

  void _sashimi(Canvas c) {
    c.drawOval(Rect.fromCenter(center: const Offset(50, 56), width: 92, height: 34), _p(_leaf));
    for (var i = 0; i < 3; i++) {
      c.save();
      c.translate(28.0 + i * 22, 44);
      c.rotate(-0.35);
      c.drawRRect(RRect.fromLTRBR(-10, -14, 10, 14, const Radius.circular(6)), _p(color));
      c.drawLine(const Offset(-6, -4), const Offset(6, -8), _stroke(_light, 2.4));
      c.drawLine(const Offset(-6, 6), const Offset(6, 2), _stroke(_light, 2.4));
      c.restore();
    }
  }

  void _bowlShape(Canvas c, Color fill) {
    c.drawOval(Rect.fromCenter(center: const Offset(50, 36), width: 84, height: 22), _p(fill));
    final bowl = Path()
      ..moveTo(8, 36)
      ..quadraticBezierTo(12, 76, 50, 76)
      ..quadraticBezierTo(88, 76, 92, 36)
      ..quadraticBezierTo(50, 50, 8, 36)
      ..close();
    c.drawPath(bowl, _p(_bowl));
    c.drawLine(const Offset(18, 54), const Offset(82, 54), _stroke(const Color(0xFFB54848), 2.5));
  }

  void _bowlDish(Canvas c) {
    _bowlShape(c, color);
    c.drawCircle(const Offset(40, 33), 3, _p(_leaf));
    c.drawCircle(const Offset(58, 36), 2.5, _p(_leaf));
  }

  void _noodles(Canvas c) {
    _bowlShape(c, _dark);
    final st = _stroke(color, 3);
    for (var i = 0; i < 4; i++) {
      final y = 30.0 + i * 3;
      final p = Path()..moveTo(18, y);
      for (var x = 18.0; x < 82; x += 8) {
        p.quadraticBezierTo(x + 4, y - 5, x + 8, y);
      }
      c.drawPath(p, st);
    }
    c.drawLine(const Offset(60, 8), const Offset(78, 40), _stroke(const Color(0xFFC98B4A), 3));
    c.drawLine(const Offset(68, 6), const Offset(84, 38), _stroke(const Color(0xFFE0A867), 3));
  }

  void _dumpling(Canvas c) {
    for (final o in const [Offset(30, 50), Offset(70, 46)]) {
      final body = Path()
        ..moveTo(o.dx - 22, o.dy + 10)
        ..quadraticBezierTo(o.dx, o.dy - 34, o.dx + 22, o.dy + 10)
        ..quadraticBezierTo(o.dx, o.dy + 16, o.dx - 22, o.dy + 10)
        ..close();
      c.drawPath(body, _p(color));
      final st = _stroke(_dark.withAlpha(140), 2);
      for (var i = -2; i <= 2; i++) {
        c.drawLine(Offset(o.dx + i * 6, o.dy - 14 + i.abs() * 4), Offset(o.dx + i * 5, o.dy - 4), st);
      }
    }
  }

  void _bao(Canvas c) {
    c.drawOval(Rect.fromCenter(center: const Offset(50, 46), width: 80, height: 50), _p(color));
    c.drawOval(Rect.fromCenter(center: const Offset(50, 40), width: 56, height: 24), _p(_light));
    c.drawCircle(const Offset(50, 30), 4, _p(_dark));
  }

  void _skewer(Canvas c) {
    for (var k = 0; k < 2; k++) {
      final dy = k * 22.0;
      c.drawLine(Offset(6, 30 + dy), Offset(94, 22 + dy), _stroke(const Color(0xFFC98B4A), 3));
      for (var i = 0; i < 3; i++) {
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(30.0 + i * 20, 28 + dy - i * 2), width: 18, height: 16),
            const Radius.circular(6),
          ),
          _p(i.isEven ? color : _dark),
        );
      }
    }
  }

  void _tempura(Canvas c) {
    c.drawOval(Rect.fromCenter(center: const Offset(50, 62), width: 92, height: 24), _p(_plate));
    final batter = _p(const Color(0xFFE3A64A));
    for (final o in const [Offset(32, 48), Offset(54, 42), Offset(72, 50)]) {
      c.drawOval(Rect.fromCenter(center: o, width: 30, height: 22), batter);
      c.drawCircle(o + const Offset(-5, -4), 3, _p(const Color(0xFFF2C77A)));
    }
    c.drawCircle(const Offset(54, 44), 6, _p(color));
  }

  void _salad(Canvas c) {
    c.drawOval(Rect.fromCenter(center: const Offset(50, 50), width: 92, height: 50), _p(_plate));
    for (final o in const [Offset(34, 46), Offset(52, 40), Offset(68, 48), Offset(46, 54)]) {
      c.drawOval(Rect.fromCenter(center: o, width: 26, height: 14), _p(_leaf));
    }
    for (final o in const [Offset(40, 44), Offset(60, 50), Offset(54, 38)]) {
      c.drawCircle(o, 6, _p(color));
    }
  }

  void _plateDish(Canvas c) {
    c.drawOval(Rect.fromCenter(center: const Offset(50, 52), width: 96, height: 44), _p(_plate));
    c.drawOval(Rect.fromCenter(center: const Offset(50, 52), width: 76, height: 32), _p(const Color(0xFFD8CEC3)));
    final rnd = math.Random(art.index * 7919 + color.hashCode);
    for (var i = 0; i < 7; i++) {
      final o = Offset(30 + rnd.nextDouble() * 40, 40 + rnd.nextDouble() * 18);
      c.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: o, width: 15, height: 11), const Radius.circular(4)),
        _p(i.isEven ? color : _dark),
      );
    }
    c.drawCircle(const Offset(40, 42), 2.5, _p(_leaf));
    c.drawCircle(const Offset(62, 46), 2.5, _p(_leaf));
  }

  void _shellfish(Canvas c) {
    c.drawOval(Rect.fromCenter(center: const Offset(50, 60), width: 94, height: 26), _p(_plate));
    for (var i = 0; i < 3; i++) {
      c.save();
      c.translate(26.0 + i * 24, 46);
      final shell = Path()
        ..moveTo(-12, 8)
        ..quadraticBezierTo(0, -24, 12, 8)
        ..close();
      c.drawPath(shell, _p(color));
      final st = _stroke(_dark, 1.6);
      c.drawLine(const Offset(0, 6), const Offset(0, -12), st);
      c.drawLine(const Offset(0, 6), const Offset(-7, -6), st);
      c.drawLine(const Offset(0, 6), const Offset(7, -6), st);
      c.restore();
    }
  }

  void _drink(Canvas c) {
    final glass = RRect.fromLTRBR(30, 10, 70, 74, const Radius.circular(8));
    c.drawRRect(glass, _p(const Color(0x33FFFFFF)));
    c.drawRRect(RRect.fromLTRBR(33, 26, 67, 71, const Radius.circular(6)), _p(color));
    for (final o in const [Offset(44, 56), Offset(54, 46), Offset(48, 36)]) {
      c.drawCircle(o, 2.5, _p(const Color(0x88FFFFFF)));
    }
    c.drawRRect(glass, _stroke(const Color(0x88FFFFFF), 2));
  }

  void _dessert(Canvas c) {
    final cup = Path()
      ..moveTo(26, 46)
      ..lineTo(74, 46)
      ..lineTo(64, 76)
      ..lineTo(36, 76)
      ..close();
    c.drawPath(cup, _p(const Color(0xFF6B5155)));
    c.drawCircle(const Offset(50, 36), 20, _p(color));
    c.drawCircle(const Offset(44, 30), 5, _p(_light));
  }

  @override
  bool shouldRepaint(DishPainter old) => old.art != art || old.color != color;
}
