import 'package:drift/drift.dart';

import '../../domain/models/catalog.dart';
import '../db/database.dart';

/// Por qué no se pudo borrar una entrada del catálogo.
class CatalogInUseException implements Exception {
  const CatalogInUseException(this.name, this.garmentCount);
  final String name;
  final int garmentCount;

  String get message => '"$name" está en uso por $garmentCount '
      '${garmentCount == 1 ? 'prenda' : 'prendas'}.';
}

/// CRUD de los catálogos editables: categorías, ocasiones y moods.
///
/// Vive aparte de `GarmentRepository` porque el ciclo de vida es distinto:
/// el catálogo cambia rara vez y lo consume toda la app, mientras que las
/// prendas cambian constantemente.
class CatalogRepository {
  CatalogRepository(this._db);

  final AppDatabase _db;

  // ---- lectura -----------------------------------------------------------

  Stream<List<Category>> watchCategories() =>
      (_db.select(_db.categories)
            ..orderBy([
              (t) => OrderingTerm.asc(t.sortOrder),
              (t) => OrderingTerm.asc(t.name),
            ]))
          .watch()
          .map((rows) => rows.map(_toCategory).toList());

  Stream<List<Occasion>> watchOccasions() =>
      (_db.select(_db.occasions)
            ..orderBy([
              (t) => OrderingTerm.asc(t.sortOrder),
              (t) => OrderingTerm.asc(t.name),
            ]))
          .watch()
          .map((rows) => rows.map(_toOccasion).toList());

  Stream<List<Mood>> watchMoods() => (_db.select(_db.moods)
        ..orderBy([
          (t) => OrderingTerm.asc(t.sortOrder),
          (t) => OrderingTerm.asc(t.name),
        ]))
      .watch()
      .map((rows) => rows.map(_toMood).toList());

  Future<List<Category>> categories() =>
      _db.select(_db.categories).get().then((r) => r.map(_toCategory).toList());

  /// Cuántas prendas usan esta categoría. Alimenta el aviso previo al
  /// borrado y las cabeceras de sección del armario.
  Future<int> garmentsInCategory(int categoryId) async {
    final count = _db.garments.id.count();
    final q = _db.selectOnly(_db.garments)
      ..addColumns([count])
      ..where(_db.garments.categoryId.equals(categoryId));
    return (await q.getSingle()).read(count) ?? 0;
  }

  // ---- categorías --------------------------------------------------------

  /// El slot es obligatorio y no tiene valor por defecto a propósito: es la
  /// única propiedad de una categoría sin la que el motor no funciona.
  Future<int> createCategory({
    required String name,
    required Slot slot,
    int formality = 2,
    int warmth = 1,
  }) {
    return _db.into(_db.categories).insert(
          CategoriesCompanion.insert(
            name: name.trim(),
            slot: slot.name,
            formality: Value(formality),
            warmth: Value(warmth),
            sortOrder: const Value(1000),
          ),
        );
  }

  Future<void> updateCategory(Category c) =>
      (_db.update(_db.categories)..where((t) => t.id.equals(c.id))).write(
        CategoriesCompanion(
          name: Value(c.name.trim()),
          slot: Value(c.slot.name),
          formality: Value(c.formality),
          warmth: Value(c.warmth),
        ),
      );

