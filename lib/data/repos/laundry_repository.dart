import 'package:drift/drift.dart';

import '../../domain/models/catalog.dart';
import '../../domain/models/garment.dart';
import '../db/database.dart';
import 'garment_repository.dart';

/// Una tanda de lavado.
class LaundryDay {
  const LaundryDay({
    required this.id,
    required this.day,
    required this.items,
    this.notes,
  });

  final int id;

  /// Normalizado a medianoche. Ver [LaundryRepository.dayKey].
  final DateTime day;

  final List<Garment> items;
  final String? notes;

  /// Cuántas prendas de cada grupo entraron. Es lo que se enseña en la
  /// lista: "12 prendas · 7 oscuros, 5 normal" dice más que un número solo.
  Map<String, int> get byGroup {
    final out = <String, int>{};
    for (final g in items) {
      final name = g.washGroup?.name ?? 'Sin clasificar';
      out.update(name, (v) => v + 1, ifAbsent: () => 1);
    }
    return out;
  }
}

/// Una prenda como candidata a entrar en una lavada.
///
/// Lleva el contexto que hace falta para decidir sin tener que recordar
/// nada: si está sucia, cuánto lleva sin lavarse y cuánto sin usarse.
class WashCandidate {
  const WashCandidate({
    required this.garment,
    required this.daysSinceWorn,
    required this.daysSinceWashed,
  });

  final Garment garment;

  /// Días desde la última vez que se usó, o null si nunca.
  final int? daysSinceWorn;

  /// Días desde la última lavada, o null si nunca se ha lavado.
  final int? daysSinceWashed;

  /// Usada después de la última lavada: candidata clara.
  bool get dirty => garment.needsWashing;
}

class LaundryRepository {
  LaundryRepository(this._db, this._garments);

  final AppDatabase _db;
  final GarmentRepository _garments;

