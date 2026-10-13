import 'package:drift/drift.dart';

import '../../domain/models/catalog.dart';
import '../../domain/models/garment.dart';
import '../../domain/models/outfit.dart';
import '../db/database.dart';
import 'garment_repository.dart';

class OutfitRepository {
  OutfitRepository(this._db, this._garments);

  final AppDatabase _db;
  final GarmentRepository _garments;

  Stream<List<SavedOutfit>> watchAll() {
    final q = _db.select(_db.outfits)
      // Los favoritos arriba: son los que se vuelven a poner.
      ..orderBy([
        (t) => OrderingTerm.desc(t.isFavorite),
        (t) => OrderingTerm.desc(t.createdAt),
      ]);
    return q.watch().asyncMap(_hydrate);
  }

  Future<int> save(
    List<Garment> items, {
    String? name,
    Occasion? occasion,
    Mood? mood,
    String? notes,
  }) {
    return _db.transaction(() async {
      final id = await _db.into(_db.outfits).insert(
            OutfitsCompanion.insert(
              name: Value(name),
              occasionId: Value(occasion?.id),
              moodId: Value(mood?.id),
              notes: Value(notes),
              createdAt: DateTime.now(),
            ),
          );
      await _db.batch((b) {
        b.insertAll(
          _db.outfitItems,
          items
              .map((g) => OutfitItemsCompanion.insert(
                    outfitId: id,
                    garmentId: g.id,
                    // La ranura se congela al guardar: si más adelante se
                    // recategoriza la prenda, el outfit guardado conserva su
                    // composición original.
                    slot: g.slot.name,
                  ))
              .toList(),
          mode: InsertMode.insertOrIgnore,
        );
      });
      return id;
    });
  }

  Future<void> setFavorite(int id, bool value) =>
      (_db.update(_db.outfits)..where((t) => t.id.equals(id)))
          .write(OutfitsCompanion(isFavorite: Value(value)));

  Future<void> rename(int id, String? name) =>
      (_db.update(_db.outfits)..where((t) => t.id.equals(id)))
          .write(OutfitsCompanion(name: Value(name)));

  Future<void> delete(int id) =>
      (_db.delete(_db.outfits)..where((t) => t.id.equals(id))).go();

  /// Marca el outfit y todas sus prendas como usados.
  Future<void> markWorn(int id, {DateTime? when}) async {
    final now = when ?? DateTime.now();
    await _db.transaction(() async {
      final row = await (_db.select(_db.outfits)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return;

      await (_db.update(_db.outfits)..where((t) => t.id.equals(id))).write(
        OutfitsCompanion(
          wearCount: Value(row.wearCount + 1),
          lastWornAt: Value(now),
        ),
      );

      final items = await (_db.select(_db.outfitItems)
            ..where((t) => t.outfitId.equals(id)))
          .get();
      for (final item in items) {
        await _garments.markWorn(item.garmentId, when: now);
      }
    });
  }

  Future<List<SavedOutfit>> _hydrate(List<OutfitRow> rows) async {
    if (rows.isEmpty) return const [];

    final links = await (_db.select(_db.outfitItems)
          ..where((t) => t.outfitId.isIn(rows.map((r) => r.id).toList())))
        .get();

    // Una sola carga de prendas para todos los outfits, en vez de una
    // consulta por outfit.
    final needed = links.map((l) => l.garmentId).toSet();
    final all = await _garments.getAll(includeArchived: true);
    final byId = {
      for (final g in all)
        if (needed.contains(g.id)) g.id: g,
    };

    final occById = {
      for (final r in await _db.select(_db.occasions).get())
        r.id: Occasion(id: r.id, name: r.name, formality: r.formality),
    };
    final moodById = {
      for (final r in await _db.select(_db.moods).get())
        r.id: Mood(id: r.id, name: r.name),
    };

    final grouped = <int, List<Garment>>{};
    for (final l in links) {
      final g = byId[l.garmentId];
      if (g != null) grouped.putIfAbsent(l.outfitId, () => []).add(g);
    }

    return rows
        .map((r) => SavedOutfit(
              id: r.id,
              items: grouped[r.id] ?? const [],
              name: r.name,
              occasion: r.occasionId == null ? null : occById[r.occasionId],
              mood: r.moodId == null ? null : moodById[r.moodId],
              notes: r.notes,
              isFavorite: r.isFavorite,
              createdAt: r.createdAt,
              lastWornAt: r.lastWornAt,
              wearCount: r.wearCount,
            ))
        .toList();
  }
}
