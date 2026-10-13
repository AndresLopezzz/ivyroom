import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ivyroom/data/db/database.dart';
import 'package:ivyroom/data/repos/catalog_repository.dart';
import 'package:ivyroom/data/repos/garment_repository.dart';
import 'package:ivyroom/data/repos/outfit_repository.dart';
import 'package:ivyroom/data/repos/plan_repository.dart';
import 'package:ivyroom/domain/models/garment.dart';
import 'package:ivyroom/domain/models/outfit.dart';

void main() {
  late AppDatabase db;
  late GarmentRepository garments;
  late OutfitRepository outfits;
  late PlanRepository plans;
  late Map<String, int> catIds;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    garments = GarmentRepository(db);
    outfits = OutfitRepository(db, garments);
    plans = PlanRepository(db, garments, outfits);
    catIds = {
      for (final c in await CatalogRepository(db).categories()) c.name: c.id,
    };
  });

  tearDown(() => db.close());

  Future<Garment> make(String category) async {
    final id = await garments.insert(GarmentDraft(
      imagePath: 'garments/a.png',
      thumbPath: 'garments/a_thumb.png',
      categoryId: catIds[category]!,
      dominantColorArgb: 0xFF1E5ADC,
    ));
    return (await garments.findById(id))!;
  }

  Future<SavedOutfit> makeOutfit(List<Garment> items, String name) async {
    final id = await outfits.save(items, name: name);
    return (await outfits.watchAll().first).firstWhere((o) => o.id == id);
  }

  final martes = DateTime(2026, 9, 8);
  final miercoles = DateTime(2026, 9, 9);

  group('dayKey', () {
    test('normaliza a medianoche', () {
      expect(PlanRepository.dayKey(DateTime(2026, 9, 8, 23, 59, 59)),
          DateTime(2026, 9, 8));
    });
  });

  group('varias opciones por día', () {
    test('un día sin planes no devuelve nada', () async {
      expect(await plans.forDay(martes), isEmpty);
    });

    test('se pueden apilar varias opciones el mismo día', () async {
      // Es el cambio central: planificar es barajar alternativas, no
      // comprometerse a una sola.
      final a = await make('Camiseta');
      final b = await make('Camisa');
      final bottom = await make('Jean');

      await plans.addPlan(martes, garments: [a, bottom]);
      await plans.addPlan(martes, garments: [b, bottom]);

      final day = await plans.forDay(martes);
      expect(day, hasLength(2));
    });

    test('replaceDay deja una sola opción', () async {
      final a = await make('Camiseta');
      final b = await make('Camisa');
      await plans.addPlan(martes, garments: [a]);
      await plans.addPlan(martes, garments: [a]);

      await plans.replaceDay(martes, garments: [b]);

      final day = await plans.forDay(martes);
      expect(day, hasLength(1));
      expect(day.single.items.map((g) => g.id), [b.id]);
    });

    test('quitar una opción no toca las demás', () async {
      final a = await make('Camiseta');
      final b = await make('Camisa');
      final first = await plans.addPlan(martes, garments: [a]);
      await plans.addPlan(martes, garments: [b]);

      await plans.removePlan(first);

      final day = await plans.forDay(martes);
      expect(day, hasLength(1));
      expect(day.single.items.map((g) => g.id), [b.id]);
    });

    test('planificar un outfit guardado', () async {
      final top = await make('Camiseta');
      final shoes = await make('Tenis');
      final outfit = await makeOutfit([top, shoes], 'Para clase');

      await plans.addPlan(martes, outfit: outfit);

      final plan = (await plans.forDay(martes)).single;
      expect(plan.outfit!.name, 'Para clase');
      expect(plan.title, 'Para clase');
      expect(plan.items.map((g) => g.id), containsAll([top.id, shoes.id]));
    });

    test('la hora no importa al consultar', () async {
      final top = await make('Camiseta');
      await plans.addPlan(DateTime(2026, 9, 8, 7, 30), garments: [top]);

      expect(await plans.forDay(DateTime(2026, 9, 8, 22)), hasLength(1));
    });

    test('borrar el día se lleva todas sus opciones', () async {
      final a = await make('Camiseta');
      await plans.addPlan(martes, garments: [a]);
      await plans.addPlan(martes, garments: [a]);

      await plans.clearDay(martes);

      expect(await plans.forDay(martes), isEmpty);
    });
  });

  group('marcar lo que se llevó', () {
    test('propaga el uso a las prendas del plan', () async {
      final top = await make('Camiseta');
      final bottom = await make('Jean');
      final id = await plans.addPlan(martes, garments: [top, bottom]);

      await plans.markWorn(id);

      expect((await garments.findById(top.id))!.wearCount, 1);
      expect((await garments.findById(bottom.id))!.wearCount, 1);
      expect((await garments.findById(top.id))!.lastWornAt, martes);
      expect((await plans.forDay(martes)).single.wasWorn, isTrue);
    });

    test('marcar una desmarca las otras del mismo día', () async {
      // Solo se puede llevar un conjunto a la vez; permitir dos falsearía el
      // historial que usa el motor para no repetir.
      final a = await make('Camiseta');
      final b = await make('Camisa');
      final first = await plans.addPlan(martes, garments: [a]);
      final second = await plans.addPlan(martes, garments: [b]);

      await plans.markWorn(first);
      await plans.markWorn(second);

      final day = await plans.forDay(martes);
      expect(day.where((p) => p.wasWorn).map((p) => p.id), [second]);
    });

    test('marcar dos veces no cuenta doble', () async {
      final top = await make('Camiseta');
      final id = await plans.addPlan(martes, garments: [top]);

      await plans.markWorn(id);
      await plans.markWorn(id);

      expect((await garments.findById(top.id))!.wearCount, 1);
    });

    test('con un outfit guardado propaga a outfit y prendas', () async {
      final top = await make('Camiseta');
      final outfit = await makeOutfit([top], 'X');
      final id = await plans.addPlan(martes, outfit: outfit);

      await plans.markWorn(id);

      expect((await outfits.watchAll().first).single.wearCount, 1);
      expect((await garments.findById(top.id))!.wearCount, 1);
    });

    test('desmarcar permite volver a marcar', () async {
      final top = await make('Camiseta');
      final id = await plans.addPlan(martes, garments: [top]);

      await plans.markWorn(id);
      await plans.unmarkWorn(id);
      expect((await plans.forDay(martes)).single.wasWorn, isFalse);

      await plans.markWorn(id);
      expect((await garments.findById(top.id))!.wearCount, 2);
    });
  });

  group('historial para el motor', () {
    test('solo cuenta lo marcado como puesto', () async {
      // Lo planificado y no confirmado es una intención, no un hecho:
      // tratarlo como hecho descartaría ropa que nunca llegaste a sacar.
      final a = await make('Camiseta');
      final b = await make('Camisa');
      await plans.addPlan(martes, garments: [a]);
      final worn = await plans.addPlan(miercoles, garments: [b]);
      await plans.markWorn(worn);

      final history = await plans.wearHistory();

      expect(history.entries, hasLength(1));
      expect(history.entries.single.garmentIds, {b.id});
    });

    test('recuerda el día en que se llevó cada conjunto', () async {
      final top = await make('Camiseta');
      final bottom = await make('Jean');
      final id = await plans.addPlan(martes, garments: [top, bottom]);
      await plans.markWorn(id);

      final history = await plans.wearHistory();

      expect(history.daysSinceCombo([top.id, bottom.id], miercoles), 1);
      expect(
        history.daysSinceComboOnWeekday(
            [top.id, bottom.id], DateTime.tuesday, DateTime(2026, 9, 15)),
        7,
      );
    });

    test('no mira más atrás del plazo pedido', () async {
      final top = await make('Camiseta');
      final viejo = DateTime.now().subtract(const Duration(days: 200));
      final id = await plans.addPlan(viejo, garments: [top]);
      await plans.markWorn(id);

      expect((await plans.wearHistory(lastDays: 30)).entries, isEmpty);
      expect((await plans.wearHistory(lastDays: 365)).entries, hasLength(1));
    });

    test('sin nada marcado el historial está vacío', () async {
      expect((await plans.wearHistory()).entries, isEmpty);
    });
  });

  group('planificar varios días', () {
    test('deja un plan por día', () async {
      final a = await make('Camiseta');
      final b = await make('Camisa');

      await plans.planDays({
        martes: [a],
        miercoles: [b],
      });

      expect((await plans.forDay(martes)).single.items.map((g) => g.id),
          [a.id]);
      expect((await plans.forDay(miercoles)).single.items.map((g) => g.id),
          [b.id]);
    });

    test('reemplaza lo que hubiera en esos días', () async {
      final a = await make('Camiseta');
      final b = await make('Camisa');
      await plans.addPlan(martes, garments: [a]);
      await plans.addPlan(martes, garments: [a]);

      await plans.planDays({
        martes: [b],
      });

      final day = await plans.forDay(martes);
      expect(day, hasLength(1));
      expect(day.single.items.map((g) => g.id), [b.id]);
    });

    test('un día sin prendas se salta, no borra lo que había', () async {
      final a = await make('Camiseta');
      await plans.addPlan(martes, garments: [a]);

      await plans.planDays({martes: const []});

      expect(await plans.forDay(martes), hasLength(1));
    });
  });

  group('rango de fechas', () {
    test('devuelve los planes ordenados por día', () async {
      final top = await make('Camiseta');
      await plans.addPlan(miercoles, garments: [top]);
      await plans.addPlan(martes, garments: [top]);

      final week = await plans
          .watchRange(DateTime(2026, 9, 7), DateTime(2026, 9, 13))
          .first;

      expect(week.map((p) => p.day), [martes, miercoles]);
    });

    test('dentro de un día, lo llevado puesto va primero', () async {
      final a = await make('Camiseta');
      final b = await make('Camisa');
      await plans.addPlan(martes, garments: [a]);
      final second = await plans.addPlan(martes, garments: [b]);
      await plans.markWorn(second);

      final day = await plans.watchRange(martes, martes).first;
      expect(day.first.id, second);
    });

    test('excluye lo que cae fuera del rango', () async {
      final top = await make('Camiseta');
      await plans.addPlan(DateTime(2026, 9, 1), garments: [top]);
      await plans.addPlan(martes, garments: [top]);

      final week = await plans
          .watchRange(DateTime(2026, 9, 7), DateTime(2026, 9, 13))
          .first;
      expect(week, hasLength(1));
    });
  });

  group('robustez', () {
    test('borrar una prenda la quita del plan sin romperlo', () async {
      final a = await make('Camiseta');
      final b = await make('Jean');
      await plans.addPlan(martes, garments: [a, b]);

      await garments.delete(a.id);

      final plan = (await plans.forDay(martes)).single;
      expect(plan.items.map((g) => g.id), [b.id]);
    });

    test('borrar el outfit deja el plan vacío pero visible', () async {
      final top = await make('Camiseta');
      final outfit = await makeOutfit([top], 'X');
      await plans.addPlan(martes, outfit: outfit);

      await outfits.delete(outfit.id);

      final plan = (await plans.forDay(martes)).single;
      expect(plan.outfit, isNull);
      expect(plan.items, isEmpty);
    });
  });

  group('foto del look', () {
    test('se guarda y devuelve la anterior para borrarla', () async {
      final a = await make('Camiseta');
      await plans.addPlan(martes, garments: [a]);
      final plan = (await plans.forDay(martes)).single;

      expect(await plans.setPhoto(plan.id, 'garments/look_1.webp'), isNull);
      expect(await plans.setPhoto(plan.id, 'garments/look_2.webp'),
          'garments/look_1.webp');

      expect((await plans.forDay(martes)).single.photoPath,
          'garments/look_2.webp');
      // El barrido de huerfanos tiene que verla como referenciada.
      expect(await plans.allPhotoPaths(), {'garments/look_2.webp'});
    });
  });
}
