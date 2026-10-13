import 'dart:math' as math;

/// Resultado del analisis cromatico de una prenda recortada.
class PaletteResult {
  const PaletteResult({required this.dominant, required this.palette});

  /// Color principal en ARGB, ya con alfa opaco.
  final int dominant;

  /// Paleta ordenada por peso, el primero es el dominante.
  final List<int> palette;

  static const empty = PaletteResult(dominant: 0xFF808080, palette: []);
}

/// Un pixel de entrada. Se recibe asi (y no como un bitmap) para que el
/// extractor siga siendo Dart puro y testeable sin `dart:ui` ni ficheros.
typedef Rgba = ({int r, int g, int b, int a});

/// Extrae el color dominante y la paleta de una prenda ya recortada.
///
/// Se implementa a mano en vez de usar `palette_generator` porque ese
/// paquete esta discontinuado por flutter.dev, y porque aqui hace falta algo
/// que ese no hace: ignorar los pixeles transparentes del recorte.
class ColorExtractor {
  const ColorExtractor({
    this.clusters = 5,
    this.alphaThreshold = 200,
    this.maxIterations = 12,
    this.maxSamples = 20000,
  });

  /// Cuantos colores devuelve la paleta como maximo.
  final int clusters;

  /// Un pixel con alfa por debajo de esto es fondo recortado o borde
  /// semitransparente: contamina la media, asi que no cuenta.
  final int alphaThreshold;

  final int maxIterations;

  /// Techo de pixeles analizados. Por encima se submuestrea: una prenda a
  /// 3000x3000 son 9 millones de pixeles y el color no cambia por mirarlos
  /// todos.
  final int maxSamples;

  PaletteResult extract(List<Rgba> pixels) {
    final samples = _sample(pixels);
    if (samples.isEmpty) return PaletteResult.empty;

    final centroids = _kMeans(samples);
    if (centroids.isEmpty) return PaletteResult.empty;

    final palette = centroids.map(_toArgb).toList();
    return PaletteResult(dominant: palette.first, palette: palette);
  }

  // ---- interno -----------------------------------------------------------

  List<List<double>> _sample(List<Rgba> pixels) {
    final opaque = <Rgba>[];
    for (final px in pixels) {
      if (px.a >= alphaThreshold) opaque.add(px);
    }
    if (opaque.isEmpty) return const [];

    final step = math.max(1, opaque.length ~/ maxSamples);
    final out = <List<double>>[];
    for (var i = 0; i < opaque.length; i += step) {
      final px = opaque[i];
      out.add([px.r.toDouble(), px.g.toDouble(), px.b.toDouble()]);
    }
    return out;
  }

  /// k-means con inicializacion determinista: la misma foto siempre da el
  /// mismo color, que es lo que el usuario espera al reabrir la prenda.
  List<({List<double> center, int weight})> _kMeans(
      List<List<double>> samples) {
    final k = math.min(clusters, samples.length);
    if (k == 0) return const [];

    // Semillas repartidas uniformemente por la muestra ya ordenada por
    // luminancia: cubre el rango claro-oscuro sin depender del azar.
    final sorted = [...samples]..sort((a, b) => _luma(a).compareTo(_luma(b)));
    final centers = <List<double>>[
      for (var i = 0; i < k; i++)
        [...sorted[((i + 0.5) * sorted.length ~/ k).clamp(0, sorted.length - 1)]]
    ];

    final assignment = List<int>.filled(samples.length, 0);

    for (var iter = 0; iter < maxIterations; iter++) {
      var moved = false;
      for (var i = 0; i < samples.length; i++) {
        var best = 0;
        var bestDist = double.infinity;
        for (var c = 0; c < k; c++) {
          final d = _dist2(samples[i], centers[c]);
          if (d < bestDist) {
            bestDist = d;
            best = c;
          }
        }
        if (assignment[i] != best) {
          assignment[i] = best;
          moved = true;
        }
      }

      final sums = List.generate(k, (_) => [0.0, 0.0, 0.0]);
      final counts = List<int>.filled(k, 0);
      for (var i = 0; i < samples.length; i++) {
        final c = assignment[i];
        sums[c][0] += samples[i][0];
        sums[c][1] += samples[i][1];
        sums[c][2] += samples[i][2];
        counts[c]++;
      }
      for (var c = 0; c < k; c++) {
        if (counts[c] == 0) continue;
        centers[c] = [
          sums[c][0] / counts[c],
          sums[c][1] / counts[c],
          sums[c][2] / counts[c],
        ];
      }

      if (!moved) break; // convergio
    }

    final counts = List<int>.filled(k, 0);
    for (final a in assignment) {
      counts[a]++;
    }

    final result = <({List<double> center, int weight})>[];
    for (var c = 0; c < k; c++) {
      if (counts[c] == 0) continue;
      result.add((center: centers[c], weight: counts[c]));
    }
    result.sort((a, b) => b.weight.compareTo(a.weight));
    return result;
  }

  double _luma(List<double> c) =>
      0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2];

  double _dist2(List<double> a, List<double> b) {
    final dr = a[0] - b[0], dg = a[1] - b[1], db = a[2] - b[2];
    return dr * dr + dg * dg + db * db;
  }

  int _toArgb(({List<double> center, int weight}) c) {
    int ch(double v) => v.round().clamp(0, 255);
    return (0xFF << 24) |
        (ch(c.center[0]) << 16) |
        (ch(c.center[1]) << 8) |
        ch(c.center[2]);
  }
}
