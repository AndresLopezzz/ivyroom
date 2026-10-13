import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_subject_segmentation/google_mlkit_subject_segmentation.dart';


/// Por qué falló el recorte automático. Se distingue para poder dar un
/// mensaje útil en vez de un "error" genérico: la mayoría de los fallos en
/// el primer uso son que el modelo aún no está descargado.
enum RemovalFailure {
  /// ML Kit no encontró ningún sujeto en la foto.
  noSubject,

  /// El modelo no está disponible todavía (primer uso sin red).
  modelUnavailable,

  unknown,
}

class BackgroundRemovalException implements Exception {
  const BackgroundRemovalException(this.reason, [this.detail]);
  final RemovalFailure reason;
  final String? detail;

  /// [message] mas el error tecnico, recortado. Para cuando falla algo que
  /// no se esperaba: sin el detalle no hay forma de saber que paso en un
  /// movil al que no se tiene acceso.
  String get messageWithDetail {
    final d = detail?.trim();
    if (reason != RemovalFailure.unknown || d == null || d.isEmpty) {
      return message;
    }
    final short = d.length > 160 ? '${d.substring(0, 160)}…' : d;
    return '$message\n\nDetalle: $short';
  }

  String get message => switch (reason) {
        RemovalFailure.noSubject =>
          'No se detectó ninguna prenda en la foto. Prueba con un fondo más '
              'liso, o recórtala a mano.',
        RemovalFailure.modelUnavailable =>
          'El modelo de recorte todavía se está descargando. Conéctate a '
              'internet e inténtalo de nuevo, o recorta a mano.',
        RemovalFailure.unknown =>
          'No se pudo recortar la foto automáticamente. Puedes recortarla '
              'a mano.',
      };

  @override
  String toString() => 'BackgroundRemovalException($reason): $detail';
}

/// Quita el fondo de una foto y devuelve un PNG con alfa.
///
/// Es una interfaz y no una clase concreta porque hay dos adaptadores
/// reales: ML Kit en el dispositivo, y uno falso con el que se prueba el
/// alta de prenda sin depender de que haya un modelo descargado.
abstract class BackgroundRemover {
  /// Lanza [BackgroundRemovalException] si no se pudo recortar.
  Future<Uint8List> removeBackground(File photo);

  Future<void> dispose();
}

/// Recorta con ML Kit Subject Segmentation, en el dispositivo y sin red
/// (salvo la descarga inicial del modelo).
class MlKitBackgroundRemover implements BackgroundRemover {
  MlKitBackgroundRemover();

  SubjectSegmenter? _segmenter;

  SubjectSegmenter get _instance => _segmenter ??= SubjectSegmenter(
        options: SubjectSegmenterOptions(
          // Basta con el bitmap ya enmascarado: la máscara de confianza es
          // mucho más cara de pasar por el canal y no aporta nada aquí.
          enableForegroundBitmap: true,
          enableForegroundConfidenceMask: false,
          enableMultipleSubjects: SubjectResultOptions(
            enableConfidenceMask: false,
            enableSubjectBitmap: false,
          ),
        ),
      );

  @override
  Future<Uint8List> removeBackground(File photo) async {
    final SubjectSegmentationResult result;
    try {
      result = await _instance.processImage(InputImage.fromFile(photo));
    } catch (e) {
      final text = e.toString().toLowerCase();
      final reason = text.contains('model') || text.contains('download')
          ? RemovalFailure.modelUnavailable
          : RemovalFailure.unknown;
      throw BackgroundRemovalException(reason, e.toString());
    }

    final png = result.foregroundBitmap;
    if (png == null || png.isEmpty) {
      throw const BackgroundRemovalException(RemovalFailure.noSubject);
    }

    // Del tamaño de la foto entera, con el fondo a alfa cero. Se devuelve
    // SIN recortar al contorno: el editor de retoque necesita que encaje
    // píxel a píxel con la foto para poder restaurar lo que ML Kit quitó de
    // más. Recortar es cosa de quien llama.
    return png;
  }

  @override
  Future<void> dispose() async {
    await _segmenter?.close();
    _segmenter = null;
  }
}
