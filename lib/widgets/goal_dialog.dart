import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import 'goal_art.dart';

/// Muestra la ventana de "¡Objetivo desbloqueado!" con confeti y animación.
Future<void> showGoalDialog(
  BuildContext context, {
  required Goal goal,
  Goal? next,
  double? missingForNext,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Cerrar',
    barrierColor: const Color(0xD9120C0E),
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (context, _, __) => _GoalDialog(
      goal: goal,
      next: next,
      missingForNext: missingForNext,
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: curved, child: child),
      );
    },
  );
}

class _GoalDialog extends StatelessWidget {
  const _GoalDialog({required this.goal, this.next, this.missingForNext});

  final Goal goal;
  final Goal? next;
  final double? missingForNext;

  @override
  Widget build(BuildContext context) {
    final index = kGoals.indexOf(goal) + 1;
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          const Positioned.fill(child: IgnorePointer(child: ConfettiView())),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.goldBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'OBJETIVO $index DE ${kGoals.length}',
                          style: AppText.body(12, weight: FontWeight.w700, color: AppColors.gold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GoalArtView(art: goal.art, size: 210),
                      Text(
                        '¡Objetivo desbloqueado!',
                        textAlign: TextAlign.center,
                        style: AppText.display(28),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${goal.percent} % · ${goal.title}',
                        textAlign: TextAlign.center,
                        style: AppText.display(19, weight: FontWeight.w700, color: AppColors.salmon),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        goal.description,
                        textAlign: TextAlign.center,
                        style: AppText.body(15, color: AppColors.muted),
                      ),
                      const SizedBox(height: 14),
                      if (next != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              const MysteryBadge(size: 40),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Siguiente objetivo al ${next!.percent} %',
                                        style: AppText.body(13, color: AppColors.muted)),
                                    Text(
                                      missingForNext == null
                                          ? '¿Qué será?'
                                          : 'Faltan ${euros(missingForNext!)} para descubrirlo',
                                      style: AppText.body(15, weight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.salmon,
                            foregroundColor: AppColors.bg,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            next == null ? '¡Sois leyenda!' : '¡A por más!',
                            style: AppText.body(17, weight: FontWeight.w800, color: AppColors.bg),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Círculo con "?" que late: un objetivo que aún no se ha descubierto.
class MysteryBadge extends StatefulWidget {
  const MysteryBadge({super.key, this.size = 52});

  final double size;

  @override
  State<MysteryBadge> createState() => _MysteryBadgeState();
}

class _MysteryBadgeState extends State<MysteryBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.5, end: 1).animate(_c),
      child: Container(
        width: widget.size,
        height: widget.size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.bg,
          border: Border.all(color: AppColors.lineStrong, width: 2),
        ),
        child: Text('?', style: AppText.display(widget.size * 0.42, color: AppColors.faint)),
      ),
    );
  }
}

/// Lluvia de confeti en bucle.
class ConfettiView extends StatefulWidget {
  const ConfettiView({super.key});

  @override
  State<ConfettiView> createState() => _ConfettiViewState();
}

class _ConfettiViewState extends State<ConfettiView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => CustomPaint(painter: _ConfettiPainter(_c.value)),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);

  final double t;

  static const _colors = [
    AppColors.gold,
    AppColors.salmon,
    AppColors.win,
    AppColors.text,
    Color(0xFF7EC8F0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const n = 28;
    for (var i = 0; i < n; i++) {
      // Valores "aleatorios" pero fijos para cada pieza.
      final rx = ((i * 37) % 100) / 100;
      final speed = 0.8 + ((i * 13) % 10) / 20;
      final phase = (i * 0.137) % 1;
      final p = (t * speed + phase) % 1;
      final x = rx * size.width + math.sin((p + rx) * 2 * math.pi) * 14;
      final y = -20 + p * (size.height + 40);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p * 6 * math.pi + i);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(-5, -2.5, 10, 5),
          const Radius.circular(2),
        ),
        Paint()..color = _colors[i % _colors.length],
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
