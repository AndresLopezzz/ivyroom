import 'package:flutter_test/flutter_test.dart';
import 'package:ivyroom/domain/models/catalog.dart';
import 'package:ivyroom/domain/stats/wardrobe_stats.dart';

import '../support/catalog_fixtures.dart';

final _today = DateTime(2026, 8, 22);

String slotLabel(Slot s) => s.name;
String colorLabel(ColorFamily c) => c.name;

void main() {
  setUp(resetGarmentIds);

  group('armario vacío', () {
    test('no divide por cero en ninguna métrica', () {
      final stats = WardrobeStats(const [], today: _today);

      expect(stats.total, 0);
      expect(stats.totalWears, 0);
      expect(stats.neverWornCount, 0);
      expect(stats.usedRatio, 0);
      expect(stats.averageWearsPerUsedGarment, 0);
      expect(stats.mostWorn(), isEmpty);
      expect(stats.forgotten(), isEmpty);
      expect(stats.byCategory(), isEmpty);
    });
  });

  group('conteos básicos', () {
    test('ignora las prendas archivadas', () {
      final stats = WardrobeStats([
        garment(Cat.tshirt, white),
        garment(Cat.jeans, blue, archived: true),
      ], today: _today);

      expect(stats.total, 1);
    });

    test('suma los usos de todas las prendas', () {
      final stats = WardrobeStats([
        garment(Cat.tshirt, white, wearCount: 3, lastWorn: _today),
        garment(Cat.jeans, blue, wearCount: 7, lastWorn: _today),
        garment(Cat.heels, black),
      ], today: _today);

      expect(stats.totalWears, 10);
    });

    test('usedRatio distingue lo estrenado de lo que sigue con etiqueta', () {
      // Dos puestas y dos nunca: la mitad del armario no se usa. Es el
      // numero que de verdad importa de esta pantalla.
      final stats = WardrobeStats([
        garment(Cat.tshirt, white, wearCount: 4, lastWorn: _today),
        garment(Cat.jeans, blue, wearCount: 1, lastWorn: _today),
        garment(Cat.shirt, white),
        garment(Cat.heels, black),
      ], today: _today);

      expect(stats.total, 4);
      expect(stats.neverWornCount, 2);
      expect(stats.usedRatio, 0.5);
    });

    test('un armario entero sin estrenar da ratio cero', () {
      final stats = WardrobeStats([
        garment(Cat.tshirt, white),
        garment(Cat.jeans, blue),
      ], today: _today);

      expect(stats.usedRatio, 0);
      expect(stats.neverWornCount, 2);
    });

    test('un armario que se usa entero da ratio uno', () {
      final stats = WardrobeStats([
        garment(Cat.tshirt, white, wearCount: 1, lastWorn: _today),
        garment(Cat.jeans, blue, wearCount: 5, lastWorn: _today),
      ], today: _today);

      expect(stats.usedRatio, 1);
      expect(stats.neverWornCount, 0);
    });
  });

  group('reparto', () {
    test('por categoría, de más a menos', () {
      final stats = WardrobeStats([
        garment(Cat.tshirt, white),
        garment(Cat.tshirt, black),
        garment(Cat.tshirt, blue),
        garment(Cat.jeans, blue),
        garment(Cat.heels, black),
      ], today: _today);

      final byCat = stats.byCategory();
      expect(byCat.first.label, 'Camiseta');
      expect(byCat.first.count, 3);
      expect(byCat.map((b) => b.count), [3, 1, 1]);
    });

    test('por ranura, en el orden natural del enum', () {
      final stats = WardrobeStats([
        garment(Cat.heels, black),
        garment(Cat.tshirt, white),
        garment(Cat.jeans, blue),
      ], today: _today);

      expect(stats.bySlot(slotLabel).map((b) => b.label),
          ['top', 'bottom', 'shoes']);
    });

    test('por color, con un color real del armario como muestra', () {
      final stats = WardrobeStats([
        garment(Cat.tshirt, red),
        garment(Cat.shirt, red),
        garment(Cat.jeans, blue),
      ], today: _today);

      final byColor = stats.byColor(colorLabel);
      expect(byColor.first.label, 'red');
      expect(byColor.first.count, 2);
      expect(byColor.first.colorArgb, red);
    });

    test('los neutros se agrupan juntos', () {
      final stats = WardrobeStats([
        garment(Cat.tshirt, black),
        garment(Cat.shirt, white),
        garment(Cat.jeans, grey),
      ], today: _today);

      final byColor = stats.byColor(colorLabel);
      expect(byColor, hasLength(1));
      expect(byColor.single.label, 'neutral');
      expect(byColor.single.count, 3);
    });
  });

  group('más puestas', () {
    test('ordena de mayor a menor uso', () {
      final poco = garment(Cat.tshirt, white, wearCount: 2, lastWorn: _today);
      final mucho = garment(Cat.jeans, blue, wearCount: 9, lastWorn: _today);
      final medio = garment(Cat.heels, black, wearCount: 5, lastWorn: _today);

      final stats = WardrobeStats([poco, mucho, medio], today: _today);
      final top = stats.mostWorn();

      expect(top.map((u) => u.garment.wearCount), [9, 5, 2]);
    });

    test('excluye lo que nunca se ha puesto', () {
      final usada = garment(Cat.tshirt, white, wearCount: 3, lastWorn: _today);
      final nueva = garment(Cat.jeans, blue);

      final stats = WardrobeStats([usada, nueva], today: _today);

      expect(stats.mostWorn().map((u) => u.garment.id), [usada.id]);
    });

    test('respeta el límite', () {
      final many = [
        for (var i = 0; i < 20; i++)
          garment(Cat.tshirt, white, wearCount: i + 1, lastWorn: _today),
      ];
      expect(WardrobeStats(many, today: _today).mostWorn(limit: 3),
          hasLength(3));
    });

    test('calcula los días desde la última vez', () {
      final g = garment(Cat.tshirt, white).copyWith(
        wearCount: 1,
        lastWornAt: _today.subtract(const Duration(days: 12)),
      );

      expect(WardrobeStats([g], today: _today).mostWorn().single.daysSinceWorn,
          12);
    });

    test('la hora del día no cuenta como un día más', () {
      final g = garment(Cat.tshirt, white).copyWith(
        wearCount: 1,
        lastWornAt: DateTime(2026, 8, 21, 23, 30),
      );

      expect(WardrobeStats([g], today: _today).mostWorn().single.daysSinceWorn,
          1);
    });
  });

  group('olvidadas', () {
    test('lo nunca estrenado va primero', () {
      final nunca = garment(Cat.heels, black);
      final vieja = garment(Cat.tshirt, white).copyWith(
        wearCount: 4,
        lastWornAt: _today.subtract(const Duration(days: 200)),
      );

      final out = WardrobeStats([vieja, nunca], today: _today).forgotten();

      expect(out.first.garment.id, nunca.id);
      expect(out.first.neverWorn, isTrue);
      expect(out.last.garment.id, vieja.id);
    });

    test('entre las nunca puestas, primero las más antiguas', () {
      final antigua = garment(Cat.tshirt, white,
          createdAt: DateTime(2026, 1, 1));
      final reciente = garment(Cat.jeans, blue,
          createdAt: DateTime(2026, 8, 1));

      final out =
          WardrobeStats([reciente, antigua], today: _today).forgotten();

      expect(out.map((u) => u.garment.id), [antigua.id, reciente.id]);
    });

    test('lo puesto hace poco no se considera olvidado', () {
      final reciente = garment(Cat.tshirt, white).copyWith(
        wearCount: 2,
        lastWornAt: _today.subtract(const Duration(days: 5)),
      );

      expect(WardrobeStats([reciente], today: _today).forgotten(), isEmpty);
    });

    test('el umbral de olvido es configurable', () {
      final g = garment(Cat.tshirt, white).copyWith(
        wearCount: 2,
        lastWornAt: _today.subtract(const Duration(days: 40)),
      );
      final stats = WardrobeStats([g], today: _today);

      expect(stats.forgotten(staleDays: 60), isEmpty);
      expect(stats.forgotten(staleDays: 30), hasLength(1));
    });

    test('entre las viejas, la que lleva más tiempo va primero', () {
      final hace100 = garment(Cat.tshirt, white).copyWith(
          wearCount: 1, lastWornAt: _today.subtract(const Duration(days: 100)));
      final hace70 = garment(Cat.jeans, blue).copyWith(
          wearCount: 1, lastWornAt: _today.subtract(const Duration(days: 70)));

      final out =
          WardrobeStats([hace70, hace100], today: _today).forgotten();

      expect(out.map((u) => u.garment.id), [hace100.id, hace70.id]);
    });
  });

  group('media de uso', () {
    test('no cuenta las prendas nunca puestas', () {
      // Si las contara, la media diría menos que usedRatio, que ya cubre ese
      // ángulo.
      final usada = garment(Cat.tshirt, white, wearCount: 10, lastWorn: _today);
      final nueva = garment(Cat.jeans, blue);

      final stats = WardrobeStats([usada, nueva], today: _today);

      expect(stats.averageWearsPerUsedGarment, 10);
      expect(stats.usedRatio, 0.5);
    });
  });

  _wearTests();

  group('ranuras que faltan', () {
    test('avisa de lo que impide montar un outfit', () {
      final stats = WardrobeStats([
        garment(Cat.tshirt, white),
        garment(Cat.jeans, blue),
      ], today: _today);

      expect(stats.missingSlots(slotLabel), [Slot.shoes]);
    });

    test('con el conjunto completo no falta nada', () {
      final stats = WardrobeStats([
        garment(Cat.tshirt, white),
        garment(Cat.jeans, blue),
        garment(Cat.heels, black),
      ], today: _today);

      expect(stats.missingSlots(slotLabel), isEmpty);
    });

    test('un vestido cubre arriba y abajo', () {
      final stats = WardrobeStats([
        garment(Cat.dress, red),
        garment(Cat.heels, black),
      ], today: _today);

      expect(stats.missingSlots(slotLabel), isEmpty);
    });
  });
}

