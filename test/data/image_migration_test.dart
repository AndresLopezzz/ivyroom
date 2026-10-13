import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:ivyroom/data/db/database.dart';
import 'package:ivyroom/data/files/image_migration.dart';
import 'package:ivyroom/data/files/image_storage.dart';
import 'package:ivyroom/data/images/image_encoder.dart';
import 'package:ivyroom/data/repos/catalog_repository.dart';
import 'package:ivyroom/data/repos/garment_repository.dart';

Uint8List png(int w, int h) {
  final image = img.Image(width: w, height: h, numChannels: 4);
  img.fill(image, color: img.ColorRgba8(30, 90, 220, 255));
  return Uint8List.fromList(img.encodePng(image));
}

/// Hace de WebP sin plugin: misma forma, otra extension.
class _FakeWebp implements ImageEncoder {
  @override
  String get extension => 'webp';

  @override
  Future<Uint8List> encode(Uint8List png, {required int quality}) async =>
      png;
}

void main() {
  late AppDatabase db;
  late GarmentRepository repo;
  late Directory root;
  late Directory cache;
  late int categoryId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = GarmentRepository(db);
    root = Directory.systemTemp.createTempSync('ivyroom_mig_');
    cache = Directory.systemTemp.createTempSync('ivyroom_cache_');
    categoryId = (await CatalogRepository(db).categories()).first.id;
  });

  tearDown(() async {
    await db.close();
    root.deleteSync(recursive: true);
    cache.deleteSync(recursive: true);
  });

  /// Una prenda como las guardaba la version vieja: PNG y con original.
  Future<int> legacyGarment(String base) async {
    final old = ImageStorage.at(root);
    final saved = await old.writeGarment(base, png(800, 600));
    final orig = 'garments/${base}_orig.jpg';
    old.fileFor(orig).writeAsBytesSync(png(1200, 900));
    return repo.insert(GarmentDraft(
      imagePath: saved.image,
      thumbPath: saved.thumb,
      originalPath: orig,
      categoryId: categoryId,
      dominantColorArgb: 0xFF1E5ADC,
    ));
  }

  ImageMigration migration() => ImageMigration(
        storage: ImageStorage.at(root, encoder: _FakeWebp()),
        garments: repo,
        cacheDirectory: cache,
      );

  test('convierte las prendas viejas y borra originales', () async {
    final id = await legacyGarment('g1');

    await migration().run();

    final g = (await repo.findById(id))!;
    expect(g.imagePath, 'garments/g1.webp');
    expect(g.thumbPath, 'garments/g1_thumb.webp');
    expect(g.originalPath, isNull);
    final files = Directory('${root.path}/garments')
        .listSync()
        .map((e) => e.uri.pathSegments.last)
        .toSet();
    expect(files, {'g1.webp', 'g1_thumb.webp'});
  });

  test('una segunda pasada no hace nada', () async {
    await legacyGarment('g1');
    await migration().run();
    expect(await migration().run(), 0);
  });

  test('una prenda con la imagen perdida no frena a las demas', () async {
    final rota = await legacyGarment('rota');
    final buena = await legacyGarment('buena');
    File('${root.path}/garments/rota.png').deleteSync();

    await migration().run();

    expect((await repo.findById(buena))!.imagePath, 'garments/buena.webp');
    // Sigue apuntando a lo que tenia: no se inventa una ruta.
    expect((await repo.findById(rota))!.imagePath, 'garments/rota.png');
  });

  test('barre las fotos viejas de la cache pero no las recientes', () async {
    final vieja = File('${cache.path}/scaled_1.jpg')..writeAsBytesSync([1, 2]);
    vieja.setLastModifiedSync(DateTime.now().subtract(const Duration(hours: 1)));
    final reciente = File('${cache.path}/scaled_2.jpg')
      ..writeAsBytesSync([1, 2]);
    final mlkit = Directory('${cache.path}/drishti_asset_cache')..createSync();
    File('${mlkit.path}/model.bin')
      ..writeAsBytesSync([1])
      ..setLastModifiedSync(DateTime(2020));

    await migration().run();

    expect(vieja.existsSync(), isFalse);
    // Puede ser la foto que el usuario acaba de elegir.
    expect(reciente.existsSync(), isTrue);
    // Lo de otros plugins no se toca.
    expect(mlkit.existsSync(), isTrue);
  });

  test('borra originales sueltas pero no otras imagenes sin fila', () async {
    final dir = Directory('${root.path}/garments')..createSync();
    final suelta = File('${dir.path}/vieja_orig.jpg')..writeAsBytesSync([1]);
    // Un alta en curso: imagen escrita, fila todavia no.
    final enCurso = File('${dir.path}/nueva.webp')..writeAsBytesSync([1]);

    await migration().run();

    expect(suelta.existsSync(), isFalse);
    expect(enCurso.existsSync(), isTrue);
  });
}
