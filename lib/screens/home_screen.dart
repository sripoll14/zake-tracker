import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/history_controller.dart';
import '../logic/meal_controller.dart';
import '../logic/pricing.dart';
import '../models/goal.dart';
import '../models/meal.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/goal_art.dart';
import 'history_screen.dart';
import 'meal_screen.dart';

/// Pantalla 1: elegir día y personas, y empezar a comer.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DayType _day = Pricing.suggestDayType(DateTime.now());

  // Nombres de cada persona, por tipo. El número de nombres = nº de personas.
  final Map<DinerType, List<String>> _names = {
    DinerType.adult: ['Adulto 1', 'Adulto 2'],
    DinerType.child: [],
    DinerType.baby: [],
  };

  static const _defaultName = {
    DinerType.adult: 'Adulto',
    DinerType.child: 'Niño',
    DinerType.baby: 'Peque',
  };

  int get _total => _names.values.fold(0, (a, l) => a + l.length);

  double get _price {
    var p = 0.0;
    _names.forEach((type, list) => p += Pricing.menuPrice(_day, type) * list.length);
    return p;
  }

  void _changeCount(DinerType type, int delta) {
    setState(() {
      final list = _names[type]!;
      if (delta > 0 && _total < 20) {
        list.add('${_defaultName[type]} ${list.length + 1}');
      } else if (delta < 0 && list.isNotEmpty) {
        list.removeLast();
      }
    });
  }

  Future<void> _rename(DinerType type, int index) async {
    final controller = TextEditingController(text: _names[type]![index]);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('¿Cómo se llama?', style: AppText.display(22)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 16,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nombre'),
          onSubmitted: (v) => Navigator.of(context).pop(v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result != null && result.trim().isNotEmpty) {
      setState(() => _names[type]![index] = result.trim());
    }
  }

  Future<void> _start() async {
    final meal = context.read<MealController>();
    if (meal.hasMeal) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('¿Empezar otra comida?'),
          content: const Text('La comida que tienes a medias se borrará.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Empezar otra'),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    final diners = <Diner>[
      for (final type in DinerType.values)
        for (final name in _names[type]!) Diner(name: name, type: type),
    ];
    meal.startMeal(dayType: _day, diners: diners);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MealScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final meal = context.watch<MealController>();
    final history = context.watch<HistoryController>();
    final last = history.last;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Row(
              children: [
                Text('ZAKE', style: AppText.display(22).copyWith(letterSpacing: 6)),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('tracker',
                      style: AppText.body(12, weight: FontWeight.w700, color: AppColors.salmonLight)),
                ),
                const Spacer(),
                IconSquareButton(
                  icon: Icons.history_rounded,
                  tooltip: 'Historial',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text('¿Le ganamos hoy al buffet?', style: AppText.display(34)),
            const SizedBox(height: 6),
            Text(
              'Apuntad cada plato y descubrid si Zake sale perdiendo con vosotros.',
              style: AppText.body(15, color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            Panel(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Center(child: GoalArtView(art: GoalArt.balance, size: 170)),
            ),
            if (meal.hasMeal) ...[
              const SizedBox(height: 16),
              const _ResumeCard(),
            ],
            const SizedBox(height: 20),
            const SectionLabel('¿Cuándo coméis?'),
            Row(
              children: [
                Expanded(
                  child: _DayOption(
                    title: 'Entre semana',
                    subtitle: 'L–J y viernes a mediodía',
                    selected: _day == DayType.weekday,
                    onTap: () => setState(() => _day = DayType.weekday),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DayOption(
                    title: 'Finde y festivos',
                    subtitle: 'Viernes noche, sáb y dom',
                    selected: _day == DayType.weekend,
                    onTap: () => setState(() => _day = DayType.weekend),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SectionLabel('¿Cuántos sois?'),
            Panel(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Column(
                children: [
                  _CountRow(
                    title: 'Adultos',
                    subtitle: '${euros(Pricing.menuPrice(_day, DinerType.adult))} por persona',
                    value: _names[DinerType.adult]!.length,
                    onChanged: (d) => _changeCount(DinerType.adult, d),
                  ),
                  const Divider(color: AppColors.line, height: 1),
                  _CountRow(
                    title: 'Niños',
                    subtitle: 'Hasta 1,30 m · ${euros(Pricing.menuPrice(_day, DinerType.child))}',
                    value: _names[DinerType.child]!.length,
                    onChanged: (d) => _changeCount(DinerType.child, d),
                  ),
                  const Divider(color: AppColors.line, height: 1),
                  _CountRow(
                    title: 'Menores de 3 años',
                    subtitle: euros(Pricing.menuPrice(_day, DinerType.baby)),
                    value: _names[DinerType.baby]!.length,
                    onChanged: (d) => _changeCount(DinerType.baby, d),
                  ),
                ],
              ),
            ),
            if (_total > 1) ...[
              const SizedBox(height: 12),
              Text('Toca un nombre para cambiarlo (sirve para el ranking del grupo):',
                  style: AppText.body(13, color: AppColors.muted)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in DinerType.values)
                    for (var i = 0; i < _names[type]!.length; i++)
                      ActionChip(
                        avatar: const Icon(Icons.edit_rounded, size: 16),
                        label: Text(_names[type]![i]),
                        backgroundColor: AppColors.surface,
                        side: BorderSide.none,
                        onPressed: () => _rename(type, i),
                      ),
                ],
              ),
            ],
            const SizedBox(height: 22),
            Material(
              color: _total == 0 ? AppColors.surfaceHigh : AppColors.salmon,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _total == 0 ? null : _start,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _total == 0
                                  ? 'Añade al menos una persona'
                                  : '${people(_total)} · pagáis ${euros(_price)} sin bebida',
                              style: AppText.body(13, weight: FontWeight.w500, color: AppColors.bg),
                            ),
                            Text('Empezar a comer',
                                style: AppText.display(20, color: AppColors.bg)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: AppColors.bg, size: 28),
                    ],
                  ),
                ),
              ),
            ),
            if (last != null) ...[
              const SizedBox(height: 12),
              Panel(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                radius: 18,
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: last.zakeLoses ? AppColors.winBg : AppColors.line,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        last.zakeLoses ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                        color: last.zakeLoses ? AppColors.win : AppColors.salmon,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Última comida · ${shortDate(last.date)} · ${people(last.people)}',
                              style: AppText.body(13, color: AppColors.muted)),
                          Text(
                            last.zakeLoses
                                ? 'Le ganasteis por ${signedEuros(last.balance)}'
                                : 'Ganó Zake por ${euros(-last.balance)}',
                            style: AppText.body(15, weight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResumeCard extends StatelessWidget {
  const _ResumeCard();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<MealController>();
    final s = c.stats;
    return Panel(
      color: AppColors.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tienes una comida a medias', style: AppText.display(18)),
          const SizedBox(height: 4),
          Text('${s.plates} platos · ${percent(s.percent)} del objetivo',
              style: AppText.body(14, color: AppColors.muted)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Continuar',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MealScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppButton(
                  label: 'Descartar',
                  primary: false,
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Text('¿Descartar la comida?'),
                        content: const Text('Se borrará todo lo apuntado y no se guardará en el historial.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Descartar'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true && context.mounted) {
                      context.read<MealController>().clearMeal();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayOption extends StatelessWidget {
  const _DayOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.line : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: selected ? AppColors.salmon : Colors.transparent, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.body(15, weight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppText.body(12, color: AppColors.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.body(15, weight: FontWeight.w700)),
                Text(subtitle, style: AppText.body(13, color: AppColors.muted)),
              ],
            ),
          ),
          AppStepper(
            value: value,
            onIncrement: () => onChanged(1),
            onDecrement: () => onChanged(-1),
            incrementLabel: 'Añadir persona',
            decrementLabel: 'Quitar persona',
          ),
        ],
      ),
    );
  }
}