  /// Borra la categoría. Las prendas que la usaban NO se borran: se mueven a
  /// "Sin clasificar", porque perder ropa por reorganizar el catálogo sería
  /// inaceptable.
  ///
  /// Con [reassignTo] se elige otro destino. Lanza [CatalogInUseException]
  /// solo si se pide `force: false` y hay prendas dentro.
  Future<void> deleteCategory(
    int id, {
    int? reassignTo,
    bool force = true,
  }) async {
    await _db.transaction(() async {
      final row = await (_db.select(_db.categories)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return;

      final inUse = await garmentsInCategory(id);
      if (inUse > 0 && !force) {
        throw CatalogInUseException(row.name, inUse);
      }

      if (inUse > 0) {
        final target = reassignTo ?? await _fallbackCategoryId();
        if (target == id) return; // reasignar a sí misma no borraría nada
        await (_db.update(_db.garments)
              ..where((t) => t.categoryId.equals(id)))
            .write(GarmentsCompanion(categoryId: Value(target)));
      }

      await (_db.delete(_db.categories)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<int> _fallbackCategoryId() async {
    final existing = await (_db.select(_db.categories)
          ..where((t) => t.name.equals(CatalogSeed.fallbackCategory)))
        .getSingleOrNull();
    if (existing != null) return existing.id;

    // Se recrea si el usuario la borró: la invariante "toda prenda tiene
    // categoría" no puede depender de que una fila concreta siga viva.
    return _db.into(_db.categories).insert(
          CategoriesCompanion.insert(
            name: CatalogSeed.fallbackCategory,
            slot: Slot.accessory.name,
            isBuiltIn: const Value(true),
            sortOrder: const Value(9999),
          ),
        );
  }

  // ---- ocasiones ---------------------------------------------------------

  Future<int> createOccasion({required String name, int formality = 2}) =>
      _db.into(_db.occasions).insert(
            OccasionsCompanion.insert(
              name: name.trim(),
              formality: Value(formality),
              sortOrder: const Value(1000),
            ),
          );

  Future<void> updateOccasion(Occasion o) =>
      (_db.update(_db.occasions)..where((t) => t.id.equals(o.id))).write(
        OccasionsCompanion(
          name: Value(o.name.trim()),
          formality: Value(o.formality),
        ),
      );

  /// Las prendas etiquetadas con ella simplemente dejan de estarlo, vía el
  /// ON DELETE CASCADE de la tabla puente.
  Future<void> deleteOccasion(int id) =>
      (_db.delete(_db.occasions)..where((t) => t.id.equals(id))).go();

  // ---- moods -------------------------------------------------------------

  Future<int> createMood(String name) => _db.into(_db.moods).insert(
        MoodsCompanion.insert(
          name: name.trim(),
          sortOrder: const Value(1000),
        ),
      );

  Future<void> updateMood(Mood m) =>
      (_db.update(_db.moods)..where((t) => t.id.equals(m.id)))
          .write(MoodsCompanion(name: Value(m.name.trim())));

  Future<void> deleteMood(int id) =>
      (_db.delete(_db.moods)..where((t) => t.id.equals(id))).go();

  // ---- tags --------------------------------------------------------------

  Stream<List<Tag>> watchTags() =>
      (_db.select(_db.tags)..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch()
          .map((rows) =>
              rows.map((r) => Tag(id: r.id, name: r.name)).toList());

  Future<void> deleteTag(int id) =>
      (_db.delete(_db.tags)..where((t) => t.id.equals(id))).go();

  /// Borra los tags que ya no cuelgan de ninguna prenda. Se llama tras
  /// editar o borrar ropa, para que la lista de tags no acumule basura.
  Future<int> pruneOrphanTags() => _db.customUpdate(
        'DELETE FROM tags WHERE id NOT IN '
        '(SELECT tag_id FROM garment_tags)',
        updates: {_db.tags},
      );

  // ---- mapeo -------------------------------------------------------------

  Category _toCategory(CategoryRow r) => Category(
        id: r.id,
        name: r.name,
        // Un slot desconocido (base de una versión futura) cae a accesorio
        // en vez de tumbar la carga del catálogo entero.
        slot: enumByName(Slot.values, r.slot) ?? Slot.accessory,
        formality: r.formality,
        warmth: r.warmth,
        isBuiltIn: r.isBuiltIn,
        sortOrder: r.sortOrder,
      );

  Occasion _toOccasion(OccasionRow r) => Occasion(
        id: r.id,
        name: r.name,
        formality: r.formality,
        isBuiltIn: r.isBuiltIn,
        sortOrder: r.sortOrder,
      );

  Mood _toMood(MoodRow r) => Mood(
        id: r.id,
        name: r.name,
        isBuiltIn: r.isBuiltIn,
        sortOrder: r.sortOrder,
      );
}

/// Decodifica un enum por su `name`, devolviendo null si no existe.
///
/// Los enums se persisten por nombre y no por índice: reordenarlos no debe
/// corromper datos ya guardados. El precio es tener que tolerar nombres que
/// ya no existen, y de eso se encarga esta función.
T? enumByName<T extends Enum>(List<T> values, String? name) {
  if (name == null) return null;
  for (final v in values) {
    if (v.name == name) return v;
  }
  return null;
}
