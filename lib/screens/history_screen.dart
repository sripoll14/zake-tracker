import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/menu_data.dart';
import '../logic/history_controller.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'summary_screen.dart';

/// Historial de comidas y estadísticas generales.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final h = context.watch<HistoryController>();
    final records = h.records;
    final best = h.best;
    final favId = h.favouriteDishId;
    final fav = favId == null ? null : kMenuById[favId];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Row(
              children: [
                IconSquareButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Volver',
                  onTap: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 12),
                Text('Historial', style: AppText.display(22)),
              ],
            ),
            const SizedBox(height: 16),
            if (records.isEmpty)
              Panel(
                child: Text(
                  'Aún no hay comidas guardadas. Cuando terminéis una, aparecerá aquí con sus estadísticas.',
                  style: AppText.body(15, color: AppColors.muted),
                ),
              )
            else ...[
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: [
                  StatTile(label: 'Comidas', value: '${records.length}'),
                  StatTile(
                    label: 'Victorias',
                    value: '${h.wins} de ${records.length}',
                    valueColor: AppColors.win,
                  ),
                  StatTile(label: 'Racha actual', value: '${h.currentStreak}'),
                  StatTile(label: 'Mejor racha', value: '${h.bestStreak}'),
                ],
              ),
              const SizedBox(height: 10),
              if (best != null && best.zakeLoses)
                Panel(
                  radius: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: AppColors.gold),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Mejor comida: ${shortDate(best.date)} (Zake perdió ${euros(best.balance)})',
                          style: AppText.body(14, weight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              if (fav != null) ...[
                const SizedBox(height: 10),
                Panel(
                  radius: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_rounded, color: AppColors.salmon),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('Plato más pedido: ${fav.name}',
                            style: AppText.body(14, weight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              const SectionLabel('Comidas'),
              Text('Desliza una comida hacia la izquierda para borrarla.',
                  style: AppText.body(12, color: AppColors.faint)),
              const SizedBox(height: 8),
              for (var i = 0; i < records.length; i++) ...[
                Dismissible(
                  key: ValueKey(records[i].date.toIso8601String()),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) => showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.surface,
                      title: const Text('¿Borrar esta comida?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Borrar'),
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (_) => context.read<HistoryController>().removeAt(i),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppColors.limitedBg,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: AppColors.limitedText),
                  ),
                  child: Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SummaryScreen(record: records[i], fromHistory: true),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              records[i].zakeLoses ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                              color: records[i].zakeLoses ? AppColors.win : AppColors.salmon,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(shortDate(records[i].date),
                                      style: AppText.body(15, weight: FontWeight.w700)),
                                  Text(
                                    '${people(records[i].people)} · ${records[i].plates} platos · ${percent(records[i].percent)}',
                                    style: AppText.body(13, color: AppColors.muted),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              signedEuros(records[i].balance),
                              style: AppText.display(16,
                                  color: records[i].zakeLoses ? AppColors.win : AppColors.salmon),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
