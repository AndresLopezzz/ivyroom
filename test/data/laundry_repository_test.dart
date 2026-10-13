import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ivyroom/data/db/database.dart';
import 'package:ivyroom/data/repos/catalog_repository.dart';
import 'package:ivyroom/data/repos/garment_repository.dart';
import 'package:ivyroom/data/repos/laundry_repository.dart';
import 'package:ivyroom/domain/models/garment.dart';

void main() {
  late AppDatabase db;
  late GarmentRepository garments;
  late LaundryRepository laundry;
  late WashGroupRepository groups;
  late Map<String, int> catIds;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    garments = GarmentRepository(db);
    laundry = LaundryRepository(db, garments);
    groups = WashGroupRepository(db);
    catIds = {
      for (final c in await CatalogRepository(db).categories()) c.name: c.id,
    };
  });

  tearDown(() => db.close());

  Future<Garment> make(String category, {int? washGroupId}) async {
    final id = await garments.insert(GarmentDraft(
      imagePath: 'garments/a.png',
      thumbPath: 'garments/a_thumb.png',
      categoryId: catIds[category]!,
      dominantColorArgb: 0xFF1E5ADC,
      washGroupId: washGroupId,
    ));
    return (await garments.findById(id))!;
  }

  Future<Garment> reload(Garment g) async => (await garments.findById(g.id))!;

  final lunes = DateTime(2026, 8, 24);
  final jueves = DateTime(2026, 8, 27);

  group('grupos de lavado', () {
    test('vienen sembrados con los del usuario', () async {
      final all = await groups.all();
      expect(all.map((g) => g.name),
          containsAll(['Oscuros', 'Normal', 'Ropa pesada', 'Delicados']));
    });

    test('se pueden crear, renombrar y borrar', () async {
      final id = await groups.create('Toallas');
      expect((await groups.all()).map((g) => g.name), contains('Toallas'));

      final creado = (await groups.all()).firstWhere((g) => g.id == id);
      await groups.update(creado.copyWith(name: 'Blancos'));
      expect((await groups.all()).map((g) => g.name), contains('Blancos'));

      await groups.delete(id);
      expect((await groups.all()).map((g) => g.name), isNot(contains('Blancos')));
    });

    test('borrar un grupo NO borra las prendas, solo las desclasifica',
        () async {
      final id = await groups.create('Toallas');
      final g = await make('Camiseta', washGroupId: id);
      expect((await reload(g)).washGroup!.name, 'Toallas');

      await groups.delete(id);

      final after = await reload(g);
      expect(after, isNotNull);
      expect(after.washGroup, isNull);
    });

    test('cuenta cuántas prendas hay en un grupo', () async {
      final oscuros =
          (await groups.all()).firstWhere((g) => g.name == 'Oscuros');
      expect(await groups.garmentsIn(oscuros.id), 0);
      await make('Camiseta', washGroupId: oscuros.id);
      expect(await groups.garmentsIn(oscuros.id), 1);
    });
  });

  group('señal de prenda sucia', () {
    test('una prenda recién dada de alta no está sucia', () async {
      final g = await make('Camiseta');
      expect(g.needsWashing, isFalse);
    });

    test('usarla la ensucia', () async {
      final g = await make('Camiseta');
      await garments.markWorn(g.id, when: lunes);

      expect((await reload(g)).needsWashing, isTrue);
    });

    test('un accesorio usado no se marca como sucio', () async {
      final g = await make('Gorra');
      await garments.markWorn(g.id, when: lunes);

      expect((await reload(g)).needsWashing, isFalse);
    });

    test('lavarla la deja limpia', () async {
      final g = await make('Camiseta');
      await garments.markWorn(g.id, when: lunes);

      await laundry.record(jueves, [await reload(g)]);

      final after = await reload(g);
      expect(after.needsWashing, isFalse);
      expect(after.wearsSinceWash, 0);
    });

    test('usarla otra vez después de lavar la vuelve a ensuciar', () async {
      final g = await make('Camiseta');
      await garments.markWorn(g.id, when: lunes);
      await laundry.record(jueves, [await reload(g)]);

      await garments.markWorn(g.id, when: DateTime(2026, 8, 28));

      final after = await reload(g);
      expect(after.needsWashing, isTrue);
      expect(after.wearsSinceWash, 1);
    });

    test('lavar por la tarde limpia lo usado esa misma manana', () async {
      // El caso que rompia la version anterior: la lavada se guardaba a
      // medianoche, asi que un uso a las 09:00 del mismo dia salia como
      // posterior y la prenda seguia marcada como sucia despues de lavarla.
      final g = await make('Camiseta');
      await garments.markWorn(g.id, when: DateTime(2026, 8, 24, 9));

      await laundry.record(
        DateTime(2026, 8, 24),
        [await reload(g)],
        now: DateTime(2026, 8, 24, 20),
      );

      expect((await reload(g)).needsWashing, isFalse);
    });

    test('usarla por la noche tras lavar por la manana la ensucia', () async {
      final g = await make('Camiseta');
      await laundry.record(
        DateTime(2026, 8, 24),
        [g],
        now: DateTime(2026, 8, 24, 9),
      );

      await garments.markWorn(g.id, when: DateTime(2026, 8, 24, 22));

      expect((await reload(g)).needsWashing, isTrue);
    });

    test('una lavada de un dia pasado se da por hecha al final del dia',
        () async {
      // Sin hora conocida, lo que menos sorprende es asumir que se lavo
      // despues de haberlo usado ese dia.
      final g = await make('Camiseta');
      await garments.markWorn(g.id, when: DateTime(2026, 8, 20, 15));

      await laundry.record(
        DateTime(2026, 8, 20),
        [await reload(g)],
        now: DateTime(2026, 8, 27, 10),
      );

      expect((await reload(g)).needsWashing, isFalse);
    });

    test('una prenda usada pero nunca lavada cuenta como sucia', () async {
      final g = await make('Camiseta');
      await garments.markWorn(g.id, when: lunes);

      final after = await reload(g);
      expect(after.lastWashedAt, isNull);
      expect(after.needsWashing, isTrue);
    });
  });

  group('registrar una lavada', () {
    test('sube el contador y fija la fecha', () async {
      final a = await make('Camiseta');
      final b = await make('Jean');

      await laundry.record(lunes, [a, b]);

      expect((await reload(a)).washCount, 1);
      // Se guarda el momento real, no la medianoche del dia.
      expect(LaundryRepository.dayKey((await reload(a)).lastWashedAt!), lunes);
      expect((await reload(b)).washCount, 1);
    });

    test('dos lavadas en días distintos suman dos', () async {
      final g = await make('Camiseta');

      await laundry.record(lunes, [g]);
      await laundry.record(jueves, [g]);

      final after = await reload(g);
      expect(after.washCount, 2);
      expect(LaundryRepository.dayKey(after.lastWashedAt!), jueves);
    });

    test('la hora no importa: un día es un día', () async {
      final g = await make('Camiseta');
      await laundry.record(DateTime(2026, 8, 24, 9, 30), [g]);

      expect(await laundry.forDay(DateTime(2026, 8, 24, 21)), isNotNull);
      expect((await reload(g)).washCount, 1);
    });

    test('regrabar el mismo día reemplaza, no acumula', () async {
      final g = await make('Camiseta');

      await laundry.record(lunes, [g]);
      await laundry.record(lunes, [g]);

      // El contador se recalcula desde el historial, así que no se infla.
      expect((await reload(g)).washCount, 1);
    });

    test('quitar una prenda de una lavada le baja el contador', () async {
      // Es la razón de recalcular en vez de incrementar a mano: si se sumara
      // al guardar, editar dejaría el contador inflado para siempre.
      final a = await make('Camiseta');
      final b = await make('Jean');
      await laundry.record(lunes, [a, b]);
      expect((await reload(b)).washCount, 1);

      await laundry.record(lunes, [a]);

      expect((await reload(a)).washCount, 1);
      expect((await reload(b)).washCount, 0);
      expect((await reload(b)).lastWashedAt, isNull);
    });

    test('borrar el día deshace las lavadas de sus prendas', () async {
      final g = await make('Camiseta');
      await laundry.record(lunes, [g]);
      await laundry.record(jueves, [g]);

      await laundry.deleteDay(jueves);

      final after = await reload(g);
      expect(after.washCount, 1);
      expect(LaundryRepository.dayKey(after.lastWashedAt!), lunes);
    });

    test('guarda las notas de la tanda', () async {
      final g = await make('Camiseta');
      await laundry.record(lunes, [g], notes: 'Agua fría');

      expect((await laundry.forDay(lunes))!.notes, 'Agua fría');
    });

    test('resume la tanda por grupo de lavado', () async {
      final all = await groups.all();
      final oscuros = all.firstWhere((g) => g.name == 'Oscuros').id;
      final pesada = all.firstWhere((g) => g.name == 'Ropa pesada').id;

      await laundry.record(lunes, [
        await make('Camiseta', washGroupId: oscuros),
        await make('Camisa', washGroupId: oscuros),
        await make('Jean', washGroupId: pesada),
      ]);

      final day = await laundry.forDay(lunes);
      expect(day!.byGroup, {'Oscuros': 2, 'Ropa pesada': 1});
    });

    test('las prendas sin grupo salen como sin clasificar', () async {
      await laundry.record(lunes, [await make('Camiseta')]);
      expect((await laundry.forDay(lunes))!.byGroup, {'Sin clasificar': 1});
    });
  });

  group('candidatas a lavar', () {
    test('las sucias van primero', () async {
      final limpia = await make('Camiseta');
      final sucia = await make('Jean');
      await garments.markWorn(sucia.id, when: lunes);

      final list = await laundry.candidates(today: jueves);

      expect(list.first.garment.id, sucia.id);
      expect(list.first.dirty, isTrue);
      expect(list.last.garment.id, limpia.id);
      expect(list.last.dirty, isFalse);
    });

    test('entre las sucias, primero la que lleva más sin lavarse', () async {
      final vieja = await make('Camiseta');
      final reciente = await make('Camisa');
      await laundry.record(DateTime(2026, 6, 1), [vieja]);
      await laundry.record(DateTime(2026, 8, 20), [reciente]);
      await garments.markWorn(vieja.id, when: jueves);
      await garments.markWorn(reciente.id, when: jueves);

      final list = await laundry.candidates(today: DateTime(2026, 8, 28));

      expect(list.first.garment.id, vieja.id);
    });

    test('lo que nunca se ha lavado va antes que lo lavado hace mucho',
        () async {
      final nunca = await make('Camiseta');
      final haceMucho = await make('Camisa');
      await laundry.record(DateTime(2026, 1, 1), [haceMucho]);
      await garments.markWorn(nunca.id, when: jueves);
      await garments.markWorn(haceMucho.id, when: jueves);

      final list = await laundry.candidates(today: DateTime(2026, 8, 28));

      expect(list.first.garment.id, nunca.id);
    });

    test('trae los días desde el último uso y la última lavada', () async {
      final g = await make('Camiseta');
      await laundry.record(DateTime(2026, 8, 20), [g]);
      await garments.markWorn(g.id, when: DateTime(2026, 8, 25));

      final c = (await laundry.candidates(today: DateTime(2026, 8, 28)))
          .firstWhere((c) => c.garment.id == g.id);

      expect(c.daysSinceWashed, 8);
      expect(c.daysSinceWorn, 3);
    });

    test('una prenda sin usar ni lavar no trae días', () async {
      await make('Camiseta');
      final c = (await laundry.candidates(today: jueves)).single;

      expect(c.daysSinceWorn, isNull);
      expect(c.daysSinceWashed, isNull);
      expect(c.dirty, isFalse);
    });

    test('no ofrece prendas archivadas', () async {
      final g = await make('Camiseta');
      await garments.setArchived(g.id, true);

      expect(await laundry.candidates(today: jueves), isEmpty);
    });
  });

  group('desgaste', () {
    test('usos por lavada mide cuánto aguanta la prenda', () async {
      final g = await make('Camiseta');
      for (final d in [1, 2, 3, 4, 5, 6]) {
        await garments.markWorn(g.id, when: DateTime(2026, 8, d));
      }
      await laundry.record(DateTime(2026, 8, 7), [await reload(g)]);
      await laundry.record(DateTime(2026, 8, 14), [await reload(g)]);

      final after = await reload(g);
      expect(after.wearCount, 6);
      expect(after.washCount, 2);
      expect(after.wearsPerWash, 3);
    });

    test('sin lavadas no hay ratio', () async {
      final g = await make('Camiseta');
      await garments.markWorn(g.id, when: lunes);

      expect((await reload(g)).wearsPerWash, isNull);
    });
  });

  group('historial', () {
    test('lista las tandas de la más reciente a la más antigua', () async {
      final g = await make('Camiseta');
      await laundry.record(lunes, [g]);
      await laundry.record(jueves, [g]);

      final all = await laundry.watchAll().first;
      expect(all.map((d) => d.day), [jueves, lunes]);
    });

    test('los días con lavada de un rango alimentan el calendario', () async {
      final g = await make('Camiseta');
      await laundry.record(lunes, [g]);
      await laundry.record(DateTime(2026, 9, 5), [g]);

      final days = await laundry
          .watchDaysInRange(DateTime(2026, 8, 24), DateTime(2026, 8, 30))
          .first;

      expect(days, {lunes});
    });

    test('borrar una prenda la quita del historial sin romperlo', () async {
      final a = await make('Camiseta');
      final b = await make('Jean');
      await laundry.record(lunes, [a, b]);

      await garments.delete(a.id);

      final day = await laundry.forDay(lunes);
      expect(day, isNotNull);
      expect(day!.items.map((g) => g.id), [b.id]);
    });
  });
}