  /// Normaliza una fecha a medianoche local, igual que el calendario: sin
  /// esto dos lavadas del mismo día con horas distintas serían días
  /// distintos y la restricción de unicidad no serviría.
  static DateTime dayKey(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Momento con el que se compara si una prenda se uso antes o despues de
  /// lavarse.
  ///
  /// Para hoy es la hora actual, que es la real. Para un dia pasado que se
  /// rellena a posteriori no hay hora que valga, asi que se toma el final
  /// del dia: sin mas informacion, lo sensato es asumir que se lavo despues
  /// de haberlo usado.
  static DateTime washedAtFor(DateTime date, {DateTime? now}) {
    final moment = now ?? DateTime.now();
    final day = dayKey(date);
    if (day == dayKey(moment)) return moment;
    return day.add(const Duration(hours: 23, minutes: 59, seconds: 59));
  }

  // ---- lectura -----------------------------------------------------------

  Stream<List<LaundryDay>> watchAll() {
    final q = _db.select(_db.laundryDays)
      ..orderBy([(t) => OrderingTerm.desc(t.day)]);
    return q.watch().asyncMap(_hydrate);
  }

  Future<LaundryDay?> forDay(DateTime date) async {
    final row = await (_db.select(_db.laundryDays)
          ..where((t) => t.day.equals(dayKey(date))))
        .getSingleOrNull();
    if (row == null) return null;
    return (await _hydrate([row])).firstOrNull;
  }

  /// Días en los que hubo lavada, dentro de un rango. Alimenta la marca del
  /// calendario.
  Stream<Set<DateTime>> watchDaysInRange(DateTime from, DateTime to) {
    final q = _db.select(_db.laundryDays)
      ..where((t) => t.day.isBiggerOrEqualValue(dayKey(from)))
      ..where((t) => t.day.isSmallerOrEqualValue(dayKey(to)));
    return q.watch().map((rows) => rows.map((r) => r.day).toSet());
  }

  /// El armario ordenado para elegir qué se lava.
  ///
  /// Lo sucio primero y, dentro de eso, lo que más tiempo lleva sin lavarse:
  /// es el orden en que uno vacía el cesto de verdad.
  Future<List<WashCandidate>> candidates({DateTime? today}) async {
    final now = dayKey(today ?? DateTime.now());
    final wardrobe = await _garments.getAll();

    int? daysFrom(DateTime? d) =>
        d == null ? null : now.difference(dayKey(d)).inDays;

    final out = [
      for (final g in wardrobe)
        WashCandidate(
          garment: g,
          daysSinceWorn: daysFrom(g.lastWornAt),
          daysSinceWashed: daysFrom(g.lastWashedAt),
        ),
    ];

    out.sort((a, b) {
      if (a.dirty != b.dirty) return a.dirty ? -1 : 1;
      // Lo que nunca se ha lavado va antes que lo lavado hace mucho.
      final da = a.daysSinceWashed ?? 1 << 30;
      final db = b.daysSinceWashed ?? 1 << 30;
      if (da != db) return db.compareTo(da);
      return a.garment.displayName.compareTo(b.garment.displayName);
    });
    return out;
  }

  // ---- escritura ---------------------------------------------------------

  /// Registra una lavada. Reemplaza la del mismo día si ya existía.
  ///
  /// El contador de lavadas de cada prenda se recalcula desde las tablas y
  /// no se incrementa a mano: si se sumara al guardar, editar una lavada
  /// para quitar una prenda dejaría su contador inflado para siempre.
  Future<int> record(
    DateTime date,
    List<Garment> garments, {
    String? notes,
    DateTime? now,
  }) async {
    final day = dayKey(date);
    final washedAt = washedAtFor(date, now: now);

    return _db.transaction(() async {
      final previous = await (_db.select(_db.laundryDays)
            ..where((t) => t.day.equals(day)))
          .getSingleOrNull();

      final affected = <int>{...garments.map((g) => g.id)};
      if (previous != null) {
        // Las prendas que salen de la lavada también hay que recalcularlas.
        final old = await (_db.select(_db.laundryItems)
              ..where((t) => t.laundryDayId.equals(previous.id)))
            .get();
        affected.addAll(old.map((l) => l.garmentId));
        await (_db.delete(_db.laundryDays)..where((t) => t.day.equals(day)))
            .go();
      }

      final id = await _db.into(_db.laundryDays).insert(
            LaundryDaysCompanion.insert(
              day: day,
              washedAt: washedAt,
              notes: Value(notes),
              createdAt: now ?? DateTime.now(),
            ),
          );

      await _db.batch((b) {
        b.insertAll(
          _db.laundryItems,
          garments
              .map((g) => LaundryItemsCompanion.insert(
                  laundryDayId: id, garmentId: g.id))
              .toList(),
          mode: InsertMode.insertOrIgnore,
        );
      });

      for (final garmentId in affected) {
        await _recomputeWash(garmentId);
      }
      return id;
    });
  }

  Future<void> deleteDay(DateTime date) async {
    final day = dayKey(date);
    await _db.transaction(() async {
      final row = await (_db.select(_db.laundryDays)
            ..where((t) => t.day.equals(day)))
          .getSingleOrNull();
      if (row == null) return;

      final items = await (_db.select(_db.laundryItems)
            ..where((t) => t.laundryDayId.equals(row.id)))
          .get();
      final affected = items.map((l) => l.garmentId).toList();

      await (_db.delete(_db.laundryDays)..where((t) => t.day.equals(day))).go();

      for (final garmentId in affected) {
        await _recomputeWash(garmentId);
      }
    });
  }

  /// Recalcula lavadas, última fecha y usos desde la última lavada de una
  /// prenda a partir de su historial completo.
  ///
  /// Ser la única forma de tocar esos campos es lo que garantiza que
  /// cuadren: cualquier alta, edición o borrado de una lavada pasa por aquí.
  Future<void> _recomputeWash(int garmentId) async {
    final rows = await (_db.select(_db.laundryItems).join([
      innerJoin(_db.laundryDays,
          _db.laundryDays.id.equalsExp(_db.laundryItems.laundryDayId)),
    ])
          ..where(_db.laundryItems.garmentId.equals(garmentId)))
        .get();

    // Se ordena por el momento real, no por el dia: es lo que decide si la
    // prenda se uso antes o despues de lavarse.
    final moments =
        rows.map((r) => r.readTable(_db.laundryDays).washedAt).toList()..sort();
    final last = moments.isEmpty ? null : moments.last;

    final garment = await (_db.select(_db.garments)
          ..where((t) => t.id.equals(garmentId)))
        .getSingleOrNull();
    if (garment == null) return;

    // Solo se sabe si el último uso es posterior a la última lavada, no
    // cuántos usos hubo en medio: el histórico de usos no se guarda uso a
    // uso. Con eso basta para la señal de "está sucia".
    final worn = garment.lastWornAt;
    final wearsSince = last == null
        ? garment.wearCount
        : (worn != null && worn.isAfter(last) ? 1 : 0);

    await (_db.update(_db.garments)..where((t) => t.id.equals(garmentId)))
        .write(GarmentsCompanion(
      washCount: Value(moments.length),
      lastWashedAt: Value(last),
      wearsSinceWash: Value(wearsSince),
    ));
  }

  Future<List<LaundryDay>> _hydrate(List<LaundryDayRow> rows) async {
    if (rows.isEmpty) return const [];

    final links = await (_db.select(_db.laundryItems)
          ..where((t) => t.laundryDayId.isIn(rows.map((r) => r.id).toList())))
        .get();

    final needed = links.map((l) => l.garmentId).toSet();
    final byId = {
      for (final g in await _garments.getAll(includeArchived: true))
        if (needed.contains(g.id)) g.id: g,
    };

    final grouped = <int, List<Garment>>{};
    for (final l in links) {
      final g = byId[l.garmentId];
      if (g != null) grouped.putIfAbsent(l.laundryDayId, () => []).add(g);
    }

    return rows
        .map((r) => LaundryDay(
              id: r.id,
              day: r.day,
              items: grouped[r.id] ?? const [],
              notes: r.notes,
            ))
        .toList();
  }
}

/// Extensión del catálogo para los grupos de lavado.
///
/// Vive aquí y no en `CatalogRepository` para no engordar aquel módulo con
/// un concepto que solo usa el lavado.
class WashGroupRepository {
  WashGroupRepository(this._db);

