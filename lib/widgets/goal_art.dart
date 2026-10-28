import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../theme/app_theme.dart';

/// Ilustración animada de un objetivo.
///
/// Un AnimationController produce un valor `t` que va de 0 a 1 una y otra
/// vez (cada 1,6 s). El CustomPainter dibuja la escena en función de `t`,
/// y así se consigue el movimiento (como un GIF, pero dibujado con código).
class GoalArtView extends StatefulWidget {
  const GoalArtView({
    super.key,
    required this.art,
    this.size = 200,
    this.animate = true,
    this.showRays = true,
  });

  final GoalArt art;
  final double size;
  final bool animate;
  final bool showRays;

  @override
  State<GoalArtView> createState() => _GoalArtViewState();
}

class _GoalArtViewState extends State<GoalArtView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _controller.repeat();
    } else {
      _controller.value = 0.25;
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // importante: liberar el controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: GoalPainter(widget.art, _controller.value, widget.showRays),
        ),
      ),
    );
  }
}

class GoalPainter extends CustomPainter {
  GoalPainter(this.art, this.t, this.showRays);

  final GoalArt art;
  final double t;
  final bool showRays;

  static const _rice = Color(0xFFF6EFE7);
  static const _salmon = AppColors.salmon;
  static const _skin = Color(0xFFF2C9A0);
  static const _ink = Color(0xFF1C1416);
  static const _sweat = Color(0xFF7EC8F0);
  static const _wood = Color(0xFFC98B4A);

  double get _wave => math.sin(2 * math.pi * t);

  Paint _p(Color c) => Paint()
    ..color = c
    ..isAntiAlias = true;

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 200;
    canvas.save();
    canvas.scale(s);

    if (showRays) _rays(canvas);
    canvas.drawCircle(const Offset(100, 100), 70, _p(AppColors.surfaceHigh));

