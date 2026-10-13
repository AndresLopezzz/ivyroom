import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:ivyroom/data/files/image_storage.dart';
import 'package:ivyroom/data/images/image_encoder.dart';

Uint8List png(int width, int height) {
  final image = img.Image(width: width, height: height, numChannels: 4);
  img.fill(image, color: img.ColorRgba8(200, 40, 40, 255));
  return Uint8List.fromList(img.encodePng(image));
}

void main() {
  late Directory root;
  late ImageStorage storage;

  setUp(() {
    root = Directory.systemTemp.createTempSync('ivyroom_storage_');
    storage = ImageStorage.at(root);
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  group('rutas relativas', () {
    // Esta es la invariante que justifica que el módulo exista: en Android
    // la raíz del sandbox cambia entre reinstalaciones, así que guardar una
    // ruta absoluta rompería todas las imágenes del armario.
    test('las rutas devueltas no contienen la raíz', () async {
      final saved = await storage.writeGarment('g1', png(80, 80));

      expect(saved.image, isNot(contains(root.path)));
      expect(saved.thumb, isNot(contains(root.path)));
      expect(saved.image, 'garments/g1.png');
      expect(saved.thumb, 'garments/g1_thumb.png');
    });

    test('usa separadores POSIX aunque el test corra en Windows', () async {
      final saved = await storage.writeGarment('g1', png(40, 40));
      expect(saved.image, isNot(contains(r'\')));
    });

    test('una ruta relativa se resuelve contra la raíz actual', () async {
      final saved = await storage.writeGarment('g1', png(40, 40));

      // Simula la reinstalación: misma ruta relativa, raíz distinta.
      final otherRoot = Directory.systemTemp.createTempSync('ivyroom_moved_');
      try {
        final moved = ImageStorage.at(otherRoot);
        expect(moved.absolutePath(saved.image), startsWith(otherRoot.path));
        expect(moved.absolutePath(saved.image), endsWith('g1.png'));
      } finally {
        otherRoot.deleteSync(recursive: true);
      }
    });

    test('crea el subdirectorio si no existe', () {
      expect(Directory('${root.path}/garments').existsSync(), isTrue);
    });
  });

  group('escritura', () {
    test('escribe imagen y miniatura y ambas existen', () async {
      final saved = await storage.writeGarment('g1', png(800, 800));

      expect(storage.exists(saved.image), isTrue);
      expect(storage.exists(saved.thumb), isTrue);
    });

    test('la miniatura se reduce al lado máximo', () async {
      final saved = await storage.writeGarment('g1', png(1200, 600));

      final thumb =
          img.decodePng(await storage.fileFor(saved.thumb).readAsBytes())!;
      expect(thumb.width, ImageStorage.thumbSize);
      // Mantiene la proporción.
      expect(thumb.height, ImageStorage.thumbSize ~/ 2);
    });

    test('una imagen vertical se reduce por el alto', () async {
      final saved = await storage.writeGarment('g1', png(400, 1000));

      final thumb =
          img.decodePng(await storage.fileFor(saved.thumb).readAsBytes())!;
      expect(thumb.height, ImageStorage.thumbSize);
    });

    test('una imagen pequeña no se agranda', () async {
      final saved = await storage.writeGarment('g1', png(100, 100));

      final thumb =
          img.decodePng(await storage.fileFor(saved.thumb).readAsBytes())!;
      expect(thumb.width, lessThanOrEqualTo(ImageStorage.thumbSize));
    });

    test('unos bytes ilegibles no dejan la celda sin imagen', () async {
      // Antes que fallar el alta entera, la miniatura apunta al original.
      final saved = await storage.writeGarment(
          'g1', Uint8List.fromList([1, 2, 3, 4, 5]));

      expect(storage.exists(saved.thumb), isTrue);
    });

    test('usa la extension y la calidad del codificador', () async {
      final enc = _FakeEncoder();
      final webp = ImageStorage.at(root, encoder: enc);

      final saved = await webp.writeGarment('g1', png(800, 800));

      expect(saved.image, 'garments/g1.fake');
      expect(saved.thumb, 'garments/g1_thumb.fake');
      // El recorte se ve a pantalla completa; la miniatura aguanta mas.
      expect(enc.qualities, [ImageStorage.imageQuality, ImageStorage.thumbQuality]);
    });

    test('newBaseName no se repite', () {
      final names = {for (var i = 0; i < 50; i++) ImageStorage.newBaseName()};
      expect(names, hasLength(50));
    });
  });

  group('recompresion', () {
    test('reescribe una prenda vieja en el formato actual', () async {
      final old = await storage.writeGarment('g1', png(800, 400));
      final webp = ImageStorage.at(root, encoder: _FakeEncoder());

      final moved = await webp.recompress(old.image);

      expect(moved!.image, 'garments/g1.fake');
      expect(webp.exists(moved.image), isTrue);
      expect(webp.exists(moved.thumb), isTrue);
      // Lo viejo sigue ahi: solo se borra cuando la base ya apunta a lo nuevo.
      expect(webp.exists(old.image), isTrue);
    });

    test('no toca lo que ya esta en el formato actual', () async {
      final saved = await storage.writeGarment('g1', png(60, 60));
      expect(await storage.recompress(saved.image), isNull);
    });

    test('un fichero que no existe no revienta', () async {
      final webp = ImageStorage.at(root, encoder: _FakeEncoder());
      expect(await webp.recompress('garments/no_existe.png'), isNull);
    });
  });

  group('borrado', () {
    test('borra las rutas indicadas', () async {
      final saved = await storage.writeGarment('g1', png(60, 60));

      await storage.deleteAll([saved.image, saved.thumb]);

      expect(storage.exists(saved.image), isFalse);
      expect(storage.exists(saved.thumb), isFalse);
    });

    test('tolera nulos, vacíos y ficheros que ya no están', () async {
      final saved = await storage.writeGarment('g1', png(60, 60));
      await storage.deleteAll([saved.image]);

      // Segunda pasada sobre lo mismo, más basura: no debe lanzar.
      await expectLater(
        storage.deleteAll([saved.image, null, '', 'garments/no_existe.png']),
        completes,
      );
    });

    test('no toca los ficheros de otras prendas', () async {
      final a = await storage.writeGarment('a', png(60, 60));
      final b = await storage.writeGarment('b', png(60, 60));

      await storage.deleteAll([a.image, a.thumb]);

      expect(storage.exists(b.image), isTrue);
      expect(storage.exists(b.thumb), isTrue);
    });
  });

  group('barrido de huerfanos', () {
    test('borra lo que ya no referencia ninguna prenda', () async {
      final viva = await storage.writeGarment('viva', png(60, 60));
      final muerta = await storage.writeGarment('muerta', png(60, 60));

      final freed = await storage.pruneOrphans({viva.image, viva.thumb});

      expect(storage.exists(viva.image), isTrue);
      expect(storage.exists(viva.thumb), isTrue);
      expect(storage.exists(muerta.image), isFalse);
      expect(storage.exists(muerta.thumb), isFalse);
      expect(freed, greaterThan(0));
    });

    test('recupera las fotos originales que quedaron sueltas', () async {
      // El caso real: durante un tiempo borrar una prenda dejaba su foto
      // original en disco para siempre.
      final viva = await storage.writeGarment('viva', png(60, 60));
      File('${root.path}/garments/muerta_orig.jpg')
          .writeAsBytesSync(png(400, 400));

      await storage.pruneOrphans({viva.image, viva.thumb});

      expect(storage.exists('garments/muerta_orig.jpg'), isFalse);
    });

    test('conserva la original si la prenda la sigue referenciando',
        () async {
      final saved = await storage.writeGarment('viva', png(60, 60));
      const orig = 'garments/viva_orig.jpg';
      storage.fileFor(orig).writeAsBytesSync(png(200, 200));

      await storage.pruneOrphans({saved.image, saved.thumb, orig});

      expect(storage.exists(orig), isTrue);
    });

    test('sin nada que borrar no libera nada', () async {
      final saved = await storage.writeGarment('viva', png(60, 60));
      expect(await storage.pruneOrphans({saved.image, saved.thumb}), 0);
    });

    test('con el armario vacio lo borra todo', () async {
      await storage.writeGarment('a', png(60, 60));
      await storage.writeGarment('b', png(60, 60));

      await storage.pruneOrphans({});

      expect(Directory('${root.path}/garments').listSync(), isEmpty);
    });

    test('usedBytes crece al escribir y baja al barrer', () async {
      expect(storage.usedBytes(), 0);
      final saved = await storage.writeGarment('a', png(200, 200));
      final full = storage.usedBytes();
      expect(full, greaterThan(0));

      await storage.writeGarment('b', png(200, 200));
      expect(storage.usedBytes(), greaterThan(full));

      await storage.pruneOrphans({saved.image, saved.thumb});
      expect(storage.usedBytes(), full);
    });
  });
}

class _FakeEncoder implements ImageEncoder {
  final qualities = <int>[];

  @override
  String get extension => 'fake';

  @override
  Future<Uint8List> encode(Uint8List png, {required int quality}) async {
    qualities.add(quality);
    return png;
  }
}
