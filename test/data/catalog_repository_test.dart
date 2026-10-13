import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ivyroom/data/db/database.dart';
import 'package:ivyroom/data/repos/catalog_repository.dart';
import 'package:ivyroom/data/repos/garment_repository.dart';
import 'package:ivyroom/domain/models/catalog.dart';

void main() {
  late AppDatabase db;
  late CatalogRepository catalog;
  late GarmentRepository garments;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    catalog = CatalogRepository(db);
    garments = GarmentRepository(db);
  });

  tearDown(() => db.close());

  Future<Category> categoryNamed(String name) async =>
      (await catalog.categories()).firstWhere((c) => c.name == name);

  Future<int> insertGarment(int categoryId) => garments.insert(GarmentDraft(
        imagePath: 'garments/a.png',
        thumbPath: 'garments/a_thumb.png',
        categoryId: categoryId,
        dominantColorArgb: 0xFF1E5ADC,
      ));

  group('crear categorías', () {
    test('una categoría nueva queda atada a su ranura', () async {
      final id = await catalog.createCategory(
        name: 'Ruana',
        slot: Slot.outer,
        formality: 2,
        warmth: 4,
      );

      final c = (await catalog.categories()).firstWhere((c) => c.id == id);
      expect(c.name, 'Ruana');
      expect(c.slot, Slot.outer);
      expect(c.warmth, 4);
      expect(c.isBuiltIn, isFalse);
    });

    test('la prenda con una categoría nueva hereda su ranura', () async {
      final id = await catalog.createCategory(name: 'Ruana', slot: Slot.outer);
      final gid = await insertGarment(id);

      final g = await garments.findById(gid);
      expect(g!.slot, Slot.outer);
    });

    test('recorta los espacios del nombre', () async {
      final id =
          await catalog.createCategory(name: '  Ruana  ', slot: Slot.outer);
      final c = (await catalog.categories()).firstWhere((c) => c.id == id);
      expect(c.name, 'Ruana');
    });

    test('no admite dos categorías con el mismo nombre', () async {
      await catalog.createCategory(name: 'Ruana', slot: Slot.outer);
      await expectLater(
        catalog.createCategory(name: 'Ruana', slot: Slot.top),
        throwsA(anything),
      );
    });

    test('las nuevas van al final del orden', () async {
      await catalog.createCategory(name: 'Ruana', slot: Slot.outer);
      final all = await catalog.watchCategories().first;
      expect(all.last.name, 'Ruana');
    });
  });

  group('editar categorías', () {
    test('renombrar no rompe el vínculo con las prendas', () async {
      final tenis = await categoryNamed('Tenis');
      final gid = await insertGarment(tenis.id);

      await catalog.updateCategory(tenis.copyWith(name: 'Zapatos de goma'));

      final g = await garments.findById(gid);
      expect(g!.category.name, 'Zapatos de goma');
      expect(g.slot, Slot.shoes);
    });

    test('cambiar la ranura recoloca la prenda en el motor', () async {
      final gorra = await categoryNamed('Gorra');
      final gid = await insertGarment(gorra.id);
      expect((await garments.findById(gid))!.slot, Slot.accessory);

      await catalog.updateCategory(gorra.copyWith(slot: Slot.top));

      expect((await garments.findById(gid))!.slot, Slot.top);
    });

    test('se puede renombrar una categoría semilla', () async {
      // "Buzo" no se dice igual en todas partes: el usuario manda.
      final buzo = await categoryNamed('Buzo');
      expect(buzo.isBuiltIn, isTrue);

      await catalog.updateCategory(buzo.copyWith(name: 'Sudadera'));
      expect((await categoryNamed('Sudadera')).id, buzo.id);
    });
  });

  group('borrar categorías', () {
    test('borrar una categoría vacía la quita del catálogo', () async {
      final id = await catalog.createCategory(name: 'Ruana', slot: Slot.outer);
      await catalog.deleteCategory(id);

      final names = (await catalog.categories()).map((c) => c.name);
      expect(names, isNot(contains('Ruana')));
    });

    test('borrar una categoría en uso NO borra las prendas', () async {
      // Perder ropa por reorganizar el catálogo sería inaceptable.
      final tenis = await categoryNamed('Tenis');
      final gid = await insertGarment(tenis.id);

      await catalog.deleteCategory(tenis.id);

      final g = await garments.findById(gid);
      expect(g, isNotNull);
      expect(g!.category.name, CatalogSeed.fallbackCategory);
    });

    test('se puede elegir a qué categoría se reasignan', () async {
      final tenis = await categoryNamed('Tenis');
      final zapatos = await categoryNamed('Zapatos');
      final gid = await insertGarment(tenis.id);

      await catalog.deleteCategory(tenis.id, reassignTo: zapatos.id);

      expect((await garments.findById(gid))!.category.name, 'Zapatos');
    });

    test('con force falso avisa en vez de borrar', () async {
      final tenis = await categoryNamed('Tenis');
      await insertGarment(tenis.id);
      await insertGarment(tenis.id);

      await expectLater(
        catalog.deleteCategory(tenis.id, force: false),
        throwsA(isA<CatalogInUseException>()
            .having((e) => e.garmentCount, 'prendas', 2)),
      );
      expect((await catalog.categories()).map((c) => c.name),
          contains('Tenis'));
    });

    test('la categoría de respaldo se recrea si se borró', () async {
      final fallback = await categoryNamed(CatalogSeed.fallbackCategory);
      await catalog.deleteCategory(fallback.id);

      // Ahora se borra una categoría con prendas: tiene que haber destino.
      final tenis = await categoryNamed('Tenis');
      final gid = await insertGarment(tenis.id);
      await catalog.deleteCategory(tenis.id);

      expect((await garments.findById(gid))!.category.name,
          CatalogSeed.fallbackCategory);
    });

    test('garmentsInCategory cuenta lo que hay dentro', () async {
      final tenis = await categoryNamed('Tenis');
      expect(await catalog.garmentsInCategory(tenis.id), 0);
      await insertGarment(tenis.id);
      expect(await catalog.garmentsInCategory(tenis.id), 1);
    });
  });

  group('ocasiones', () {
    test('crear y usar una ocasión propia', () async {
      final id = await catalog.createOccasion(name: 'Universidad', formality: 1);
      final tenis = await categoryNamed('Tenis');

      final gid = await garments.insert(GarmentDraft(
        imagePath: 'a.png',
        thumbPath: 'b.png',
        categoryId: tenis.id,
        dominantColorArgb: 0xFF1E5ADC,
        occasionIds: {id},
      ));

      final g = await garments.findById(gid);
      expect(g!.occasions.single.name, 'Universidad');
      expect(g.occasions.single.formality, 1);
    });

    test('borrar una ocasión desetiqueta las prendas pero no las borra',
        () async {
      final id = await catalog.createOccasion(name: 'Universidad');
      final tenis = await categoryNamed('Tenis');
      final gid = await garments.insert(GarmentDraft(
        imagePath: 'a.png',
        thumbPath: 'b.png',
        categoryId: tenis.id,
        dominantColorArgb: 0xFF1E5ADC,
        occasionIds: {id},
      ));

      await catalog.deleteOccasion(id);

      final g = await garments.findById(gid);
      expect(g, isNotNull);
      expect(g!.occasions, isEmpty);
    });

    test('renombrar una ocasión se refleja en las prendas', () async {
      final all = await catalog.watchOccasions().first;
      final trabajo = all.firstWhere((o) => o.name == 'Trabajo');
      final tenis = await categoryNamed('Tenis');
      final gid = await garments.insert(GarmentDraft(
        imagePath: 'a.png',
        thumbPath: 'b.png',
        categoryId: tenis.id,
        dominantColorArgb: 0xFF1E5ADC,
        occasionIds: {trabajo.id},
      ));

      await catalog.updateOccasion(trabajo.copyWith(name: 'Oficina'));

      expect((await garments.findById(gid))!.occasions.single.name, 'Oficina');
    });
  });

  group('moods', () {
    test('crear, usar y borrar un mood propio', () async {
      final id = await catalog.createMood('Playero');
      final tenis = await categoryNamed('Tenis');
      final gid = await garments.insert(GarmentDraft(
        imagePath: 'a.png',
        thumbPath: 'b.png',
        categoryId: tenis.id,
        dominantColorArgb: 0xFF1E5ADC,
        moodIds: {id},
      ));

      expect((await garments.findById(gid))!.moods.single.name, 'Playero');

      await catalog.deleteMood(id);
      expect((await garments.findById(gid))!.moods, isEmpty);
    });
  });

  group('tags', () {
    test('pruneOrphanTags limpia los que ya no cuelgan de nada', () async {
      final tenis = await categoryNamed('Tenis');
      final gid = await garments.insert(GarmentDraft(
        imagePath: 'a.png',
        thumbPath: 'b.png',
        categoryId: tenis.id,
        dominantColorArgb: 0xFF1E5ADC,
        tags: {'playa', 'verano'},
      ));

      expect(await catalog.watchTags().first, hasLength(2));

      await garments.delete(gid);
      await catalog.pruneOrphanTags();

      expect(await catalog.watchTags().first, isEmpty);
    });

    test('no borra tags que siguen en uso por otra prenda', () async {
      final tenis = await categoryNamed('Tenis');
      GarmentDraft d(Set<String> tags) => GarmentDraft(
            imagePath: 'a.png',
            thumbPath: 'b.png',
            categoryId: tenis.id,
            dominantColorArgb: 0xFF1E5ADC,
            tags: tags,
          );

      final a = await garments.insert(d({'playa'}));
      await garments.insert(d({'playa', 'verano'}));

      await garments.delete(a);
      await catalog.pruneOrphanTags();

      expect((await catalog.watchTags().first).map((t) => t.name),
          containsAll(['playa', 'verano']));
    });
  });
}
