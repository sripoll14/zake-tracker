import 'meal.dart';

/// Resultado de una persona del grupo, para el ranking.
class DinerResult {
  const DinerResult({required this.name, required this.cost, required this.plates});

  final String name;
  final double cost;
  final int plates;

  Map<String, dynamic> toJson() => {'name': name, 'cost': cost, 'plates': plates};

  factory DinerResult.fromJson(Map<String, dynamic> json) => DinerResult(
        name: json['name'] as String,
        cost: (json['cost'] as num).toDouble(),
        plates: json['plates'] as int,
      );
}

/// Una comida terminada, tal y como se guarda en el historial.
class MealRecord {
  const MealRecord({
    required this.date,
    required this.dayType,
    required this.people,
    required this.paid,
    required this.zakeIncome,
    required this.foodCost,
    required this.plates,
    required this.rounds,
    required this.goals,
    required this.dishCounts,
    required this.categoryCosts,
    required this.diners,
  });

  final DateTime date;
  final DayType dayType;
  final int people;

  /// Lo que se pagó de menús, con IVA.
  final double paid;

  /// Lo que se queda Zake: menús sin IVA + beneficio de bebidas y postres.
  final double zakeIncome;

  /// Coste estimado de todo lo que se comió.
  final double foodCost;

  final int plates;
  final int rounds;
  final List<int> goals;

  /// Veces que se pidió cada plato (id → cantidad).
  final Map<String, int> dishCounts;

  /// Coste por categoría (nombre de la categoría → euros).
  final Map<String, double> categoryCosts;

  /// Resultado de cada persona, ordenado de mayor a menor coste.
  final List<DinerResult> diners;

  /// Positivo: Zake pierde ese dinero. Negativo: Zake gana.
  double get balance => foodCost - zakeIncome;
  bool get zakeLoses => balance > 0;
  double get percent => zakeIncome <= 0 ? 0 : foodCost / zakeIncome * 100;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'dayType': dayType.name,
        'people': people,
        'paid': paid,
        'zakeIncome': zakeIncome,
        'foodCost': foodCost,
        'plates': plates,
        'rounds': rounds,
        'goals': goals,
        'dishCounts': dishCounts,
        'categoryCosts': categoryCosts,
        'diners': diners.map((d) => d.toJson()).toList(),
      };

  factory MealRecord.fromJson(Map<String, dynamic> json) => MealRecord(
        date: DateTime.parse(json['date'] as String),
        dayType: DayType.values.byName(json['dayType'] as String),
        people: json['people'] as int,
        paid: (json['paid'] as num).toDouble(),
        zakeIncome: (json['zakeIncome'] as num).toDouble(),
        foodCost: (json['foodCost'] as num).toDouble(),
        plates: json['plates'] as int,
        rounds: json['rounds'] as int,
        goals: (json['goals'] as List).map((e) => e as int).toList(),
        dishCounts: Map<String, dynamic>.from(json['dishCounts'] as Map)
            .map((k, v) => MapEntry(k, v as int)),
        categoryCosts: Map<String, dynamic>.from(json['categoryCosts'] as Map)
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
        diners: (json['diners'] as List)
            .map((e) => DinerResult.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
