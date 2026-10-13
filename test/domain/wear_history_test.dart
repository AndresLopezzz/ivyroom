import 'package:flutter_test/flutter_test.dart';
import 'package:ivyroom/domain/models/outfit.dart';
import 'package:ivyroom/domain/outfit/outfit_engine.dart';
import 'package:ivyroom/domain/outfit/wear_history.dart';

import '../support/catalog_fixtures.dart';

/// Un lunes, para que los tests de "mismo día de la semana" sean legibles.
final _lunes = DateTime(2026, 9, 7);
DateTime _now() => _lunes;

WearEntry worn(DateTime day, List<int> ids) =>
    WearEntry(day: day, garmentIds: ids.toSet());

void main() {
  setUp(resetGarmentIds);

  group('WearHistory', () {
    test('sin historial no sabe nada', () {
      expect(WearHistory.empty.daysSinceCombo([1, 2], _lunes), isNull);
      expect(WearHistory.empty.timesWorn([1, 2]), 0);
    });

    test('la clave no depende del orden de las prendas', () {
      final h = WearHistory([worn(_lunes, [3, 1, 2])]);
      expect(h.daysSinceCombo([1, 2, 3], _lunes), 0);
      expect(h.daysSinceCombo([2, 3, 1], _lunes), 0);
    });

    test('un conjunto distinto no cuenta como el mismo', () {
      final h = WearHistory([worn(_lunes, [1, 2, 3])]);
      expect(h.daysSinceCombo([1, 2], _lunes), isNull);
      expect(h.daysSinceCombo([1, 2, 4], _lunes), isNull);
    });

    test('cuenta los días desde la última vez, no desde la primera', () {
      final h = WearHistory([
        worn(_lunes.subtract(const Duration(days: 30)), [1, 2]),
        worn(_lunes.subtract(const Duration(days: 3)), [1, 2]),
      ]);
      expect(h.daysSinceCombo([1, 2], _lunes), 3);
    });

    test('la hora del día no cuenta como un día más', () {
      final h = WearHistory([worn(DateTime(2026, 9, 6, 23, 30), [1, 2])]);
      expect(h.daysSinceCombo([1, 2], DateTime(2026, 9, 7, 8)), 1);
    });

    test('cuenta las veces que se ha llevado', () {
      final h = WearHistory([
        worn(_lunes.subtract(const Duration(days: 7)), [1, 2]),
        worn(_lunes.subtract(const Duration(days: 14)), [1, 2]),
        worn(_lunes, [3, 4]),
      ]);
      expect(h.timesWorn([1, 2]), 2);
      expect(h.timesWorn([3, 4]), 1);
    });

    group('mismo día de la semana', () {
      test('encuentra la última vez que cayó en ese día', () {
        final h = WearHistory([
          worn(_lunes.subtract(const Duration(days: 7)), [1, 2]), // lunes
          worn(_lunes.subtract(const Duration(days: 3)), [1, 2]), // viernes
        ]);

        expect(h.daysSinceComboOnWeekday([1, 2], DateTime.monday, _lunes), 7);
      });

      test('ignora las veces que cayó en otro día', () {
        final h = WearHistory([
          worn(_lunes.subtract(const Duration(days: 3)), [1, 2]), // viernes
        ]);

        expect(h.daysSinceComboOnWeekday([1, 2], DateTime.monday, _lunes),
            isNull);
      });

      test('devuelve la más reciente de ese día de la semana', () {
        final h = WearHistory([
          worn(_lunes.subtract(const Duration(days: 21)), [1, 2]),
          worn(_lunes.subtract(const Duration(days: 7)), [1, 2]),
        ]);

        expect(h.daysSinceComboOnWeekday([1, 2], DateTime.monday, _lunes), 7);
      });
    });
  });

  group('el motor no repite', () {
    const engine = RuleOutfitEngine(now: _now);

    test('penaliza el conjunto llevado ayer', () {
      final top = garment(Cat.tshirt, white);
      final bottom = garment(Cat.jeans, blue);
      final shoes = garment(Cat.sneakers, grey);
      final wardrobe = [top, bottom, shoes];
      final combo = [top.id, bottom.id, shoes.id];

      final fresh = engine.scoreOne(wardrobe);
      final repeated = engine.scoreOne(
        wardrobe,
        history: WearHistory([
          worn(_lunes.subtract(const Duration(days: 1)), combo),
        ]),
      );

      expect(repeated.score, lessThan(fresh.score));
      expect(repeated.reasons, contains(contains('hace 1 día')));
    });

    test('penaliza mas fuerte el mismo dia de la semana', () {
      final top = garment(Cat.tshirt, white);
      final bottom = garment(Cat.jeans, blue);
      final shoes = garment(Cat.sneakers, grey);
      final wardrobe = [top, bottom, shoes];
      final combo = [top.id, bottom.id, shoes.id];

      // Hace 7 dias: dentro del plazo de dia de la semana y del de repeticion.
      final sameWeekday = engine.scoreOne(
        wardrobe,
        history: WearHistory([
          worn(_lunes.subtract(const Duration(days: 7)), combo),
        ]),
      );
      // Hace 8 dias: mismo plazo de repeticion, pero otro dia de la semana.
      final otherWeekday = engine.scoreOne(
        wardrobe,
        history: WearHistory([
          worn(_lunes.subtract(const Duration(days: 8)), combo),
        ]),
      );

      expect(sameWeekday.score, lessThan(otherWeekday.score));
      expect(sameWeekday.reasons, contains(contains('otro lunes')));
    });

    test('un conjunto viejo ya no penaliza', () {
      final top = garment(Cat.tshirt, white);
      final bottom = garment(Cat.jeans, blue);
      final shoes = garment(Cat.sneakers, grey);
      final wardrobe = [top, bottom, shoes];

      final fresh = engine.scoreOne(wardrobe);
      final old = engine.scoreOne(
        wardrobe,
        history: WearHistory([
          worn(_lunes.subtract(const Duration(days: 120)),
              [top.id, bottom.id, shoes.id]),
        ]),
      );

      expect(old.score, fresh.score);
      expect(old.reasons, isNot(contains(contains('llevaste'))));
    });

    test('prefiere el conjunto no repetido al generar', () {
      final top = garment(Cat.tshirt, white);
      final bottomA = garment(Cat.jeans, black);
      final bottomB = garment(Cat.trousers, black);
      final shoes = garment(Cat.sneakers, grey);
      final wardrobe = [top, bottomA, bottomB, shoes];

      final out = engine.generate(
        wardrobe,
        const OutfitRequest(count: 5),
        history: WearHistory([
          worn(_lunes.subtract(const Duration(days: 1)),
              [top.id, bottomA.id, shoes.id]),
        ]),
      );

      // El mejor no deberia ser el que se llevo ayer.
      final best = out.first.items.map((g) => g.id).toSet();
      expect(best, isNot({top.id, bottomA.id, shoes.id}));
    });

    test('desactivar los plazos quita la penalizacion', () {
      final top = garment(Cat.tshirt, white);
      final bottom = garment(Cat.jeans, blue);
      final shoes = garment(Cat.sneakers, grey);
      final wardrobe = [top, bottom, shoes];
      final history = WearHistory([
        worn(_lunes.subtract(const Duration(days: 1)),
            [top.id, bottom.id, shoes.id]),
      ]);

      final penalized = engine.scoreOne(wardrobe, history: history);
      final ignored = engine.scoreOne(
        wardrobe,
        history: history,
        req: const OutfitRequest(
            avoidRepeatDays: 0, avoidSameWeekdayDays: 0),
      );

      expect(ignored.score, greaterThan(penalized.score));
    });
  });

  group('planificar otro dia', () {
    const engine = RuleOutfitEngine(now: _now);

    test('juzga el dia de la semana del dia pedido, no el de hoy', () {
      final top = garment(Cat.tshirt, white);
      final bottom = garment(Cat.jeans, blue);
      final shoes = garment(Cat.sneakers, grey);
      final wardrobe = [top, bottom, shoes];
      final combo = [top.id, bottom.id, shoes.id];

      // Historial: se llevo el martes pasado.
      final history = WearHistory([
        worn(DateTime(2026, 9, 1), combo), // martes
      ]);

      // Pedido para el martes que viene: deberia avisar.
      final forTuesday = engine.scoreOne(
        wardrobe,
        history: history,
        req: OutfitRequest(forDay: DateTime(2026, 9, 8)),
      );
      expect(forTuesday.reasons, contains(contains('otro martes')));

      // Pedido para el miercoles: mismo conjunto, pero otro dia.
      final forWednesday = engine.scoreOne(
        wardrobe,
        history: history,
        req: OutfitRequest(forDay: DateTime(2026, 9, 9)),
      );
      expect(forWednesday.reasons, isNot(contains(contains('otro'))));
    });
  });
}
