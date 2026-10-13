import 'package:flutter/services.dart';

/// El modelo de recorte de ML Kit, que vive en Google Play Services.
///
/// Instalada desde Play, la app lo trae de serie. Instalada desde un APK,
/// Play Services lo baja cuando le parece, que puede ser nunca, y el recorte
/// falla con "el modelo se esta descargando". Esto lo pide explicitamente
/// (ver `MainActivity.ensureSegmentationModel`).
class SegmentationModel {
  const SegmentationModel._();

  static const _channel = MethodChannel('ivyroom/mlkit');
  static Future<bool>? _pending;

  /// Se asegura de que el modelo este instalado. True si lo esta.
  ///
  /// Comparte la misma espera entre quien lo llame a la vez: la llamada al
  /// arrancar la app y la de un recorte que fallo no lanzan dos descargas.
  static Future<bool> ensure({
    Duration timeout = const Duration(minutes: 3),
  }) {
    return _pending ??= _ensure(timeout).whenComplete(() => _pending = null);
  }

  static Future<bool> _ensure(Duration timeout) async {
    try {
      final status = await _channel
          .invokeMethod<String>('ensureSegmentationModel')
          .timeout(timeout);
      return status == 'ready';
    } on MissingPluginException {
      // Fuera de Android (tests, escritorio): no hay nada que instalar.
      return false;
    } catch (_) {
      return false;
    }
  }
}
