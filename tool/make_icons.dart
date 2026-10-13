// Genera los iconos de Android desde `assets/branding/logo.png`.
//
//   dart run tool/make_icons.dart
//
// No usa `flutter_launcher_icons` a proposito: `package:image` ya es
// dependencia de la app —se usa para extraer el color de las prendas—, asi
// que esto no anade nada al arbol de paquetes. Y ese arbol ya dio bastantes
// problemas de versiones como para meterle una herramienta mas por generar
// diez PNG.
import 'dart:io';

import 'package:image/image.dart' as img;

/// Fondo del icono: el mismo papel calido de la app, no blanco puro.
const _paper = (0xF6, 0xF5, 0xF2);

/// Tinta del logotipo.
const _ink = (0x14, 0x13, 0x10);

/// Densidades de Android y su factor respecto a mdpi.
const _densities = {
  'mdpi': 1.0,
  'hdpi': 1.5,
  'xhdpi': 2.0,
  'xxhdpi': 3.0,
  'xxxhdpi': 4.0,
};

/// El icono clasico mide 48 dp.
const _legacyDp = 48;

/// El adaptativo mide 108 dp, de los cuales solo los 72 centrales se ven
/// siempre: el resto lo puede recortar el lanzador segun la forma que use.
const _adaptiveDp = 108;

void main() {
  final source = File('assets/branding/logo.png');
  if (!source.existsSync()) {
    stderr.writeln('No esta assets/branding/logo.png');
    exit(1);
  }

  final glyph = _glyphFrom(img.decodePng(source.readAsBytesSync())!);
  stdout.writeln('Logotipo recortado a ${glyph.width}x${glyph.height}');

  final res = Directory('android/app/src/main/res');

  for (final entry in _densities.entries) {
    final dir = Directory('${res.path}/mipmap-${entry.key}')
      ..createSync(recursive: true);

    // Clasico: el logotipo sobre el papel, con aire alrededor.
    final legacy = (_legacyDp * entry.value).round();
    _write(
      '${dir.path}/ic_launcher.png',
      _compose(glyph, size: legacy, fill: 0.78, background: _paper),
    );

    // Adaptativo: solo el logotipo, transparente, y mas pequeno porque el
    // lanzador se puede comer los bordes.
    final adaptive = (_adaptiveDp * entry.value).round();
    _write(
      '${dir.path}/ic_launcher_foreground.png',
      _compose(glyph, size: adaptive, fill: 0.60),
    );
  }

  // El mismo logotipo para la pantalla de arranque, pero **sin color
  // propio**: blanco con alfa, para que lo tina la app con su tinta. Esa
  // decision vive en el tema, no en un PNG.
  //
  // En blanco y no en dos canales (gris + alfa): `setPixelRgba` no mapea la
  // alfa cuando la imagen tiene dos canales y el fichero salia transparente
  // entero. Con el RGB constante el PNG comprime practicamente igual.
  final wordmark = img.copyResize(
    glyph,
    width: 800,
    height: (800 * glyph.height / glyph.width).round(),
    interpolation: img.Interpolation.cubic,
  );
  for (var y = 0; y < wordmark.height; y++) {
    for (var x = 0; x < wordmark.width; x++) {
      final p = wordmark.getPixel(x, y);
      wordmark.setPixelRgba(x, y, 255, 255, 255, p.a.round());
    }
  }
  _write('assets/branding/wordmark.png', wordmark);

  stdout.writeln('Listo.');
}

/// Convierte el logotipo —negro sobre casi blanco— en una silueta con
/// transparencia.
///
/// La alfa sale de lo oscuro que es cada pixel y no de un corte por umbral:
/// asi los bordes suavizados del original siguen suavizados y el contorno no
/// queda dentado.
///
/// Pero antes hay que **estirar el rango**. El negro del original no es
/// negro puro ni su fondo es blanco puro, asi que `255 - luminancia` dejaba
/// el logotipo entero al 90 % de opacidad y el fondo con un 2 % de suciedad.
/// Se ve como un gris lavado, no como tinta.
img.Image _glyphFrom(img.Image source) {
  var darkest = 255.0;
  var lightest = 0.0;
  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      final l = img.getLuminance(source.getPixel(x, y)).toDouble();
      if (l < darkest) darkest = l;
      if (l > lightest) lightest = l;
    }
  }
  final range = (lightest - darkest).clamp(1.0, 255.0);
  stdout.writeln('Rango del original: $darkest a $lightest');

  final out = img.Image(
    width: source.width,
    height: source.height,
    numChannels: 4,
  );
  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      final l = img.getLuminance(source.getPixel(x, y)).toDouble();
      final alpha = ((lightest - l) / range * 255).round().clamp(0, 255);
      out.setPixelRgba(x, y, _ink.$1, _ink.$2, _ink.$3, alpha);
    }
  }
  // El original trae margen blanco propio; sin recortarlo, el logotipo sale
  // el doble de pequeno de lo que toca dentro del icono.
  return img.trim(out, mode: img.TrimMode.transparent);
}

/// Coloca el logotipo centrado en un lienzo cuadrado, ocupando [fill] del
/// lado, sin deformarlo.
img.Image _compose(
  img.Image glyph, {
  required int size,
  required double fill,
  (int, int, int)? background,
}) {
  final canvas = img.Image(width: size, height: size, numChannels: 4);
  if (background != null) {
    img.fill(
      canvas,
      color: img.ColorRgba8(background.$1, background.$2, background.$3, 255),
    );
  }

  final box = size * fill;
  final scale = (box / glyph.width) < (box / glyph.height)
      ? box / glyph.width
      : box / glyph.height;
  final scaled = img.copyResize(
    glyph,
    width: (glyph.width * scale).round(),
    height: (glyph.height * scale).round(),
    interpolation: img.Interpolation.cubic,
  );

  return img.compositeImage(
    canvas,
    scaled,
    dstX: ((size - scaled.width) / 2).round(),
    dstY: ((size - scaled.height) / 2).round(),
  );
}

void _write(String path, img.Image image) {
  File(path).writeAsBytesSync(img.encodePng(image, level: 9));
  stdout.writeln('  $path  ${image.width}x${image.height}');
}
