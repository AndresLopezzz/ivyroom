import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/color/color_theory.dart';
import '../../domain/models/catalog.dart';
import '../../domain/models/garment.dart';
import '../db/database.dart';
import 'catalog_repository.dart';

/// Datos necesarios para dar de alta o editar una prenda.
class GarmentDraft {
  const GarmentDraft({
    required this.imagePath,
    required this.thumbPath,
    this.originalPath,
    required this.categoryId,
    required this.dominantColorArgb,
    this.palette = const [],
    this.name,
    this.brand,
    this.notes,
    this.seasons = const {},
    this.occasionIds = const {},
    this.moodIds = const {},
    this.tags = const {},
    this.washGroupId,
    this.isFavorite = false,
  });

  final String imagePath;
  final String thumbPath;
  final String? originalPath;
  final int categoryId;
  final int dominantColorArgb;
  final List<int> palette;
  final String? name;
  final String? brand;
  final String? notes;
  final Set<Season> seasons;
  final Set<int> occasionIds;
  final Set<int> moodIds;
  final Set<String> tags;
  final int? washGroupId;
  final bool isFavorite;
}

/// Filtros del armario.
///
/// Todos, sin excepción, se traducen a SQL. La familia de color incluida:
/// se persiste como columna precisamente para que ningún filtro tenga que
/// resolverse en memoria trayendo antes el armario entero.
class ClosetFilter {
  const ClosetFilter({
    this.slots = const {},
    this.categoryIds = const {},
    this.colorFamilies = const {},
    this.seasons = const {},
    this.occasionIds = const {},
    this.moodIds = const {},
    this.tagIds = const {},
    this.washGroupIds = const {},
    this.query,
    this.onlyFavorites = false,
    this.onlyForgotten = false,
    this.includeArchived = false,
  });

  final Set<Slot> slots;
  final Set<int> categoryIds;
  final Set<ColorFamily> colorFamilies;
  final Set<Season> seasons;
  final Set<int> occasionIds;
  final Set<int> moodIds;
  final Set<int> tagIds;
  final Set<int> washGroupIds;
  final String? query;
  final bool onlyFavorites;

  /// Ver [Garment.isForgotten].
  final bool onlyForgotten;
  final bool includeArchived;

  bool get isEmpty =>
      slots.isEmpty &&
      categoryIds.isEmpty &&
      colorFamilies.isEmpty &&
      seasons.isEmpty &&
      occasionIds.isEmpty &&
      moodIds.isEmpty &&
      tagIds.isEmpty &&
      washGroupIds.isEmpty &&
      (query == null || query!.trim().isEmpty) &&
      !onlyFavorites &&
      !onlyForgotten;

  /// Cuántos criterios hay activos. Alimenta la insignia del botón de
  /// filtros.
  int get activeCount =>
      (slots.isEmpty ? 0 : 1) +
      (categoryIds.isEmpty ? 0 : 1) +
      (colorFamilies.isEmpty ? 0 : 1) +
      (seasons.isEmpty ? 0 : 1) +
      (occasionIds.isEmpty ? 0 : 1) +
      (moodIds.isEmpty ? 0 : 1) +
      (tagIds.isEmpty ? 0 : 1) +
      (washGroupIds.isEmpty ? 0 : 1) +
      ((query?.trim().isNotEmpty ?? false) ? 1 : 0) +
      (onlyFavorites ? 1 : 0) +
      (onlyForgotten ? 1 : 0);

  /// El `copyWith` vive aquí y no en la hoja de filtros: mientras estuvo en
  /// la UI, añadir un campo obligaba a tocar tres sitios y olvidarse de uno
  /// perdía el filtro en silencio, sin que el compilador dijera nada.
  ClosetFilter copyWith({
    Set<Slot>? slots,
    Set<int>? categoryIds,
    Set<ColorFamily>? colorFamilies,
    Set<Season>? seasons,
    Set<int>? occasionIds,
    Set<int>? moodIds,
    Set<int>? tagIds,
    Set<int>? washGroupIds,
    String? query,
    bool clearQuery = false,
    bool? onlyFavorites,
    bool? onlyForgotten,
    bool? includeArchived,
  }) {
    return ClosetFilter(
      slots: slots ?? this.slots,
      categoryIds: categoryIds ?? this.categoryIds,
      colorFamilies: colorFamilies ?? this.colorFamilies,
      seasons: seasons ?? this.seasons,
      occasionIds: occasionIds ?? this.occasionIds,
      moodIds: moodIds ?? this.moodIds,
      tagIds: tagIds ?? this.tagIds,
      washGroupIds: washGroupIds ?? this.washGroupIds,
      query: clearQuery ? null : (query ?? this.query),
      onlyFavorites: onlyFavorites ?? this.onlyFavorites,
      onlyForgotten: onlyForgotten ?? this.onlyForgotten,
      includeArchived: includeArchived ?? this.includeArchived,
    );
  }

