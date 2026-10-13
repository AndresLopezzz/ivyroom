import 'package:flutter_test/flutter_test.dart';
import 'package:ivyroom/domain/models/catalog.dart';
import 'package:ivyroom/domain/models/garment.dart';
import 'package:ivyroom/domain/models/outfit.dart';
import 'package:ivyroom/domain/outfit/outfit_engine.dart';

import '../support/catalog_fixtures.dart';

final _today = DateTime(2026, 8, 22);
DateTime _now() => _today;

void main() {
  setUp(resetGarmentIds);

  const engine = RuleOutfitEngine(now: _now);

  group('composicion', () {
    test('no propone nada con un armario vacio', () {
      expect(engine.generate([], const OutfitRequest()), isEmpty);
    });

    test('no propone nada si falta una ranura obligatoria', () {
      // Solo camisetas: sin pantalon ni zapatos no hay conjunto posible.
      final w = [garment(Cat.tshirt, black), garment(Cat.tshirt, white)];
      expect(engine.generate(w, const OutfitRequest()), isEmpty);
    });

    test('toda sugerencia lleva top, bottom y shoes', () {
      final w = [
        garment(Cat.tshirt, white),
        garment(Cat.jeans, blue),
        garment(Cat.sneakers, white),
      ];
      final out = engine.generate(w, const OutfitRequest());
      expect(out, isNotEmpty);
      for (final s in out) {
        expect(s.bySlot(Slot.top), isNotNull);
        expect(s.bySlot(Slot.bottom), isNotNull);
        expect(s.bySlot(Slot.shoes), isNotNull);
      }
    });

    test('un vestido compone sin top ni bottom', () {
      final w = [garment(Cat.dress, red), garment(Cat.heels, black)];
      final out = engine.generate(w, const OutfitRequest());
      expect(out, isNotEmpty);
      expect(out.first.bySlot(Slot.dress), isNotNull);
    });

    test('nunca repite la misma prenda dentro de un outfit', () {
      final w = [
        garment(Cat.tshirt, white),
        garment(Cat.jeans, blue),
        garment(Cat.sneakers, white),
        garment(Cat.jacket, black),
      ];
      for (final s in engine.generate(w, const OutfitRequest(count: 50))) {
        final ids = s.items.map((x) => x.id).toList();
        expect(ids.toSet().length, ids.length);
      }
    });

    test('no devuelve dos sugerencias con el mismo conjunto', () {
      final w = [
        for (var i = 0; i < 4; i++) garment(Cat.tshirt, white),
        for (var i = 0; i < 4; i++) garment(Cat.jeans, blue),
        for (var i = 0; i < 3; i++) garment(Cat.sneakers, grey),
      ];
      final out = engine.generate(w, const OutfitRequest(count: 30));
      final keys = out.map((s) => s.key).toList();
      expect(keys.toSet().length, keys.length);
    });

    test('respeta la misma semilla y cambia con otra', () {
      final w = [
        for (var i = 0; i < 5; i++) garment(Cat.tshirt, white),
        for (var i = 0; i < 5; i++) garment(Cat.jeans, blue),
        for (var i = 0; i < 5; i++) garment(Cat.sneakers, grey),
      ];
      final a = engine.generate(w, const OutfitRequest(seed: 1, count: 5));
      final b = engine.generate(w, const OutfitRequest(seed: 1, count: 5));
      expect(a.map((s) => s.key), b.map((s) => s.key));
    });
  });

  group('filtros', () {
    test('descarta lo archivado', () {
      final hidden = garment(Cat.jeans, blue, archived: true);
      final w = [
        garment(Cat.tshirt, white),
        hidden,
        garment(Cat.trousers, grey),
        garment(Cat.sneakers, white),
      ];
      final out = engine.generate(w, const OutfitRequest(count: 50));
      expect(out, isNotEmpty);
      expect(out.expand((s) => s.items), isNot(contains(hidden)));
    });

    test('filtra por temporada pero deja pasar lo no etiquetado', () {
      final winterOnly = garment(Cat.sweater, grey, seasons: {Season.winter});
      final anySeason = garment(Cat.tshirt, white);
      final w = [
        winterOnly,
        anySeason,
        garment(Cat.jeans, blue),
        garment(Cat.sneakers, white),
      ];
      final out = engine
          .generate(w, const OutfitRequest(season: Season.summer, count: 50));
      final used = out.expand((s) => s.items).toSet();
      expect(used, isNot(contains(winterOnly)));
      expect(used, contains(anySeason));
    });

    test('filtra por ocasion', () {
      final sportOnly = garment(Cat.joggers, grey, occasions: {Occ.sport});
      final w = [
        garment(Cat.shirt, white),
        sportOnly,
        garment(Cat.trousers, black),
        garment(Cat.flats, black),
      ];
      final out = engine
          .generate(w, const OutfitRequest(occasion: Occ.work, count: 50));
      expect(out.expand((s) => s.items), isNot(contains(sportOnly)));
    });

    test('con calor descarta el abrigo de invierno', () {
      final coat = garment(Cat.coat, black);
      final w = [
        garment(Cat.tshirt, white),
        garment(Cat.shorts, blue),
        garment(Cat.sandals, white),
        coat,
      ];
      final out = engine.generate(w, const OutfitRequest(tempC: 30, count: 50));
      expect(out.expand((s) => s.items), isNot(contains(coat)));
    });

    test('mustInclude aparece en todas las sugerencias', () {
      final pick = garment(Cat.blazer, black);
      final w = [
        pick,
        garment(Cat.shirt, white),
        garment(Cat.trousers, grey),
        garment(Cat.heels, black),
      ];
      final out = engine.generate(
          w, OutfitRequest(mustInclude: pick, count: 20));
      expect(out, isNotEmpty);
      for (final s in out) {
        expect(s.items, contains(pick));
      }
    });
  });

  group('puntuacion de color', () {
    test('prefiere complementarios a tonos que chocan', () {
      // Dos armarios identicos salvo el color del pantalon.
      List<Garment> wardrobe(int bottomColor) {
        resetGarmentIds();
        return [
          garment(Cat.tshirt, blue),
          garment(Cat.jeans, bottomColor),
          garment(Cat.sneakers, grey),
        ];
      }

      const req = OutfitRequest();
      final good = engine.generate(wardrobe(orange), req).first;
      final bad = engine.generate(wardrobe(green), req).first;
      expect(good.score, greaterThan(bad.score));
    });

    test('un neutro no penaliza nunca', () {
      List<Garment> wardrobe(int topColor) {
        resetGarmentIds();
        return [
          garment(Cat.tshirt, topColor),
          garment(Cat.jeans, black),
          garment(Cat.sneakers, black),
        ];
      }

      const req = OutfitRequest();
      final withRed = engine.generate(wardrobe(red), req).first;
      expect(
        withRed.reasons,
        contains(contains('neutro')),
      );
      expect(withRed.score, greaterThan(0.5));
    });

    test('penaliza tres colores saturados a la vez', () {
      resetGarmentIds();
      final loud = engine.generate([
        garment(Cat.tshirt, red),
        garment(Cat.jeans, green),
        garment(Cat.sneakers, blue),
      ], const OutfitRequest()).first;

      resetGarmentIds();
      final calm = engine.generate([
        garment(Cat.tshirt, red),
        garment(Cat.jeans, black),
        garment(Cat.sneakers, white),
      ], const OutfitRequest()).first;

      expect(loud.score, lessThan(calm.score));
      expect(loud.reasons, contains(contains('colores fuertes')));
    });
  });

  group('clima, ocasion y novedad', () {
    test('con frio mete capa de abrigo', () {
      final w = [
        garment(Cat.sweater, grey),
        garment(Cat.trousers, black),
        garment(Cat.boots, black),
        garment(Cat.coat, black),
      ];
      final out = engine.generate(w, const OutfitRequest(tempC: 2, count: 5));
      expect(out.first.bySlot(Slot.outer), isNotNull);
    });

    test('prefiere formalidad acorde a la ocasion', () {
      final w = [
        garment(Cat.shirt, white),
        garment(Cat.hoodie, grey),
        garment(Cat.trousers, black),
        garment(Cat.joggers, grey),
        garment(Cat.heels, black),
        garment(Cat.sneakers, white),
      ];
      final out = engine.generate(
          w, const OutfitRequest(occasion: Occ.formal, count: 1));
      final avg = out.first.items
              .map((x) => x.category.formality)
              .reduce((a, b) => a + b) /
          out.first.items.length;
      expect(avg, greaterThan(2.5));
    });

    test('penaliza lo puesto ayer frente a lo no usado', () {
      List<Garment> wardrobe(DateTime? worn) {
        resetGarmentIds();
        return [
          garment(Cat.tshirt, white, lastWorn: worn),
          garment(Cat.jeans, black),
          garment(Cat.sneakers, white),
        ];
      }

      const req = OutfitRequest();
      final fresh = engine.generate(wardrobe(null), req).first;
      final stale = engine
          .generate(wardrobe(_today.subtract(const Duration(days: 1))), req)
          .first;
      expect(stale.score, lessThan(fresh.score));
    });

    test('avoidRecentDays a cero desactiva la penalizacion', () {
      resetGarmentIds();
      final w = [
        garment(Cat.tshirt, white,
            lastWorn: _today.subtract(const Duration(days: 1))),
        garment(Cat.jeans, black),
        garment(Cat.sneakers, white),
      ];
      final out = engine
          .generate(w, const OutfitRequest(avoidRecentDays: 0, count: 1));
      expect(out.first.reasons, isNot(contains(contains('hace poco'))));
    });

    test('coincidir con el mood suma', () {
      List<Garment> wardrobe(Set<Mood> moods) {
        resetGarmentIds();
        return [
          garment(Cat.tshirt, white, moods: moods),
          garment(Cat.jeans, black, moods: moods),
          garment(Cat.sneakers, white, moods: moods),
        ];
      }

      const req = OutfitRequest(mood: Md.elegant);
      final match = engine.generate(wardrobe({Md.elegant}), req).first;
      final miss = engine.generate(wardrobe({Md.playful}), req).first;
      expect(match.score, greaterThan(miss.score));
    });
  });

  group('salida', () {
    test('respeta count y viene ordenado de mayor a menor', () {
      final w = [
        for (var i = 0; i < 6; i++) garment(Cat.tshirt, white),
        for (var i = 0; i < 6; i++) garment(Cat.jeans, blue),
        for (var i = 0; i < 6; i++) garment(Cat.sneakers, grey),
      ];
      final out = engine.generate(w, const OutfitRequest(count: 7));
      expect(out.length, 7);
      for (var i = 1; i < out.length; i++) {
        expect(out[i - 1].score, greaterThanOrEqualTo(out[i].score));
      }
    });

    test('la puntuacion queda normalizada en [0, 1]', () {
      final w = [
        garment(Cat.tshirt, white),
        garment(Cat.jeans, blue),
        garment(Cat.sneakers, grey),
      ];
      for (final s in engine.generate(w, const OutfitRequest(count: 20))) {
        expect(s.score, inInclusiveRange(0.0, 1.0));
      }
    });

    test('siempre acompana al menos una razon legible', () {
      final w = [
        garment(Cat.tshirt, white),
        garment(Cat.jeans, blue),
        garment(Cat.sneakers, grey),
      ];
      for (final s in engine.generate(w, const OutfitRequest(count: 10))) {
        expect(s.reasons, isNotEmpty);
      }
    });
  });
}
