import '../models/dish.dart';
import '../models/meal.dart';

// ---------------------------------------------------------------------------
// LA CARTA DE ZAKE
//
// Todos los platos de la carta del buffet (versión en PDF de Zake, San Juan
// de Alicante). Los números ("id") son los mismos que en la carta, para que
// sea fácil buscarlos en la mesa.
//
// IMPORTANTE: el campo `cost` es una ESTIMACIÓN de lo que le cuesta a Zake
// la materia prima de cada plato (no el precio de venta). Se ha calculado a
// partir de precios de mayorista aproximados y se ha redondeado un poco a la
// baja a propósito, para que ganarle a Zake sea un reto. En la memoria
// (docs/MEMORIA.md) se explica cómo se ha estimado.
// ---------------------------------------------------------------------------

// Colores de los dibujos.
const int _salmon = 0xFFFF8A5B;
const int _tuna = 0xFFD94F5C;
const int _prawn = 0xFFFFB48A;
const int _whiteFish = 0xFFEDE3D3;
const int _octopus = 0xFFB5656B;
const int _smoked = 0xFFE9733F;
const int _avocado = 0xFF9CC46B;
const int _green = 0xFF5E9E52;
const int _fried = 0xFFE3A64A;
const int _beef = 0xFF8B4A3A;
const int _pork = 0xFFC7724E;
const int _chicken = 0xFFD9A066;
const int _duck = 0xFFA0522D;
const int _crab = 0xFFF28B82;
const int _rice = 0xFFF6EFE7;
const int _soup = 0xFFB86A2E;
const int _miso = 0xFFD9B47A;
const int _noodle = 0xFFE8C26E;
const int _dough = 0xFFF1E4C8;
const int _shell = 0xFFD9C3A5;
const int _water = 0xFF7EC8F0;
const int _soda = 0xFF8A3B2E;
const int _beer = 0xFFE3AE33;
const int _wine = 0xFF7A1F2B;
const int _coffee = 0xFF6B4226;
const int _icecream = 0xFFF2D8C9;