  /// Añade o quita un valor de un conjunto sin que quien llama tenga que
  /// clonarlo a mano en cada `FilterChip`.
  ClosetFilter toggleSlot(Slot v) => copyWith(slots: _flip(slots, v));
  ClosetFilter toggleCategory(int v) =>
      copyWith(categoryIds: _flip(categoryIds, v));
  ClosetFilter toggleColor(ColorFamily v) =>
      copyWith(colorFamilies: _flip(colorFamilies, v));
  ClosetFilter toggleSeason(Season v) => copyWith(seasons: _flip(seasons, v));
  ClosetFilter toggleOccasion(int v) =>
      copyWith(occasionIds: _flip(occasionIds, v));
  ClosetFilter toggleMood(int v) => copyWith(moodIds: _flip(moodIds, v));
  ClosetFilter toggleTag(int v) => copyWith(tagIds: _flip(tagIds, v));
  ClosetFilter toggleWashGroup(int v) =>
      copyWith(washGroupIds: _flip(washGroupIds, v));

  static Set<T> _flip<T>(Set<T> set, T value) {
    final next = {...set};
    if (!next.remove(value)) next.add(value);
    return next;
  }
}

class GarmentRepository {
  GarmentRepository(this._db);

  final AppDatabase _db;

  // ---- lectura -----------------------------------------------------------

  /// Stream reactivo de todo el armario. Drift reemite en cuanto cambia
  /// cualquiera de las tablas implicadas, incluidas las puente.
  Stream<List<Garment>> watchAll({bool includeArchived = false}) =>
      watchFiltered(ClosetFilter(includeArchived: includeArchived));

  /// [queryColors] son las familias de color a las que se refiere el texto
  /// de busqueda ("negro" es neutro). Las resuelve quien llama porque los
  /// nombres de los colores son cosa de la interfaz, no de los datos.
  Stream<List<Garment>> watchFiltered(
    ClosetFilter filter, {
    Set<ColorFamily> queryColors = const {},
  }) {
    final q = _db.select(_db.garments);

    if (!filter.includeArchived) {
      q.where((t) => t.isArchived.equals(false));
    }
    if (filter.onlyFavorites) {
      q.where((t) => t.isFavorite.equals(true));
    }
    if (filter.categoryIds.isNotEmpty) {
      q.where((t) => t.categoryId.isIn(filter.categoryIds.toList()));
    }
    if (filter.slots.isNotEmpty) {
      // El slot vive en `categories`, así que se filtra con un subselect en
      // vez de un join: el join duplicaría filas y obligaría a deduplicar.
      q.where((t) => t.categoryId.isInQuery(
            _db.selectOnly(_db.categories)
              ..addColumns([_db.categories.id])
              ..where(_db.categories.slot
                  .isIn(filter.slots.map((s) => s.name).toList())),
          ));
    }
    if (filter.colorFamilies.isNotEmpty) {
      q.where((t) =>
          t.colorFamily.isIn(filter.colorFamilies.map((c) => c.name).toList()));
    }
    final text = filter.query?.trim();
    if (text != null && text.isNotEmpty) {
      final like = '%$text%';
      // Lo que una persona escribe al buscar puede ser cualquier cosa que
      // vea en la prenda: el nombre, la marca, el tipo ("jean"), el color
      // ("negro") o una etiqueta suya ("oficina").
      q.where((t) {
        Expression<bool> e = t.name.like(like) |
            t.brand.like(like) |
            t.notes.like(like) |
            t.categoryId.isInQuery(_db.selectOnly(_db.categories)
              ..addColumns([_db.categories.id])
              ..where(_db.categories.name.like(like))) |
            existsQuery(_db.select(_db.garmentTags).join([
              innerJoin(_db.tags, _db.tags.id.equalsExp(_db.garmentTags.tagId)),
            ])
              ..where(_db.garmentTags.garmentId.equalsExp(t.id) &
                  _db.tags.name.like(like)));
        if (queryColors.isNotEmpty) {
          e = e | t.colorFamily.isIn(queryColors.map((c) => c.name).toList());
        }
        return e;
      });
    }
    if (filter.seasons.isNotEmpty) {
      q.where((t) => existsQuery(_db.select(_db.garmentSeasons)
        ..where((s) =>
            s.garmentId.equalsExp(t.id) &
            s.season.isIn(filter.seasons.map((e) => e.name).toList()))));
    }
    if (filter.occasionIds.isNotEmpty) {
      q.where((t) => existsQuery(_db.select(_db.garmentOccasions)
        ..where((s) =>
            s.garmentId.equalsExp(t.id) &
            s.occasionId.isIn(filter.occasionIds.toList()))));
    }
    if (filter.moodIds.isNotEmpty) {
      q.where((t) => existsQuery(_db.select(_db.garmentMoods)
        ..where((s) =>
            s.garmentId.equalsExp(t.id) &
            s.moodId.isIn(filter.moodIds.toList()))));
    }
    if (filter.washGroupIds.isNotEmpty) {
      q.where((t) => t.washGroupId.isIn(filter.washGroupIds.toList()));
    }
    if (filter.tagIds.isNotEmpty) {
      q.where((t) => existsQuery(_db.select(_db.garmentTags)
        ..where((s) =>
            s.garmentId.equalsExp(t.id) &
            s.tagId.isIn(filter.tagIds.toList()))));
    }

    q.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final hydrated = q.watch().asyncMap(_hydrateAll);
    if (!filter.onlyForgotten) return hydrated;
    // En Dart y no en SQL: la regla vive en el modelo y asi no se duplica.
    // Lo que ya se filtro arriba deja pocas filas.
    return hydrated.map((all) {
      final now = DateTime.now();
      return [for (final g in all) if (g.isForgotten(now)) g];
    });
  }

