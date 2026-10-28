import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/meal_controller.dart';
import '../models/goal.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/dish_art.dart';
import '../widgets/goal_art.dart';
import '../widgets/goal_dialog.dart';
import '../widgets/score_gauge.dart';
import 'summary_screen.dart';

/// Pantalla 3: marcador en directo con los objetivos misteriosos.
class ScoreScreen extends StatelessWidget {
  const ScoreScreen({super.key});

  Future<void> _finish(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('¿Terminar la comida?'),
        content: const Text('Verás el resumen y podrás guardarlo en el historial.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Seguir comiendo'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Terminar'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final record = context.read<MealController>().buildRecord();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SummaryScreen(record: record)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<MealController>();
    final meal = c.meal;
    if (meal == null) return const Scaffold(body: SizedBox.shrink());
    final s = c.stats;
    final next = c.nextGoal;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Row(
              children: [
                IconSquareButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Volver a la carta',
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${people(meal.diners.length)} · ronda ${meal.currentRound + 1}',
                          style: AppText.body(13, color: AppColors.muted)),
                      Text('Marcador', style: AppText.display(22)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Panel(
              radius: 28,
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 18),
              child: Column(
                children: [
                  ScoreGauge(percent: s.percent, unlocked: meal.unlockedGoals),
                  const SizedBox(height: 8),
                  Text(
                    s.zakeLoses ? '¡Zake está perdiendo!' : _mood(s.percent),
                    style: AppText.display(22),
                  ),
                  const SizedBox(height: 4),
                  if (next != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.muted),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Próximo objetivo misterioso: faltan ${euros(c.missingFor(next))}',
                            textAlign: TextAlign.center,
                            style: AppText.body(14, color: AppColors.muted),
                          ),
                        ),
                      ],
                    )
                  else
                    Text('¡Todos los objetivos conseguidos!',
                        style: AppText.body(14, color: AppColors.gold)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              children: [
                StatTile(label: 'Habéis pagado (menús)', value: euros(s.paid)),
                StatTile(label: 'Zake ingresa (sin IVA + bebidas)', value: euros(s.zakeIncome)),
                StatTile(
                  label: 'Coste de lo comido',
                  value: euros(s.foodCost),
                  valueColor: s.zakeLoses ? AppColors.win : AppColors.salmon,
                ),
                StatTile(label: 'Coste por persona', value: euros(s.costPerPerson)),
              ],
            ),
            const SizedBox(height: 12),
            Panel(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  SectionLabel(
                    'Objetivos',
                    trailing: Text('${meal.unlockedGoals.length} de ${kGoals.length}',
                        style: AppText.body(13, weight: FontWeight.w700, color: AppColors.gold)),
                  ),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                    children: [
                      for (final g in kGoals)
                        _GoalCell(
                          goal: g,
                          unlocked: meal.unlockedGoals.contains(g.percent),
                          onTap: () => showGoalDialog(
                            context,
                            goal: g,
                            next: c.nextGoal,
                            missingForNext: c.nextGoal == null ? null : c.missingFor(c.nextGoal!),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const SectionLabel('Para remontar'),
            for (final d in c.suggestions()) ...[
              Panel(
                radius: 18,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    DishArtView(dish: d, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.name, style: AppText.body(15, weight: FontWeight.w700)),
                          Text(
                            d.limited
                                ? 'Nº ${d.id} · os quedan ${meal.limitPerDish - c.countTotal(d)}'
                                : 'Nº ${d.id} · ${d.category.label}',
                            style: AppText.body(13, color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    Text('≈ ${euros(d.cost)}', style: AppText.display(16, color: AppColors.win)),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: 'Pedir ${d.name}',
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.salmon,
                        foregroundColor: AppColors.bg,
                      ),
                      onPressed: () => c.add(d),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 4),
            const WarningBox(
              'Ojo: si sobra comida en la mesa, Zake puede cobraros un extra. '
              'Pedid solo lo que vayáis a comer: ganar no vale si se tira comida.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Seguir pidiendo',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: 'Terminar comida',
                    primary: false,
                    onPressed: () => _finish(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _mood(double pct) {
    if (pct < 25) return 'Acabáis de empezar';
    if (pct < 50) return 'Buen ritmo';
    if (pct < 75) return 'Vais por la mitad';
    if (pct < 90) return 'Esto se pone interesante';
    return 'Casi empate';
  }
}

class _GoalCell extends StatelessWidget {
  const _GoalCell({required this.goal, required this.unlocked, required this.onTap});

  final Goal goal;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: unlocked ? onTap : null,
      child: Column(
        children: [
          if (unlocked)
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(color: AppColors.goldBg, shape: BoxShape.circle),
              child: GoalArtView(art: goal.art, size: 56, showRays: false),
            )
          else
            const MysteryBadge(size: 56),
          const SizedBox(height: 6),
          Text('${goal.percent} %', style: AppText.body(12, weight: FontWeight.w700)),
          Text(
            unlocked ? goal.title : '???',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.body(11, color: unlocked ? AppColors.muted : AppColors.faint),
          ),
        ],
      ),
    );
  }
}
