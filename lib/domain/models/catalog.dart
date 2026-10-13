/// Catálogos editables por el usuario.
///
/// Categoría, ocasión y mood eran enums de Dart. Dejaron de serlo porque el
/// vocabulario de un armario es personal y regional: lo que en España es una
/// "sudadera" en Colombia es un "buzo", y nadie debería tener que esperar a
/// una actualización de la app para llamar a sus prendas como las llama.
///
/// Lo que NO es editable es [Slot]: es estructural. El motor de outfits
/// compone por ranuras, así que una categoría nueva tiene que declarar
/// obligatoriamente si va arriba, abajo, es un vestido, un abrigo, un
/// calzado o un accesorio.
library;

/// Ranura que ocupa una prenda en un outfit.
///
/// Cerrado a propósito: las plantillas de composición del motor están
/// escritas en términos de estas seis ranuras.
enum Slot { top, bottom, dress, outer, shoes, accessory }

enum Season { spring, summer, autumn, winter }

/// Familia cromática derivada del tono. Se persiste calculada para poder
/// filtrar el armario por color desde SQL.
enum ColorFamily {
  red,
  orange,
  yellow,
  green,
  cyan,
  blue,
  purple,
  pink,
  brown,
  neutral,
}

/// Temperatura del color. Los neutros no son ni cálidos ni fríos y por eso
/// nunca penalizan una combinación.
enum Warmth { warm, cool, neutral }

/// Tipo de prenda: "Camiseta", "Tenis", "Ruana". Editable.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.slot,
    this.formality = 2,
    this.warmth = 1,
    this.isBuiltIn = false,
    this.sortOrder = 0,
  });

  final int id;
  final String name;

  /// Obligatorio y no opcional: sin ranura, el motor no puede componer con
  /// esta categoría.
  final Slot slot;

  /// 0 = deportivo o de estar en casa, 4 = formal de evento. Se compara con
  /// la formalidad que pide la ocasión.
  final int formality;

  /// 0 = ropa de verano, 4 = abrigo de invierno. Alimenta el ajuste por
  /// temperatura.
  final int warmth;

  /// Las categorías semilla se marcan para poder avisar antes de borrarlas,
  /// no para impedirlo: el usuario manda sobre su propio armario.
  final bool isBuiltIn;

  final int sortOrder;

  Category copyWith({
    String? name,
    Slot? slot,
    int? formality,
    int? warmth,
    int? sortOrder,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      slot: slot ?? this.slot,
      formality: formality ?? this.formality,
      warmth: warmth ?? this.warmth,
      isBuiltIn: isBuiltIn,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) => other is Category && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category($id, $name, ${slot.name})';
}

/// Situación para la que sirve una prenda: "Trabajo", "Fiesta", "Universidad".
class Occasion {
  const Occasion({
    required this.id,
    required this.name,
    this.formality = 2,
    this.isBuiltIn = false,
    this.sortOrder = 0,
  });

  final int id;
  final String name;
  final int formality;
  final bool isBuiltIn;
  final int sortOrder;

  Occasion copyWith({String? name, int? formality, int? sortOrder}) => Occasion(
        id: id,
        name: name ?? this.name,
        formality: formality ?? this.formality,
        isBuiltIn: isBuiltIn,
        sortOrder: sortOrder ?? this.sortOrder,
      );

  @override
  bool operator ==(Object other) => other is Occasion && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Occasion($id, $name)';
}

/// Rollo o actitud de una prenda: "Elegante", "Relajado", "Rockero".
class Mood {
  const Mood({
    required this.id,
    required this.name,
    this.isBuiltIn = false,
    this.sortOrder = 0,
  });

  final int id;
  final String name;
  final bool isBuiltIn;
  final int sortOrder;

  Mood copyWith({String? name, int? sortOrder}) => Mood(
        id: id,
        name: name ?? this.name,
        isBuiltIn: isBuiltIn,
        sortOrder: sortOrder ?? this.sortOrder,
      );

  @override
  bool operator ==(Object other) => other is Mood && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Mood($id, $name)';
}

