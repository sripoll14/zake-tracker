/// Categorías de la carta, en el mismo orden en que aparecen en el menú de Zake.
enum DishCategory {
  ensaladas('Ensaladas'),
  sopas('Sopas'),
  entrantes('Entrantes'),
  nigiri('Nigiri y gunkan'),
  maki('Maki'),
  uramaki('Uramaki'),
  temaki('Temaki'),
  sashimi('Sashimi'),
  arroces('Arroces y pasta'),
  teppanyaki('Teppanyaki'),
  especiales('Especiales'),
  wok('Wok'),
  finde('Fin de semana'),
  extras('Bebidas y postres');

  const DishCategory(this.label);

  /// Nombre que se muestra en pantalla.
  final String label;
}

/// Tipo de dibujo con el que se representa cada plato.
enum DishArt {
  nigiri,
  gunkan,
  maki,
  uramaki,
  temaki,
  sashimi,
  bowl,
  noodles,
  dumpling,
  bao,
  skewer,
  tempura,
  salad,
  plate,
  shellfish,
  drink,
  dessert,
}

/// Un plato (o bebida/postre) de la carta.
class Dish {
  const Dish({
    required this.id,
    required this.name,
    required this.category,
    required this.art,
    this.detail = '',
    this.cost = 0,
    this.price = 0,
    this.limited = false,
    this.weekendOnly = false,
    this.spicy = 0,
    this.color = 0xFFFF8A5B,
  });

  /// Número del plato en la carta (p. ej. "27").
  final String id;
  final String name;
  final DishCategory category;
  final DishArt art;

  /// Texto corto: piezas o ingredientes.
  final String detail;

  /// Coste estimado de ingredientes para el restaurante, en euros.
  /// Solo se usa en la comida (no en bebidas y postres).
  final double cost;

  /// Precio de venta con IVA. Solo se usa en bebidas y postres,
  /// que se pagan aparte del menú.
  final double price;

  /// "Plato limitado, no puede repetir": uno por persona en toda la comida.
  final bool limited;

  /// Solo se puede pedir en fin de semana.
  final bool weekendOnly;

  /// Nivel de picante de 0 a 3 (las guindillas de la carta).
  final int spicy;

  /// Color principal del dibujo (formato 0xAARRGGBB).
  final int color;

  /// Bebidas y postres: no se comen dentro del menú, se pagan aparte.
  bool get isExtra => category == DishCategory.extras;
}
