import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

/// Qué salió mal al importar. Se distingue para poder decir algo útil en vez
/// de "fichero inválido": casi siempre el usuario ha elegido el zip
/// equivocado, y saberlo le ahorra pensar que su respaldo está roto.
enum BackupProblem {
  notAZip,
  notAnIvyroomBackup,
  fromNewerVersion,
  corrupted,
}

class BackupException implements Exception {
  const BackupException(this.problem, [this.detail]);
  final BackupProblem problem;
  final String? detail;

  String get message => switch (problem) {
        BackupProblem.notAZip =>
          'Ese archivo no es un respaldo de Ivyroom.',
        BackupProblem.notAnIvyroomBackup =>
          'El archivo es un zip, pero no contiene un respaldo de Ivyroom.',
        BackupProblem.fromNewerVersion =>
          'Ese respaldo lo creó una versión más nueva de la app. Actualiza '
              'Ivyroom antes de importarlo.',
        BackupProblem.corrupted =>
          'El respaldo está incompleto o dañado y no se puede importar.',
      };

  @override
  String toString() => 'BackupException($problem): $detail';
}

/// Lo que se sabe de un respaldo antes de decidir importarlo.
class BackupSummary {
  const BackupSummary({
    required this.garmentCount,
    required this.imageCount,
    required this.createdAt,
    required this.appVersion,
    required this.bytes,
  });

  final int garmentCount;
  final int imageCount;
  final DateTime createdAt;
  final String appVersion;
  final int bytes;
}

/// Empaqueta y restaura el armario completo.
///
/// Todo vive solo en el teléfono, así que sin esto un teléfono perdido o
/// roto significa perder el armario entero, con las horas de fotografiar y
/// etiquetar dentro. Y el riesgo crece con cada prenda que se añade.
///
/// El formato es un zip corriente: la base SQLite tal cual, la carpeta de
/// imágenes, y un manifiesto con la versión. Deliberadamente inspeccionable
/// desde cualquier ordenador — si algún día la app desaparece, las fotos
/// siguen ahí.
class WardrobeBackup {
  const WardrobeBackup({
    required this.databaseFile,
    required this.imagesDirectory,
    this.appVersion = '1',
  });

  /// Fichero SQLite de la app.
  final File databaseFile;

  /// Directorio con los PNG y las miniaturas.
  final Directory imagesDirectory;

  final String appVersion;

  static const manifestName = 'ivyroom.json';
  static const databaseName = 'ivyroom.sqlite';
  static const imagesPrefix = 'garments/';

  /// Versión del formato del propio respaldo, no de la app. Sube solo si el
  /// zip deja de poder leerse con el código viejo.
  static const formatVersion = 1;

  // ---- exportar ----------------------------------------------------------

  /// Construye el zip en memoria y devuelve sus bytes.
  ///
  /// Se hace en memoria a propósito: un armario de 200 prendas ronda los
  /// 60 MB, que cabe de sobra, y evita dejar temporales a medias si el
  /// usuario cancela el diálogo de compartir.
  Future<Uint8List> export({required int garmentCount}) async {
    final archive = Archive();

    if (!databaseFile.existsSync()) {
      throw const BackupException(
          BackupProblem.corrupted, 'no existe la base de datos');
    }

    final dbBytes = await databaseFile.readAsBytes();
    archive.addFile(
        ArchiveFile(databaseName, dbBytes.length, dbBytes));

    var imageCount = 0;
    if (imagesDirectory.existsSync()) {
      for (final entity in imagesDirectory.listSync()) {
        if (entity is! File) continue;
        final bytes = await entity.readAsBytes();
        archive.addFile(ArchiveFile(
          '$imagesPrefix${p.basename(entity.path)}',
          bytes.length,
          bytes,
        ));
        imageCount++;
      }
    }

    final manifest = jsonEncode({
      'format': formatVersion,
      'app': appVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'garments': garmentCount,
      'images': imageCount,
    });
    final manifestBytes = utf8.encode(manifest);
    archive.addFile(
        ArchiveFile(manifestName, manifestBytes.length, manifestBytes));

    final encoded = ZipEncoder().encode(archive);
    return Uint8List.fromList(encoded);
  }

  /// Nombre de fichero con la fecha, para que varios respaldos no se pisen
  /// en la carpeta de descargas.
  static String fileNameFor(DateTime when) {
    String two(int v) => v.toString().padLeft(2, '0');
    return 'ivyroom-${when.year}${two(when.month)}${two(when.day)}'
        '-${two(when.hour)}${two(when.minute)}.zip';
  }

