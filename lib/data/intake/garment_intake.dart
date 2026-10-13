import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../domain/color/color_extractor.dart';
import '../../domain/models/catalog.dart';
import '../files/image_storage.dart';
import '../images/background_remover.dart';
import '../images/image_ops.dart';
import '../repos/garment_repository.dart';

/// Cómo se quita el fondo. Es una elección explícita del usuario porque
/// ML Kit falla con fondos cargados, y ahí el retoque manual es la
/// diferencia entre una prenda usable y una inservible.
enum RemovalMode {
  auto('Automático', 'Recorta la prenda sola. Rápido.'),
  autoThenTouchUp('Automático y retocar', 'Recorta y te deja corregirlo.'),
  manual('A mano', 'Borra tú el fondo con la brocha.');

  const RemovalMode(this.label, this.description);
  final String label;
  final String description;
}

/// Una prenda recortada y analizada, todavía sin etiquetar ni guardar.
class GarmentCutout {
  const GarmentCutout({
    required this.png,
    required this.palette,
    required this.needsTouchUp,
    this.source,
  });

  /// PNG con fondo transparente, ya recortado al contorno.
  final Uint8List png;

  final PaletteResult palette;

  /// El flujo debe pasar por el editor de máscara antes de etiquetar.
  final bool needsTouchUp;

  /// La foto encuadrada, del mismo tamaño que [png], cuando el recorte vino
  /// de ML Kit y todavía se va a retocar. Es de donde el pincel de
  /// "Restaurar" saca los píxeles que el recorte automático quitó de más:
  /// sin ella solo podría deshacer lo borrado a mano.
  final Uint8List? source;

  GarmentCutout withPng(Uint8List next, PaletteResult nextPalette) =>
      GarmentCutout(
        png: next,
        palette: nextPalette,
        needsTouchUp: false,
      );
}

/// Datos del formulario de etiquetado, ya resueltos a ids de catálogo.
class GarmentTagging {
  const GarmentTagging({
    required this.categoryId,
    required this.colorArgb,
    this.name,
    this.brand,
    this.notes,
    this.seasons = const {},
    this.occasionIds = const {},
    this.moodIds = const {},
    this.tags = const {},
    this.washGroupId,
    this.isFavorite = false,
  });

  final int categoryId;
  final int colorArgb;
  final String? name;
  final String? brand;
  final String? notes;
  final Set<Season> seasons;
  final Set<int> occasionIds;
  final Set<int> moodIds;
  final Set<String> tags;

  /// Con que carga va a la lavadora. Opcional.
  final int? washGroupId;

  final bool isFavorite;
}

/// El alta de una prenda, de principio a fin.
///
/// Antes esto vivía repartido en cuatro métodos privados de un
/// `StatefulWidget`, entrelazado con `setState` y guardas de `mounted`. Las
/// piezas puras estaban testeadas; el montaje no, y el montaje es donde
/// están los fallos de este flujo: el orden de los pasos, el ciclo de vida
/// del temporal que se le pasa a ML Kit, qué queda a medias si algo revienta.
///
/// La interfaz son dos operaciones. Todo lo demás —isolates, ficheros
/// temporales, disco, drift— queda detrás.
class GarmentIntake {
  const GarmentIntake({
    required this.remover,
    required this.storage,
    required this.garments,
    @visibleForTesting this.tempDirectory,
  });

  final BackgroundRemover remover;
  final ImageStorage storage;
  final GarmentRepository garments;

  /// Inyectable para que los tests comprueben que el temporal que se le pasa
  /// a ML Kit siempre se limpia, tambien cuando la segmentacion falla.
  final Future<Directory> Function()? tempDirectory;

  /// Normaliza la foto recién tomada: la reescala a un tamaño con el que se
  /// pueda trabajar sin que la memoria se dispare.
  ///
  /// Una foto de 12 Mpx no mejora ni el recorte ni el análisis de color.
  Future<Uint8List> normalizePhoto(Uint8List raw) =>
      compute(downscale, raw);