  Future<Garment?> findById(int id) async {
    final row = await (_db.select(_db.garments)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return null;
    return (await _hydrateAll([row])).first;
  }

  Future<List<Garment>> getAll({bool includeArchived = false}) {
    final q = _db.select(_db.garments);
    if (!includeArchived) q.where((t) => t.isArchived.equals(false));
    return q.get().then(_hydrateAll);
  }

  // ---- escritura ---------------------------------------------------------

  Future<int> insert(GarmentDraft d) {
    return _db.transaction(() async {
      final id = await _db.into(_db.garments).insert(
            GarmentsCompanion.insert(
              imagePath: d.imagePath,
              thumbPath: d.thumbPath,
              originalPath: Value(d.originalPath),
              categoryId: d.categoryId,
              dominantColorArgb: d.dominantColorArgb,
              colorFamily: Hsl.fromArgb(d.dominantColorArgb).family.name,
              paletteJson: Value(jsonEncode(d.palette)),
              name: Value(d.name),
              brand: Value(d.brand),
              notes: Value(d.notes),
              washGroupId: Value(d.washGroupId),
              isFavorite: Value(d.isFavorite),
              createdAt: DateTime.now(),
            ),
          );
      await _writeSideTables(id, d);
      return id;
    });
  }

  Future<void> update(int id, GarmentDraft d) {
    return _db.transaction(() async {
      await (_db.update(_db.garments)..where((t) => t.id.equals(id))).write(
        GarmentsCompanion(
          imagePath: Value(d.imagePath),
          thumbPath: Value(d.thumbPath),
          originalPath: Value(d.originalPath),
          categoryId: Value(d.categoryId),
          dominantColorArgb: Value(d.dominantColorArgb),
          // Se recalcula siempre: si el usuario corrige el color a mano, la
          // columna derivada tiene que seguirle o el filtro mentiría.
          colorFamily: Value(Hsl.fromArgb(d.dominantColorArgb).family.name),
          paletteJson: Value(jsonEncode(d.palette)),
          name: Value(d.name),
          brand: Value(d.brand),
          notes: Value(d.notes),
          washGroupId: Value(d.washGroupId),
          isFavorite: Value(d.isFavorite),
        ),
      );
      await _clearSideTables(id);
      await _writeSideTables(id, d);
    });
  }

  Future<void> setFavorite(int id, bool value) =>
      (_db.update(_db.garments)..where((t) => t.id.equals(id)))
          .write(GarmentsCompanion(isFavorite: Value(value)));

  Future<void> setArchived(int id, bool value) =>
      (_db.update(_db.garments)..where((t) => t.id.equals(id)))
          .write(GarmentsCompanion(isArchived: Value(value)));

  /// Marca la prenda como puesta. Alimenta la penalización por novedad del
  /// motor de outfits.
  Future<void> markWorn(int id, {DateTime? when}) async {
    final row = await (_db.select(_db.garments)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return;
    // Se escribe con la API tipada de drift y no con SQL crudo: escribir la
    // fecha a mano obligaba a replicar el formato de almacenamiento de drift
    // (segundos unix), que es un detalle interno suyo y puede cambiar.
    await (_db.update(_db.garments)..where((t) => t.id.equals(id))).write(
      GarmentsCompanion(
        wearCount: Value(row.wearCount + 1),
        lastWornAt: Value(when ?? DateTime.now()),
        // Un uso mas desde la ultima lavada: es lo que marca la prenda como
        // sucia y lo que se pone a cero al lavarla.
        wearsSinceWash: Value(row.wearsSinceWash + 1),
      ),
    );
  }

  /// Apunta la prenda a imagenes nuevas y olvida la foto original.
  ///
  /// Solo cambia rutas: los ficheros viejos los borra quien llama, y solo
  /// despues de esto, para que la base nunca apunte a algo que ya no esta.
  Future<void> replaceImages(
    int id, {
    required String image,
    required String thumb,
  }) =>
      (_db.update(_db.garments)..where((t) => t.id.equals(id))).write(
        GarmentsCompanion(
          imagePath: Value(image),
          thumbPath: Value(thumb),
          originalPath: const Value(null),
        ),
      );

  /// Borra la fila. Los ficheros de imagen los borra quien llama, que es
  /// quien conoce `ImageStorage`.
  Future<void> delete(int id) =>
      (_db.delete(_db.garments)..where((t) => t.id.equals(id))).go();

  /// Todas las rutas de imagen referenciadas por alguna prenda.
  ///
  /// Es lo que permite barrer los ficheros huerfanos: cualquier cosa en el
  /// directorio que no este aqui ya no le pertenece a nadie.
  Future<Set<String>> allImagePaths() async {
    final rows = await _db.select(_db.garments).get();
    return {
      for (final r in rows) ...[
        r.imagePath,
        r.thumbPath,
        if (r.originalPath != null) r.originalPath!,
      ],
    };
  }

  // ---- interno -----------------------------------------------------------

  Future<int> _tagId(String rawName) async {
    final name = rawName.trim().toLowerCase();
    final existing =
        await (_db.select(_db.tags)..where((t) => t.name.equals(name)))
            .getSingleOrNull();
    if (existing != null) return existing.id;
    return _db.into(_db.tags).insert(TagsCompanion.insert(name: name));
  }

  Future<void> _writeSideTables(int id, GarmentDraft d) async {
    await _db.batch((b) {
      b.insertAll(
        _db.garmentSeasons,
        d.seasons
            .map((s) =>
                GarmentSeasonsCompanion.insert(garmentId: id, season: s.name))
            .toList(),
        mode: InsertMode.insertOrIgnore,
      );
      b.insertAll(
        _db.garmentOccasions,
        d.occasionIds
            .map((oid) => GarmentOccasionsCompanion.insert(
                garmentId: id, occasionId: oid))
            .toList(),
        mode: InsertMode.insertOrIgnore,
      );
      b.insertAll(
        _db.garmentMoods,
        d.moodIds
            .map((mid) =>
                GarmentMoodsCompanion.insert(garmentId: id, moodId: mid))
            .toList(),
        mode: InsertMode.insertOrIgnore,
      );
    });

    // Los tags necesitan resolver o crear antes la fila en `tags`, así que
    // no caben en el batch de arriba.
    for (final raw in d.tags) {
      if (raw.trim().isEmpty) continue;
      final tagId = await _tagId(raw);
      await _db.into(_db.garmentTags).insert(
            GarmentTagsCompanion.insert(garmentId: id, tagId: tagId),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  Future<void> _clearSideTables(int id) async {
    await (_db.delete(_db.garmentSeasons)..where((t) => t.garmentId.equals(id)))
        .go();
    await (_db.delete(_db.garmentOccasions)
          ..where((t) => t.garmentId.equals(id)))
        .go();
    await (_db.delete(_db.garmentMoods)..where((t) => t.garmentId.equals(id)))
        .go();
    await (_db.delete(_db.garmentTags)..where((t) => t.garmentId.equals(id)))
        .go();
  }

  /// Carga catálogos y atributos multivalor de todas las prendas en un
  /// número fijo de consultas, no una por prenda: con un armario grande el
  /// N+1 se nota al scrollear.
  Future<List<Garment>> _hydrateAll(List<GarmentRow> rows) async {
    if (rows.isEmpty) return const [];
    final ids = rows.map((r) => r.id).toList();

    final catalog = CatalogRepository(_db);
    final categoriesById = {
      for (final c in await catalog.categories()) c.id: c,
    };

    final washById = {
      for (final r in await _db.select(_db.washGroups).get())
        r.id: WashGroup(
            id: r.id,
            name: r.name,
            isBuiltIn: r.isBuiltIn,
            sortOrder: r.sortOrder),
    };

    final occById = {
      for (final r in await _db.select(_db.occasions).get())
        r.id: Occasion(
            id: r.id,
            name: r.name,
            formality: r.formality,
            isBuiltIn: r.isBuiltIn,
            sortOrder: r.sortOrder),
    };
    final moodById = {
      for (final r in await _db.select(_db.moods).get())
        r.id: Mood(
            id: r.id,
            name: r.name,
            isBuiltIn: r.isBuiltIn,
            sortOrder: r.sortOrder),
    };

    final seasons = <int, Set<Season>>{};
    for (final r in await (_db.select(_db.garmentSeasons)
          ..where((t) => t.garmentId.isIn(ids)))
        .get()) {
      final v = enumByName(Season.values, r.season);
      if (v != null) seasons.putIfAbsent(r.garmentId, () => {}).add(v);
    }

    final occasions = <int, Set<Occasion>>{};
    for (final r in await (_db.select(_db.garmentOccasions)
          ..where((t) => t.garmentId.isIn(ids)))
        .get()) {
      final v = occById[r.occasionId];
      if (v != null) occasions.putIfAbsent(r.garmentId, () => {}).add(v);
    }

    final moods = <int, Set<Mood>>{};
    for (final r in await (_db.select(_db.garmentMoods)
          ..where((t) => t.garmentId.isIn(ids)))
        .get()) {
      final v = moodById[r.moodId];
      if (v != null) moods.putIfAbsent(r.garmentId, () => {}).add(v);
    }

    final tags = <int, Set<String>>{};
    final tagJoin = await (_db.select(_db.garmentTags).join([
      innerJoin(_db.tags, _db.tags.id.equalsExp(_db.garmentTags.tagId)),
    ])
          ..where(_db.garmentTags.garmentId.isIn(ids)))
        .get();
    for (final row in tagJoin) {
      final gid = row.readTable(_db.garmentTags).garmentId;
      tags.putIfAbsent(gid, () => {}).add(row.readTable(_db.tags).name);
    }

    // Si la categoría desapareciera, la prenda sigue siendo visible con una
    // categoría sintética: nunca se oculta ropa por un problema de catálogo.
    Category categoryFor(int id) =>
        categoriesById[id] ??
        Category(
          id: id,
          name: CatalogSeed.fallbackCategory,
          slot: Slot.accessory,
        );

    return rows
        .map((r) => Garment(
              id: r.id,
              imagePath: r.imagePath,
              thumbPath: r.thumbPath,
              originalPath: r.originalPath,
              category: categoryFor(r.categoryId),
              dominantColorArgb: r.dominantColorArgb,
              palette: _decodePalette(r.paletteJson),
              name: r.name,
              brand: r.brand,
              notes: r.notes,
              seasons: seasons[r.id] ?? const {},
              occasions: occasions[r.id] ?? const {},
              moods: moods[r.id] ?? const {},
              tags: tags[r.id] ?? const {},
              washGroup:
                  r.washGroupId == null ? null : washById[r.washGroupId],
              isFavorite: r.isFavorite,
              isArchived: r.isArchived,
              wearCount: r.wearCount,
              lastWornAt: r.lastWornAt,
              washCount: r.washCount,
              lastWashedAt: r.lastWashedAt,
              wearsSinceWash: r.wearsSinceWash,
              createdAt: r.createdAt,
            ))
        .toList();
  }

  List<int> _decodePalette(String json) {
    try {
      final raw = jsonDecode(json);
      if (raw is! List) return const [];
      return raw.whereType<int>().toList();
    } on FormatException {
      return const [];
    }
  }
}
