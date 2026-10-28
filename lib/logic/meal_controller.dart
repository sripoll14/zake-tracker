import 'package:flutter/foundation.dart';

import '../data/menu_data.dart';
import '../models/dish.dart';
import '../models/goal.dart';
import '../models/meal.dart';
import '../models/meal_record.dart';
import 'meal_calculator.dart';
import 'storage.dart';

/// Cerebro de la comida en curso.
///
/// Es un ChangeNotifier: cada vez que algo cambia llama a notifyListeners()
/// y las pantallas que lo escuchan (con Provider) se redibujan solas.
class MealController extends ChangeNotifier {
  MealController(this._storage) : _meal = _storage.loadCurrentMeal();

  final Storage _storage;
  Meal? _meal;
  MealStats? _statsCache;
  Goal? _pendingGoal;

  Meal? get meal => _meal;
  bool get hasMeal => _meal != null;

  /// Estadísticas de la comida. Se calculan una vez y se guardan en caché
  /// hasta que vuelve a cambiar algo.
  MealStats get stats => _statsCache ??= MealCalculator.calculate(_meal!);

  // ------------------------------------------------------------ Empezar/acabar

  void startMeal({required DayType dayType, required List<Diner> diners}) {
    _meal = Meal(startedAt: DateTime.now(), dayType: dayType, diners: diners);
    _pendingGoal = null;
    _changed(checkGoals: false);
  }

  /// Borra la comida en curso (tras guardarla en el historial o descartarla).
  void clearMeal() {
    _meal = null;
    _pendingGoal = null;
    _statsCache = null;
    _storage.saveCurrentMeal(null);
    notifyListeners();
  }

  /// Crea el resumen que se guarda en el historial.
  MealRecord buildRecord() {
    final m = _meal!;
    final s = stats;
    final diners = <DinerResult>[
      for (var i = 0; i < m.diners.length; i++)
        DinerResult(
          name: m.diners[i].name,
          cost: s.costByDiner[i] ?? 0,
          plates: s.platesByDiner[i] ?? 0,
        ),
    ]..sort((a, b) => b.cost.compareTo(a.cost));

    return MealRecord(
      date: m.startedAt,
      dayType: m.dayType,
      people: m.diners.length,
      paid: s.paid,
      zakeIncome: s.zakeIncome,
      foodCost: s.foodCost,
      plates: s.plates,
      rounds: m.rounds,
      goals: m.unlockedGoals.toList()..sort(),
      dishCounts: Map<String, int>.from(s.dishCounts),
      categoryCosts: s.costByCategory.map((k, v) => MapEntry(k.name, v)),
      diners: diners,
    );
  }

  // ----------------------------------------------------------------- Platos

  int countInRound(Dish dish) => _meal!.entries
      .where((e) => e.dishId == dish.id && e.round == _meal!.currentRound)
      .length;

  int countTotal(Dish dish) =>
      _meal!.entries.where((e) => e.dishId == dish.id).length;

  /// Un plato limitado solo puede pedirse una vez por persona en toda la comida.
  bool canAdd(Dish dish) =>
      !dish.limited || countTotal(dish) < _meal!.limitPerDish;

  void add(Dish dish) {
    final m = _meal;
    if (m == null || !canAdd(dish)) return;
    m.entries.add(OrderEntry(
      dishId: dish.id,
      round: m.currentRound,
      diner: m.currentDiner,
    ));
    _changed();
  }

  /// Quita el último pedido de ese plato en la ronda actual,
  /// preferiblemente el de la persona seleccionada.
  void remove(Dish dish) {
    final m = _meal;
    if (m == null) return;
    var i = m.entries.lastIndexWhere((e) =>
        e.dishId == dish.id &&
        e.round == m.currentRound &&
        e.diner == m.currentDiner);
    if (i < 0) {
      i = m.entries.lastIndexWhere(
          (e) => e.dishId == dish.id && e.round == m.currentRound);
    }
    if (i < 0) return;
    m.entries.removeAt(i);
    _changed();
  }

  // ----------------------------------------------------------------- Rondas

  void newRound() {
    final m = _meal!;
    m.rounds++;
    m.currentRound = m.rounds - 1;
    _changed(checkGoals: false);
  }

  void selectRound(int round) {
    _meal!.currentRound = round;
    _changed(checkGoals: false);
  }

  /// Platos de comida pedidos en una ronda.
  int platesInRound(int round) => _meal!.entries
      .where((e) => e.round == round && !(kMenuById[e.dishId]?.isExtra ?? true))
      .length;

  // --------------------------------------------------------------- Personas

  void selectDiner(int index) {
    _meal!.currentDiner = index;
    _changed(checkGoals: false);
  }

  // -------------------------------------------------------------- Objetivos

  /// Siguiente objetivo aún no conseguido (null si ya están todos).
  Goal? get nextGoal {
    for (final g in kGoals) {
      if (!_meal!.unlockedGoals.contains(g.percent)) return g;
    }
    return null;
  }

  /// Euros de comida que faltan para llegar a un objetivo.
  double missingFor(Goal goal) {
    final s = stats;
    final needed = s.zakeIncome * goal.percent / 100 - s.foodCost;
    return needed < 0 ? 0 : needed;
  }

  /// Devuelve el objetivo recién conseguido (si lo hay) y lo marca como
  /// mostrado. La pantalla de la carta lo usa para enseñar la animación.
  Goal? takePendingGoal() {
    final g = _pendingGoal;
    _pendingGoal = null;
    return g;
  }

  /// Platos más "caros" para Zake que aún se pueden pedir: sugerencias
  /// para remontar.
  List<Dish> suggestions({int count = 3}) {
    final m = _meal!;
    final options = kMenu
        .where((d) => !d.isExtra)
        .where((d) => m.dayType == DayType.weekend || !d.weekendOnly)
        .where(canAdd)
        .toList()
      ..sort((a, b) => b.cost.compareTo(a.cost));
    return options.take(count).toList();
  }

  // ---------------------------------------------------------------- Interno

  void _changed({bool checkGoals = true}) {
    _statsCache = null;
    if (checkGoals) _checkGoals();
    _storage.saveCurrentMeal(_meal);
    notifyListeners();
  }

  /// Desbloquea los objetivos superados. Una vez conseguido, un objetivo
  /// no se pierde aunque se quite un plato.
  void _checkGoals() {
    final m = _meal;
    if (m == null) return;
    final pct = stats.percent;
    for (final g in kGoals) {
      if (pct >= g.percent && !m.unlockedGoals.contains(g.percent)) {
        m.unlockedGoals.add(g.percent);
        _pendingGoal = g; // si se pasan varios a la vez, se muestra el mayor
      }
    }
  }
}
