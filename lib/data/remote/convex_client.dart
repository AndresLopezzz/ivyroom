import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../app/config.dart';
import 'closet_sync.dart';

/// URL del despliegue de Convex. Ver [AppConfig].
const convexUrl = AppConfig.convexUrl;

class ConvexException implements Exception {
  const ConvexException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Cliente minimo de la API HTTP de Convex.
///
/// Se usa la API HTTP y no un SDK de Dart: los que hay son de terceros y
/// jovenes, y la app no necesita suscripciones en tiempo real, solo llamar
/// a unas pocas funciones. Esto son tres peticiones POST.
class ConvexClient implements RemoteApi {
  ConvexClient({
    required this.token,
    this.baseUrl = convexUrl,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  /// Token de identidad de la sesion (el ID token de Google), o null.
  final Future<String?> Function() token;
  final String baseUrl;
  final http.Client _http;

  @override
  Future<dynamic> query(String path, [Map<String, Object?> args = const {}]) =>
      _call('query', path, args);

  @override
  Future<dynamic> mutation(String path,
          [Map<String, Object?> args = const {}]) =>
      _call('mutation', path, args);

  Future<dynamic> _call(
      String kind, String path, Map<String, Object?> args) async {
    final t = await token();
    final res = await _http.post(
      Uri.parse('$baseUrl/api/$kind'),
      headers: {
        'Content-Type': 'application/json',
        if (t != null) 'Authorization': 'Bearer $t',
      },
      body: jsonEncode({'path': path, 'args': args, 'format': 'json'}),
    );
    final Object? body;
    try {
      body = jsonDecode(utf8.decode(res.bodyBytes));
    } catch (_) {
      throw ConvexException('Respuesta inesperada del servidor '
          '(${res.statusCode})');
    }
    if (body is Map && body['status'] == 'success') return body['value'];
    final message = body is Map ? body['errorMessage'] : null;
    throw ConvexException(_clean('$message'));
  }

  /// Sube un fichero al almacenamiento de Convex y devuelve su id.
  @override
  Future<String> upload(Uint8List bytes, String contentType) async {
    final url = await mutation('sync:generateUploadUrl') as String;
    final res = await _http.post(
      Uri.parse(url),
      headers: {'Content-Type': contentType},
      body: bytes,
    );
    if (res.statusCode != 200) {
      throw ConvexException('No se pudo subir la imagen (${res.statusCode})');
    }
    return (jsonDecode(res.body) as Map)['storageId'] as String;
  }

  /// Convex envuelve los errores de las funciones en un texto tecnico
  /// ("[CONVEX M(...)] Uncaught Error: ..."). Al usuario solo le sirve el
  /// mensaje.
  static String _clean(String raw) {
    final m = RegExp(r'Uncaught Error: (.*?)(\n|\s+at |$)').firstMatch(raw);
    return m?.group(1)?.trim() ?? raw;
  }
}
