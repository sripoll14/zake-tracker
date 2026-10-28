import '../models/dish.dart';

// Búsqueda de platos por texto.

/// Pasa a minúsculas y quita tildes, para que "salmon" encuentre "Salmón".
String normalize(String text) {
  const from = 'áàäâéèëêíìïîóòöôúùüûñç';
  const to = 'aaaaeeeeiiiioooouuuunc';
  final lower = text.toLowerCase();
  final out = StringBuffer();
  for (final ch in lower.split('')) {
    final i = from.indexOf(ch);
    out.write(i >= 0 ? to[i] : ch);
  }
  return out.toString();
}

/// ¿El plato coincide con lo escrito? Busca en el nombre, la descripción,
/// la categoría y el número de la carta. Si se escriben varias palabras,
/// tienen que aparecer todas ("maki salmon").
bool matchesQuery(Dish dish, String query) {
  final words = normalize(query).split(' ').where((w) => w.isNotEmpty);
  if (words.isEmpty) return true;
  final haystack = normalize(
    '${dish.name} ${dish.detail} ${dish.category.label} ${dish.id}',
  );
  return words.every(haystack.contains);
}