  final AppDatabase _db;

  Stream<List<WashGroup>> watchAll() => (_db.select(_db.washGroups)
        ..orderBy([
          (t) => OrderingTerm.asc(t.sortOrder),
          (t) => OrderingTerm.asc(t.name),
        ]))
      .watch()
      .map((rows) => rows.map(_toDomain).toList());

  Future<List<WashGroup>> all() =>
      _db.select(_db.washGroups).get().then((r) => r.map(_toDomain).toList());

  Future<int> create(String name) => _db.into(_db.washGroups).insert(
        WashGroupsCompanion.insert(
          name: name.trim(),
          sortOrder: const Value(1000),
        ),
      );

  Future<void> update(WashGroup group) =>
      (_db.update(_db.washGroups)..where((t) => t.id.equals(group.id)))
          .write(WashGroupsCompanion(name: Value(group.name.trim())));

  /// Borrar un grupo deja sus prendas sin clasificar, no las borra.
  Future<void> delete(int id) =>
      (_db.delete(_db.washGroups)..where((t) => t.id.equals(id))).go();

  Future<int> garmentsIn(int groupId) async {
    final count = _db.garments.id.count();
    final q = _db.selectOnly(_db.garments)
      ..addColumns([count])
      ..where(_db.garments.washGroupId.equals(groupId));
    return (await q.getSingle()).read(count) ?? 0;
  }

  WashGroup _toDomain(WashGroupRow r) => WashGroup(
        id: r.id,
        name: r.name,
        isBuiltIn: r.isBuiltIn,
        sortOrder: r.sortOrder,
      );
}
