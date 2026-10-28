import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart' as fmt;

/// Medidor semicircular de 0 % a 150 % con los objetivos marcados encima.
/// Los objetivos conseguidos salen dorados con un ✓; los demás, con "?".
class ScoreGauge extends StatelessWidget {
  const ScoreGauge({
    super.key,
    required this.percent,
    required this.unlocked,
  });

  final double percent;
  final Set<int> unlocked;

  static const double maxPercent = 150;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 330 / 200,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: percent),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) => Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _GaugePainter(value, unlocked)),
            ),
            Align(
              alignment: const Alignment(0, 0.3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(fmt.percent(value), style: AppText.display(44)),
                  const SizedBox(height: 4),
                  Text('del objetivo recuperado',
                      style: AppText.body(13, color: AppColors.muted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.value, this.unlocked);

  final double value;
  final Set<int> unlocked;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 330;
    canvas.save();
    canvas.scale(s);

    const center = Offset(165, 168);
    const r = 130.0;
    final rect = Rect.fromCircle(center: center, radius: r);

    final track = Paint()
      ..color = AppColors.bg
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, track);

    final fraction = (value / ScoreGauge.maxPercent).clamp(0.0, 1.0);
    if (fraction > 0) {
      final progress = Paint()
        ..color = value >= 100 ? AppColors.win : AppColors.salmon
        ..style = PaintingStyle.stroke
        ..strokeWidth = 22
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, math.pi, math.pi * fraction, false, progress);
    }

    for (final g in kGoals) {
      final a = math.pi + math.pi * g.percent / ScoreGauge.maxPercent;
      final o = center + Offset(math.cos(a) * r, math.sin(a) * r);
      if (unlocked.contains(g.percent)) {
        canvas.drawCircle(o, 16, Paint()..color = AppColors.surface);
        canvas.drawCircle(o, 13, Paint()..color = AppColors.gold);
        final check = Path()
          ..moveTo(o.dx - 6, o.dy)
          ..lineTo(o.dx - 1.5, o.dy + 5)
          ..lineTo(o.dx + 6.5, o.dy - 5);
        canvas.drawPath(
          check,
          Paint()
            ..color = AppColors.bg
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      } else {
        canvas.drawCircle(o, 16, Paint()..color = AppColors.surface);
        canvas.drawCircle(o, 13, Paint()..color = AppColors.surfaceHigh);
        canvas.drawCircle(
          o,
          13,
          Paint()
            ..color = const Color(0xFF6B5155)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        final tp = TextPainter(
          text: TextSpan(text: '?', style: AppText.display(16, color: AppColors.muted)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, o - Offset(tp.width / 2, tp.height / 2));
      }
    }

    for (final mark in const [(0, '0 %'), (150, '150 %')]) {
      final a = math.pi + math.pi * mark.$1 / ScoreGauge.maxPercent;
      final o = center + Offset(math.cos(a) * r, math.sin(a) * r + 22);
      final tp = TextPainter(
        text: TextSpan(text: mark.$2, style: AppText.body(11, color: AppColors.muted)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, o - Offset(tp.width / 2, tp.height / 2));
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.value != value || old.unlocked.length != unlocked.length;
}
