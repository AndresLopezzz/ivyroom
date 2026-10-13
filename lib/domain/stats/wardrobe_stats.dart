import '../models/catalog.dart';
import '../models/garment.dart';

/// Una prenda con su métrica de uso, ya lista para pintar.
class GarmentUsage {
  const GarmentUsage({
    required this.garment,
    required this.daysSinceWorn,
  });

  final Garment garment;

  /// Días desde la última vez, o null si nunca se ha puesto.
  final int? daysSinceWorn;

  bool get neverWorn => garment.wearCount == 0;
}

/// Una prenda con su métrica de desgaste.
class GarmentWear {
  const GarmentWear({required this.garment, required this.daysSinceWashed});

  final Garment garment;
  final int? daysSinceWashed;

  int get washCount => garment.washCount;
  double? get wearsPerWash => garment.wearsPerWash;
}

/// Reparto de algo por categorías: sirve igual para colores que para tipos.
class Breakdown {
  const Breakdown(this.label, this.count, {this.colorArgb});

  final String label;
  final int count;

  /// Color representativo, cuando lo hay (reparto por familia cromática).
  final int? colorArgb;
}

/// Retrato del armario a partir de lo que ya se guarda.
///
/// Es Dart puro y sin I/O: recibe la lista de prendas y devuelve números.
/// Toda la información sale de `wearCount` y `lastWornAt`, que se llevan
/// registrando desde el principio; aquí solo se leen.
class WardrobeStats {
  WardrobeStats(List<Garment> wardrobe, {DateTime? today})
      : _today = _midnight(today ?? DateTime.now()),
        _garments = wardrobe.where((g) => !g.isArchived).toList();

  final List<Garment> _garments;
  final DateTime _today;

  static DateTime _midnight(DateTime d) => DateTime(d.year, d.month, d.day);

  int get total => _garments.length;

  int get totalWears =>
      _garments.fold(0, (sum, g) => sum + g.wearCount);

  /// Cuántas prendas no se han puesto ni una vez.
  int get neverWornCount =>
      _garments.where((g) => g.wearCount == 0).length;

  /// Proporción del armario que sí se usa, de 0 a 1.
  ///
  /// Es el número que de verdad importa: un armario grande del que solo se
  /// usa un tercio es un problema, y sin esto no se ve.
  double get usedRatio {
    if (_garments.isEmpty) return 0;
    return (total - neverWornCount) / total;
  }

  /// Usos por prenda de media, contando solo las que se han puesto alguna
  /// vez. Incluir las que nunca se han usado aplastaría la media y diría
  /// menos que `usedRatio`, que ya cubre ese ángulo.
  double get averageWearsPerUsedGarment {
    final used = _garments.where((g) => g.wearCount > 0).toList();
    if (used.isEmpty) return 0;
    return used.fold(0, (sum, g) => sum + g.wearCount) / used.length;
  }

  int? _daysSince(Garment g) {
    final worn = g.lastWornAt;
    if (worn == null) return null;
    return _today.difference(_midnight(worn)).inDays;
  }

  /// Lo que más se pone, de mayor a menor.
  List<GarmentUsage> mostWorn({int limit = 10}) {
    final used = _garments.where((g) => g.wearCount > 0).toList()
      ..sort((a, b) => b.wearCount.compareTo(a.wearCount));
    return [
      for (final g in used.take(limit))
        GarmentUsage(garment: g, daysSinceWorn: _daysSince(g)),
    ];
  }

  /// Prendas olvidadas: las que nunca se han puesto y, tras ellas, las que
  /// llevan más tiempo sin usarse.
  ///
  /// El orden importa: lo que nunca se ha estrenado va primero porque es
  /// donde está la decisión interesante (¿por qué la compré?), no en la
  /// camiseta que no me pongo desde hace tres semanas.
  List<GarmentUsage> forgotten({int limit = 10, int staleDays = 60}) {
    final never = _garments.where((g) => g.wearCount == 0).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final stale = _garments
        .where((g) =>
            g.wearCount > 0 && (_daysSince(g) ?? 0) >= staleDays)
        .toList()
      ..sort((a, b) => (_daysSince(b) ?? 0).compareTo(_daysSince(a) ?? 0));

    return [
      for (final g in [...never, ...stale].take(limit))
        GarmentUsage(garment: g, daysSinceWorn: _daysSince(g)),
    ];
  }

  /// Cuántas prendas hay de cada tipo, de más a menos.
  List<Breakdown> byCategory() {
    final counts = <String, int>{};
    for (final g in _garments) {
      counts.update(g.category.name, (v) => v + 1, ifAbsent: () => 1);
    }
    return _sorted(counts);
  }