/// Grupo de lavado: con qué otras prendas va esta a la lavadora.
///
/// Es un catálogo editable como los demás porque cada quien separa la ropa a
/// su manera. Lo que NO es editable es la idea: una prenda pertenece a un
/// grupo y solo a uno, porque en la vida real acaba en una carga concreta.
class WashGroup {
  const WashGroup({
    required this.id,
    required this.name,
    this.isBuiltIn = false,
    this.sortOrder = 0,
  });

  final int id;
  final String name;
  final bool isBuiltIn;
  final int sortOrder;

  WashGroup copyWith({String? name, int? sortOrder}) => WashGroup(
        id: id,
        name: name ?? this.name,
        isBuiltIn: isBuiltIn,
        sortOrder: sortOrder ?? this.sortOrder,
      );

  @override
  bool operator ==(Object other) => other is WashGroup && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WashGroup($id, $name)';
}

/// Tag libre, sin más semántica que la que le dé el usuario.
class Tag {
  const Tag({required this.id, required this.name});

  final int id;
  final String name;

  @override
  bool operator ==(Object other) => other is Tag && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// Semillas del primer arranque.
///
/// Vocabulario en español neutro de Latinoamérica y sin ambigüedades
/// regionales donde se puede: "Zapatos" para el calzado genérico y "Tenis"
/// para el deportivo, en vez de "zapatillas". Todo esto es renombrable desde
/// la app, así que son un punto de partida, no una decisión cerrada.
class CatalogSeed {
  const CatalogSeed._();

  /// (nombre, slot, formalidad, abrigo)
  static const categories = <(String, Slot, int, int)>[
    // Arriba
    ('Camiseta', Slot.top, 1, 1),
    ('Camisa', Slot.top, 3, 1),
    ('Blusa', Slot.top, 3, 1),
    ('Suéter', Slot.top, 2, 3),
    ('Buzo', Slot.top, 1, 3),
    ('Top', Slot.top, 1, 0),
    // Abajo
    ('Jean', Slot.bottom, 2, 2),
    ('Pantalón', Slot.bottom, 3, 2),
    ('Short', Slot.bottom, 1, 0),
    ('Falda', Slot.bottom, 3, 1),
    ('Pantalón deportivo', Slot.bottom, 1, 2),
    // Vestido
    ('Vestido', Slot.dress, 4, 1),
    ('Enterizo', Slot.dress, 3, 1),
    // Abrigo
    ('Chaqueta', Slot.outer, 3, 3),
    ('Abrigo', Slot.outer, 4, 4),
    ('Blazer', Slot.outer, 4, 2),
    ('Cárdigan', Slot.outer, 2, 2),
    // Zapatos
    ('Zapatos', Slot.shoes, 3, 1),
    ('Tenis', Slot.shoes, 1, 1),
    ('Botas', Slot.shoes, 3, 3),
    ('Tacones', Slot.shoes, 4, 1),
    ('Baletas', Slot.shoes, 3, 1),
    ('Sandalias', Slot.shoes, 1, 0),
    // Accesorio
    ('Bolso', Slot.accessory, 2, 0),
    ('Gorra', Slot.accessory, 2, 1),
    ('Bufanda', Slot.accessory, 2, 2),
    ('Cinturón', Slot.accessory, 2, 0),
    ('Accesorio', Slot.accessory, 2, 0),
  ];

  /// (nombre, formalidad)
  static const occasions = <(String, int)>[
    ('Casual', 1),
    ('Trabajo', 3),
    ('Formal', 4),
    ('Fiesta', 3),
    ('Deporte', 0),
    ('Casa', 0),
    ('Cita', 3),
    ('Viaje', 1),
  ];

  /// Grupos de lavado. Son los que el usuario separa de verdad al lavar, no
  /// una taxonomía de etiqueta de cuidado.
  static const washGroups = <String>[
    'Oscuros',
    'Normal',
    'Ropa pesada',
    'Delicados',
  ];

  static const moods = <String>[
    'Relajado',
    'Atrevido',
    'Elegante',
    'Divertido',
    'Minimalista',
    'Cómodo',
    'Rockero',
    'Romántico',
  ];

  /// Nombre de la categoría a la que van a parar las prendas cuya categoría
  /// se borra. Se crea sola si hace falta: una prenda nunca puede quedarse
  /// sin categoría, porque sin ranura desaparecería del motor de outfits.
  static const fallbackCategory = 'Sin clasificar';
}
