
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;

/// Formato en el que se guardan en disco las imagenes de las prendas.
///
/// Existe como interfaz porque el codificador bueno (WebP) es nativo y en un
/// test de `flutter test` no hay plugins: ahi se usa [PngEncoder], que es
/// Dart puro, y el resto del almacenamiento se prueba igual.
abstract class ImageEncoder {
  /// Extension de fichero, sin punto.
  String get extension;

  /// Codifica un PNG (con o sin alfa) al formato de disco.
  Future<Uint8List> encode(Uint8List png, {required int quality});
}

/// Sin perdida. Solo para tests y como red si el nativo no esta disponible.
class PngEncoder implements ImageEncoder {
  const PngEncoder();

  @override
  String get extension => 'png';

  @override
  Future<Uint8List> encode(Uint8List png, {required int quality}) async => png;
}

/// WebP con perdida y con transparencia.
///
/// Un recorte de prenda en PNG pesa unos 300 KB; en WebP a calidad 85 se
/// queda en una sexta parte sin diferencia visible a tamano de pantalla. El
/// PNG es sin perdida, y eso en una foto es pagar por ruido del sensor.
class WebpEncoder implements ImageEncoder {
  const WebpEncoder();

  @override
  String get extension => 'webp';

  @override
  Future<Uint8List> encode(Uint8List png, {required int quality}) async {
    // Solo lee la cabecera: no decodifica pixeles.
    final size = _size(png);
    // Sin tamano no se le puede decir al plugin que no reescale, y por
    // defecto lo haria. Mejor guardar los bytes tal cual: Flutter decodifica
    // por contenido, no por extension.
    if (size == null) return png;
    // `minWidth`/`minHeight` en el plugin son un tope de reescalado; con el
    // tamano real no reescala nada, que es lo que se quiere aqui: el tamano
    // ya lo decide quien llama.
    return FlutterImageCompress.compressWithList(
      png,
      format: CompressFormat.webp,
      quality: quality,
      minWidth: size.$1,
      minHeight: size.$2,
      keepExif: false,
    );
  }
}

(int, int)? _size(Uint8List bytes) {
  try {
    final d = img.PngDecoder().startDecode(bytes);
    if (d != null) return (d.width, d.height);
  } catch (_) {
    // Cabecera ilegible.
  }
  return null;
}

/// WebP si el dispositivo lo sabe hacer; PNG si no.
///
/// En escritorio el plugin no existe, y una app que no puede guardar prendas
/// por un formato es peor que una que ocupa algo mas.
Future<ImageEncoder> bestAvailableEncoder() async {
  const webp = WebpEncoder();
  try {
    final probe = img.Image(width: 2, height: 2, numChannels: 4);
    final out = await webp.encode(
      Uint8List.fromList(img.encodePng(probe)),
      quality: 80,
    );
    if (out.isNotEmpty) return webp;
  } catch (e) {
    // MissingPluginException / UnsupportedError: se cae a PNG.
    debugPrint('[ivy] WebP no disponible, se usa PNG: $e');
  }
  return const PngEncoder();
}