  /// Cuántas prendas hay de cada ranura, en el orden natural del enum.
  List<Breakdown> bySlot(String Function(Slot) label) {
    final counts = <Slot, int>{};
    for (final g in _garments) {
      counts.update(g.slot, (v) => v + 1, ifAbsent: () => 1);
    }
    return [
      for (final slot in Slot.values)
        if (counts[slot] != null) Breakdown(label(slot), counts[slot]!),
    ];
  }

  /// Reparto por familia cromática, con un color representativo de cada una
  /// tomado de una prenda real del armario.
  List<Breakdown> byColor(String Function(ColorFamily) label) {
    final counts = <ColorFamily, int>{};
    final sample = <ColorFamily, int>{};
    for (final g in _garments) {
      final family = g.colorFamily;
      counts.update(family, (v) => v + 1, ifAbsent: () => 1);
      sample.putIfAbsent(family, () => g.dominantColorArgb);
    }

    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final e in entries)
        Breakdown(label(e.key), e.value, colorArgb: sample[e.key]),
    ];
  }

  // ---- lavado ------------------------------------------------------------

  /// Prendas usadas después de su última lavada.
  int get dirtyCount => _garments.where((g) => g.needsWashing).length;

  /// Lavadas registradas en total.
  int get totalWashes => _garments.fold(0, (sum, g) => sum + g.washCount);

  /// Lo más lavado del armario, de más a menos.
  ///
  /// Es la respuesta a "¿cuánto me va a durar esto?": una prenda no se
  /// estropea por el tiempo que lleva colgada sino por las vueltas que da en
  /// la lavadora, así que este es el contador que predice el desgaste.
  List<GarmentWear> mostWashed({int limit = 10}) {
    final washed = _garments.where((g) => g.washCount > 0).toList()
      ..sort((a, b) => b.washCount.compareTo(a.washCount));
    return [for (final g in washed.take(limit)) _wearOf(g)];
  }

  /// Prendas que rinden menos: pocas puestas por cada lavada.
  ///
  /// Un número bajo significa que la prenda va a la lavadora casi cada vez
  /// que se usa, así que se gasta el doble de rápido que otra que aguanta
  /// varias puestas.
  List<GarmentWear> hardestOnClothes({int limit = 10, int minWashes = 2}) {
    final rated = _garments
        .where((g) => g.washCount >= minWashes && g.wearsPerWash != null)
        .toList()
      ..sort((a, b) => a.wearsPerWash!.compareTo(b.wearsPerWash!));
    return [for (final g in rated.take(limit)) _wearOf(g)];
  }

  /// Prendas usadas pero que nunca se han registrado como lavadas.
  ///
  /// No implica que estén sucias de verdad: casi siempre significa que el
  /// registro de lavado va con retraso, y por eso se enseña aparte en vez de
  /// mezclarlo con el desgaste real.
  int get neverWashedButWorn =>
      _garments.where((g) => g.wearCount > 0 && g.washCount == 0).length;

  /// Cuántas prendas hay en cada grupo de lavado.
  List<Breakdown> byWashGroup() {
    final counts = <String, int>{};
    for (final g in _garments) {
      counts.update(g.washGroup?.name ?? 'Sin clasificar', (v) => v + 1,
          ifAbsent: () => 1);
    }
    return _sorted(counts);
  }

  GarmentWear _wearOf(Garment g) => GarmentWear(
        garment: g,
        daysSinceWashed: g.lastWashedAt == null
            ? null
            : _today.difference(_midnight(g.lastWashedAt!)).inDays,
      );

  /// Los tipos de los que hay poco o nada, dentro de las ranuras que un
  /// outfit necesita.
  ///
  /// No es un juicio de estilo: son las ranuras sin las que el motor no
  /// puede componer, y saberlo explica por qué a veces no propone nada.
  List<Slot> missingSlots(String Function(Slot) label) {
    final present = _garments.map((g) => g.slot).toSet();
    const needed = [Slot.top, Slot.bottom, Slot.shoes];
    return [
      for (final slot in needed)
        if (!present.contains(slot) && !present.contains(Slot.dress)) slot,
    ];
  }

  static List<Breakdown> _sorted(Map<String, int> counts) {
    final entries = counts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        return byCount != 0 ? byCount : a.key.compareTo(b.key);
      });
    return [for (final e in entries) Breakdown(e.key, e.value)];
  }
}
