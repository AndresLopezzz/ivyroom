import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../images/image_encoder.dart';

/// Guarda y resuelve las imágenes de las prendas dentro del sandbox de la app.
///
/// Fuera de esta clase SOLO circulan rutas relativas. La raíz del sandbox de
/// Android cambia entre reinstalaciones y actualizaciones, así que persistir
/// una ruta absoluta rompería todas las imágenes del armario. Esa es la
/// invariante que justifica que este módulo exista.
class ImageStorage {
  /// Acepta la raíz en vez de buscarla, para que los tests puedan apuntar a
  /// un directorio temporal. Antes solo existía `instance()`, que llamaba a
  /// `getApplicationDocumentsDirectory()` por dentro, y eso dejaba la
  /// invariante de arriba sin una sola prueba.
  ImageStorage.at(this._root, {this.encoder = const PngEncoder()}) {
    final dir = Directory(p.join(_root.path, _subdir));
    if (!dir.existsSync()) dir.createSync(recursive: true);
  }

  static const _subdir = 'garments';
  static const thumbSize = 400;

  /// Calidad WebP. El recorte se ve a pantalla completa en el detalle; la
  /// miniatura solo en celdas pequenas y aguanta bastante mas perdida.
  static const imageQuality = 85;
  static const thumbQuality = 75;

  final Directory _root;

  /// Formato de disco. Por defecto PNG, que es lo que puede correr en un
  /// test; la app real pasa el mejor disponible en [instance].
  final ImageEncoder encoder;

  /// Instancia real de la app. Sin caché estática: el `Provider` de Riverpod
  /// ya se encarga de eso, y un `static` mutable filtraba estado entre tests.
  static Future<ImageStorage> instance() async => ImageStorage.at(
        await getApplicationDocumentsDirectory(),
        encoder: await bestAvailableEncoder(),
      );

  /// Convierte una ruta relativa guardada en la base a la ruta absoluta
  /// actual del dispositivo.
  String absolutePath(String relative) => p.join(_root.path, relative);

  File fileFor(String relative) => File(absolutePath(relative));

  bool exists(String relative) => fileFor(relative).existsSync();

  /// Escribe el recorte y su miniatura. Devuelve ambas rutas RELATIVAS.
  ///
  /// Recibe PNG porque es lo que produce todo el flujo de captura; el
  /// formato en disco lo decide [encoder].
  Future<({String image, String thumb})> writeGarment(
    String baseName,
    Uint8List pngBytes,
  ) async {
    // `p.join` usa el separador nativo, que en Windows es `\`. Se normaliza a
    // `/` para que las rutas guardadas sean válidas en cualquier plataforma:
    // una base creada en un test de escritorio tiene que poder leerse igual.
    final ext = encoder.extension;
    final imageRel = _rel('$baseName.$ext');
    final thumbRel = _rel('${baseName}_thumb.$ext');

    await fileFor(imageRel).writeAsBytes(
      await encoder.encode(pngBytes, quality: imageQuality),
      flush: true,
    );

    // La miniatura evita cargar la imagen completa en cada celda del grid,
    // que es lo que mata el scroll con cien prendas. Se hace en un isolate:
    // decodificar el recorte entero en el hilo de la UI congela la pantalla.
    final thumbPng = await compute(makeThumbnail, pngBytes);
    await fileFor(thumbRel).writeAsBytes(
      await encoder.encode(thumbPng, quality: thumbQuality),
      flush: true,
    );

    return (image: imageRel, thumb: thumbRel);
  }

  /// Lado mayor de una foto de look. Se ve a pantalla completa en el
  /// calendario, pero no hace falta mas: es un recuerdo, no un archivo.
  static const lookMaxSide = 1440;

  /// Guarda la foto de un look. Recibe PNG ya reducido ([lookMaxSide]).
  Future<String> writeLook(Uint8List pngBytes) async {
    final rel = _rel('look_${newBaseName()}.${encoder.extension}');
    await fileFor(rel).writeAsBytes(
      await encoder.encode(pngBytes, quality: 80),
      flush: true,
    );
    return rel;
  }

