import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ivyroom/data/db/database.dart';
import 'package:ivyroom/data/repos/catalog_repository.dart';
import 'package:ivyroom/data/repos/garment_repository.dart';
import 'package:ivyroom/domain/models/catalog.dart';
import 'package:ivyroom/ui/labels.dart';

void main() {
  late AppDatabase db;
  late GarmentRepository repo;
  late CatalogRepository catalog;
  late Map<String, Category> cats;
  late Map<String, Occasion> occs;
  late Map<String, Mood> moods;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = GarmentRepository(db);
    catalog = CatalogRepository(db);
    cats = {for (final c in await catalog.categories()) c.name: c};
    occs = {for (final o in await catalog.watchOccasions().first) o.name: o};
    moods = {for (final m in await catalog.watchMoods().first) m.name: m};
  });

  tearDown(() => db.close());

  GarmentDraft draft({
    String category = 'Camiseta',
    int color = 0xFF1E5ADC,
    String? name,
    Set<Season> seasons = const {},
    Set<String> occasions = const {},
    Set<String> moodNames = const {},
    Set<String> tags = const {},
    List<int> palette = const [],
  }) {
    return GarmentDraft(
      imagePath: 'garments/a.png',
      thumbPath: 'garments/a_thumb.png',
      categoryId: cats[category]!.id,
      dominantColorArgb: color,
      name: name,
      seasons: seasons,
      occasionIds: occasions.map((o) => occs[o]!.id).toSet(),
      moodIds: moodNames.map((m) => moods[m]!.id).toSet(),
      tags: tags,
      palette: palette,
    );
  }

  group('semillas del catálogo', () {
    test('una base nueva viene con los catálogos poblados', () {
      expect(cats, isNotEmpty);
      expect(occs, isNotEmpty);
      expect(moods, isNotEmpty);
    });

    test('usa vocabulario neutro: Zapatos y Tenis, no zapatillas', () {
      expect(cats.keys, contains('Zapatos'));
      expect(cats.keys, contains('Tenis'));
      expect(cats.keys.join(' ').toLowerCase(), isNot(contains('zapatilla')));
    });

    test('toda categoría tiene una ranura válida', () {
      for (final c in cats.values) {
        expect(Slot.values, contains(c.slot));
      }
    });

    test('hay al menos una categoría por ranura', () {
      final covered = cats.values.map((c) => c.slot).toSet();
      expect(covered, containsAll(Slot.values));
    });
  });

  group('alta y lectura', () {
    test('guarda y recupera una prenda con todos sus atributos', () async {
      final id = await repo.insert(draft(
        category: 'Chaqueta',
        name: 'Bomber negra',
        seasons: {Season.autumn, Season.winter},
        occasions: {'Casual'},
        moodNames: {'Rockero'},
        tags: {'favorita', 'cuero'},
        palette: [0xFF111111, 0xFF222222],
      ));

      final g = await repo.findById(id);
      expect(g, isNotNull);
      expect(g!.name, 'Bomber negra');
      expect(g.category.name, 'Chaqueta');
      expect(g.slot, Slot.outer);
      expect(g.seasons, {Season.autumn, Season.winter});
      expect(g.occasions.map((o) => o.name), {'Casual'});
      expect(g.moods.map((m) => m.name), {'Rockero'});
      expect(g.tags, {'favorita', 'cuero'});
      expect(g.palette, [0xFF111111, 0xFF222222]);
    });

    test('findById devuelve null si no existe', () async {
      expect(await repo.findById(999), isNull);
    });

    test('los tags se normalizan y no se duplican en la tabla', () async {
      await repo.insert(draft(tags: {'Verano', 'playa'}));
      await repo.insert(draft(tags: {'verano', 'PLAYA'}));

      final tags = await catalog.watchTags().first;
      expect(tags.map((t) => t.name).toSet(), {'verano', 'playa'});
    });

    test('watchAll reemite al insertar', () async {
      final stream = repo.watchAll();
      expect(await stream.first, isEmpty);
      await repo.insert(draft());
      expect(await stream.first, hasLength(1));
    });

    test('persiste la familia de color derivada del ARGB', () async {
      final id = await repo.insert(draft(color: 0xFFDC1E1E));
      final row = await db.customSelect(
        'SELECT color_family FROM garments WHERE id = ?',
        variables: [Variable.withInt(id)],
      ).getSingle();
      expect(row.read<String>('color_family'), ColorFamily.red.name);
    });
  });

  group('edición', () {
    test('update reemplaza los atributos multivalor, no los acumula',
        () async {
      final id = await repo.insert(draft(
        seasons: {Season.summer},
        tags: {'viejo'},
        occasions: {'Casual'},
      ));
      await repo.update(
          id,
          draft(
            seasons: {Season.winter},
            tags: {'nuevo'},
            occasions: {'Trabajo'},
            name: 'renombrada',
          ));

      final g = await repo.findById(id);
      expect(g!.seasons, {Season.winter});
      expect(g.tags, {'nuevo'});
      expect(g.occasions.map((o) => o.name), {'Trabajo'});
      expect(g.name, 'renombrada');
    });

    test('cambiar el color a mano actualiza la familia persistida', () async {
      // La columna es dato derivado: si no siguiera al color, el filtro
      // mentiría en silencio.
      final id = await repo.insert(draft(color: 0xFFDC1E1E));
      await repo.update(id, draft(color: 0xFF1E5ADC));

      final out = await repo
          .watchFiltered(const ClosetFilter(colorFamilies: {ColorFamily.blue}))
          .first;
      expect(out.map((g) => g.id), contains(id));
    });

    test('markWorn incrementa el contador y guarda la fecha exacta', () async {
      final id = await repo.insert(draft());
      expect((await repo.findById(id))!.wearCount, 0);

      final when = DateTime(2026, 8, 20, 14, 30);
      await repo.markWorn(id, when: when);
      await repo.markWorn(id, when: when);

      final g = await repo.findById(id);
      expect(g!.wearCount, 2);
      expect(g.lastWornAt, when);
    });

    test('archivar oculta la prenda de watchAll', () async {
      final id = await repo.insert(draft());
      await repo.setArchived(id, true);
      expect(await repo.watchAll().first, isEmpty);
      expect(await repo.watchAll(includeArchived: true).first, hasLength(1));
    });

    test('borrar arrastra las filas de las tablas puente', () async {
      final id = await repo.insert(draft(
        seasons: {Season.summer},
        moodNames: {'Relajado'},
        tags: {'x'},
      ));
      await repo.delete(id);

      expect(await repo.findById(id), isNull);
      expect(await db.select(db.garmentSeasons).get(), isEmpty);
      expect(await db.select(db.garmentMoods).get(), isEmpty);
      expect(await db.select(db.garmentTags).get(), isEmpty);
      // El tag en sí sobrevive: puede estar en uso por otras prendas.
      expect(await db.select(db.tags).get(), hasLength(1));
    });
  });

  group('filtros', () {
    test('por ranura expande a todas sus categorías', () async {
      await repo.insert(draft(category: 'Camiseta'));
      await repo.insert(draft(category: 'Suéter'));
      await repo.insert(draft(category: 'Jean'));

      final out =
          await repo.watchFiltered(const ClosetFilter(slots: {Slot.top})).first;
      expect(out, hasLength(2));
    });

    test('ranura y categoría a la vez se aplican en AND', () async {
      await repo.insert(draft(category: 'Camiseta'));
      await repo.insert(draft(category: 'Jean'));

      // Un jean no es un top: la intersección queda vacía.
      final out = await repo
          .watchFiltered(ClosetFilter(
            slots: const {Slot.top},
            categoryIds: {cats['Jean']!.id},
          ))
          .first;
      expect(out, isEmpty);
    });

    test('por temporada', () async {
      await repo.insert(draft(seasons: {Season.summer}));
      await repo.insert(draft(seasons: {Season.winter}));

      final out = await repo
          .watchFiltered(const ClosetFilter(seasons: {Season.summer}))
          .first;
      expect(out, hasLength(1));
    });

    test('por familia de color, resuelto en SQL', () async {
      await repo.insert(draft(color: 0xFF1E5ADC)); // azul
      await repo.insert(draft(color: 0xFFDC1E1E)); // rojo

      final out = await repo
          .watchFiltered(const ClosetFilter(colorFamilies: {ColorFamily.blue}))
          .first;
      expect(out, hasLength(1));
      expect(out.first.colorFamily, ColorFamily.blue);
    });

    test('por ocasión', () async {
      await repo.insert(draft(occasions: {'Trabajo'}));
      await repo.insert(draft(occasions: {'Deporte'}));

      final out = await repo
          .watchFiltered(ClosetFilter(occasionIds: {occs['Trabajo']!.id}))
          .first;
      expect(out, hasLength(1));
    });

    test('por mood', () async {
      await repo.insert(draft(moodNames: {'Elegante'}));
      await repo.insert(draft(moodNames: {'Relajado'}));

      final out = await repo
          .watchFiltered(ClosetFilter(moodIds: {moods['Elegante']!.id}))
          .first;
      expect(out, hasLength(1));
    });

    test('por texto busca en nombre y marca', () async {
      await repo.insert(draft(name: 'Camisa de lino'));
      await repo.insert(draft(name: 'Jean claro'));

      final out =
          await repo.watchFiltered(const ClosetFilter(query: 'lino')).first;
      expect(out, hasLength(1));
    });

    test('el texto encuentra por tipo de prenda', () async {
      await repo.insert(draft(category: 'Camiseta'));
      await repo.insert(draft(category: 'Zapatos'));

      final out =
          await repo.watchFiltered(const ClosetFilter(query: 'zapa')).first;
      expect(out.single.category.name, 'Zapatos');
    });

    test('el texto encuentra por etiqueta', () async {
      await repo.insert(draft(tags: {'oficina'}));
      await repo.insert(draft(tags: {'playa'}));

      final out =
          await repo.watchFiltered(const ClosetFilter(query: 'ofi')).first;
      expect(out.single.tags, {'oficina'});
    });

    test('el texto encuentra por color', () async {
      await repo.insert(draft(color: 0xFF1E5ADC)); // azul
      await repo.insert(draft(color: 0xFFDC1E1E)); // rojo

      final out = await repo
          .watchFiltered(const ClosetFilter(query: 'celeste'),
              queryColors: Labels.colorFamiliesMatching('celeste'))
          .first;
      expect(out.single.dominantColorArgb, 0xFF1E5ADC);
    });

    test('olvidadas: sin ponerse en dos meses, no las recien usadas', () async {
      final vieja = await repo.insert(draft(name: 'vieja'));
      final reciente = await repo.insert(draft(name: 'reciente'));
      final now = DateTime.now();
      await repo.markWorn(vieja, when: now.subtract(const Duration(days: 90)));
      await repo.markWorn(reciente, when: now);

      final out = await repo
          .watchFiltered(const ClosetFilter(onlyForgotten: true))
          .first;
      expect(out.map((g) => g.name), ['vieja']);
    });

    test('una prenda recien dada de alta y sin usar no esta olvidada',
        () async {
      await repo.insert(draft());
      final out = await repo
          .watchFiltered(const ClosetFilter(onlyForgotten: true))
          .first;
      expect(out, isEmpty);
    });

    test('por tag', () async {
      await repo.insert(draft(tags: {'playa'}));
      await repo.insert(draft(tags: {'oficina'}));

      final tags = await catalog.watchTags().first;
      final playa = tags.firstWhere((t) => t.name == 'playa');

      final out =
          await repo.watchFiltered(ClosetFilter(tagIds: {playa.id})).first;
      expect(out, hasLength(1));
    });

    test('combinar filtros los aplica en AND', () async {
      await repo.insert(
          draft(category: 'Camiseta', seasons: {Season.summer}));
      await repo.insert(
          draft(category: 'Camiseta', seasons: {Season.winter}));
      await repo.insert(draft(category: 'Jean', seasons: {Season.summer}));

      final out = await repo
          .watchFiltered(const ClosetFilter(
            slots: {Slot.top},
            seasons: {Season.summer},
          ))
          .first;
      expect(out, hasLength(1));
    });

    test('un filtro vacío devuelve todo lo no archivado', () async {
      await repo.insert(draft());
      await repo.insert(draft());
      expect(
          await repo.watchFiltered(const ClosetFilter()).first, hasLength(2));
    });
  });

  group('ClosetFilter', () {
    test('copyWith conserva los campos que no se tocan', () {
      const f = ClosetFilter(
        slots: {Slot.top},
        seasons: {Season.summer},
        onlyFavorites: true,
        query: 'lino',
      );
      final next = f.copyWith(onlyFavorites: false);

      expect(next.slots, {Slot.top});
      expect(next.seasons, {Season.summer});
      expect(next.query, 'lino');
      expect(next.onlyFavorites, isFalse);
    });

    test('clearQuery distingue "no lo toques" de "quítalo"', () {
      const f = ClosetFilter(query: 'lino');
      expect(f.copyWith().query, 'lino');
      expect(f.copyWith(clearQuery: true).query, isNull);
    });

    test('toggle añade y quita', () {
      const f = ClosetFilter();
      final on = f.toggleSlot(Slot.top);
      expect(on.slots, {Slot.top});
      expect(on.toggleSlot(Slot.top).slots, isEmpty);
    });

    test('toggle no muta el conjunto original', () {
      const f = ClosetFilter(slots: {Slot.top});
      f.toggleSlot(Slot.shoes);
      expect(f.slots, {Slot.top});
    });

    test('activeCount cuenta criterios, no valores', () {
      const f = ClosetFilter(
        slots: {Slot.top, Slot.bottom, Slot.shoes},
        onlyFavorites: true,
      );
      expect(f.activeCount, 2);
      expect(const ClosetFilter().activeCount, 0);
      expect(const ClosetFilter().isEmpty, isTrue);
    });

    test('includeArchived no cuenta como filtro activo', () {
      // Es una preferencia de visualización, no un criterio de búsqueda.
      const f = ClosetFilter(includeArchived: true);
      expect(f.isEmpty, isTrue);
      expect(f.activeCount, 0);
    });
  });

  group('robustez', () {
    test('una paleta corrupta no revienta la carga', () async {
      final id = await repo.insert(draft());
      await db.customStatement(
        'UPDATE garments SET palette_json = ? WHERE id = ?',
        ['{no es json válido', id],
      );
      final g = await repo.findById(id);
      expect(g!.palette, isEmpty);
    });
  });
}
