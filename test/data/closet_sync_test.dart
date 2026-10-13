import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:ivyroom/data/files/image_storage.dart';
import 'package:ivyroom/data/remote/closet_sync.dart';
import 'package:ivyroom/domain/models/garment.dart';

import '../support/catalog_fixtures.dart';

/// Servidor falso que recuerda lo subido como lo haria Convex.
class FakeApi implements RemoteApi {
  final images = <String, String>{};
  final looks = <String, String>{};
  var uploads = 0;
  Map<String, Object?>? lastPush;

  @override
  Future<dynamic> query(String path, [Map<String, Object?>? args]) async {
    expect(path, 'sync:manifest');
    return {'garments': {...images}, 'looks': {...looks}};
  }

  @override
  Future<dynamic> mutation(String path, [Map<String, Object?>? args]) async {
    expect(path, 'sync:push');
    lastPush = args;
    for (final g in (args!['garments'] as List).cast<Map>()) {
      if (g['imageId'] != null) images['${g['localId']}'] = g['imageKey'] as String;
    }
    return null;
  }

  @override
  Future<String> upload(Uint8List bytes, String contentType) async {
    uploads++;
    return 'file$uploads';
  }
}

void main() {
  late Directory root;
  late ImageStorage storage;

  setUp(() {
    root = Directory.systemTemp.createTempSync('ivyroom_sync_');
    storage = ImageStorage.at(root);
  });

  tearDown(() => root.deleteSync(recursive: true));

  Garment garment(int id, String image) {
    storage.fileFor(image).writeAsBytesSync([1, 2, 3]);
    final thumb = image.replaceFirst('.', '_thumb.');
    storage.fileFor(thumb).writeAsBytesSync([1]);
    return Garment(
      id: id,
      imagePath: image,
      thumbPath: thumb,
      category: Cat.tshirt,
      dominantColorArgb: 0xFF1E5ADC,
      createdAt: DateTime(2026),
    );
  }

  test('sube las imagenes nuevas y no las que ya estan', () async {
    final api = FakeApi();
    final sync = ClosetSync(api: api, storage: storage);
    final g = [garment(1, 'garments/a.webp'), garment(2, 'garments/b.webp')];

    final first = await sync.push(garments: g, outfits: [], plans: []);
    expect(first.uploaded, 4); // imagen + miniatura de cada una

    final second = await sync.push(garments: g, outfits: [], plans: []);
    expect(second.uploaded, 0,
        reason: 'subirlo todo cada vez se comeria el giga gratuito');
  });

  test('si la imagen cambia de ruta se vuelve a subir', () async {
    final api = FakeApi();
    final sync = ClosetSync(api: api, storage: storage);
    await sync.push(
        garments: [garment(1, 'garments/a.png')], outfits: [], plans: []);

    final again = await sync.push(
        garments: [garment(1, 'garments/a.webp')], outfits: [], plans: []);
    expect(again.uploaded, 2);
  });

  test('una prenda sin fichero se salta sin romper la subida', () async {
    final api = FakeApi();
    final g = garment(1, 'garments/a.webp');
    storage.fileFor(g.imagePath).deleteSync();

    final report = await ClosetSync(api: api, storage: storage)
        .push(garments: [g], outfits: [], plans: []);
    expect(report.garments, 0);
    expect(api.lastPush, isNotNull);
  });

  test('los metadatos llevan nombres de catalogo, no ids', () {
    final data = ClosetSync.garmentData(garment(1, 'garments/a.webp'));
    expect(data['category'], 'Camiseta');
    expect(data['slot'], 'top');
  });
}
