import 'dart:math' as math;

import '../models/catalog.dart';

/// Un color en HSL, desacoplado de `dart:ui` para que el dominio siga siendo
/// Dart puro y testeable con `dart test`.
class Hsl {
  const Hsl(this.h, this.s, this.l);

  /// Tono en grados [0, 360).
  final double h;

  /// Saturacion [0, 1].
  final double s;

  /// Luminosidad [0, 1].
  final double l;

  factory Hsl.fromRgb(int r, int g, int b) {
    final rf = r / 255.0, gf = g / 255.0, bf = b / 255.0;
    final max = math.max(rf, math.max(gf, bf));
    final min = math.min(rf, math.min(gf, bf));
    final delta = max - min;
    final l = (max + min) / 2;

    if (delta == 0) return Hsl(0, 0, l);

    final s = delta / (1 - (2 * l - 1).abs());
    double h;
    if (max == rf) {
      h = 60 * (((gf - bf) / delta) % 6);
    } else if (max == gf) {
      h = 60 * ((bf - rf) / delta + 2);
    } else {
      h = 60 * ((rf - gf) / delta + 4);
    }
    if (h < 0) h += 360;
    return Hsl(h, s, l);
  }

  factory Hsl.fromArgb(int argb) => Hsl.fromRgb(
        (argb >> 16) & 0xFF,
        (argb >> 8) & 0xFF,
        argb & 0xFF,
      );

  /// Un color es neutro cuando no aporta tono perceptible: grises, negros,
  /// blancos, y tambien beiges/camel (poco saturados y claros). Los neutros
  /// combinan con todo, asi que el motor los trata como comodines.
  bool get isNeutral {
    if (s < 0.15) return true;
    if (l < 0.12 || l > 0.92) return true;
    // Beige / camel / crudo: tono calido y claro. El umbral de saturacion es
    // alto a proposito porque la S de HSL se dispara cuando L pasa de 0.5
    // aunque el croma real (max-min) sea pequeno.
    if (s < 0.50 && l > 0.65 && h >= 20 && h <= 60) return true;
    return false;
  }

  Warmth get warmth {
    if (isNeutral) return Warmth.neutral;
    // Rojos-amarillos calidos; azules-verdes frios.
    return (h < 90 || h >= 300) ? Warmth.warm : Warmth.cool;
  }

  ColorFamily get family {
    if (isNeutral) {
      // Marron: tono naranja con saturacion apreciable pero oscuro.
      if (s >= 0.15 && l < 0.45 && h >= 15 && h <= 45) return ColorFamily.brown;
      return ColorFamily.neutral;
    }
    if (h >= 15 && h < 45 && l < 0.42) return ColorFamily.brown;
    if (h < 15 || h >= 345) return ColorFamily.red;
    if (h < 45) return ColorFamily.orange;
    if (h < 70) return ColorFamily.yellow;
    if (h < 165) return ColorFamily.green;
    if (h < 200) return ColorFamily.cyan;
    if (h < 260) return ColorFamily.blue;
    if (h < 300) return ColorFamily.purple;
    return ColorFamily.pink;
  }
}

/// Distancia angular mas corta entre dos tonos, en grados [0, 180].
double hueDistance(double a, double b) {
  final d = (a - b).abs() % 360;
  return d > 180 ? 360 - d : d;
}

/// Relacion cromatica entre dos colores. El orden va de mas seguro a mas
/// arriesgado, y `clash` es el unico caso que el motor penaliza.
enum Harmony {
  neutralPair('uno de los dos es neutro, combina con todo', 0.85),
  monochrome('mismo tono, look monocromo', 1.0),
  analogous('tonos vecinos, transición suave', 0.9),
  complementary('colores opuestos, contraste alto', 0.8),
  triadic('tríada equilibrada', 0.7),
  clash('tonos que chocan', 0.25);

  const Harmony(this.reason, this.score);

  /// Texto legible que acaba en las `reasons` de la sugerencia.
  final String reason;

  /// Puntuacion [0, 1] que aporta esta relacion.
  final double score;
}

Harmony harmonyBetween(Hsl a, Hsl b) {
  if (a.isNeutral || b.isNeutral) return Harmony.neutralPair;

  final d = hueDistance(a.h, b.h);
  if (d < 20) return Harmony.monochrome;
  if (d < 50) return Harmony.analogous;
  if (d >= 150) return Harmony.complementary;
  if (d >= 100 && d < 140) return Harmony.triadic;
  return Harmony.clash;
}

/// Contraste de luminosidad. Un outfit con todo al mismo nivel de claridad
/// se ve plano; uno con contraste extremo puede cansar. Se premia la banda
/// intermedia.
double lightnessContrastScore(double l1, double l2) {
  final d = (l1 - l2).abs();
  if (d < 0.10) return 0.45; // plano
  if (d < 0.55) return 1.0; // contraste comodo
  return 0.75; // muy marcado, pero valido
}
