import 'dart:io';

import 'package:path/path.dart' as p;

import '../repos/garment_repository.dart';
import 'image_storage.dart';

/// Pone las imagenes que ya hay en disco al dia con el formato actual.
///
/// Las primeras versiones guardaban todo en PNG y, ademas, la foto sin
/// recortar de cada prenda —que no usaba ninguna pantalla y era el 75 % del
/// espacio—. Esto recomprime los recortes y miniaturas al formato de
/// [ImageStorage.encoder] y borra las originales.
///
/// Es idempotente y barato cuando no queda nada que hacer, asi que corre en
/// cada arranque: no hace falta guardar en ningun sitio si ya se hizo, y si
/// una pasada se corta a medias la siguiente la termina.
class ImageMigration {
  const ImageMigration({
    required this.storage,
    required this.garments,
    this.cacheDirectory,
  });

  final ImageStorage storage;
  final GarmentRepository garments;

  /// Cache de la app, para barrer lo que dejaron versiones anteriores.
  final Directory? cacheDirectory;

  /// Devuelve los bytes liberados.
  Future<int> run() async {
    final before = storage.usedBytes();

    for (final g in await garments.getAll(includeArchived: true)) {
      final stale = p.extension(g.imagePath) != '.${storage.encoder.extension}';
      if (!stale && g.originalPath == null) continue;

      try {
        final moved = stale ? await storage.recompress(g.imagePath) : null;
        await garments.replaceImages(
          g.id,
          image: moved?.image ?? g.imagePath,
          thumb: moved?.thumb ?? g.thumbPath,
        );
        // Despues de actualizar la fila, nunca antes: si esto se corta, lo
        // peor que queda es un fichero huerfano, no una prenda sin imagen.
        await storage.deleteAll([
          if (moved != null) ...[g.imagePath, g.thumbPath],
          g.originalPath,
        ]);
      } catch (_) {
        // Una prenda que no se puede convertir se queda como estaba; no es
        // motivo para dejar las demas sin convertir.
      }
    }

    // Originales que ya no apunta ninguna fila: las dejaban versiones que
    // borraban la prenda sin su foto. Solo `_orig`, nunca un barrido
    // general: un alta en curso escribe sus imagenes antes que su fila, y un
    // barrido de huerfanos ahora mismo se las llevaria por delante.
    final referenced = await garments.allImagePaths();
    for (final f in storage.files()) {
      final rel = 'garments/${p.basename(f.path)}';
      if (p.basenameWithoutExtension(f.path).endsWith('_orig') &&
          !referenced.contains(rel)) {
        await storage.deleteAll([rel]);
      }
    }

    final cacheFreed = _sweepCache();
    return before - storage.usedBytes() + cacheFreed;
  }

  static const _leftovers = {'.jpg', '.jpeg', '.png', '.webp', '.heic', '.zip'};

  /// Fotos que el selector copio a la cache y respaldos ya compartidos.
  ///
  /// Solo ficheros sueltos en la raiz, nunca subdirectorios: ahi guardan sus
  /// cosas ML Kit y otros plugins. Y solo lo que tiene mas de unos minutos:
  /// esto corre al arrancar, pero nada impide abrir el alta mientras tanto, y
  /// la foto recien elegida no se puede borrar debajo del usuario.
  int _sweepCache() {
    final dir = cacheDirectory;
    if (dir == null || !dir.existsSync()) return 0;
    final cutoff = DateTime.now().subtract(const Duration(minutes: 10));
    var freed = 0;
    for (final e in dir.listSync()) {
      if (e is! File) continue;
      if (!_leftovers.contains(p.extension(e.path).toLowerCase())) continue;
      try {
        if (e.lastModifiedSync().isAfter(cutoff)) continue;
        final size = e.lengthSync();
        e.deleteSync();
        freed += size;
      } on FileSystemException {
        // Bloqueado o ya borrado: no importa.
      }
    }
    return freed;
  }
}
