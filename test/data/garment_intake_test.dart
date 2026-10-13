import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:ivyroom/data/db/database.dart';
import 'package:ivyroom/data/files/image_storage.dart';
import 'package:ivyroom/data/images/background_remover.dart';
import 'package:ivyroom/data/intake/garment_intake.dart';
import 'package:ivyroom/data/repos/catalog_repository.dart';
import 'package:ivyroom/data/repos/garment_repository.dart';
import 'package:ivyroom/domain/color/color_theory.dart';
import 'package:ivyroom/domain/models/catalog.dart';

/// PNG de `size`x`size` con un cuadrado central opaco del color dado y el
/// resto transparente: imita lo que devuelve la segmentación.
Uint8List cutoutPng(int r, int g, int b, {int size = 60}) {
  final image = img.Image(width: size, height: size, numChannels: 4);
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final inside = x > size ~/ 4 && x < size * 3 ~/ 4 && y > size ~/ 4 &&
          y < size * 3 ~/ 4;
      image.setPixelRgba(x, y, r, g, b, inside ? 255 : 0);
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

Uint8List opaquePng(int r, int g, int b, {int size = 40}) {
  final image = img.Image(width: size, height: size, numChannels: 4);
  img.fill(image, color: img.ColorRgba8(r, g, b, 255));
  return Uint8List.fromList(img.encodePng(image));
}

/// Adaptador falso de segmentación. Es el segundo adaptador que justifica
/// que `BackgroundRemover` sea una interfaz: sin él, probar el alta exigiría
/// un dispositivo con el modelo de ML Kit descargado.
class FakeRemover implements BackgroundRemover {
  FakeRemover({this.result, this.failWith});

  final Uint8List? result;
  final BackgroundRemovalException? failWith;

  /// Rutas de los ficheros que recibió, para poder comprobar después que
  /// ninguno sobrevivió.
  final seenPaths = <String>[];
  var disposed = false;

  @override
  Future<Uint8List> removeBackground(File photo) async {
    seenPaths.add(photo.path);
    expect(photo.existsSync(), isTrue,
        reason: 'la foto debe existir cuando se llama al recorte');
    final failure = failWith;
    if (failure != null) throw failure;
    return result!;
  }

  @override
  Future<void> dispose() async => disposed = true;
}

/// Repositorio que revienta al insertar, para provocar el camino de error de
/// `commit`.
class ExplodingRepository extends GarmentRepository {
  ExplodingRepository(super.db);

  @override
  Future<int> insert(GarmentDraft d) async => throw StateError('boom');
}

void main() {
  late Directory tmpRoot;
  late AppDatabase db;
  late ImageStorage storage;
  late GarmentRepository garments;
  late int categoryId;

  setUp(() async {
    tmpRoot = Directory.systemTemp.createTempSync('ivyroom_intake_');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    storage = ImageStorage.at(tmpRoot);
    garments = GarmentRepository(db);
    final cats = await CatalogRepository(db).categories();
    categoryId = cats.firstWhere((c) => c.name == 'Camiseta').id;
  });

  tearDown(() async {
    await db.close();
    if (tmpRoot.existsSync()) tmpRoot.deleteSync(recursive: true);
  });

  GarmentIntake intakeWith(BackgroundRemover remover,
          {GarmentRepository? repo}) =>
      GarmentIntake(
        remover: remover,
        storage: storage,
        garments: repo ?? garments,
        tempDirectory: () async => tmpRoot,
      );


  group('prepare', () {
    test('modo manual no llama a la segmentación y pide retoque', () async {
      final remover = FakeRemover();
      final photo = opaquePng(200, 40, 40);

      final cutout =
          await intakeWith(remover).prepare(photo, RemovalMode.manual);

      expect(remover.seenPaths, isEmpty);
      expect(cutout.needsTouchUp, isTrue);
      expect(cutout.png, photo);
    });

    test('modo automático recorta y ya trae el color analizado', () async {
      final remover = FakeRemover(result: cutoutPng(220, 30, 30));

      final cutout = await intakeWith(remover)
          .prepare(opaquePng(10, 10, 10), RemovalMode.auto);

      expect(cutout.needsTouchUp, isFalse);
      expect(Hsl.fromArgb(cutout.palette.dominant).family, ColorFamily.red);
    });

    test('modo automático con retoque no analiza el color todavía', () async {
      // Analizarlo aquí sería trabajo tirado: el usuario aún va a borrar
      // zonas, y eso cambia el color dominante.
      final remover = FakeRemover(result: cutoutPng(220, 30, 30));

      final cutout = await intakeWith(remover)
          .prepare(opaquePng(10, 10, 10), RemovalMode.autoThenTouchUp);

      expect(cutout.needsTouchUp, isTrue);
      expect(cutout.palette.palette, isEmpty);
    });

    test('con retoque pasa la foto para poder restaurar lo que ML Kit quito',
        () async {
      // Del tamano de la foto y sin recortar al contorno: tiene que encajar
      // pixel a pixel con ella o "Restaurar" pintaria desplazado.
      final cut = cutoutPng(220, 30, 30, size: 100);
      final framed = opaquePng(10, 10, 10);
      final cutout = await intakeWith(FakeRemover(result: cut))
          .prepare(framed, RemovalMode.autoThenTouchUp);

      expect(cutout.source, framed);
      expect(cutout.png, cut);
    });

    test('el modo automatico si recorta al contorno', () async {
      final cut = cutoutPng(220, 30, 30, size: 100);
      final cutout = await intakeWith(FakeRemover(result: cut))
          .prepare(opaquePng(10, 10, 10), RemovalMode.auto);

      expect(img.decodePng(cutout.png)!.width, lessThan(100));
      expect(cutout.source, isNull);
    });
  });

  group('ciclo de vida del fichero temporal', () {
    test('borra el temporal tras un recorte correcto', () async {
      final remover = FakeRemover(result: cutoutPng(220, 30, 30));

      await intakeWith(remover)
          .prepare(opaquePng(10, 10, 10), RemovalMode.auto);

      expect(remover.seenPaths, hasLength(1));
      expect(File(remover.seenPaths.single).existsSync(), isFalse);
    });

    test('borra el temporal también cuando la segmentación falla', () async {
      // Este es justo el fallo que no se podía comprobar mientras el pipeline
      // vivía dentro del StatefulWidget.
      final remover = FakeRemover(
        failWith:
            const BackgroundRemovalException(RemovalFailure.noSubject),
      );

      await expectLater(
        intakeWith(remover).prepare(opaquePng(10, 10, 10), RemovalMode.auto),
        throwsA(isA<BackgroundRemovalException>()),
      );

      expect(remover.seenPaths, hasLength(1));
      expect(File(remover.seenPaths.single).existsSync(), isFalse);
    });

    test('un fallo de segmentación no deja nada escrito ni en base', () async {
      final remover = FakeRemover(
        failWith: const BackgroundRemovalException(
            RemovalFailure.modelUnavailable),
      );

      await expectLater(
        intakeWith(remover).prepare(opaquePng(10, 10, 10), RemovalMode.auto),
        throwsA(isA<BackgroundRemovalException>()),
      );

      expect(await garments.getAll(), isEmpty);
      expect(
        Directory('${tmpRoot.path}/garments').listSync(),
        isEmpty,
      );
    });
  });

  group('finishTouchUp', () {
    test('recorta al contorno y calcula el color de lo que quedó', () async {
      final remover = FakeRemover(result: cutoutPng(10, 10, 10));
      final intake = intakeWith(remover);
      final cutout =
          await intake.prepare(opaquePng(5, 5, 5), RemovalMode.manual);

      // El editor devuelve un PNG con un cuadrado azul centrado y el resto
      // transparente, más grande que el contenido.
      final edited = cutoutPng(30, 90, 220, size: 100);
      final done = await intake.finishTouchUp(cutout, edited);

      expect(done.needsTouchUp, isFalse);
      expect(Hsl.fromArgb(done.palette.dominant).family, ColorFamily.blue);

      // Recortado al contorno: el resultado es menor que los 100px de origen.
      final decoded = img.decodePng(done.png)!;
      expect(decoded.width, lessThan(100));
    });
  });

  group('commit', () {
    test('persiste la prenda con rutas relativas y ficheros reales',
        () async {
      final remover = FakeRemover(result: cutoutPng(220, 30, 30));
      final intake = intakeWith(remover);
      final cutout = await intake.prepare(
          opaquePng(10, 10, 10), RemovalMode.auto);

      final id = await intake.commit(
        cutout,
        GarmentTagging(categoryId: categoryId, colorArgb: 0xFFDC1E1E),
      );

      final saved = await garments.findById(id);
      expect(saved, isNotNull);
      expect(saved!.category.name, 'Camiseta');

      // La invariante del proyecto: nunca rutas absolutas en la base.
      expect(saved.imagePath, startsWith('garments/'));
      expect(saved.thumbPath, startsWith('garments/'));
      expect(saved.imagePath, isNot(contains(tmpRoot.path)));

      expect(storage.exists(saved.imagePath), isTrue);
      expect(storage.exists(saved.thumbPath), isTrue);
      // La foto sin recortar no se usaba en ningun sitio y era el 75 % del
      // espacio de cada prenda.
      expect(saved.originalPath, isNull);
    });

    test('si la fila falla, no deja imágenes huérfanas en disco', () async {
      final remover = FakeRemover(result: cutoutPng(220, 30, 30));
      final intake = intakeWith(remover, repo: ExplodingRepository(db));
      final cutout =
          await intake.prepare(opaquePng(10, 10, 10), RemovalMode.auto);

      await expectLater(
        intake.commit(cutout, GarmentTagging(categoryId: categoryId, colorArgb: 0xFFDC1E1E)),
        throwsA(isA<StateError>()),
      );

      expect(Directory('${tmpRoot.path}/garments').listSync(), isEmpty);
    });

    test('guarda temporadas, ocasiones, moods y tags', () async {
      final catalog = CatalogRepository(db);
      final occ = await catalog.watchOccasions().first;
      final moods = await catalog.watchMoods().first;

      final remover = FakeRemover(result: cutoutPng(220, 30, 30));
      final intake = intakeWith(remover);
      final cutout =
          await intake.prepare(opaquePng(10, 10, 10), RemovalMode.auto);

      final id = await intake.commit(
        cutout,
        GarmentTagging(
          categoryId: categoryId,
          colorArgb: 0xFFDC1E1E,
          seasons: {Season.summer},
          occasionIds: {occ.first.id},
          moodIds: {moods.first.id},
          tags: {'playa'},
          isFavorite: true,
        ),
      );

      final saved = (await garments.findById(id))!;
      expect(saved.seasons, {Season.summer});
      expect(saved.occasions.single.name, occ.first.name);
      expect(saved.moods.single.name, moods.first.name);
      expect(saved.tags, {'playa'});
      expect(saved.isFavorite, isTrue);
    });
  });
}