// ---- desgaste --------------------------------------------------------------

void _wearTests() {
  group('desgaste', () {
    test('sin lavadas registradas no hay ranking', () {
      final stats = WardrobeStats([
        garment(Cat.tshirt, white, wearCount: 5, lastWorn: _today),
      ], today: _today);

      expect(stats.totalWashes, 0);
      expect(stats.mostWashed(), isEmpty);
      expect(stats.neverWashedButWorn, 1);
    });

    test('ordena de más a menos lavadas', () {
      final poco = garment(Cat.tshirt, white, washCount: 2, lastWashed: _today);
      final mucho = garment(Cat.jeans, blue, washCount: 11, lastWashed: _today);

      final stats = WardrobeStats([poco, mucho], today: _today);

      expect(stats.mostWashed().map((w) => w.garment.id), [mucho.id, poco.id]);
      expect(stats.totalWashes, 13);
    });

    test('las que rinden menos por lavada van primero', () {
      // Una que se lava casi cada uso se gasta el doble de rápido.
      final sufrida =
          garment(Cat.tshirt, white, wearCount: 3, washCount: 3);
      final resistente =
          garment(Cat.jeans, blue, wearCount: 20, washCount: 4);

      final stats = WardrobeStats([resistente, sufrida], today: _today);
      final harsh = stats.hardestOnClothes();

      expect(harsh.first.garment.id, sufrida.id);
      expect(harsh.first.wearsPerWash, 1);
      expect(harsh.last.wearsPerWash, 5);
    });

    test('no juzga con una sola lavada', () {
      // Con una lavada el ratio es ruido, no señal.
      final stats = WardrobeStats([
        garment(Cat.tshirt, white, wearCount: 1, washCount: 1),
      ], today: _today);

      expect(stats.hardestOnClothes(), isEmpty);
      expect(stats.hardestOnClothes(minWashes: 1), hasLength(1));
    });

    test('cuenta lo sucio', () {
      final sucia = garment(Cat.tshirt, white,
          wearCount: 1,
          lastWorn: _today,
          washCount: 1,
          lastWashed: _today.subtract(const Duration(days: 5)));
      final limpia = garment(Cat.jeans, blue,
          wearCount: 1,
          lastWorn: _today.subtract(const Duration(days: 5)),
          washCount: 1,
          lastWashed: _today);

      final stats = WardrobeStats([sucia, limpia], today: _today);
      expect(stats.dirtyCount, 1);
    });

    test('reparte por grupo de lavado', () {
      final stats = WardrobeStats([
        garment(Cat.tshirt, white, washGroup: Wash.oscuros),
        garment(Cat.shirt, black, washGroup: Wash.oscuros),
        garment(Cat.jeans, blue, washGroup: Wash.pesada),
        garment(Cat.heels, black),
      ], today: _today);

      final byGroup = {
        for (final b in stats.byWashGroup()) b.label: b.count,
      };
      expect(byGroup, {'Oscuros': 2, 'Ropa pesada': 1, 'Sin clasificar': 1});
    });

    test('días desde la última lavada', () {
      final g = garment(Cat.tshirt, white,
          washCount: 2,
          lastWashed: _today.subtract(const Duration(days: 9)));

      expect(WardrobeStats([g], today: _today).mostWashed().single
          .daysSinceWashed, 9);
    });
  });
}
