import 'catalog.dart';
import 'garment.dart';

/// Peticion al motor de outfits. Todos los filtros son opcionales: sin
/// ninguno, el motor propone combinaciones generales del armario.
class OutfitRequest {
  const OutfitRequest({
    this.occasion,
    this.mood,
    this.season,
    this.tempC,
    this.mustInclude,
    this.avoidRecentDays = 7,
    this.avoidRepeatDays = 14,
    this.avoidSameWeekdayDays = 28,
    this.count = 10,
    this.seed = 0,
    this.forDay,
  });

  final Occasion? occasion;
  final Mood? mood;
  final Season? season;

  /// Temperatura en grados Celsius. Decide cuanto abrigo pide el outfit.
  final double? tempC;

  /// Prenda que la sugerencia debe contener si o si.
  final Garment? mustInclude;

  /// Penaliza prendas usadas en los ultimos N dias, para no repetir.
  final int avoidRecentDays;

  /// Penaliza repetir el mismo conjunto exacto dentro de este plazo.
  final int avoidRepeatDays;

  /// Penaliza repetir el mismo conjunto en el mismo dia de la semana dentro
  /// de este plazo. Es mas largo que [avoidRepeatDays] a proposito: ponerse
  /// lo mismo dos lunes seguidos canta mucho mas que un lunes y un jueves.
  final int avoidSameWeekdayDays;

  final int count;

  /// Semilla del muestreo. Fija => resultados reproducibles en los tests.
  final int seed;

  /// Para que dia se pide. Null significa hoy.
  ///
  /// Hace falta para planificar la semana: el lunes que viene no se juzga
  /// con el dia de la semana de hoy ni con lo que se llevo ayer.
  final DateTime? forDay;

  /// Los campos opcionales llevan un `clear*` propio porque `null` ya
  /// significa "sin filtro": sin ellos no habria forma de distinguir "no lo
  /// toques" de "quitalo".
  OutfitRequest copyWith({
    Occasion? occasion,
    Mood? mood,
    Season? season,
    double? tempC,
    Garment? mustInclude,
    int? avoidRecentDays,
    int? avoidRepeatDays,
    int? avoidSameWeekdayDays,
    int? count,
    int? seed,
    DateTime? forDay,
    bool clearOccasion = false,
    bool clearMood = false,
    bool clearSeason = false,
    bool clearTemp = false,
    bool clearMustInclude = false,
  }) {
    return OutfitRequest(
      occasion: clearOccasion ? null : (occasion ?? this.occasion),
      mood: clearMood ? null : (mood ?? this.mood),
      season: clearSeason ? null : (season ?? this.season),
      tempC: clearTemp ? null : (tempC ?? this.tempC),
      mustInclude:
          clearMustInclude ? null : (mustInclude ?? this.mustInclude),
      avoidRecentDays: avoidRecentDays ?? this.avoidRecentDays,
      avoidRepeatDays: avoidRepeatDays ?? this.avoidRepeatDays,
      avoidSameWeekdayDays:
          avoidSameWeekdayDays ?? this.avoidSameWeekdayDays,
      count: count ?? this.count,
      seed: seed ?? this.seed,
      forDay: forDay ?? this.forDay,
    );
  }
}

/// Una combinacion propuesta, con su puntuacion y el porque en lenguaje
/// natural. Las razones no son decorativas: obligan a que cada regla sea
/// explicable y hacen trivial depurar el motor.
class OutfitSuggestion {
  const OutfitSuggestion({
    required this.items,
    required this.score,
    required this.reasons,
  });

  final List<Garment> items;
  final double score;
  final List<String> reasons;

  Garment? bySlot(Slot slot) {
    for (final g in items) {
      if (g.slot == slot) return g;
    }
    return null;
  }

  /// Clave estable de la combinacion, para deduplicar sugerencias.
  String get key {
    final ids = items.map((g) => g.id).toList()..sort();
    return ids.join('-');
  }
}

/// Un outfit que el usuario ha guardado explicitamente.
class SavedOutfit {
  const SavedOutfit({
    required this.id,
    required this.items,
    this.name,
    this.occasion,
    this.mood,
    this.notes,
    this.isFavorite = false,
    required this.createdAt,
    this.lastWornAt,
    this.wearCount = 0,
  });

  final int id;
  final List<Garment> items;
  final String? name;
  final Occasion? occasion;
  final Mood? mood;
  final String? notes;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? lastWornAt;
  final int wearCount;

  String get displayName => name ?? occasion?.name ?? 'Outfit';
}
