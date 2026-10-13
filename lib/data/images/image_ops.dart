import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../domain/color/color_extractor.dart';

/// Operaciones sobre pixeles, todas pesadas y todas pensadas para correr
/// dentro de un isolate (`compute`). Son funciones de nivel superior y sin
/// estado justamente por eso: un `compute` no puede recibir un closure que
/// capture contexto.

/// Recorta el PNG al rectangulo minimo que contiene pixeles visibles.
///
/// ML Kit devuelve el bitmap del tamano de la foto entera con el fondo
/// transparente, asi que sin este paso la prenda queda diminuta y rodeada de
/// vacio en el grid.
Uint8List autoCropTransparent(Uint8List pngBytes) {
  final src = img.decodePng(pngBytes);
  if (src == null || !src.hasAlpha) return pngBytes;

  var minX = src.width, minY = src.height, maxX = -1, maxY = -1;
  for (var y = 0; y < src.height; y++) {
    for (var x = 0; x < src.width; x++) {
      if (src.getPixel(x, y).a > 16) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }

  // Todo transparente: se devuelve tal cual antes que producir una imagen
  // de tamano cero.
  if (maxX < minX || maxY < minY) return pngBytes;

  // Un margen pequeno evita que la prenda quede pegada al borde.
  const pad = 8;
  minX = (minX - pad).clamp(0, src.width - 1);
  minY = (minY - pad).clamp(0, src.height - 1);
  maxX = (maxX + pad).clamp(0, src.width - 1);
  maxY = (maxY + pad).clamp(0, src.height - 1);

  final cropped = img.copyCrop(
    src,
    x: minX,
    y: minY,
    width: maxX - minX + 1,
    height: maxY - minY + 1,
  );
  return Uint8List.fromList(img.encodePng(cropped));
}

/// Reduce el lado mayor a `maxSide` si hace falta. Una foto de movil son
/// 12 Mpx que ni el recorte ni el analisis de color necesitan.
Uint8List downscale(Uint8List bytes, {int maxSide = 1600}) {
  final src = img.decodeImage(bytes);
  if (src == null) return bytes;
  final longest = src.width > src.height ? src.width : src.height;
  if (longest <= maxSide) return Uint8List.fromList(img.encodePng(src));

  final resized = img.copyResize(
    src,
    width: src.width >= src.height ? maxSide : null,
    height: src.height > src.width ? maxSide : null,
    interpolation: img.Interpolation.average,
  );
  return Uint8List.fromList(img.encodePng(resized));
}

/// [downscale] al tamano de una foto de look. De nivel superior para
/// `compute`, que no acepta argumentos con nombre.
Uint8List downscaleLook(Uint8List bytes) => downscale(bytes, maxSide: 1440);

/// Analiza el color de un PNG recortado, ignorando lo transparente.
PaletteResult extractPalette(Uint8List pngBytes) {
  final src = img.decodePng(pngBytes);
  if (src == null) return PaletteResult.empty;

  // Se submuestrea ya aqui: pasar millones de records al extractor solo para
  // que el descarte 19 de cada 20 es desperdiciar memoria.
  final step = _stepFor(src.width * src.height, 40000);
  final pixels = <Rgba>[];
  for (var y = 0; y < src.height; y += step) {
    for (var x = 0; x < src.width; x += step) {
      final p = src.getPixel(x, y);
      pixels.add((
        r: p.r.toInt(),
        g: p.g.toInt(),
        b: p.b.toInt(),
        a: src.hasAlpha ? p.a.toInt() : 255,
      ));
    }
  }
  return const ColorExtractor().extract(pixels);
}

int _stepFor(int total, int target) {
  if (total <= target) return 1;
  // Paso en ambos ejes, de ahi la raiz cuadrada.
  var step = 1;
  while ((total / (step * step)) > target) {
    step++;
  }
  return step;
}

/// Argumentos de [applyEraserMask]. `compute` solo acepta un parametro.
class MaskArgs {
  const MaskArgs(this.pngBytes, this.maskPng);

  /// Imagen base (con o sin alfa).
  final Uint8List pngBytes;

  /// Mascara en escala de grises del mismo tamano: negro = borrar,
  /// blanco = conservar.
  final Uint8List maskPng;
}

/// Aplica una mascara de borrado pintada a mano sobre la imagen.
///
/// El alfa resultante es el minimo entre el alfa original y el de la
/// mascara, de modo que el retoque manual solo puede quitar mas, nunca
/// resucitar fondo que el usuario ya habia borrado en un paso anterior.
Uint8List applyEraserMask(MaskArgs args) {
  final base = img.decodeImage(args.pngBytes);
  final mask = img.decodeImage(args.maskPng);
  if (base == null || mask == null) return args.pngBytes;

  final out = base.convert(numChannels: 4);
  final sx = mask.width / out.width;
  final sy = mask.height / out.height;

  for (var y = 0; y < out.height; y++) {
    for (var x = 0; x < out.width; x++) {
      final m = mask.getPixel(
        (x * sx).floor().clamp(0, mask.width - 1),
        (y * sy).floor().clamp(0, mask.height - 1),
      );
      final keep = m.r.toInt(); // 0 = borrado, 255 = conservado
      final p = out.getPixel(x, y);
      final a = p.a.toInt();
      out.setPixelRgba(x, y, p.r, p.g, p.b, a < keep ? a : keep);
    }
  }
  return Uint8List.fromList(img.encodePng(out));
}