  /// Reescribe una prenda ya guardada en el formato actual.
  ///
  /// Devuelve las rutas nuevas, o `null` si no hay nada que hacer (ya esta
  /// en el formato actual o el fichero no se puede leer). Los ficheros
  /// viejos NO se borran aqui: eso solo es seguro despues de que la base
  /// apunte a los nuevos.
  Future<({String image, String thumb})?> recompress(String imageRel) async {
    if (p.extension(imageRel) == '.${encoder.extension}') return null;
    final file = fileFor(imageRel);
    if (!file.existsSync()) return null;

    final png = await compute(_asPng, await file.readAsBytes());
    if (png == null) return null;
    return writeGarment(
      p.basenameWithoutExtension(imageRel),
      png,
    );
  }

  Future<void> deleteAll(Iterable<String?> relativePaths) async {
    for (final rel in relativePaths) {
      if (rel == null || rel.isEmpty) continue;
      final f = fileFor(rel);
      if (!f.existsSync()) continue;
      try {
        await f.delete();
      } on FileSystemException {
        // Un fichero que ya no está no es un error que deba interrumpir el
        // borrado del resto.
      }
    }
  }

  /// Borra los ficheros del directorio que ya no referencia ninguna prenda.
  ///
  /// Hace falta porque un borrado puede quedarse a medias (la fila se va y
  /// el fichero no) y porque durante un tiempo las fotos originales no se
  /// borraban en absoluto. Devuelve cuantos bytes se recuperaron, para poder
  /// decirselo al usuario en vez de hacerlo a sus espaldas.
  Future<int> pruneOrphans(Set<String> referenced) async {
    final dir = Directory(p.join(_root.path, _subdir));
    if (!dir.existsSync()) return 0;

    // Se comparan nombres de fichero y no rutas: las referencias vienen con
    // separador POSIX y el listado del disco con el nativo.
    final keep = referenced.map((r) => p.basename(r)).toSet();

    var freed = 0;
    for (final entity in dir.listSync()) {
      if (entity is! File) continue;
      if (keep.contains(p.basename(entity.path))) continue;
      try {
        freed += entity.lengthSync();
        entity.deleteSync();
      } on FileSystemException {
        // Un fichero bloqueado no debe interrumpir la limpieza del resto.
      }
    }
    return freed;
  }

  /// Los ficheros del directorio de imagenes.
  List<File> files() {
    final dir = Directory(p.join(_root.path, _subdir));
    if (!dir.existsSync()) return const [];
    return dir.listSync().whereType<File>().toList();
  }

  /// Cuanto ocupan las imagenes del armario, en bytes.
  int usedBytes() {
    final dir = Directory(p.join(_root.path, _subdir));
    if (!dir.existsSync()) return 0;
    var total = 0;
    for (final entity in dir.listSync()) {
      if (entity is File) total += entity.lengthSync();
    }
    return total;
  }

  String _rel(String fileName) => '$_subdir/$fileName';

  static int _counter = 0;

  /// Nombre base único para una prenda nueva.
  ///
  /// Lleva un contador además del reloj porque `microsecondsSinceEpoch` no
  /// tiene la resolución que su nombre promete: en Windows avanza a saltos
  /// de milisegundos, así que dos altas seguidas obtenían el mismo nombre y
  /// la segunda pisaba las imágenes de la primera.
  static String newBaseName() =>
      'g_${DateTime.now().microsecondsSinceEpoch}_${_counter++}';
}

/// Miniatura de [ImageStorage.thumbSize] en el lado mayor, como PNG.
///
/// De nivel superior para poder correr en `compute`.
Uint8List makeThumbnail(Uint8List pngBytes) {
  final decoded = img.decodePng(pngBytes);
  // Si no se pudo decodificar, la miniatura es el original antes que dejar
  // el grid sin imagen.
  if (decoded == null) return pngBytes;
  const size = ImageStorage.thumbSize;
  if (decoded.width <= size && decoded.height <= size) return pngBytes;
  final thumb = img.copyResize(
    decoded,
    width: decoded.width >= decoded.height ? size : null,
    height: decoded.height > decoded.width ? size : null,
    interpolation: img.Interpolation.average,
  );
  return Uint8List.fromList(img.encodePng(thumb, level: 6));
}

Uint8List? _asPng(Uint8List bytes) {
  if (img.PngDecoder().isValidFile(bytes)) return bytes;
  try {
    final decoded = img.decodeImage(bytes);
    return decoded == null ? null : Uint8List.fromList(img.encodePng(decoded));
  } catch (_) {
    // `decodeImage` lanza con algunos bytes corruptos en vez de dar null.
    return null;
  }
}
