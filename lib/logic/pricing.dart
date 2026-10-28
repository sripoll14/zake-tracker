import '../models/meal.dart';

/// Precios del buffet y reglas económicas.
///
/// Si Zake cambia los precios, solo hay que tocar este archivo.
class Pricing {
  Pricing._();

  /// IVA de restauración en España (los precios de la carta lo incluyen).
  static const double iva = 0.10;

  /// Parte del precio (sin IVA) de una bebida o postre que es beneficio
  /// para el restaurante. Las bebidas tienen mucho margen: una caña o un
  /// refresco le cuestan a un bar entre un 20 % y un 35 % de lo que cobra.
  static const double extrasMargin = 0.70;

  static const double _weekdayAdult = 18.95;
  static const double _weekdayChild = 10.95;
  static const double _weekendAdult = 22.95;
  static const double _weekendChild = 12.95;

  /// Menú infantil para menores de 3 años (igual todos los días).
  static const double _baby = 4.95;

  /// Precio del menú (con IVA) de un comensal.
  static double menuPrice(DayType day, DinerType type) {
    return switch (type) {
      DinerType.adult => day == DayType.weekend ? _weekendAdult : _weekdayAdult,
      DinerType.child => day == DayType.weekend ? _weekendChild : _weekdayChild,
      DinerType.baby => _baby,
    };
  }

  /// Quita el IVA de un precio.
  static double withoutIva(double price) => price / (1 + iva);

  /// Lo que gana Zake con una bebida o postre de este precio.
  static double extraProfit(double price) => withoutIva(price) * extrasMargin;

  /// Sugiere el tipo de día según la carta:
  /// fin de semana = cena del viernes, sábado y domingo.
  /// (Los festivos se eligen a mano en la pantalla de inicio.)
  static DayType suggestDayType(DateTime now) {
    if (now.weekday == DateTime.saturday || now.weekday == DateTime.sunday) {
      return DayType.weekend;
    }
    if (now.weekday == DateTime.friday && now.hour >= 18) {
      return DayType.weekend;
    }
    return DayType.weekday;
  }
}