  // ---- importar ----------------------------------------------------------

  /// Lee el manifiesto sin tocar nada.
  ///
  /// Existe separado de [import] para poder enseñarle al usuario qué hay
  /// dentro y pedirle confirmación ANTES de sobrescribir su armario actual,
  /// que es una operación sin vuelta atrás.
  static BackupSummary inspect(Uint8List zipBytes) {
    final archive = _decode(zipBytes);

    final manifest = archive.findFile(manifestName);
    if (manifest == null) {
      throw const BackupException(BackupProblem.notAnIvyroomBackup);
    }

    final Map<String, dynamic> data;
    try {
      data = jsonDecode(utf8.decode(manifest.content as List<int>))
          as Map<String, dynamic>;
    } catch (e) {
      throw BackupException(BackupProblem.corrupted, e.toString());
    }

    final format = data['format'];
    if (format is! int) {
      throw const BackupException(BackupProblem.notAnIvyroomBackup);
    }
    if (format > formatVersion) {
      throw const BackupException(BackupProblem.fromNewerVersion);
    }
    if (archive.findFile(databaseName) == null) {
      throw const BackupException(
          BackupProblem.corrupted, 'falta la base de datos');
    }

    return BackupSummary(
      garmentCount: (data['garments'] as num?)?.toInt() ?? 0,
      imageCount: (data['images'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(data['createdAt'] as String? ?? '') ??
              DateTime.fromMillisecondsSinceEpoch(0),
      appVersion: '${data['app'] ?? '?'}',
      bytes: zipBytes.length,
    );
  }

  /// Reemplaza el armario actual por el del respaldo.
  ///
  /// La base tiene que estar CERRADA antes de llamar aquí: se sobrescribe el
  /// fichero, y drift no se enteraría. Quien llama es responsable de cerrarla
  /// y de reiniciar la app o los providers después.
  ///
  /// Escribe primero a un lado y renombra al final, para que un fallo a
  /// mitad no deje al usuario sin el armario viejo Y sin el nuevo.
  Future<BackupSummary> import(Uint8List zipBytes) async {
    final summary = inspect(zipBytes);
    final archive = _decode(zipBytes);

    final staging = Directory(
      '${imagesDirectory.parent.path}/.ivyroom_import',
    );
    if (staging.existsSync()) staging.deleteSync(recursive: true);
    staging.createSync(recursive: true);

    try {
      // 1. Todo a la zona de preparación.
      final dbEntry = archive.findFile(databaseName)!;
      final stagedDb = File('${staging.path}/$databaseName');
      await stagedDb.writeAsBytes(dbEntry.content as List<int>, flush: true);

      final stagedImages = Directory('${staging.path}/images')
        ..createSync(recursive: true);
      for (final entry in archive.files) {
        if (!entry.isFile) continue;
        if (!entry.name.startsWith(imagesPrefix)) continue;
        final name = p.basename(entry.name);
        if (name.isEmpty) continue;
        await File('${stagedImages.path}/$name')
            .writeAsBytes(entry.content as List<int>, flush: true);
      }

      // 2. Y solo entonces se pisa lo que hay.
      if (imagesDirectory.existsSync()) {
        imagesDirectory.deleteSync(recursive: true);
      }
      imagesDirectory.createSync(recursive: true);
      for (final entity in stagedImages.listSync()) {
        if (entity is! File) continue;
        entity.copySync(
            p.join(imagesDirectory.path, p.basename(entity.path)));
      }

      // La base la última: mientras no se toque, la app sigue arrancando.
      stagedDb.copySync(databaseFile.path);
      // Los ficheros auxiliares de SQLite describen el estado de la base
      // vieja; dejarlos junto a la nueva la corrompe.
      for (final suffix in const ['-wal', '-shm', '-journal']) {
        final aux = File('${databaseFile.path}$suffix');
        if (aux.existsSync()) aux.deleteSync();
      }

      return summary;
    } finally {
      if (staging.existsSync()) staging.deleteSync(recursive: true);
    }
  }

  static Archive _decode(Uint8List bytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (e) {
      throw BackupException(BackupProblem.notAZip, e.toString());
    }
    // `ZipDecoder` no protesta con bytes cualesquiera: devuelve un archivo
    // vacío. Sin esta comprobación, elegir un .txt por error diría "no es un
    // respaldo de Ivyroom" en vez de "eso no es ni un zip".
    if (archive.files.isEmpty) {
      throw const BackupException(BackupProblem.notAZip, 'archivo vacío');
    }
    return archive;
  }
}
