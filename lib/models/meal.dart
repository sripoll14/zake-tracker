/// Precio entre semana o de fin de semana y festivos.
enum DayType { weekday, weekend }

/// Tipo de comensal: cada uno paga un menú distinto.
enum DinerType { adult, child, baby }

/// Una persona de la mesa.
class Diner {
  Diner({required this.name, required this.type});

  String name;
  final DinerType type;

  Map<String, dynamic> toJson() => {'name': name, 'type': type.name};

  factory Diner.fromJson(Map<String, dynamic> json) => Diner(
        name: json['name'] as String,
        type: DinerType.values.byName(json['type'] as String),
      );
}

/// Un plato pedido: qué plato, en qué ronda y para quién.
class OrderEntry {
  const OrderEntry({
    required this.dishId,
    required this.round,
    required this.diner,
  });

  final String dishId;

  /// Índice de la ronda (0 = ronda 1).
  final int round;

  /// Índice del comensal en [Meal.diners].
  final int diner;

  Map<String, dynamic> toJson() => {'d': dishId, 'r': round, 'p': diner};

  factory OrderEntry.fromJson(Map<String, dynamic> json) => OrderEntry(
        dishId: json['d'] as String,
        round: json['r'] as int,
        diner: json['p'] as int,
      );
}

/// La comida en curso.
class Meal {
  Meal({
    required this.startedAt,
    required this.dayType,
    required this.diners,
    List<OrderEntry>? entries,
    this.rounds = 1,
    this.currentRound = 0,
    this.currentDiner = 0,
    Set<int>? unlockedGoals,
  })  : entries = entries ?? <OrderEntry>[],
        unlockedGoals = unlockedGoals ?? <int>{};

  final DateTime startedAt;
  final DayType dayType;
  final List<Diner> diners;
  final List<OrderEntry> entries;

  /// Número de rondas abiertas hasta ahora.
  int rounds;

  /// Ronda que se está apuntando ahora mismo.
  int currentRound;

  /// Comensal al que se asignan los platos que se añaden.
  int currentDiner;

  /// Porcentajes de los objetivos ya conseguidos (25, 50, 75...).
  final Set<int> unlockedGoals;

  /// Cuántas veces se puede pedir un plato limitado en toda la comida:
  /// uno por persona que paga menú normal (los bebés no cuentan).
  int get limitPerDish {
    final n = diners.where((d) => d.type != DinerType.baby).length;
    return n < 1 ? 1 : n;
  }

  Map<String, dynamic> toJson() => {
        'startedAt': startedAt.toIso8601String(),
        'dayType': dayType.name,
        'diners': diners.map((d) => d.toJson()).toList(),
        'entries': entries.map((e) => e.toJson()).toList(),
        'rounds': rounds,
        'currentRound': currentRound,
        'currentDiner': currentDiner,
        'goals': unlockedGoals.toList(),
      };

  factory Meal.fromJson(Map<String, dynamic> json) => Meal(
        startedAt: DateTime.parse(json['startedAt'] as String),
        dayType: DayType.values.byName(json['dayType'] as String),
        diners: (json['diners'] as List)
            .map((e) => Diner.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        entries: (json['entries'] as List)
            .map((e) => OrderEntry.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        rounds: json['rounds'] as int,
        currentRound: json['currentRound'] as int,
        currentDiner: json['currentDiner'] as int,
        unlockedGoals: (json['goals'] as List).map((e) => e as int).toSet(),
      );
}
