import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal.dart';
import '../models/meal_record.dart';

/// Guarda y recupera datos en el propio móvil.
///
/// Usa shared_preferences, que guarda pares clave → texto. Los objetos se
/// convierten a JSON (texto) con sus métodos toJson / fromJson.
class Storage {
  Storage(this._prefs);

  final SharedPreferences _prefs;

  static const _kCurrentMeal = 'current_meal_v1';
  static const _kHistory = 'history_v1';

  static Future<Storage> open() async =>
      Storage(await SharedPreferences.getInstance());

  /// Comida a medias (por si se cierra la app en mitad de la cena).
  Meal? loadCurrentMeal() {
    final raw = _prefs.getString(_kCurrentMeal);
    if (raw == null) return null;
    try {
      return Meal.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      // Si el dato guardado está corrupto, se ignora en vez de romper la app.
      return null;
    }
  }

  Future<void> saveCurrentMeal(Meal? meal) async {
    if (meal == null) {
      await _prefs.remove(_kCurrentMeal);
    } else {
      await _prefs.setString(_kCurrentMeal, jsonEncode(meal.toJson()));
    }
  }

  List<MealRecord> loadHistory() {
    final raw = _prefs.getString(_kHistory);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => MealRecord.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHistory(List<MealRecord> records) async {
    await _prefs.setString(
      _kHistory,
      jsonEncode(records.map((r) => r.toJson()).toList()),
    );
  }
}
