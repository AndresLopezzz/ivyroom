import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ivyroom/data/db/database.dart';
import 'package:ivyroom/data/files/image_storage.dart';
import 'package:ivyroom/data/remote/closet_restore.dart';
import 'package:ivyroom/data/remote/closet_sync.dart';
import 'package:ivyroom/data/repos/catalog_repository.dart';
import 'package:ivyroom/data/repos/garment_repository.dart';
import 'package:ivyroom/data/repos/outfit_repository.dart';
import 'package:ivyroom/data/repos/plan_repository.dart';

class _Api implements RemoteApi {
  _Api(this.closet);
  final Map<String, Object?> closet;

  @override
  Future<dynamic> query(String path, [Map<String, Object?>? args]) async {
    if (path == 'sync:manifest') {
      return {
        'garments': {
          for (final g in (closet['garments'] as List).cast<Map>())
            '${g['localId']}': 'x',
        },
        'looks': {},
      };
    }
    expect(path, 'view:closet');
    return closet;
  }

  @override
  Future<dynamic> mutation(String path, [Map<String, Object?>? args]) =>
      throw UnimplementedError();

  @override
  Future<String> upload(Uint8List bytes, String contentType) =>
      throw UnimplementedError();
}

void main() {
  late AppDatabase db;
  late Directory root;
  late ClosetRestore restore;
  late GarmentRepository garments;
  late OutfitRepository outfits;
  late PlanRepository plans;

  ClosetRestore build(Map<String, Object?> closet) => ClosetRestore(
        api: _Api(closet),
        storage: ImageStorage.at(root),
        garments: garments,
        catalog: CatalogRepository(db),
        outfits: outfits,
        plans: plans,
        download: (_) async => Uint8List.fromList([1, 2, 3]),
      );

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    root = Directory.systemTemp.createTempSync('ivyroom_restore_');
    garments = GarmentRepository(db);
    outfits = OutfitRepository(db, garments);
    plans = PlanRepository(db, garments, outfits);
  });

  tearDown(() async {
    await db.close();
    root.deleteSync(recursive: true);
  });

  Map<String, Object?> garment(int id, Map<String, Object?> data) => {
        'localId': id,
        'data': data,
        'imageUrl': 'https://x/img$id',
        'thumbUrl': 'https://x/thumb$id',
      };

  test('baja prendas, outfits y el diario a un movil vacio', () async {
    restore = build({
      'garments': [
        garment(10, {
          'name': 'Camiseta rosa',
          'rawName': 'Camiseta rosa',
          'category': 'Camiseta',
          'slot': 'top',
          'color': 0xFFF4A6B0,
          'tags': ['verano'],
          'favorite': true,
        }),
        garment(11, {'name': 'Jean', 'category': 'Jean', 'slot': 'bottom'}),
      ],
      'outfits': [
        {
          'localId': 1,
          'data': {'name': 'Domingo', 'garments': [10, 11]},
        },
      ],
      'looks': [
        {
          'localId': 1,
          'data': {
            'day': DateTime(2026, 10, 1).millisecondsSinceEpoch,
            'garments': [10, 11],
            'worn': true,
          },
          'photoUrl': 'https://x/look',
        },
      ],
    });

    expect(await restore.restore('c1'), 2);

    final all = await garments.getAll();
    final shirt = all.firstWhere((g) => g.category.name == 'Camiseta');
    expect(shirt.name, 'Camiseta rosa');
    expect(shirt.tags, {'verano'});
    expect(shirt.isFavorite, isTrue);
    expect(ImageStorage.at(root).exists(shirt.imagePath), isTrue);
    // Sin nombre propio: el de la nube era el del tipo y no se copia.
    expect(all.firstWhere((g) => g.category.name == 'Jean').name, isNull);

    final saved = await outfits.watchAll().first;
    expect(saved.single.name, 'Domingo');
    expect(saved.single.items, hasLength(2));

    final look = (await plans.forDay(DateTime(2026, 10, 1))).single;
    expect(look.wasWorn, isTrue);
    expect(look.photoPath, isNotNull);
  });

  test('un tipo de prenda que no existe en este movil se crea', () async {
    restore = build({
      'garments': [
        garment(1, {'name': 'Kimono', 'category': 'Kimono', 'slot': 'outer'}),
      ],
      'outfits': [],
      'looks': [],
    });
    await restore.restore('c1');
    expect((await garments.getAll()).single.category.name, 'Kimono');
  });

  test('cuenta lo que hay en la nube', () async {
    restore = build({
      'garments': [garment(1, {'category': 'Camiseta', 'slot': 'top'})],
      'outfits': [],
      'looks': [],
    });
    expect(await restore.remoteCount(), 1);
  });
}