  /// Del encuadre al recorte listo para etiquetar.
  ///
  /// Lanza [BackgroundRemovalException] si la segmentación falla. Cuando eso
  /// pasa no queda nada escrito en ningún sitio: el temporal se borra
  /// siempre, tanto en el camino feliz como en el de error.
  Future<GarmentCutout> prepare(
    Uint8List framed,
    RemovalMode mode,
  ) async {
    if (mode == RemovalMode.manual) {
      // Sin recorte automático no hay nada que analizar todavía: el color se
      // calcula al salir del editor, sobre lo que el usuario deje.
      return GarmentCutout(
        png: framed,
        palette: PaletteResult.empty,
        needsTouchUp: true,
      );
    }

    final cut = await _segment(framed);

    if (mode == RemovalMode.autoThenTouchUp) {
      // Sin recortar al contorno: tiene que encajar con [framed]. El recorte
      // se hace al salir del editor, en [finishTouchUp].
      return GarmentCutout(
        png: cut,
        palette: PaletteResult.empty,
        needsTouchUp: true,
        source: framed,
      );
    }

    final trimmed = await compute(autoCropTransparent, cut);
    return GarmentCutout(
      png: trimmed,
      palette: await compute(extractPalette, trimmed),
      needsTouchUp: false,
    );
  }

  /// Cierra el recorte tras pasar por el editor de máscara.
  ///
  /// Recorta al contorno otra vez a propósito: si el usuario borró medio
  /// fondo a mano, la prenda tiene que volver a centrarse.
  Future<GarmentCutout> finishTouchUp(
    GarmentCutout cutout,
    Uint8List edited,
  ) async {
    final trimmed = await compute(autoCropTransparent, edited);
    final palette = await compute(extractPalette, trimmed);
    return cutout.withPng(trimmed, palette);
  }

  /// Persiste la prenda: imágenes a disco y fila en la base.
  ///
  /// Devuelve el id. Si la escritura de la fila falla, borra las imágenes que
  /// acababa de escribir: dejar imágenes huérfanas ocupando espacio por una prenda
  /// que no existe es una fuga silenciosa que nadie va a limpiar nunca.
  Future<int> commit(GarmentCutout cutout, GarmentTagging tagging) async {
    final base = ImageStorage.newBaseName();
    final saved = await storage.writeGarment(base, cutout.png);

    try {
      return await garments.insert(GarmentDraft(
        imagePath: saved.image,
        thumbPath: saved.thumb,
        categoryId: tagging.categoryId,
        dominantColorArgb: tagging.colorArgb,
        palette: cutout.palette.palette,
        name: tagging.name,
        brand: tagging.brand,
        notes: tagging.notes,
        seasons: tagging.seasons,
        occasionIds: tagging.occasionIds,
        moodIds: tagging.moodIds,
        tags: tagging.tags,
        washGroupId: tagging.washGroupId,
        isFavorite: tagging.isFavorite,
      ));
    } catch (_) {
      await storage.deleteAll([saved.image, saved.thumb]);
      rethrow;
    }
  }

  /// ML Kit recibe un fichero, no bytes, así que el recorte hay que volcarlo
  /// a disco. Va a un temporal y no al almacenamiento definitivo porque el
  /// alta todavía puede cancelarse.
  Future<Uint8List> _segment(Uint8List framed) async {
    final dir = await (tempDirectory?.call() ??
        Future.value(Directory.systemTemp));
    final tmp = File(
      '${dir.path}/ivyroom_${DateTime.now().microsecondsSinceEpoch}.png',
    );
    try {
      await tmp.writeAsBytes(framed, flush: true);
      return await remover.removeBackground(tmp);
    } finally {
      if (tmp.existsSync()) {
        try {
          await tmp.delete();
        } on FileSystemException {
          // Un temporal que no se puede borrar no debe tumbar el alta.
        }
      }
    }
  }
}