    switch (art) {
      case GoalArt.chopsticks:
        _chopsticks(canvas);
      case GoalArt.halfNigiri:
        _halfNigiri(canvas);
      case GoalArt.sweatingChef:
        _chef(canvas);
      case GoalArt.balance:
        _balance(canvas);
      case GoalArt.cryingRegister:
        _register(canvas);
      case GoalArt.crown:
        _crown(canvas);
    }
    canvas.restore();
  }

  /// Rayos de fondo que giran despacio. Como hay 8 rayos, girar 1/8 de
  /// vuelta por ciclo hace que el bucle no "salte".
  void _rays(Canvas c) {
    c.save();
    c.translate(100, 100);
    c.rotate(t * math.pi / 4);
    final paint = _stroke(AppColors.goldBg, 16);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      c.drawLine(Offset(math.cos(a) * 70, math.sin(a) * 70),
          Offset(math.cos(a) * 96, math.sin(a) * 96), paint);
    }
    c.restore();
  }

  void _nigiri(Canvas c, Offset center, double scale, {Color fish = _salmon}) {
    c.save();
    c.translate(center.dx, center.dy);
    c.scale(scale);
    c.drawOval(Rect.fromCenter(center: const Offset(0, 10), width: 80, height: 32), _p(_rice));
    final p = Path()
      ..moveTo(-42, 4)
      ..quadraticBezierTo(0, -36, 42, -2)
      ..quadraticBezierTo(42, 10, 0, 10)
      ..quadraticBezierTo(-42, 10, -42, 4)
      ..close();
    c.drawPath(p, _p(fish));
    final st = _stroke(const Color(0xFFFFC2A6), 3.5);
    c.drawLine(const Offset(-20, -14), const Offset(-12, 6), st);
    c.drawLine(const Offset(0, -18), const Offset(5, 6), st);
    c.drawLine(const Offset(18, -14), const Offset(22, 4), st);
    c.restore();
  }

  // 25 %: dos palillos que "aplauden" sobre un nigiri que bota.
  void _chopsticks(Canvas c) {
    final bounce = (_wave).abs() * 10;
    _nigiri(c, Offset(92, 132 - bounce), 0.75);
    for (final k in [0, 1]) {
      c.save();
      c.translate(160, 40);
      c.rotate(2.25 + (k == 0 ? 1 : -1) * (0.06 + 0.06 * _wave));
      c.drawLine(Offset.zero, const Offset(110, 0), _stroke(k == 0 ? _wood : const Color(0xFFE0A867), 7));
      c.restore();
    }
  }

  // 50 %: nigiri con un mordisco y migas que caen.
  void _halfNigiri(Canvas c) {
    _nigiri(c, const Offset(100, 112), 1.1);
    final bite = _p(AppColors.surfaceHigh);
    c.drawCircle(const Offset(142, 98), 16, bite);
    c.drawCircle(const Offset(146, 118), 14, bite);
    c.drawCircle(const Offset(138, 80), 10, bite);
    for (var i = 0; i < 3; i++) {
      final phase = (t + i / 3) % 1;
      final o = Offset(140 + i * 6.0, 120 + phase * 40);
      c.drawCircle(o, 3, _p(_rice.withAlpha((255 * (1 - phase)).round())));
    }
  }

  // 75 %: chef que tiembla y suda.
  void _chef(Canvas c) {
    c.save();
    c.translate(0, -4 * _wave.abs());
    c.translate(100, 140);
    c.rotate(0.04 * _wave);
    c.translate(-100, -140);
    c.drawCircle(const Offset(100, 116), 42, _p(_skin));
    final white = _p(Colors.white);
    c.drawCircle(const Offset(78, 62), 16, white);
    c.drawCircle(const Offset(100, 52), 20, white);
    c.drawCircle(const Offset(122, 62), 16, white);
    c.drawRect(const Rect.fromLTRB(72, 62, 128, 82), white);
    c.drawRect(const Rect.fromLTRB(72, 76, 128, 82), _p(const Color(0xFFE6DCD2)));
    final brow = _stroke(const Color(0xFF5A3A2A), 3);
    c.drawLine(const Offset(78, 100), const Offset(91, 96), brow);
    c.drawLine(const Offset(122, 100), const Offset(109, 96), brow);
    c.drawOval(Rect.fromCenter(center: const Offset(86, 112), width: 9, height: 11), _p(_ink));
    c.drawOval(Rect.fromCenter(center: const Offset(114, 112), width: 9, height: 11), _p(_ink));
    c.drawCircle(const Offset(74, 126), 6, _p(const Color(0xAAF0A58A)));
    c.drawCircle(const Offset(126, 126), 6, _p(const Color(0xAAF0A58A)));
    final mouth = Path()
      ..moveTo(88, 136)
      ..quadraticBezierTo(94, 130, 100, 136)
      ..quadraticBezierTo(106, 142, 112, 136);
    c.drawPath(mouth, _stroke(_ink, 3));
    c.restore();
    for (var i = 0; i < 3; i++) {
      final phase = (t + i * 0.33) % 1;
      final base = [const Offset(146, 88), const Offset(56, 96), const Offset(150, 116)][i];
      _drop(c, base + Offset(0, phase * 30), (1 - phase));
    }
  }

  void _drop(Canvas c, Offset o, double opacity) {
    final p = Path()
      ..moveTo(o.dx, o.dy - 8)
      ..quadraticBezierTo(o.dx + 7, o.dy + 2, o.dx, o.dy + 5)
      ..quadraticBezierTo(o.dx - 7, o.dy + 2, o.dx, o.dy - 8)
      ..close();
    c.drawPath(p, _p(_sweat.withAlpha((255 * opacity.clamp(0.0, 1.0)).round())));
  }

  // 100 %: balanza que se equilibra.
  void _balance(Canvas c) {
    const pivot = Offset(100, 66);
    final angle = 0.16 * _wave;
    final pole = _p(const Color(0xFF6B5155));
    c.drawRRect(RRect.fromLTRBR(80, 150, 120, 158, const Radius.circular(4)), pole);
    c.drawRect(const Rect.fromLTRB(96, 66, 104, 152), pole);
    final dx = math.cos(angle) * 62, dy = math.sin(angle) * 62;
    final left = pivot - Offset(dx, dy);
    final right = pivot + Offset(dx, dy);
    c.drawLine(left, right, _stroke(const Color(0xFF8E7A75), 6));
    c.drawCircle(pivot, 8, _p(_salmon));
    for (final end in [left, right]) {
      c.drawLine(end, end + const Offset(-14, 34), _stroke(const Color(0xFF8E7A75), 2));
      c.drawLine(end, end + const Offset(14, 34), _stroke(const Color(0xFF8E7A75), 2));
      c.drawOval(Rect.fromCenter(center: end + const Offset(0, 36), width: 44, height: 10), pole);
    }
    _nigiri(c, left + const Offset(0, 24), 0.34);
    for (var i = 0; i < 3; i++) {
      final o = right + Offset(-8.0 + i * 8, 28 - i * 3.0);
      c.drawCircle(o, 7, _p(i.isEven ? AppColors.gold : const Color(0xFFE3AE33)));
    }
  }

  // 125 %: caja registradora que llora y suelta monedas.
  void _register(Canvas c) {
    final body = _p(const Color(0xFF8E7A75));
    c.drawRRect(RRect.fromLTRBR(56, 92, 144, 150, const Radius.circular(10)), body);
    c.drawRRect(RRect.fromLTRBR(66, 60, 134, 92, const Radius.circular(8)), _p(const Color(0xFF6B5155)));
    c.drawRRect(RRect.fromLTRBR(72, 66, 128, 86, const Radius.circular(4)), _p(const Color(0xFF1F3A2A)));
    final tp = TextPainter(
      text: TextSpan(text: '−€', style: TextStyle(color: AppColors.win, fontSize: 16, fontWeight: FontWeight.w800)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(100 - tp.width / 2, 76 - tp.height / 2));
    c.drawCircle(const Offset(84, 114), 5, _p(_ink));
    c.drawCircle(const Offset(116, 114), 5, _p(_ink));
    final mouth = Path()
      ..moveTo(88, 136)
      ..quadraticBezierTo(100, 126, 112, 136);
    c.drawPath(mouth, _stroke(_ink, 3));
    c.drawRect(const Rect.fromLTRB(60, 150, 140, 160), _p(const Color(0xFF6B5155)));
    for (var i = 0; i < 2; i++) {
      final phase = (t + i * 0.5) % 1;
      _drop(c, Offset(i == 0 ? 84 : 116, 124 + phase * 26), 1 - phase);
    }
    for (var i = 0; i < 3; i++) {
      final phase = (t + i / 3) % 1;
      final x = 100 + (i - 1) * 30 * phase;
      final y = 156 - math.sin(phase * math.pi) * 40 + phase * 20;
      c.drawCircle(Offset(x, y), 6, _p(AppColors.gold.withAlpha((255 * (1 - phase * 0.7)).round())));
    }
  }

  // 150 %: nigiri coronado con destellos.
  void _crown(Canvas c) {
    final scale = 1.0 + 0.05 * _wave;
    c.save();
    c.translate(100, 112);
    c.scale(scale);
    c.translate(-100, -112);
    _nigiri(c, const Offset(100, 124), 1.0);
    final crown = Path()
      ..moveTo(72, 84)
      ..lineTo(78, 58)
      ..lineTo(90, 74)
      ..lineTo(100, 50)
      ..lineTo(110, 74)
      ..lineTo(122, 58)
      ..lineTo(128, 84)
      ..close();
    c.drawPath(crown, _p(AppColors.gold));
    c.drawCircle(const Offset(100, 76), 4, _p(_salmon));
    c.drawCircle(const Offset(88, 136), 3.5, _p(_ink));
    c.drawCircle(const Offset(112, 136), 3.5, _p(_ink));
    final smile = Path()
      ..moveTo(93, 142)
      ..quadraticBezierTo(100, 148, 107, 142);
    c.drawPath(smile, _stroke(_ink, 2.6));
    c.restore();
    const spots = [Offset(52, 64), Offset(150, 58), Offset(160, 130), Offset(44, 136)];
    for (var i = 0; i < spots.length; i++) {
      final k = math.sin(2 * math.pi * (t + i / spots.length)).abs();
      _sparkle(c, spots[i], 4 + 7 * k);
    }
  }

  void _sparkle(Canvas c, Offset o, double r) {
    final p = Path()
      ..moveTo(o.dx, o.dy - r)
      ..lineTo(o.dx + r * 0.3, o.dy - r * 0.3)
      ..lineTo(o.dx + r, o.dy)
      ..lineTo(o.dx + r * 0.3, o.dy + r * 0.3)
      ..lineTo(o.dx, o.dy + r)
      ..lineTo(o.dx - r * 0.3, o.dy + r * 0.3)
      ..lineTo(o.dx - r, o.dy)
      ..lineTo(o.dx - r * 0.3, o.dy - r * 0.3)
      ..close();
    c.drawPath(p, _p(AppColors.gold));
  }

  @override
  bool shouldRepaint(GoalPainter old) =>
      old.t != t || old.art != art || old.showRays != showRays;
}
