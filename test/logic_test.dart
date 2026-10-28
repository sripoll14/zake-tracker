import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zake_tracker/data/menu_data.dart';
import 'package:zake_tracker/logic/meal_calculator.dart';
import 'package:zake_tracker/logic/meal_controller.dart';
import 'package:zake_tracker/logic/pricing.dart';
import 'package:zake_tracker/logic/storage.dart';
import 'package:zake_tracker/models/meal.dart';
import 'package:zake_tracker/models/meal_record.dart';
import 'package:zake_tracker/logic/history_controller.dart';
import 'package:zake_tracker/utils/search.dart';

// Tests de la lógica (sin pantallas). Se ejecutan con:  flutter test

Future<MealController> _controllerWith(List<Diner> diners, {DayType day = DayType.weekend}) async {
  SharedPreferences.setMockInitialValues({});
  final storage = await Storage.open();
  return MealController(storage)..startMeal(dayType: day, diners: diners);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('el precio del menú depende del día y del tipo de comensal', () {
    expect(Pricing.menuPrice(DayType.weekday, DinerType.adult), 18.95);
    expect(Pricing.menuPrice(DayType.weekend, DinerType.adult), 22.95);
    expect(Pricing.menuPrice(DayType.weekend, DinerType.child), 12.95);
    expect(Pricing.menuPrice(DayType.weekday, DinerType.baby), 4.95);
  });

  test('el viernes por la noche cuenta como fin de semana', () {
    expect(Pricing.suggestDayType(DateTime(2026, 10, 30, 21)), DayType.weekend); // viernes
    expect(Pricing.suggestDayType(DateTime(2026, 10, 30, 14)), DayType.weekday);
    expect(Pricing.suggestDayType(DateTime(2026, 10, 31, 14)), DayType.weekend); // sábado
  });

  test('una comida vacía empieza al 0 %', () {
    final meal = Meal(
      startedAt: DateTime(2026),
      dayType: DayType.weekend,
      diners: [Diner(name: 'A', type: DinerType.adult)],
    );
    final s = MealCalculator.calculate(meal);
    expect(s.paid, 22.95);
    expect(s.menuIncome, closeTo(22.95 / 1.10, 0.001));
    expect(s.foodCost, 0);
    expect(s.percent, 0);
    expect(s.zakeLoses, isFalse);
  });

  test('las bebidas suben lo que ingresa Zake, no el coste', () async {
    final c = await _controllerWith([Diner(name: 'A', type: DinerType.adult)]);
    final before = c.stats.zakeIncome;
    c.add(kMenuById['b2']!); // refresco
    expect(c.stats.foodCost, 0);
    expect(c.stats.zakeIncome, greaterThan(before));
    expect(c.stats.plates, 0);
  });

  test('añadir y quitar platos actualiza el coste', () async {
    final c = await _controllerWith([Diner(name: 'A', type: DinerType.adult)]);
    final nigiri = kMenuById['27']!;
    c.add(nigiri);
    c.add(nigiri);
    expect(c.countInRound(nigiri), 2);
    expect(c.stats.foodCost, closeTo(nigiri.cost * 2, 0.001));
    c.remove(nigiri);
    expect(c.countTotal(nigiri), 1);
  });

  test('los platos limitados son uno por persona en toda la comida', () async {
    final c = await _controllerWith([
      Diner(name: 'A', type: DinerType.adult),
      Diner(name: 'B', type: DinerType.adult),
      Diner(name: 'Bebé', type: DinerType.baby),
    ]);
    final sashimi = kMenuById['523']!;
    expect(c.meal!.limitPerDish, 2); // el bebé no cuenta
    c.add(sashimi);
    c.newRound();
    c.add(sashimi);
    c.add(sashimi); // este ya no entra
    expect(c.countTotal(sashimi), 2);
    expect(c.canAdd(sashimi), isFalse);
  });

  test('las rondas guardan sus platos por separado', () async {
    final c = await _controllerWith([Diner(name: 'A', type: DinerType.adult)]);
    final gyoza = kMenuById['17']!;
    c.add(gyoza);
    c.newRound();
    expect(c.countInRound(gyoza), 0);
    expect(c.countTotal(gyoza), 1);
    c.selectRound(0);
    expect(c.countInRound(gyoza), 1);
  });

  test('se desbloquean objetivos al superar los porcentajes', () async {
    final c = await _controllerWith([Diner(name: 'A', type: DinerType.adult)]);
    final gambon = kMenuById['75']!;
    while (c.stats.percent < 30) {
      c.add(gambon);
    }
    expect(c.meal!.unlockedGoals, contains(25));
    expect(c.takePendingGoal()?.percent, 25);
    expect(c.takePendingGoal(), isNull); // solo se muestra una vez
  });

  test('el resumen ordena el ranking de más a menos coste', () async {
    final c = await _controllerWith([
      Diner(name: 'Ana', type: DinerType.adult),
      Diner(name: 'Luis', type: DinerType.adult),
    ]);
    c.selectDiner(1);
    c.add(kMenuById['75']!);
    c.selectDiner(0);
    c.add(kMenuById['9']!);
    final record = c.buildRecord();
    expect(record.diners.first.name, 'Luis');
    expect(record.people, 2);
  });

  test('una comida se guarda y se recupera igual (JSON)', () async {
    final c = await _controllerWith([Diner(name: 'A', type: DinerType.adult)]);
    c.add(kMenuById['27']!);
    final json = c.meal!.toJson();
    final copy = Meal.fromJson(json);
    expect(copy.entries.length, 1);
    expect(copy.dayType, DayType.weekend);
  });

  test('el buscador ignora tildes y mayúsculas', () {
    final nigiri = kMenuById['27']!; // Nigiri de salmón
    expect(matchesQuery(nigiri, 'SALMON'), isTrue);
    expect(matchesQuery(nigiri, 'nigiri salmón'), isTrue);
    expect(matchesQuery(nigiri, '27'), isTrue);
    expect(matchesQuery(nigiri, 'atun'), isFalse);
    expect(matchesQuery(nigiri, '   '), isTrue);
  });

  test('los platos muy pedidos salen del historial', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await Storage.open();
    final h = HistoryController(storage);
    MealRecord meal(Map<String, int> counts) => MealRecord(
          date: DateTime(2026),
          dayType: DayType.weekend,
          people: 1,
          paid: 22.95,
          zakeIncome: 20.86,
          foodCost: 10,
          plates: 5,
          rounds: 1,
          goals: const [],
          dishCounts: counts,
          categoryCosts: const {},
          diners: const [],
        );
    await h.add(meal({'27': 2, '75': 1}));
    await h.add(meal({'27': 2, '9': 1}));
    expect(h.popularDishIds(), contains('27')); // 4 veces en total
    expect(h.popularDishIds(), isNot(contains('75'))); // solo 1 vez
  });

  test('todos los platos tienen un número distinto', () {
    final ids = kMenu.map((d) => d.id).toList();
    expect(ids.toSet().length, ids.length);
  });
}
