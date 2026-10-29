import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/menu_data.dart';
import '../logic/history_controller.dart';
import '../logic/meal_controller.dart';
import '../models/dish.dart';
import '../models/meal.dart';
import '../theme/app_theme.dart';
import '../utils/format.dart';
import '../utils/search.dart';
import '../widgets/chili_icon.dart';
import '../widgets/common.dart';
import '../widgets/dish_art.dart';
import '../widgets/goal_dialog.dart';
import 'score_screen.dart';

/// Filtros que se pueden combinar con el buscador.
enum DishFilter {
  popular('Muy pedidos'),
  spicy('Picantes'),
  notSpicy('Sin picante'),
  limited('Limitados'),
  ordered('Ya pedidos');

  const DishFilter(this.label);
  final String label;
}

/// Pantalla 2: la carta. Aquí se apuntan los platos ronda a ronda.
class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  DishCategory _category = DishCategory.nigiri;

  final TextEditingController _search = TextEditingController();
  String _query = '';
  final Set<DishFilter> _filters = {};
  bool _showFilters = false;

  /// Una clave por categoría para poder centrar su chip en la fila.
  final Map<DishCategory, GlobalKey> _categoryKeys = {};

  void _selectCategory(DishCategory cat) {
    setState(() => _category = cat);
    // Tras redibujar, desplaza la fila para que la categoría elegida se vea.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _categoryKeys[cat]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Panel inferior con todas las categorías a la vista.
  Future<void> _openCategorySheet(List<DishCategory> categories) async {
    final picked = await showModalBottomSheet<DishCategory>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Categorías', style: AppText.display(22)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final cat in categories)
                    AppChip(
                      label: cat.label,
                      selected: cat == _category,
                      filledWhenSelected: true,
                      onTap: () => Navigator.of(context).pop(cat),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (picked != null && mounted) _selectCategory(picked);
  }

  /// Hay búsqueda o filtros activos: se muestran resultados de toda la carta.
  bool get _searching => _query.trim().isNotEmpty || _filters.isNotEmpty;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggleFilter(DishFilter f) {
    setState(() {
      if (!_filters.remove(f)) {
        _filters.add(f);
        // "Picantes" y "Sin picante" no tienen sentido a la vez.
        if (f == DishFilter.spicy) _filters.remove(DishFilter.notSpicy);
        if (f == DishFilter.notSpicy) _filters.remove(DishFilter.spicy);
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _search.clear();
      _query = '';
      _filters.clear();
    });
  }

  /// Platos "muy pedidos": los favoritos del historial y los que ya se han
  /// pedido 3 veces o más en esta comida.
  Set<String> _popularIds(MealController c, HistoryController h) {
    final ids = <String>{...h.popularDishIds()};
    c.stats.dishCounts.forEach((id, n) {
      if (n >= 3) ids.add(id);
    });
    return ids;
  }

  bool _passesFilters(Dish d, MealController c, Set<String> popular) {
    for (final f in _filters) {
      final ok = switch (f) {
        DishFilter.popular => popular.contains(d.id),
        DishFilter.spicy => d.spicy > 0,
        DishFilter.notSpicy => d.spicy == 0,
        DishFilter.limited => d.limited,
        DishFilter.ordered => c.countTotal(d) > 0,
      };
      if (!ok) return false;
    }
    return true;
  }

  /// Si al añadir un plato se ha conseguido un objetivo, se enseña la
  /// animación justo después de redibujar la pantalla.
  void _maybeShowGoal(MealController c) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final goal = c.takePendingGoal();
      if (goal == null) return;
      final next = c.nextGoal;
      showGoalDialog(
        context,
        goal: goal,
        next: next,
        missingForNext: next == null ? null : c.missingFor(next),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<MealController>();
    final history = context.watch<HistoryController>();
    final meal = c.meal;
    if (meal == null) {
      // La comida se ha cerrado (p. ej. desde el resumen): no hay nada que mostrar.
      return const Scaffold(body: SizedBox.shrink());
    }
    _maybeShowGoal(c);

    final popular = _popularIds(c, history);
    final categories = categoriesFor(meal.dayType);
    if (!categories.contains(_category)) _category = categories.first;

    // Lo que se enseña en la lista: o la categoría elegida, o los resultados
    // de la búsqueda agrupados por categoría (con un título por grupo).
    final items = <Object>[];
    if (_searching) {
      for (final cat in categories) {
        final found = dishesFor(cat, meal.dayType)
            .where((d) => matchesQuery(d, _query))
            .where((d) => _passesFilters(d, c, popular))
            .toList();
        if (found.isEmpty) continue;
        items.add(cat);
        items.addAll(found);
      }
    } else {
      items.addAll(dishesFor(_category, meal.dayType));
      if (_category == DishCategory.extras) items.add('extras-note');
    }
    final resultCount = items.whereType<Dish>().length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  IconSquareButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Volver al inicio',
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${meal.dayType == DayType.weekend ? 'Finde' : 'Entre semana'} · ${people(meal.diners.length)}',
                          style: AppText.body(13, color: AppColors.muted),
                        ),
                        Text('La carta', style: AppText.display(22)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text('${c.stats.plates} platos',
                        style: AppText.body(13, weight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _RoundsBar(controller: c),
            if (meal.diners.length > 1) ...[
              const SizedBox(height: 10),
              _DinerBar(controller: c),
            ],
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _search,
                      onChanged: (v) => setState(() => _query = v),
                      textInputAction: TextInputAction.search,
                      style: AppText.body(15),
                      decoration: InputDecoration(
                        hintText: 'Buscar por nombre o número',
                        hintStyle: AppText.body(15, color: AppColors.faint),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted),
                        suffixIcon: _query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Borrar búsqueda',
                                icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                                onPressed: () => setState(() {
                                  _search.clear();
                                  _query = '';
                                }),
                              ),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.salmon, width: 2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterButton(
                    active: _filters.length,
                    open: _showFilters,
                    onTap: () => setState(() => _showFilters = !_showFilters),
                  ),
                ],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: _showFilters
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: HorizontalScroller(
                        children: [
                          for (final f in DishFilter.values)
                            _FilterChip(
                              filter: f,
                              selected: _filters.contains(f),
                              onTap: () => _toggleFilter(f),
                            ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            const SizedBox(height: 10),
            if (_searching)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        resultCount == 1 ? '1 plato encontrado' : '$resultCount platos encontrados',
                        style: AppText.body(14, weight: FontWeight.w700),
                      ),
                    ),
                    TextButton(onPressed: _clearSearch, child: const Text('Volver a la carta')),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                  children: [
                    IconSquareButton(
                      icon: Icons.grid_view_rounded,
                      tooltip: 'Ver todas las categorías',
                      onTap: () => _openCategorySheet(categories),
                    ),
                    Expanded(
                      child: HorizontalScroller(
                        padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                        children: [
                          for (final cat in categories)
                            AppChip(
                              key: _categoryKeys.putIfAbsent(cat, GlobalKey.new),
                              label: cat.label,
                              selected: cat == _category,
                              filledWhenSelected: true,
                              onTap: () => _selectCategory(cat),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'No hay platos que coincidan. Prueba con otra palabra o quita algún filtro.',
                        textAlign: TextAlign.center,
                        style: AppText.body(15, color: AppColors.muted),
                      ),
                    )
                  : ListView.separated(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        if (item is DishCategory) {
                          return Padding(
                            padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                            child: Text(item.label.toUpperCase(), style: AppText.label()),
                          );
                        }
                        if (item is Dish) {
                          return DishTile(
                            dish: item,
                            controller: c,
                            popular: popular.contains(item.id),
                          );
                        }
                        return const WarningBox(
                          'Las bebidas y postres no van en el menú: se pagan aparte y casi '
                          'todo es beneficio para Zake. Por eso suben su marcador.',
                        );
                      },
                    ),
            ),
            _ScoreBar(controller: c),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.active, required this.open, required this.onTap});

  final int active;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Filtros',
      child: Material(
        color: open || active > 0 ? AppColors.line : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: active > 0 ? AppColors.salmon : Colors.transparent, width: 2),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.tune_rounded, color: AppColors.text),
                if (active > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: AppColors.salmon, shape: BoxShape.circle),
                      child: Text('$active',
                          style: AppText.body(10, weight: FontWeight.w800, color: AppColors.bg)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.filter, required this.selected, required this.onTap});

  final DishFilter filter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget? icon = switch (filter) {
      DishFilter.popular => const FireIcon(size: 16),
      DishFilter.spicy => const ChiliIcon(size: 16),
      _ => null,
    };
    return Material(
      color: selected ? AppColors.line : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: selected ? AppColors.salmon : Colors.transparent, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.check_rounded, size: 16, color: AppColors.salmon),
                ),
              if (icon != null) ...[icon, const SizedBox(width: 6)],
              Text(
                filter.label,
                style: AppText.body(14, weight: selected ? FontWeight.w700 : FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fuego naranja: plato muy pedido.
class FireIcon extends StatelessWidget {
  const FireIcon({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.local_fire_department_rounded, size: size, color: const Color(0xFFFF9F43));
  }
}

class _RoundsBar extends StatelessWidget {
  const _RoundsBar({required this.controller});

  final MealController controller;

  @override
  Widget build(BuildContext context) {
    final meal = controller.meal!;
    return HorizontalScroller(
      height: 56,
      children: [
        for (var r = 0; r < meal.rounds; r++)
          AppChip(
            label: 'Ronda ${r + 1}',
            subtitle: r == meal.currentRound
                ? 'ahora · ${controller.platesInRound(r)} platos'
                : '${controller.platesInRound(r)} platos',
            selected: r == meal.currentRound,
            onTap: () => controller.selectRound(r),
          ),
        Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.lineStrong, width: 2),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: controller.newRound,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                child: Text('+ Nueva ronda',
                    style: AppText.body(14, weight: FontWeight.w700, color: AppColors.salmonLight)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DinerBar extends StatelessWidget {
  const _DinerBar({required this.controller});

  final MealController controller;

  @override
  Widget build(BuildContext context) {
    final meal = controller.meal!;
    return HorizontalScroller(
      children: [
        Center(child: Text('Para:', style: AppText.body(13, color: AppColors.muted))),
        for (var i = 0; i < meal.diners.length; i++)
          AppChip(
            label: meal.diners[i].name,
            selected: i == meal.currentDiner,
            onTap: () => controller.selectDiner(i),
          ),
      ],
    );
  }
}

/// Una fila de la carta: dibujo, nombre, coste y botones − / +.
class DishTile extends StatelessWidget {
  const DishTile({
    super.key,
    required this.dish,
    required this.controller,
    this.popular = false,
  });

  final Dish dish;
  final MealController controller;

  /// Se muestra el fuego de "Muy pedido".
  final bool popular;

  @override
  Widget build(BuildContext context) {
    final inRound = controller.countInRound(dish);
    final total = controller.countTotal(dish);
    final limit = controller.meal!.limitPerDish;
    final showTotal = !dish.limited && total > inRound;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: inRound > 0 ? AppColors.lineStrong : AppColors.surface,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          DishArtView(dish: dish),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!dish.isExtra)
                  Text('Nº ${dish.id}',
                      style: AppText.body(12, weight: FontWeight.w700, color: AppColors.muted)),
                Text(dish.name, style: AppText.body(16, weight: FontWeight.w700)),
                if (dish.detail.isNotEmpty)
                  Text(dish.detail, style: AppText.body(13, color: AppColors.muted)),
                Text(
                  dish.isExtra
                      ? '${euros(dish.price)} · suma para Zake'
                      : 'Coste para Zake ≈ ${euros(dish.cost)}',
                  style: AppText.body(13, color: AppColors.muted),
                ),
                if (dish.limited || dish.spicy > 0 || popular || showTotal)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (popular)
                          _Badge(
                            'Muy pedido',
                            const Color(0xFF4A2E14),
                            const Color(0xFFFFC58A),
                            icon: const FireIcon(size: 13),
                          ),
                        if (dish.limited)
                          _Badge('Limitado · $total de $limit', AppColors.limitedBg, AppColors.limitedText),
                        if (dish.spicy > 0)
                          Semantics(
                            label: 'Picante nivel ${dish.spicy} de 3',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (var i = 0; i < dish.spicy; i++) const ChiliIcon(size: 16),
                              ],
                            ),
                          ),
                        if (showTotal)
                          Text('En total: $total',
                              style: AppText.body(12, color: AppColors.faint)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppStepper(
            value: inRound,
            canIncrement: controller.canAdd(dish),
            onIncrement: () => controller.add(dish),
            onDecrement: () => controller.remove(dish),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, this.bg, this.fg, {this.icon});

  final String text;
  final Color bg;
  final Color fg;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 3)],
          Text(text, style: AppText.body(11, weight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

/// Panel inferior con el marcador resumido.
class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.controller});

  final MealController controller;

  @override
  Widget build(BuildContext context) {
    final s = controller.stats;
    final color = s.zakeLoses ? AppColors.win : AppColors.salmon;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coste para Zake', style: AppText.body(13, color: AppColors.muted)),
                    Text(euros(s.foodCost), style: AppText.display(28, color: color)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Zake ingresa', style: AppText.body(13, color: AppColors.muted)),
                  Text(euros(s.zakeIncome), style: AppText.display(20, weight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProgressBar(value: s.percent / 100, color: color, height: 14),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  s.zakeLoses
                      ? '¡Zake ya pierde ${euros(s.balance)}!'
                      : 'Faltan ${euros(-s.balance)} para empatar',
                  style: AppText.body(14, weight: FontWeight.w500),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.salmon,
                  foregroundColor: AppColors.bg,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScoreScreen()),
                ),
                child: Text('Marcador',
                    style: AppText.body(14, weight: FontWeight.w700, color: AppColors.bg)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
