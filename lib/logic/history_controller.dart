import 'package:flutter/foundation.dart';

import '../models/meal_record.dart';
import 'storage.dart';

/// Historial de comidas terminadas y sus estadísticas.
class HistoryController extends ChangeNotifier {
  HistoryController(this._storage) : _records = _storage.loadHistory();

  final Storage _storage;
  final List<MealRecord> _records;

  /// De la más reciente a la más antigua.
  List<MealRecord> get records => List.unmodifiable(_records);

  bool get isEmpty => _records.isEmpty;
  MealRecord? get last => _records.isEmpty ? null : _records.first;

  Future<void> add(MealRecord record) async {
    _records.insert(0, record);
    notifyListeners();
    await _storage.saveHistory(_records);
  }

  Future<void> removeAt(int index) async {
    _records.removeAt(index);
    notifyListeners();
    await _storage.saveHistory(_records);
  }

  int get wins => _records.where((r) => r.zakeLoses).length;

  /// Victorias seguidas contando desde la última comida.
  int get currentStreak {
    var n = 0;
    for (final r in _records) {
      if (!r.zakeLoses) break;
      n++;
    }
    return n;
  }

  int get bestStreak {
    var best = 0, now = 0;
    for (final r in _records.reversed) {
      now = r.zakeLoses ? now + 1 : 0;
      if (now > best) best = now;
    }
    return best;
  }

  /// La comida en la que más perdió Zake.
  MealRecord? get best {
    if (_records.isEmpty) return null;
    return _records.reduce((a, b) => a.balance >= b.balance ? a : b);
  }

  /// Plato más pedido en todas las comidas (id del plato).
  String? get favouriteDishId {
    final total = <String, int>{};
    for (final r in _records) {
      r.dishCounts.forEach((k, v) => total[k] = (total[k] ?? 0) + v);
    }
    if (total.isEmpty) return null;
    return total.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// Platos "muy pedidos" según el historial: los [top] más pedidos en todas
  /// las comidas guardadas, siempre que se hayan pedido al menos [minTotal]
  /// veces en total.
  Set<String> popularDishIds({int top = 8, int minTotal = 3}) {
    final total = <String, int>{};
    for (final r in _records) {
      r.dishCounts.forEach((k, v) => total[k] = (total[k] ?? 0) + v);
    }
    final ranked = total.entries.where((e) => e.value >= minTotal).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ranked.take(top).map((e) => e.key).toSet();
  }
}