const List<Dish> kMenu = [
  // ---------------------------------------------------------------- Ensaladas
  Dish(id: '1', name: 'Ensalada de gambas', category: DishCategory.ensaladas, art: DishArt.salad, color: _prawn, cost: 0.70),
  Dish(id: '3', name: 'Ensalada de salmón', category: DishCategory.ensaladas, art: DishArt.salad, color: _salmon, cost: 0.80),
  Dish(id: '4', name: 'Ensalada de atún', category: DishCategory.ensaladas, art: DishArt.salad, color: _tuna, cost: 0.80),
  Dish(id: '6', name: 'Wakame', detail: 'Ensalada de algas', category: DishCategory.ensaladas, art: DishArt.salad, color: _green, cost: 0.35),
  Dish(id: '521', name: 'Tartar mango y salmón', category: DishCategory.ensaladas, art: DishArt.plate, color: _salmon, cost: 1.40, limited: true),
  Dish(id: '522', name: 'Tartar Zake mixto', detail: 'Salmón, atún y aguacate', category: DishCategory.ensaladas, art: DishArt.plate, color: _tuna, cost: 1.60, limited: true),

  // -------------------------------------------------------------------- Sopas
  Dish(id: '9', name: 'Sopa de miso', category: DishCategory.sopas, art: DishArt.bowl, color: _miso, cost: 0.25),
  Dish(id: '8', name: 'Sopa agripicante', category: DishCategory.sopas, art: DishArt.bowl, color: _soup, cost: 0.35, spicy: 1),

  // ---------------------------------------------------------------- Entrantes
  Dish(id: '10', name: 'Patatas fritas', category: DishCategory.entrantes, art: DishArt.tempura, color: _noodle, cost: 0.25),
  Dish(id: '7', name: 'Pan chino frito', category: DishCategory.entrantes, art: DishArt.bao, color: _fried, cost: 0.20),
  Dish(id: '11', name: 'Bola de India', category: DishCategory.entrantes, art: DishArt.tempura, color: _salmon, cost: 0.45),
  Dish(id: '13', name: 'Rollito thai', detail: '1 unidad', category: DishCategory.entrantes, art: DishArt.tempura, color: _fried, cost: 0.20),
  Dish(id: '14', name: 'Tempura de verduras', category: DishCategory.entrantes, art: DishArt.tempura, color: _avocado, cost: 0.35),
  Dish(id: '15', name: 'Tempura de langostinos', detail: '4 piezas', category: DishCategory.entrantes, art: DishArt.tempura, color: _prawn, cost: 0.90),
  Dish(id: '16', name: 'Crab rangoon', detail: 'Queso frito · 4 piezas', category: DishCategory.entrantes, art: DishArt.dumpling, color: _fried, cost: 0.40),
  Dish(id: '17', name: 'Gyoza', detail: 'Cerdo y col · 4 piezas', category: DishCategory.entrantes, art: DishArt.dumpling, color: _dough, cost: 0.40),
  Dish(id: '18', name: 'Shu mai', detail: 'Lomo de cerdo · 4 piezas', category: DishCategory.entrantes, art: DishArt.dumpling, color: _noodle, cost: 0.45),
  Dish(id: '19', name: 'Xiao long bao', detail: 'Cerdo y col china · 4 piezas', category: DishCategory.entrantes, art: DishArt.bao, color: _dough, cost: 0.45),
  Dish(id: '20', name: 'Shia jiao', detail: 'Gambas y bambú · 4 piezas', category: DishCategory.entrantes, art: DishArt.dumpling, color: 0xFFF6D7CC, cost: 0.55),
  Dish(id: '5', name: 'Bao conejo de jade', detail: 'Relleno dulce · 2 piezas', category: DishCategory.entrantes, art: DishArt.bao, color: _dough, cost: 0.30),
  Dish(id: '21', name: 'Pincho de Mongolia', detail: '2 pinchos', category: DishCategory.entrantes, art: DishArt.skewer, color: _beef, cost: 0.70, spicy: 1),
  Dish(id: '12', name: 'Costilla BBQ thai', detail: '2 piezas', category: DishCategory.entrantes, art: DishArt.skewer, color: _pork, cost: 0.80),
  Dish(id: '23', name: 'Yaki bao', detail: '1 pieza', category: DishCategory.entrantes, art: DishArt.bao, color: _chicken, cost: 0.55),
  Dish(id: '24', name: 'Bolas de gambas thai', detail: '2 bolas', category: DishCategory.entrantes, art: DishArt.tempura, color: _prawn, cost: 0.50),
  Dish(id: '22', name: 'Takoyaki', detail: 'Bola de pulpo · 2 bolas', category: DishCategory.entrantes, art: DishArt.tempura, color: _fried, cost: 0.40),
  Dish(id: '25', name: 'Bola de mundo', detail: '2 bolas', category: DishCategory.entrantes, art: DishArt.tempura, color: _fried, cost: 0.40),
  Dish(id: '26', name: 'Pato Pekín', detail: '2 rollos', category: DishCategory.entrantes, art: DishArt.temaki, color: _duck, cost: 1.10),

  // ------------------------------------------------------- Nigiri y gunkan (2)
  Dish(id: '27', name: 'Nigiri de salmón', detail: '2 piezas', category: DishCategory.nigiri, art: DishArt.nigiri, color: _salmon, cost: 0.65),
  Dish(id: '28', name: 'Nigiri de atún', detail: '2 piezas', category: DishCategory.nigiri, art: DishArt.nigiri, color: _tuna, cost: 0.80),
  Dish(id: '29', name: 'Nigiri de langostino', detail: '2 piezas', category: DishCategory.nigiri, art: DishArt.nigiri, color: _prawn, cost: 0.55),
  Dish(id: '30', name: 'Nigiri de pez mantequilla', detail: '2 piezas', category: DishCategory.nigiri, art: DishArt.nigiri, color: _whiteFish, cost: 0.45),
  Dish(id: '31', name: 'Ebi fumé', detail: 'Langostino flambeado · 2 piezas', category: DishCategory.nigiri, art: DishArt.nigiri, color: _smoked, cost: 0.60),
  Dish(id: '32', name: 'Salmón fumé', detail: 'Salmón flambeado · 2 piezas', category: DishCategory.nigiri, art: DishArt.nigiri, color: _smoked, cost: 0.70),
  Dish(id: '33', name: 'Nigiri de pulpo', detail: '2 piezas', category: DishCategory.nigiri, art: DishArt.nigiri, color: _octopus, cost: 0.75),
  Dish(id: '534', name: 'Rollo de salmón', detail: '2 piezas', category: DishCategory.nigiri, art: DishArt.gunkan, color: _salmon, cost: 1.00, limited: true),
  Dish(id: '35', name: 'Gunkan calabacín y salmón', detail: '2 piezas', category: DishCategory.nigiri, art: DishArt.gunkan, color: _salmon, cost: 0.50),
  Dish(id: '36', name: 'Gunkan de salmón', detail: '2 piezas', category: DishCategory.nigiri, art: DishArt.gunkan, color: _salmon, cost: 0.70),
  Dish(id: '37', name: 'Gunkan calabacín y surimi', detail: '2 piezas', category: DishCategory.nigiri, art: DishArt.gunkan, color: _crab, cost: 0.35),

  // ---------------------------------------------------------------- Maki (8)
  Dish(id: '38', name: 'Maki de aguacate', detail: '8 piezas', category: DishCategory.maki, art: DishArt.maki, color: _avocado, cost: 0.45),
  Dish(id: '39', name: 'Maki de salmón', detail: '8 piezas', category: DishCategory.maki, art: DishArt.maki, color: _salmon, cost: 0.80),
  Dish(id: '40', name: 'Maki de atún', detail: '8 piezas', category: DishCategory.maki, art: DishArt.maki, color: _tuna, cost: 0.95),
  Dish(id: '41', name: 'Futo maki', detail: 'Salmón, queso y aguacate · 8 piezas', category: DishCategory.maki, art: DishArt.maki, color: _salmon, cost: 1.00),
  Dish(id: '42', name: 'Tempura pez mantequilla', detail: 'Con aguacate y queso · 8 piezas', category: DishCategory.maki, art: DishArt.uramaki, color: _fried, cost: 0.90),

  // ------------------------------------------------------------- Uramaki (8)
  Dish(id: '43', name: 'Ebi tobiko', detail: 'Gamba tempura, aguacate y tobiko', category: DishCategory.uramaki, art: DishArt.uramaki, color: _salmon, cost: 1.10),
  Dish(id: '44', name: 'California fumé', detail: 'Cangrejo, aguacate, pepino y queso', category: DishCategory.uramaki, art: DishArt.uramaki, color: _crab, cost: 1.00),
  Dish(id: '45', name: 'California Zake', detail: 'Cangrejo, aguacate y cebolla crujiente', category: DishCategory.uramaki, art: DishArt.uramaki, color: _fried, cost: 0.95),
  Dish(id: '46', name: 'Ebi salmón fumé', detail: 'Gamba tempura cubierta de salmón', category: DishCategory.uramaki, art: DishArt.uramaki, color: _smoked, cost: 1.40),
  Dish(id: '47', name: 'Futo frito', detail: 'Salmón, queso y aguacate en tempura', category: DishCategory.uramaki, art: DishArt.uramaki, color: _fried, cost: 1.10),
  Dish(id: '48', name: 'Zake frito', detail: 'Gambas y aguacate en tempura', category: DishCategory.uramaki, art: DishArt.uramaki, color: _fried, cost: 1.05),
  Dish(id: '49', name: 'Pato maki', detail: 'Pato, pepino y cebollino', category: DishCategory.uramaki, art: DishArt.uramaki, color: _duck, cost: 1.10),
  Dish(id: '50', name: 'Zake roll', detail: 'Gamba tempura, aguacate, salmón y atún', category: DishCategory.uramaki, art: DishArt.uramaki, color: _tuna, cost: 1.50),

  // -------------------------------------------------------------- Temaki (1)
  Dish(id: '51', name: 'Temaki California', detail: '1 cono', category: DishCategory.temaki, art: DishArt.temaki, color: _crab, cost: 0.50),
  Dish(id: '52', name: 'Temaki de salmón', detail: '1 cono', category: DishCategory.temaki, art: DishArt.temaki, color: _salmon, cost: 0.65),
  Dish(id: '53', name: 'Temaki de atún', detail: '1 cono', category: DishCategory.temaki, art: DishArt.temaki, color: _tuna, cost: 0.75),
  Dish(id: '54', name: 'Temaki ebi', detail: '1 cono', category: DishCategory.temaki, art: DishArt.temaki, color: _prawn, cost: 0.60),

  // ------------------------------------------------------------------ Sashimi
  Dish(id: '523', name: 'Sashimi de salmón', category: DishCategory.sashimi, art: DishArt.sashimi, color: _salmon, cost: 1.80, limited: true),
  Dish(id: '524', name: 'Sashimi mixto', detail: 'Salmón, atún y pez mantequilla', category: DishCategory.sashimi, art: DishArt.sashimi, color: _tuna, cost: 1.90, limited: true),

  // ---------------------------------------------------------- Arroces y pasta
  Dish(id: '100', name: 'Arroz blanco', category: DishCategory.arroces, art: DishArt.bowl, color: _rice, cost: 0.15),
  Dish(id: '61', name: 'Arroz frito chino', category: DishCategory.arroces, art: DishArt.bowl, color: _noodle, cost: 0.40),
  Dish(id: '62', name: 'Khao niaw', detail: 'Arroz frito', category: DishCategory.arroces, art: DishArt.bowl, color: _fried, cost: 0.45),
  Dish(id: '63', name: 'Arroz coreano', category: DishCategory.arroces, art: DishArt.bowl, color: _salmon, cost: 0.90, spicy: 2),
  Dish(id: '64', name: 'Pad thai', detail: 'Tallarines thai', category: DishCategory.arroces, art: DishArt.noodles, color: _fried, cost: 0.80),
  Dish(id: '65', name: 'Chow mein', detail: 'Tallarines chinos', category: DishCategory.arroces, art: DishArt.noodles, color: _noodle, cost: 0.55),
  Dish(id: '66', name: 'Yaki udon', detail: 'Tallarines japoneses', category: DishCategory.arroces, art: DishArt.noodles, color: _dough, cost: 0.70),

  // --------------------------------------------------------------- Teppanyaki
  Dish(id: '70', name: 'Tori teriyaki', detail: 'Pollo', category: DishCategory.teppanyaki, art: DishArt.skewer, color: _chicken, cost: 0.70),
  Dish(id: '71', name: 'Ebi teppanyaki', detail: 'Gambas', category: DishCategory.teppanyaki, art: DishArt.skewer, color: _prawn, cost: 0.85),
  Dish(id: '72', name: 'Atún teppanyaki', category: DishCategory.teppanyaki, art: DishArt.plate, color: _tuna, cost: 1.40),
  Dish(id: '73', name: 'Salmón teppanyaki', category: DishCategory.teppanyaki, art: DishArt.plate, color: _salmon, cost: 1.30),
  Dish(id: '74', name: 'Sepia teppanyaki', category: DishCategory.teppanyaki, art: DishArt.plate, color: _whiteFish, cost: 0.90),
  Dish(id: '75', name: 'Gambón teppanyaki', category: DishCategory.teppanyaki, art: DishArt.shellfish, color: 0xFFE0563A, cost: 1.70),

  // --------------------------------------------------------------- Especiales
  Dish(id: '76', name: 'Verdura al wok', category: DishCategory.especiales, art: DishArt.plate, color: _avocado, cost: 0.40),
  Dish(id: '78', name: 'Pollo frito thai', category: DishCategory.especiales, art: DishArt.plate, color: _fried, cost: 0.65),
  Dish(id: '79', name: 'Pollo al curry', category: DishCategory.especiales, art: DishArt.plate, color: _noodle, cost: 0.60, spicy: 1),
  Dish(id: '80', name: 'Pollo salsa Bangkok', category: DishCategory.especiales, art: DishArt.plate, color: _soup, cost: 0.65, spicy: 1),
  Dish(id: '81', name: 'Pollo salsa de ostras', category: DishCategory.especiales, art: DishArt.plate, color: _chicken, cost: 0.65),
  Dish(id: '82', name: 'Cerdo con mango', category: DishCategory.especiales, art: DishArt.plate, color: _pork, cost: 0.70),
  Dish(id: '83', name: 'Ternera con setas', category: DishCategory.especiales, art: DishArt.plate, color: _beef, cost: 0.95),
  Dish(id: '84', name: 'Sepia salsa Zake', category: DishCategory.especiales, art: DishArt.plate, color: _salmon, cost: 0.85),
  Dish(id: '85', name: 'Gambas especial Zake', category: DishCategory.especiales, art: DishArt.plate, color: _prawn, cost: 0.95, spicy: 1),
  Dish(id: '86', name: 'Ternera a la pimienta negra', category: DishCategory.especiales, art: DishArt.plate, color: _beef, cost: 1.00),
  Dish(id: '87', name: 'Tipan de ternera', detail: 'En plancha caliente', category: DishCategory.especiales, art: DishArt.plate, color: _beef, cost: 1.05),
  Dish(id: '89', name: 'Gambas Sichuan', category: DishCategory.especiales, art: DishArt.plate, color: 0xFFE0563A, cost: 0.95, spicy: 2),
  Dish(id: '92', name: 'Ternera estilo Indonesia', category: DishCategory.especiales, art: DishArt.plate, color: _beef, cost: 1.00, spicy: 3),

  // ---------------------------------------------------------------------- Wok
  Dish(id: '93', name: 'Gambas al ajo thai', category: DishCategory.wok, art: DishArt.shellfish, color: _prawn, cost: 1.00),
  Dish(id: '94', name: 'Pollo Chongqing', category: DishCategory.wok, art: DishArt.plate, color: _chicken, cost: 0.70, spicy: 2),
  Dish(id: '95', name: 'Tipan de pollo', detail: 'En plancha caliente', category: DishCategory.wok, art: DishArt.plate, color: _chicken, cost: 0.75),
  Dish(id: '98', name: 'Almejas estilo Shanghái', category: DishCategory.wok, art: DishArt.shellfish, color: _shell, cost: 1.20),
  Dish(id: '99', name: 'Navajas al vapor', category: DishCategory.wok, art: DishArt.shellfish, color: _shell, cost: 1.50),

  // ------------------------------------------------- Fin de semana (limitados)
  Dish(id: '151', name: 'Maki especial trufa', detail: 'Gamba tempura, salmón y trufa', category: DishCategory.finde, art: DishArt.uramaki, color: _salmon, cost: 1.80, limited: true, weekendOnly: true),
  Dish(id: '152', name: 'Maki futo fumé', detail: 'Salmón, queso y aguacate', category: DishCategory.finde, art: DishArt.uramaki, color: _smoked, cost: 1.50, limited: true, weekendOnly: true),
  Dish(id: '153', name: 'Carpaccio de salmón', detail: 'Con salsa de mango', category: DishCategory.finde, art: DishArt.sashimi, color: _salmon, cost: 1.30, limited: true, weekendOnly: true),
  Dish(id: '154', name: 'Carpaccio mixto', detail: 'Salmón, atún y pez con ponzu', category: DishCategory.finde, art: DishArt.sashimi, color: _tuna, cost: 1.50, limited: true, weekendOnly: true),
  Dish(id: '155', name: 'Sashimi de gamba roja', detail: '1 pieza', category: DishCategory.finde, art: DishArt.shellfish, color: 0xFFE0563A, cost: 1.60, limited: true, weekendOnly: true),
  Dish(id: '156', name: 'Niku teppanyaki', detail: 'Solomillo de ternera', category: DishCategory.finde, art: DishArt.plate, color: _beef, cost: 2.40, limited: true, weekendOnly: true),

  // ------------------------------------- Bebidas y postres (se pagan aparte)
  Dish(id: 'b1', name: 'Agua', category: DishCategory.extras, art: DishArt.drink, color: _water, price: 2.65),
  Dish(id: 'b2', name: 'Refresco', category: DishCategory.extras, art: DishArt.drink, color: _soda, price: 3.25),
  Dish(id: 'b3', name: 'Té frío o isotónica', category: DishCategory.extras, art: DishArt.drink, color: _beer, price: 2.95),
  Dish(id: 'b4', name: 'Zumo', category: DishCategory.extras, art: DishArt.drink, color: 0xFFF29E38, price: 2.65),
  Dish(id: 'b5', name: 'Caña', category: DishCategory.extras, art: DishArt.drink, color: _beer, price: 2.50),
  Dish(id: 'b6', name: 'Caña grande', category: DishCategory.extras, art: DishArt.drink, color: _beer, price: 3.90),
  Dish(id: 'b7', name: 'Cerveza (botellín)', category: DishCategory.extras, art: DishArt.drink, color: _beer, price: 3.15),
  Dish(id: 'b8', name: 'Cerveza japonesa', category: DishCategory.extras, art: DishArt.drink, color: _beer, price: 3.25),
  Dish(id: 'b9', name: 'Jarra de cerveza 1,5 l', category: DishCategory.extras, art: DishArt.drink, color: _beer, price: 9.50),
  Dish(id: 'b10', name: 'Copa de vino', category: DishCategory.extras, art: DishArt.drink, color: _wine, price: 3.25),
  Dish(id: 'b11', name: 'Tinto de verano', category: DishCategory.extras, art: DishArt.drink, color: _wine, price: 3.35),
  Dish(id: 'b12', name: 'Sangría 1 l', category: DishCategory.extras, art: DishArt.drink, color: _wine, price: 8.95),
  Dish(id: 'b13', name: 'Sake (jarra)', category: DishCategory.extras, art: DishArt.drink, color: _rice, price: 5.25),
  Dish(id: 'b14', name: 'Café', category: DishCategory.extras, art: DishArt.drink, color: _coffee, price: 1.75),
  Dish(id: 'b15', name: 'Té japonés', category: DishCategory.extras, art: DishArt.drink, color: _green, price: 2.15),
  Dish(id: 'p1', name: 'Bola de helado', category: DishCategory.extras, art: DishArt.dessert, color: _icecream, price: 1.95),
  Dish(id: 'p2', name: 'Helado de té verde', category: DishCategory.extras, art: DishArt.dessert, color: _avocado, price: 3.25),
  Dish(id: 'p3', name: 'Helado de sésamo', category: DishCategory.extras, art: DishArt.dessert, color: 0xFF5A4A44, price: 3.25),
  Dish(id: 'p4', name: 'Helado flameado', category: DishCategory.extras, art: DishArt.dessert, color: _fried, price: 3.95),
];

/// Acceso rápido a un plato por su número.
final Map<String, Dish> kMenuById = {for (final d in kMenu) d.id: d};

/// Categorías que se pueden pedir según el día.
List<DishCategory> categoriesFor(DayType day) => DishCategory.values
    .where((c) => day == DayType.weekend || c != DishCategory.finde)
    .toList();

/// Platos de una categoría que se pueden pedir según el día.
List<Dish> dishesFor(DishCategory category, DayType day) => kMenu
    .where((d) => d.category == category)
    .where((d) => day == DayType.weekend || !d.weekendOnly)
    .toList();
