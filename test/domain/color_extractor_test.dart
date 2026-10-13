import 'package:flutter_test/flutter_test.dart';
import 'package:ivyroom/domain/color/color_extractor.dart';
import 'package:ivyroom/domain/color/color_theory.dart';
import 'package:ivyroom/domain/models/catalog.dart';

Rgba px(int r, int g, int b, [int a = 255]) => (r: r, g: g, b: b, a: a);

List<Rgba> fill(int count, Rgba color) => List.filled(count, color);

void main() {
  const extractor = ColorExtractor();

  test('sin pixeles devuelve el resultado vacio', () {
    expect(extractor.extract([]).dominant, PaletteResult.empty.dominant);
  });

  test('una imagen de un solo color devuelve ese color', () {
    final r = extractor.extract(fill(500, px(220, 30, 30)));
    expect(Hsl.fromArgb(r.dominant).family, ColorFamily.red);
    expect((r.dominant >> 16) & 0xFF, closeTo(220, 3));
  });

  test('el alfa siempre sale opaco', () {
    final r = extractor.extract(fill(100, px(10, 200, 10)));
    expect((r.dominant >> 24) & 0xFF, 0xFF);
  });

  test('ignora los pixeles transparentes del recorte', () {
    // Mayoria de fondo verde recortado (alfa 0) y minoria de prenda roja.
    final pixels = [
      ...fill(900, px(0, 255, 0, 0)),
      ...fill(100, px(220, 30, 30)),
    ];
    final r = extractor.extract(pixels);
    expect(Hsl.fromArgb(r.dominant).family, ColorFamily.red);
  });

  test('ignora tambien los bordes semitransparentes', () {
    final pixels = [
      ...fill(900, px(0, 255, 0, 120)), // borde con antialias
      ...fill(100, px(30, 90, 220)),
    ];
    final r = extractor.extract(pixels);
    expect(Hsl.fromArgb(r.dominant).family, ColorFamily.blue);
  });

  test('si todo es transparente devuelve el resultado vacio', () {
    final r = extractor.extract(fill(500, px(10, 20, 30, 0)));
    expect(r.dominant, PaletteResult.empty.dominant);
    expect(r.palette, isEmpty);
  });

  test('el dominante es el color mayoritario, no la media', () {
    // 80% azul y 20% amarillo: la media seria gris verdoso, el dominante
    // tiene que seguir siendo azul.
    final pixels = [
      ...fill(800, px(30, 90, 220)),
      ...fill(200, px(240, 220, 40)),
    ];
    final r = extractor.extract(pixels);
    expect(Hsl.fromArgb(r.dominant).family, ColorFamily.blue);
  });

  test('la paleta viene ordenada por peso y contiene ambos colores', () {
    final pixels = [
      ...fill(700, px(220, 30, 30)),
      ...fill(300, px(30, 90, 220)),
    ];
    final r = extractor.extract(pixels);
    expect(r.palette.length, greaterThanOrEqualTo(2));
    expect(r.palette.first, r.dominant);

    final families =
        r.palette.map((c) => Hsl.fromArgb(c).family).toSet();
    expect(families, contains(ColorFamily.red));
    expect(families, contains(ColorFamily.blue));
  });

  test('la paleta nunca excede el numero de clusters', () {
    final pixels = [
      for (var i = 0; i < 12; i++) ...fill(100, px(i * 20, 255 - i * 20, 128)),
    ];
    expect(extractor.extract(pixels).palette.length, lessThanOrEqualTo(5));
  });

  test('es determinista: la misma entrada da el mismo color', () {
    final pixels = [
      ...fill(400, px(120, 60, 200)),
      ...fill(300, px(20, 20, 20)),
      ...fill(200, px(240, 240, 240)),
    ];
    final a = extractor.extract(pixels);
    final b = extractor.extract(pixels);
    expect(a.dominant, b.dominant);
    expect(a.palette, b.palette);
  });

  test('el submuestreo no cambia el color de una prenda grande', () {
    const small = ColorExtractor(maxSamples: 100);
    final pixels = fill(50000, px(200, 40, 40));
    expect(Hsl.fromArgb(small.extract(pixels).dominant).family,
        ColorFamily.red);
  });

  test('detecta el negro y el blanco como neutros', () {
    expect(
      Hsl.fromArgb(extractor.extract(fill(300, px(15, 15, 15))).dominant)
          .isNeutral,
      isTrue,
    );
    expect(
      Hsl.fromArgb(extractor.extract(fill(300, px(245, 245, 245))).dominant)
          .isNeutral,
      isTrue,
    );
  });
}
