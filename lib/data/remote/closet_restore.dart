import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../domain/models/catalog.dart';
import '../../domain/models/garment.dart';
import '../files/image_storage.dart';
import '../repos/catalog_repository.dart';
import '../repos/garment_repository.dart';
import '../repos/outfit_repository.dart';
import '../repos/plan_repository.dart';
import 'closet_sync.dart';

/// Baja de la nube un armario completo a un movil vacio.
///
/// Es el camino de vuelta de [ClosetSync]: sin el, reinstalar la app dejaba
/// el armario solo en el servidor, y la primera sincronizacion lo borraba.
/// Las prendas se recrean con ids locales nuevos; los outfits y el diario se
/// reenganchan con una tabla de equivalencias.
class ClosetRestore {
  ClosetRestore({
    required this.api,
    required this.storage,
    required this.garments,
    required this.catalog,
    required this.outfits,
    required this.plans,
    Future<Uint8List> Function(String url)? download,
  }) : _download = download ?? _httpGet;

  final RemoteApi api;
  final ImageStorage storage;
  final GarmentRepository garments;
  final CatalogRepository catalog;
  final OutfitRepository outfits;
  final PlanRepository plans;
  final Future<Uint8List> Function(String url) _download;

  static Future<Uint8List> _httpGet(String url) async {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) throw Exception('Descarga fallida');
    return res.bodyBytes;
  }

  /// Cuantas prendas tiene la nube para este usuario.
  Future<int> remoteCount() async {
    final manifest = await api.query('sync:manifest') as Map;
    return (manifest['garments'] as Map).length;
  }

  /// Restaura y devuelve cuantas prendas se recuperaron.
  Future<int> restore(String closetId) async {
    final raw =
        await api.query('view:closet', {'closetId': closetId}) as Map;

    var categories = await catalog.categories();
    final occasions = {
      for (final o in await catalog.watchOccasions().first) o.name: o.id,
    };
    final moods = {for (final m in await catalog.watchMoods().first) m.name: m.id};

    final idMap = <int, Garment>{};
    for (final g in (raw['garments'] as List).cast<Map>()) {
      final data = Map<String, dynamic>.from(g['data'] as Map);
      final imageUrl = g['imageUrl'] as String?;
      final thumbUrl = g['thumbUrl'] as String?;
      if (imageUrl == null || thumbUrl == null) continue;

      // Tipo de prenda por nombre; si no existe en este movil, se crea con
      // la ranura que traia.
      final catName = data['category'] as String? ?? 'Otro';
      var category = categories.where((c) => c.name == catName).firstOrNull;
      if (category == null) {
        final slot = Slot.values
                .where((s) => s.name == data['slot'])
                .firstOrNull ??
            Slot.accessory;
        await catalog.createCategory(name: catName, slot: slot);
        categories = await catalog.categories();
        category = categories.firstWhere((c) => c.name == catName);
      }

      Future<int> idFor(Map<String, int> table, String name,
          Future<int> Function(String) create) async {
        return table[name] ??= await create(name);
      }

      final base = ImageStorage.newBaseName();
      final ext = imageUrl.contains('.png') ? 'png' : 'webp';
      final imageRel = 'garments/$base.$ext';
      final thumbRel = 'garments/${base}_thumb.$ext';
      try {
        await storage.fileFor(imageRel).writeAsBytes(await _download(imageUrl));
        await storage.fileFor(thumbRel).writeAsBytes(await _download(thumbUrl));
      } catch (_) {
        await storage.deleteAll([imageRel, thumbRel]);
        continue; // una imagen caida no frena el resto
      }

      final id = await garments.insert(GarmentDraft(
        imagePath: imageRel,
        thumbPath: thumbRel,
        categoryId: category.id,
        dominantColorArgb: (data['color'] as num?)?.toInt() ?? 0xFF9E9E9E,
        name: _name(data, catName),
        brand: data['brand'] as String?,
        notes: data['notes'] as String?,
        seasons: {
          for (final s in (data['seasons'] as List? ?? const []))
            ...Season.values.where((v) => v.name == s),
        },
        occasionIds: {
          for (final o in (data['occasions'] as List? ?? const []).cast<String>())
            await idFor(occasions, o, (n) => catalog.createOccasion(name: n)),
        },
        moodIds: {
          for (final m in (data['moods'] as List? ?? const []).cast<String>())
            await idFor(moods, m, catalog.createMood),
        },
        tags: {...(data['tags'] as List? ?? const []).cast<String>()},
        isFavorite: data['favorite'] as bool? ?? false,
      ));
      if (data['archived'] == true) await garments.setArchived(id, true);
      final restored = await garments.findById(id);
      if (restored != null) idMap[(g['localId'] as num).toInt()] = restored;
    }

    List<Garment> mapIds(Object? ids) => [
          for (final id in (ids as List? ?? const []))
            ?idMap[(id as num).toInt()],
        ];

    for (final o in (raw['outfits'] as List).cast<Map>()) {
      final data = Map<String, dynamic>.from(o['data'] as Map);
      final items = mapIds(data['garments']);
      if (items.isEmpty) continue;
      final name = data['name'] as String?;
      final id = await outfits.save(items, name: name == 'Outfit' ? null : name);
      if (data['favorite'] == true) await outfits.setFavorite(id, true);
    }

    for (final l in (raw['looks'] as List).cast<Map>()) {
      final data = Map<String, dynamic>.from(l['data'] as Map);
      final items = mapIds(data['garments']);
      if (items.isEmpty) continue;
      final day = DateTime.fromMillisecondsSinceEpoch(
          (data['day'] as num).toInt());
      final planId = await plans.addPlan(day, garments: items);
      if (data['worn'] == true) await plans.markWorn(planId);
      final photoUrl = l['photoUrl'] as String?;
      if (photoUrl != null) {
        try {
          final rel = 'garments/look_${ImageStorage.newBaseName()}.webp';
          await storage.fileFor(rel).writeAsBytes(await _download(photoUrl));
          await plans.setPhoto(planId, rel);
        } catch (_) {
          // Sin la foto el look sigue valiendo.
        }
      }
    }

    return idMap.length;
  }

  /// El nombre propio de la prenda. Las primeras versiones subian el nombre
  /// visible, que sin nombre propio es el del tipo: ese no se restaura.
  static String? _name(Map<String, dynamic> data, String category) {
    if (data.containsKey('rawName')) return data['rawName'] as String?;
    final n = data['name'] as String?;
    return n == null || n == category ? null : n;
  }
}
