import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ivyroom/data/backup/wardrobe_backup.dart';

void main() {
  late Directory root;
  late File db;
  late Directory images;
  late WardrobeBackup backup;

  setUp(() {
    root = Directory.systemTemp.createTempSync('ivyroom_backup_');
    db = File('${root.path}/ivyroom.sqlite')
      ..writeAsStringSync('SQLite format 3 (de mentira)');
    images = Directory('${root.path}/garments')..createSync();
    File('${images.path}/g1.png').writeAsStringSync('imagen 1');
    File('${images.path}/g1_thumb.png').writeAsStringSync('miniatura 1');
    File('${images.path}/g1_orig.jpg').writeAsStringSync('original 1');
    backup = WardrobeBackup(databaseFile: db, imagesDirectory: images);
  });

  tearDown(() {
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  group('exportar', () {
    test('el zip lleva base, imágenes y manifiesto', () async {
      final bytes = await backup.export(garmentCount: 1);
      final archive = ZipDecoder().decodeBytes(bytes);
      final names = archive.files.map((f) => f.name).toSet();

      expect(names, contains(WardrobeBackup.databaseName));
      expect(names, contains(WardrobeBackup.manifestName));
      expect(names, contains('garments/g1.png'));
      expect(names, contains('garments/g1_thumb.png'));
      expect(names, contains('garments/g1_orig.jpg'));
    });

    test('el manifiesto cuenta lo que hay dentro', () async {
      final bytes = await backup.export(garmentCount: 7);
      final summary = WardrobeBackup.inspect(bytes);

      expect(summary.garmentCount, 7);
      expect(summary.imageCount, 3);
      expect(summary.bytes, bytes.length);
    });

    test('el nombre de fichero lleva la fecha para no pisarse', () {
      final a = WardrobeBackup.fileNameFor(DateTime(2026, 8, 22, 9, 5));
      expect(a, 'ivyroom-20260822-0905.zip');
      final b = WardrobeBackup.fileNameFor(DateTime(2026, 12, 1, 23, 59));
      expect(b, 'ivyroom-20261201-2359.zip');
      expect(a, isNot(b));
    });

    test('exportar un armario vacío sigue produciendo un zip válido',
        () async {
      images.deleteSync(recursive: true);
      final bytes = await backup.export(garmentCount: 0);

      final summary = WardrobeBackup.inspect(bytes);
      expect(summary.garmentCount, 0);
      expect(summary.imageCount, 0);
    });

    test('sin base de datos falla en vez de producir un zip inútil',
        () async {
      db.deleteSync();
      await expectLater(
        backup.export(garmentCount: 0),
        throwsA(isA<BackupException>()
            .having((e) => e.problem, 'problema', BackupProblem.corrupted)),
      );
    });
  });

  group('inspeccionar antes de importar', () {
    test('un fichero que no es zip se rechaza con un mensaje claro', () {
      expect(
        () => WardrobeBackup.inspect(
            Uint8List.fromList(utf8.encode('esto es un txt'))),
        throwsA(isA<BackupException>()
            .having((e) => e.problem, 'problema', BackupProblem.notAZip)),
      );
    });

    test('un zip cualquiera sin manifiesto se rechaza', () {
      final other = Archive()
        ..addFile(ArchiveFile('foto.jpg', 3, [1, 2, 3]));
      final bytes = Uint8List.fromList(ZipEncoder().encode(other));

      expect(
        () => WardrobeBackup.inspect(bytes),
        throwsA(isA<BackupException>().having((e) => e.problem, 'problema',
            BackupProblem.notAnIvyroomBackup)),
      );
    });

    test('un respaldo de una versión futura se rechaza', () {
      final manifest = utf8.encode(jsonEncode({
        'format': WardrobeBackup.formatVersion + 1,
        'garments': 1,
      }));
      final archive = Archive()
        ..addFile(ArchiveFile(
            WardrobeBackup.manifestName, manifest.length, manifest))
        ..addFile(ArchiveFile(WardrobeBackup.databaseName, 3, [1, 2, 3]));

      expect(
        () => WardrobeBackup.inspect(
            Uint8List.fromList(ZipEncoder().encode(archive))),
        throwsA(isA<BackupException>().having(
            (e) => e.problem, 'problema', BackupProblem.fromNewerVersion)),
      );
    });

    test('un respaldo sin base de datos se rechaza como dañado', () {
      final manifest = utf8.encode(jsonEncode({'format': 1, 'garments': 1}));
      final archive = Archive()
        ..addFile(ArchiveFile(
            WardrobeBackup.manifestName, manifest.length, manifest));

      expect(
        () => WardrobeBackup.inspect(
            Uint8List.fromList(ZipEncoder().encode(archive))),
        throwsA(isA<BackupException>()
            .having((e) => e.problem, 'problema', BackupProblem.corrupted)),
      );
    });

    test('inspeccionar no toca nada del disco', () async {
      final bytes = await backup.export(garmentCount: 1);
      final before = images.listSync().map((e) => e.path).toSet();

      WardrobeBackup.inspect(bytes);

      expect(images.listSync().map((e) => e.path).toSet(), before);
      expect(db.readAsStringSync(), 'SQLite format 3 (de mentira)');
    });
  });

  group('importar', () {
    /// Un respaldo hecho en "otro teléfono", con contenido distinto.
    Future<Uint8List> foreignBackup() async {
      final other = Directory.systemTemp.createTempSync('ivyroom_other_');
      try {
        final otherDb = File('${other.path}/ivyroom.sqlite')
          ..writeAsStringSync('base del otro telefono');
        final otherImages = Directory('${other.path}/garments')..createSync();
        File('${otherImages.path}/x1.png').writeAsStringSync('foto ajena 1');
        File('${otherImages.path}/x2.png').writeAsStringSync('foto ajena 2');

        // `return await` y no `return` a secas: en un try/finally, un
        // `return future` ejecuta el finally ANTES de que el future resuelva,
        // y el directorio se borraba mientras se estaba leyendo.
        return await WardrobeBackup(
          databaseFile: otherDb,
          imagesDirectory: otherImages,
        ).export(garmentCount: 2);
      } finally {
        other.deleteSync(recursive: true);
      }
    }

    test('reemplaza base e imágenes por las del respaldo', () async {
      final bytes = await foreignBackup();

      final summary = await backup.import(bytes);

      expect(summary.garmentCount, 2);
      expect(db.readAsStringSync(), 'base del otro telefono');
      expect(File('${images.path}/x1.png').readAsStringSync(),
          'foto ajena 1');
    });

    test('las imágenes del armario viejo desaparecen', () async {
      // Si sobrevivieran quedarían huérfanas para siempre: la base nueva no
      // las referencia.
      final bytes = await foreignBackup();

      await backup.import(bytes);

      expect(File('${images.path}/g1.png').existsSync(), isFalse);
      expect(File('${images.path}/g1_orig.jpg').existsSync(), isFalse);
    });

    test('un ciclo exportar-importar deja todo exactamente igual', () async {
      final bytes = await backup.export(garmentCount: 1);

      await backup.import(bytes);

      expect(db.readAsStringSync(), 'SQLite format 3 (de mentira)');
      expect(File('${images.path}/g1.png').readAsStringSync(), 'imagen 1');
      expect(File('${images.path}/g1_thumb.png').readAsStringSync(),
          'miniatura 1');
      expect(File('${images.path}/g1_orig.jpg').readAsStringSync(),
          'original 1');
    });

    test('borra los ficheros auxiliares de SQLite de la base vieja',
        () async {
      // Un -wal que describe la base anterior corrompe la nueva.
      File('${db.path}-wal').writeAsStringSync('wal viejo');
      File('${db.path}-shm').writeAsStringSync('shm viejo');
      final bytes = await foreignBackup();

      await backup.import(bytes);

      expect(File('${db.path}-wal').existsSync(), isFalse);
      expect(File('${db.path}-shm').existsSync(), isFalse);
    });

    test('un zip inválido no toca el armario actual', () async {
      // Lo importante del staging: fallar sin dejar al usuario sin lo viejo
      // y sin lo nuevo.
      await expectLater(
        backup.import(Uint8List.fromList(utf8.encode('basura'))),
        throwsA(isA<BackupException>()),
      );

      expect(db.readAsStringSync(), 'SQLite format 3 (de mentira)');
      expect(File('${images.path}/g1.png').readAsStringSync(), 'imagen 1');
    });

    test('un respaldo de versión futura no toca el armario actual', () async {
      final manifest = utf8.encode(jsonEncode({
        'format': WardrobeBackup.formatVersion + 1,
        'garments': 99,
      }));
      final archive = Archive()
        ..addFile(ArchiveFile(
            WardrobeBackup.manifestName, manifest.length, manifest))
        ..addFile(ArchiveFile(WardrobeBackup.databaseName, 5, [1, 2, 3, 4, 5]));

      await expectLater(
        backup.import(Uint8List.fromList(ZipEncoder().encode(archive))),
        throwsA(isA<BackupException>()),
      );

      expect(db.readAsStringSync(), 'SQLite format 3 (de mentira)');
      expect(File('${images.path}/g1.png').existsSync(), isTrue);
    });

    test('no deja la carpeta de preparación tirada', () async {
      final bytes = await foreignBackup();
      await backup.import(bytes);

      expect(Directory('${root.path}/.ivyroom_import').existsSync(), isFalse);
    });

    test('importar un respaldo vacío deja el armario vacío, no roto',
        () async {
      final other = Directory.systemTemp.createTempSync('ivyroom_empty_');
      final Uint8List bytes;
      try {
        final otherDb = File('${other.path}/ivyroom.sqlite')
          ..writeAsStringSync('base vacia');
        bytes = await WardrobeBackup(
          databaseFile: otherDb,
          imagesDirectory: Directory('${other.path}/garments')..createSync(),
        ).export(garmentCount: 0);
      } finally {
        other.deleteSync(recursive: true);
      }

      await backup.import(bytes);

      expect(images.existsSync(), isTrue);
      expect(images.listSync(), isEmpty);
      expect(db.readAsStringSync(), 'base vacia');
    });
  });
}
