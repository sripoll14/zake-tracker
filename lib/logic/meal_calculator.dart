import '../data/menu_data.dart';
import '../models/dish.dart';
import '../models/meal.dart';
import 'pricing.dart';

/// Todos los números de una comida, calculados a partir de lo pedido.
class MealStats {
  const MealStats({
    required this.paid,
    required this.menuIncome,
    required this.extrasProfit,
    required this.extrasSpent,
    required this.foodCost,
    required this.plates,
    required this.costByCategory,
    required this.costByDiner,
    required this.platesByDiner,
    required this.dishCounts,
    required this.payingDiners,
  });

  /// Lo pagado en menús, con IVA (lo que veis en el ticket, sin bebidas).
  final double paid;

  /// Lo que se queda Zake de los menús (sin IVA).
  final double menuIncome;

  /// Beneficio de Zake con bebidas y postres.
  final double extrasProfit;

  /// Lo gastado en bebidas y postres, con IVA.
  final double extrasSpent;

  /// Coste estimado de toda la comida.
  final double foodCost;

  /// Platos de comida pedidos (sin contar bebidas ni postres).
  final int plates;

  final Map<DishCategory, double> costByCategory;
  final Map<int, double> costByDiner;
  final Map<int, int> platesByDiner;

  /// Veces que se ha pedido cada plato de comida.
  final Map<String, int> dishCounts;

  /// Personas que pagan menú (para el "por persona").
  final int payingDiners;

  /// Lo que gana Zake antes de pagar la comida: el objetivo a superar.
  double get zakeIncome => menuIncome + extrasProfit;

  /// Porcentaje del ingreso de Zake que ya os habéis comido.
  double get percent => zakeIncome <= 0 ? 0 : foodCost / zakeIncome * 100;

  /// Positivo: Zake pierde ese dinero. Negativo: aún gana.
  double get balance => foodCost - zakeIncome;

  bool get zakeLoses => balance > 0;

  double get costPerPerson => payingDiners == 0 ? 0 : foodCost / payingDiners;
}

/// Funciones puras (sin estado) para calcular las estadísticas.
/// Al no depender de la interfaz, se pueden probar con tests unitarios.
class MealCalculator {
  MealCalculator._();

  static MealStats calculate(Meal meal, {Map<String, Dish>? menu}) {
    final dishes = menu ?? kMenuById;

    var paid = 0.0;
    for (final d in meal.diners) {
      paid += Pricing.menuPrice(meal.dayType, d.type);
    }

    var foodCost = 0.0;
    var extrasProfit = 0.0;
    var extrasSpent = 0.0;
    var plates = 0;
    final byCategory = <DishCategory, double>{};
    final byDiner = <int, double>{};
    final platesByDiner = <int, int>{};
    final counts = <String, int>{};

    for (final e in meal.entries) {
      final dish = dishes[e.dishId];
      if (dish == null) continue; // plato que ya no existe en la carta
      if (dish.isExtra) {
        extrasProfit += Pricing.extraProfit(dish.price);
        extrasSpent += dish.price;
        continue;
      }
      foodCost += dish.cost;
      plates++;
      byCategory[dish.category] = (byCategory[dish.category] ?? 0) + dish.cost;
      byDiner[e.diner] = (byDiner[e.diner] ?? 0) + dish.cost;
      platesByDiner[e.diner] = (platesByDiner[e.diner] ?? 0) + 1;
      counts[dish.id] = (counts[dish.id] ?? 0) + 1;
    }

    return MealStats(
      paid: paid,
      menuIncome: Pricing.withoutIva(paid),
      extrasProfit: extrasProfit,
      extrasSpent: extrasSpent,
      foodCost: foodCost,
      plates: plates,
      costByCategory: byCategory,
      costByDiner: byDiner,
      platesByDiner: platesByDiner,
      dishCounts: counts,
      payingDiners: meal.diners.length,
    );
  }
}
