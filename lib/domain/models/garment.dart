import '../color/color_theory.dart';
import 'catalog.dart';

/// Una prenda del armario, ya recortada y etiquetada.
///
/// Modelo de dominio inmutable, sin dependencias de drift ni de Flutter: el
/// motor de outfits solo conoce esta clase.
class Garment {
  Garment({
    required this.id,
    required this.imagePath,
    required this.thumbPath,
    this.originalPath,
    required this.category,
    required this.dominantColorArgb,
    this.palette = const [],
    this.name,
    this.brand,
    this.notes,
    this.seasons = const {},
    this.occasions = const {},
    this.moods = const {},
    this.tags = const {},
    this.washGroup,
    this.isFavorite = false,
    this.isArchived = false,
    this.wearCount = 0,
    this.lastWornAt,
    this.washCount = 0,
    this.lastWashedAt,
    this.wearsSinceWash = 0,
    required this.createdAt,
  }) : color = Hsl.fromArgb(dominantColorArgb);

  final int id;

  /// Rutas RELATIVAS al directorio de documentos de la app. En Android la
  /// ruta absoluta del sandbox cambia entre reinstalaciones y
  /// actualizaciones, así que guardar la absoluta rompería las imágenes.
  final String imagePath;
  final String thumbPath;

  /// Foto sin recortar. Se guarda para poder rehacer el recorte, y hay que
  /// acordarse de borrarla con la prenda: pesa mas que el recorte y la
  /// miniatura juntos.
  final String? originalPath;

  final Category category;
  final int dominantColorArgb;

  /// Se calcula una vez en el constructor y no en un getter: el motor
  /// evalúa hasta 4 000 combinaciones y accede al color de cada prenda en
  /// cada par, así que derivarlo al vuelo son cientos de miles de
  /// conversiones RGB→HSL por generación.
  final Hsl color;

  final List<int> palette;

  final String? name;
  final String? brand;
  final String? notes;

  final Set<Season> seasons;
  final Set<Occasion> occasions;
  final Set<Mood> moods;
  final Set<String> tags;

  /// Con qué carga va a la lavadora. Null mientras no se haya clasificado.
  final WashGroup? washGroup;

  final bool isFavorite;
  final bool isArchived;
  final int wearCount;
  final DateTime? lastWornAt;

  /// Cuántas veces se ha lavado. Es la métrica de desgaste real: una prenda
  /// no se estropea por el tiempo que lleva colgada sino por las lavadas.
  final int washCount;

  final DateTime? lastWashedAt;

  /// Usos acumulados desde la última lavada. Se pone a cero al lavar.
  final int wearsSinceWash;

  final DateTime createdAt;

  /// Si la prenda se ha usado después de su última lavada, está sucia.
  ///
  /// Es la señal que hace útil el registro de lavado: contesta sola la
  /// pregunta de "¿esto entra en esta carga?" sin tener que recordar nada.
  ///
  /// Los accesorios nunca se marcan solos: un cinturon o unas gafas no van
  /// al cesto por haberse puesto. Se pueden seguir lavando a mano desde la
  /// lista de lavado, y esa lavada se registra igual.
  bool get needsWashing {
    if (slot == Slot.accessory) return false;
    final worn = lastWornAt;
    if (worn == null) return false;
    final washed = lastWashedAt;
    return washed == null || worn.isAfter(washed);
  }

  /// Sin ponerse desde hace [forgottenAfter], o nunca puesta y en el armario
  /// desde hace [neverWornGrace].
  ///
  /// Una prenda recien comprada no esta olvidada solo porque aun no ha
  /// salido: por eso las nunca usadas tienen su propio margen, mas corto.
  bool isForgotten(DateTime now) {
    if (isArchived) return false;
    final worn = lastWornAt;
    if (worn != null) return now.difference(worn) >= forgottenAfter;
    return now.difference(createdAt) >= neverWornGrace;
  }

  static const forgottenAfter = Duration(days: 60);
  static const neverWornGrace = Duration(days: 30);

  /// Usos por lavada, o null si nunca se ha lavado. Cuanto más alto, menos
  /// desgaste por uso.
  double? get wearsPerWash => washCount == 0 ? null : wearCount / washCount;

  Slot get slot => category.slot;
  ColorFamily get colorFamily => color.family;
  bool get isNeutral => color.isNeutral;

  String get displayName =>
      name?.trim().isNotEmpty == true ? name!.trim() : category.name;

  Garment copyWith({
    String? imagePath,
    String? thumbPath,
    String? originalPath,
    Category? category,
    int? dominantColorArgb,
    List<int>? palette,
    String? name,
    String? brand,
    String? notes,
    Set<Season>? seasons,
    Set<Occasion>? occasions,
    Set<Mood>? moods,
    Set<String>? tags,
    WashGroup? washGroup,
    bool? isFavorite,
    bool? isArchived,
    int? wearCount,
    DateTime? lastWornAt,
    int? washCount,
    DateTime? lastWashedAt,
    int? wearsSinceWash,
  }) {
    return Garment(
      id: id,
      imagePath: imagePath ?? this.imagePath,
      thumbPath: thumbPath ?? this.thumbPath,
      originalPath: originalPath ?? this.originalPath,
      category: category ?? this.category,
      dominantColorArgb: dominantColorArgb ?? this.dominantColorArgb,
      palette: palette ?? this.palette,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      notes: notes ?? this.notes,
      seasons: seasons ?? this.seasons,
      occasions: occasions ?? this.occasions,
      moods: moods ?? this.moods,
      tags: tags ?? this.tags,
      washGroup: washGroup ?? this.washGroup,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      wearCount: wearCount ?? this.wearCount,
      lastWornAt: lastWornAt ?? this.lastWornAt,
      washCount: washCount ?? this.washCount,
      lastWashedAt: lastWashedAt ?? this.lastWashedAt,
      wearsSinceWash: wearsSinceWash ?? this.wearsSinceWash,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) => other is Garment && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
