import '../domain/models/catalog.dart';

/// Nombres legibles de los enums que siguen siendo cerrados.
///
/// Categoría, ocasión y mood ya NO están aquí: sus nombres los escribe el
/// usuario y viven en la base. Solo quedan los tres enums estructurales.
class Labels {
  const Labels._();

  static const _slot = {
    Slot.top: 'Arriba',
    Slot.bottom: 'Abajo',
    Slot.dress: 'Vestido',
    Slot.outer: 'Abrigo',
    Slot.shoes: 'Zapatos',
    Slot.accessory: 'Accesorio',
  };

  /// Descripción de qué entra en cada ranura. Se enseña al crear una
  /// categoría, que es el momento en que el usuario tiene que elegir una y
  /// puede no tener claro qué significa.
  static const _slotHint = {
    Slot.top: 'Camisetas, camisas, suéteres...',
    Slot.bottom: 'Jeans, pantalones, faldas...',
    Slot.dress: 'Vestidos y enterizos, sustituyen a arriba y abajo',
    Slot.outer: 'Chaquetas, abrigos, blazers, se ponen encima',
    Slot.shoes: 'Todo el calzado',
    Slot.accessory: 'Bolsos, gorras, cinturones, joyas...',
  };

  static const _season = {
    Season.spring: 'Primavera',
    Season.summer: 'Verano',
    Season.autumn: 'Otoño',
    Season.winter: 'Invierno',
  };

  static const _colorFamily = {
    ColorFamily.red: 'Rojo',
    ColorFamily.orange: 'Naranja',
    ColorFamily.yellow: 'Amarillo',
    ColorFamily.green: 'Verde',
    ColorFamily.cyan: 'Cian',
    ColorFamily.blue: 'Azul',
    ColorFamily.purple: 'Morado',
    ColorFamily.pink: 'Rosado',
    ColorFamily.brown: 'Café',
    ColorFamily.neutral: 'Neutro',
  };

  /// Caen al `name` del enum si falta la traducción: un valor nuevo saldría
  /// en inglés, pero nunca revienta la pantalla.
  static String slot(Slot v) => _slot[v] ?? v.name;
  static String slotHint(Slot v) => _slotHint[v] ?? '';
  static String season(Season v) => _season[v] ?? v.name;
  static String colorFamily(ColorFamily v) => _colorFamily[v] ?? v.name;

  /// Como se nombra un color al buscar, que no siempre es como lo llama la
  /// app: nadie busca "neutro", busca "negro" o "beige".
  static const _colorWords = {
    ColorFamily.red: ['rojo', 'roja', 'vino', 'granate'],
    ColorFamily.orange: ['naranja', 'mostaza', 'coral'],
    ColorFamily.yellow: ['amarillo', 'amarilla'],
    ColorFamily.green: ['verde', 'oliva', 'militar'],
    ColorFamily.cyan: ['cian', 'turquesa', 'aguamarina'],
    ColorFamily.blue: ['azul', 'celeste', 'marino', 'jean', 'denim'],
    ColorFamily.purple: ['morado', 'morada', 'lila', 'violeta'],
    ColorFamily.pink: ['rosado', 'rosada', 'rosa', 'fucsia'],
    ColorFamily.brown: ['cafe', 'marron', 'camel', 'chocolate'],
    ColorFamily.neutral: [
      'neutro', 'negro', 'negra', 'blanco', 'blanca', 'gris', 'beige',
      'crema', 'hueso',
    ],
  };

  /// Familias de color a las que puede referirse un texto de busqueda.
  ///
  /// Basta con que el texto empiece una palabra de la lista ("ros" encuentra
  /// rosado) para que los resultados aparezcan mientras se escribe.
  static Set<ColorFamily> colorFamiliesMatching(String text) {
    final q = fold(text.trim());
    if (q.length < 3) return const {};
    return {
      for (final e in _colorWords.entries)
        if (e.value.any((w) => w.startsWith(q))) e.key,
    };
  }

  /// Minusculas y sin tildes, para comparar como compara una persona.
  static String fold(String s) {
    const from = 'áéíóúüñ';
    const to = 'aeiouun';
    final lower = s.toLowerCase();
    final out = StringBuffer();
    for (final ch in lower.split('')) {
      final i = from.indexOf(ch);
      out.write(i < 0 ? ch : to[i]);
    }
    return out.toString();
  }

  /// Escala de formalidad, compartida por categorías y ocasiones.
  static const formality = [
    'Deportivo',
    'Casual',
    'Diario',
    'Arreglado',
    'Formal',
  ];

  /// Escala de abrigo.
  static const warmth = [
    'Muy fresco',
    'Fresco',
    'Templado',
    'Abrigado',
    'Muy abrigado',
  ];

  static String scale(List<String> table, int value) =>
      table[value.clamp(0, table.length - 1)];
}
