import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/menu_data.dart';
import '../logic/history_controller.dart';
import '../logic/meal_controller.dart';
import '../models/dish.dart';
import '../models/goal.dart';
import '../models/meal_record.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/goal_art.dart';
import '../widgets/goal_dialog.dart';

/// Pantalla 4: resumen final. También se usa para ver comidas del historial.
class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key, required this.record, this.fromHistory = false});

  final MealRecord record;

  /// true si se abre desde el historial (entonces no se puede guardar otra vez).
  final bool fromHistory;

  Future<void> _save(BuildContext context) async {
    await context.read<HistoryController>().add(record);
    if (!context.mounted) return;
    context.read<MealController>().clearMeal();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _discard(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('¿Salir sin guardar?'),
        content: const Text('Esta comida no aparecerá en el historial.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Salir sin guardar'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    context.read<MealController>().clearMeal();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final r = record;
    final win = r.zakeLoses;
    final maxBar = r.foodCost > r.zakeIncome ? r.foodCost : r.zakeIncome;

    final categories = r.categoryCosts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategory = categories.isEmpty ? 1.0 : categories.first.value;

    String? starDish;
    if (r.dishCounts.isNotEmpty) {
      final top = r.dishCounts.entries.reduce((a, b) => a.value >= b.value ? a : b);
      final dish = kMenuById[top.key];
      if (dish != null) starDish = '${dish.name} ×${top.value}';
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            if (fromHistory)
              Align(
                alignment: Alignment.centerLeft,
                child: IconSquareButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Volver',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            if (fromHistory) const SizedBox(height: 12),
            Panel(
              color: win ? AppColors.winBg : AppColors.line,
              radius: 28,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                children: [
                  GoalArtView(
                    art: win ? GoalArt.crown : GoalArt.sweatingChef,
                    size: 150,
                    showRays: win,
                  ),
                  Text(
                    win
                        ? (r.people > 1 ? '¡Victoria en grupo!' : '¡Victoria!')
                        : 'Esta vez gana Zake',
                    textAlign: TextAlign.center,
                    style: AppText.display(32),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    win
                        ? 'Zake ha perdido ${euros(r.balance)} con ${r.people > 1 ? 'vosotros ${r.people}' : 'contigo'}'
                        : 'Se ha quedado con ${euros(-r.balance)} de beneficio. ¡La próxima!',
                    textAlign: TextAlign.center,
                    style: AppText.body(15, color: win ? const Color(0xFFCDEBD6) : AppColors.muted),
                  ),
                  const SizedBox(height: 4),
                  Text(shortDate(r.date), style: AppText.body(13, color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CompareRow(
                    label: 'Zake ingresó (menús sin IVA + bebidas)',
                    value: r.zakeIncome,
                    fraction: maxBar == 0 ? 0 : r.zakeIncome / maxBar,
                    color: AppColors.faint,
                  ),
                  const SizedBox(height: 12),
                  _CompareRow(
                    label: 'Le costasteis',
                    value: r.foodCost,
                    fraction: maxBar == 0 ? 0 : r.foodCost / maxBar,
                    color: win ? AppColors.win : AppColors.salmon,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pagasteis ${euros(r.paid)} en menús · ${percent(r.percent)} del objetivo',
                    style: AppText.body(13, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            if (r.diners.length > 1) ...[
              const SizedBox(height: 12),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Ranking del grupo'),
                    for (var i = 0; i < r.diners.length; i++)
                      _RankingRow(position: i + 1, diner: r.diners[i]),
                  ],
                ),
              ),
            ],
            if (categories.isNotEmpty) ...[
              const SizedBox(height: 12),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('¿Dónde le hicisteis daño?'),
                    for (final e in categories)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 104,
                              child: Text(
                                _categoryLabel(e.key),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.body(14),
                              ),
                            ),
                            Expanded(
                              child: ProgressBar(
                                value: topCategory == 0 ? 0 : e.value / topCategory,
                                color: AppColors.salmon,
                                height: 10,
                              ),
                            ),
                            SizedBox(
                              width: 72,
                              child: Text(euros(e.value),
                                  textAlign: TextAlign.right,
                                  style: AppText.body(14, weight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Panel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Objetivos conseguidos', style: AppText.body(13, color: AppColors.muted)),
                        Text('${r.goals.length} de ${kGoals.length}', style: AppText.display(20)),
                      ],
                    ),
                  ),
                  for (final g in kGoals)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: r.goals.contains(g.percent)
                          ? Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                              child: const Icon(Icons.check_rounded, size: 18, color: AppColors.bg),
                            )
                          : const MysteryBadge(size: 28),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: StatTile(label: 'rondas', value: '${r.rounds}')),
                const SizedBox(width: 10),
                Expanded(child: StatTile(label: 'platos', value: '${r.plates}')),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: StatTile(label: 'plato estrella', value: starDish ?? '—', valueSize: 16),
                ),
              ],
            ),
            if (!fromHistory) ...[
              const SizedBox(height: 20),
              AppButton(label: 'Guardar en el historial', onPressed: () => _save(context)),
              const SizedBox(height: 10),
              AppButton(label: 'Salir sin guardar', primary: false, onPressed: () => _discard(context)),
            ],
          ],
        ),
      ),
    );
  }

  static String _categoryLabel(String name) {
    for (final c in DishCategory.values) {
      if (c.name == name) return c.label;
    }
    return name;
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
  });

  final String label;
  final double value;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: AppText.body(14, color: AppColors.muted))),
            Text(euros(value), style: AppText.body(15, weight: FontWeight.w700, color: color == AppColors.faint ? AppColors.text : color)),
          ],
        ),
        const SizedBox(height: 6),
        ProgressBar(value: fraction, color: color),
      ],
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.position, required this.diner});

  final int position;
  final DinerResult diner;

  @override
  Widget build(BuildContext context) {
    final medal = position == 1
        ? AppColors.gold
        : position == 2
            ? const Color(0xFFC9C3BD)
            : position == 3
                ? const Color(0xFFC98B4A)
                : AppColors.surfaceHigh;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: medal, shape: BoxShape.circle),
            child: Text('$position',
                style: AppText.body(14,
                    weight: FontWeight.w800,
                    color: position <= 3 ? AppColors.bg : AppColors.text)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(position == 1 ? '${diner.name} · MVP' : diner.name,
                    style: AppText.body(15, weight: FontWeight.w700)),
                Text('${diner.plates} platos', style: AppText.body(12, color: AppColors.muted)),
              ],
            ),
          ),
          Text(euros(diner.cost), style: AppText.display(16, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}
