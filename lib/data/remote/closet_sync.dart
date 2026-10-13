import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../domain/models/garment.dart';
import '../../domain/models/outfit.dart';
import '../files/image_storage.dart';
import '../repos/plan_repository.dart';

/// Lo que la sincronizacion necesita del servidor. Interfaz para poder
/// probarla con un servidor falso.
abstract class RemoteApi {
  Future<dynamic> query(String path, [Map<String, Object?> args]);
  Future<dynamic> mutation(String path, [Map<String, Object?> args]);
  Future<String> upload(Uint8List bytes, String contentType);
}

class SyncReport {
  const SyncReport({required this.uploaded, required this.garments});

  /// Ficheros subidos en esta pasada.
  final int uploaded;
  final int garments;
}

/// Sube a Convex una copia del armario local.
///
/// El movil manda: el servidor solo refleja. Se mandan siempre todos los
/// metadatos (son pocos KB) y solo las imagenes que el servidor no tiene ya,
/// que es lo caro. El servidor borra lo que el movil ya no tiene.
class ClosetSync {
  const ClosetSync({required this.api, required this.storage});

  final RemoteApi api;
  final ImageStorage storage;

  Future<SyncReport> push({
    required List<Garment> garments,
    required List<SavedOutfit> outfits,
    required List<DayPlan> plans,
  }) async {
    final manifest = await api.query('sync:manifest') as Map;
    final remoteImages = Map<String, dynamic>.from(manifest['garments'] as Map);
    final remoteLooks = Map<String, dynamic>.from(manifest['looks'] as Map);
    var uploaded = 0;

    final garmentRows = <Map<String, Object?>>[];
    for (final g in garments) {
      final row = <String, Object?>{
        'localId': g.id,
        'data': garmentData(g),
        'imageKey': g.imagePath,
      };
      if (remoteImages['${g.id}'] != g.imagePath) {
        final image = storage.fileFor(g.imagePath);
        final thumb = storage.fileFor(g.thumbPath);
        // Sin fichero no se puede subir; la prenda espera a la proxima vez.
        if (!image.existsSync() || !thumb.existsSync()) continue;
        row['imageId'] =
            await api.upload(await image.readAsBytes(), _mime(g.imagePath));
        row['thumbId'] =
            await api.upload(await thumb.readAsBytes(), _mime(g.thumbPath));
        uploaded += 2;
      }
      garmentRows.add(row);
    }

    final lookRows = <Map<String, Object?>>[];
    for (final plan in plans) {
      final row = <String, Object?>{
        'localId': plan.id,
        'data': lookData(plan),
      };
      final photo = plan.photoPath;
      if (photo != null) {
        row['photoKey'] = photo;
        final file = storage.fileFor(photo);
        if (remoteLooks['${plan.id}'] != photo && file.existsSync()) {
          row['photoId'] =
              await api.upload(await file.readAsBytes(), _mime(photo));
          uploaded++;
        }
      }
      lookRows.add(row);
    }

    await api.mutation('sync:push', {
      'garments': garmentRows,
      'outfits': [
        for (final o in outfits) {'localId': o.id, 'data': outfitData(o)},
      ],
      'looks': lookRows,
    });

    return SyncReport(uploaded: uploaded, garments: garmentRows.length);
  }

  static String _mime(String path) => switch (p.extension(path)) {
        '.webp' => 'image/webp',
        '.png' => 'image/png',
        _ => 'image/jpeg',
      };

  /// Lo que el visor necesita para pintar y filtrar una prenda. Nombres y no
  /// ids de catalogo: el visor no tiene la base del dueno.
  static Map<String, Object?> garmentData(Garment g) => {
        'name': g.displayName,
        // El nombre propio, que puede no existir. `name` es el visible.
        'rawName': g.name,
        'brand': g.brand,
        'notes': g.notes,
        'category': g.category.name,
        'slot': g.slot.name,
        'color': g.dominantColorArgb,
        'seasons': [for (final s in g.seasons) s.name],
        'occasions': [for (final o in g.occasions) o.name],
        'moods': [for (final m in g.moods) m.name],
        'tags': g.tags.toList(),
        'favorite': g.isFavorite,
        'archived': g.isArchived,
        'wearCount': g.wearCount,
        'lastWornAt': g.lastWornAt?.millisecondsSinceEpoch,
        'createdAt': g.createdAt.millisecondsSinceEpoch,
      };

  static Map<String, Object?> outfitData(SavedOutfit o) => {
        'name': o.displayName,
        'garments': [for (final g in o.items) g.id],
        'favorite': o.isFavorite,
        'wearCount': o.wearCount,
      };

  static Map<String, Object?> lookData(DayPlan plan) => {
        'day': plan.day.millisecondsSinceEpoch,
        'garments': [for (final g in plan.items) g.id],
        'worn': plan.wasWorn,
        'title': plan.title,
      };
}
