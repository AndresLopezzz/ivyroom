import 'package:flutter_test/flutter_test.dart';
import 'package:ivyroom/domain/color/color_theory.dart';
import 'package:ivyroom/domain/models/catalog.dart';

void main() {
  group('Hsl.fromRgb', () {
    test('convierte primarios correctamente', () {
      expect(Hsl.fromRgb(255, 0, 0).h, closeTo(0, 0.5));
      expect(Hsl.fromRgb(0, 255, 0).h, closeTo(120, 0.5));
      expect(Hsl.fromRgb(0, 0, 255).h, closeTo(240, 0.5));
      expect(Hsl.fromRgb(255, 0, 0).s, closeTo(1.0, 0.01));
      expect(Hsl.fromRgb(255, 0, 0).l, closeTo(0.5, 0.01));
    });

    test('los grises tienen saturacion cero', () {
      expect(Hsl.fromRgb(128, 128, 128).s, 0);
    });

    test('fromArgb ignora el canal alfa', () {
      expect(Hsl.fromArgb(0xFFFF0000).h, closeTo(0, 0.5));
      expect(Hsl.fromArgb(0x00FF0000).h, closeTo(0, 0.5));
    });
  });

  group('neutros', () {
    test('negro, blanco y gris son neutros', () {
      expect(Hsl.fromRgb(0, 0, 0).isNeutral, isTrue);
      expect(Hsl.fromRgb(255, 255, 255).isNeutral, isTrue);
      expect(Hsl.fromRgb(120, 120, 120).isNeutral, isTrue);
    });

    test('el beige cuenta como neutro', () {
      expect(Hsl.fromRgb(222, 202, 170).isNeutral, isTrue);
    });

    test('un rojo saturado no es neutro', () {
      expect(Hsl.fromRgb(220, 30, 30).isNeutral, isFalse);
    });
  });

  group('familia de color', () {
    test('clasifica tonos vivos', () {
      expect(Hsl.fromRgb(220, 30, 30).family, ColorFamily.red);
      expect(Hsl.fromRgb(30, 90, 220).family, ColorFamily.blue);
      expect(Hsl.fromRgb(40, 180, 60).family, ColorFamily.green);
    });

    test('el marron oscuro no se confunde con naranja', () {
      expect(Hsl.fromRgb(101, 67, 33).family, ColorFamily.brown);
      expect(Hsl.fromRgb(255, 140, 0).family, ColorFamily.orange);
    });

    test('los grises caen en neutral', () {
      expect(Hsl.fromRgb(128, 128, 128).family, ColorFamily.neutral);
    });
  });

  group('temperatura', () {
    test('rojos calidos, azules frios, grises neutros', () {
      expect(Hsl.fromRgb(220, 30, 30).warmth, Warmth.warm);
      expect(Hsl.fromRgb(30, 90, 220).warmth, Warmth.cool);
      expect(Hsl.fromRgb(128, 128, 128).warmth, Warmth.neutral);
    });
  });

  group('hueDistance', () {
    test('toma siempre el camino corto del circulo', () {
      expect(hueDistance(10, 350), closeTo(20, 0.01));
      expect(hueDistance(350, 10), closeTo(20, 0.01));
      expect(hueDistance(0, 180), closeTo(180, 0.01));
    });
  });

  group('harmonyBetween', () {
    final blue = Hsl.fromRgb(30, 90, 220);
    final orange = Hsl.fromRgb(230, 130, 30);
    final black = Hsl.fromRgb(20, 20, 20);

    test('azul y naranja son complementarios', () {
      expect(harmonyBetween(blue, orange), Harmony.complementary);
    });

    test('cualquier cosa con un neutro es combinable', () {
      expect(harmonyBetween(blue, black), Harmony.neutralPair);
      expect(harmonyBetween(black, orange), Harmony.neutralPair);
    });

    test('mismo tono da monocromo', () {
      expect(
        harmonyBetween(const Hsl(220, 0.8, 0.4), const Hsl(225, 0.6, 0.6)),
        Harmony.monochrome,
      );
    });

    test('tonos vecinos dan analogo', () {
      expect(
        harmonyBetween(const Hsl(200, 0.8, 0.5), const Hsl(235, 0.8, 0.5)),
        Harmony.analogous,
      );
    });

    test('la banda intermedia choca', () {
      expect(
        harmonyBetween(const Hsl(0, 0.9, 0.5), const Hsl(75, 0.9, 0.5)),
        Harmony.clash,
      );
    });

    test('la relacion es simetrica', () {
      expect(harmonyBetween(blue, orange), harmonyBetween(orange, blue));
    });
  });

  group('lightnessContrastScore', () {
    test('penaliza el look plano y premia el contraste medio', () {
      expect(lightnessContrastScore(0.5, 0.52), lessThan(0.5));
      expect(lightnessContrastScore(0.2, 0.6), 1.0);
      expect(lightnessContrastScore(0.05, 0.95), lessThan(1.0));
    });
  });
}
