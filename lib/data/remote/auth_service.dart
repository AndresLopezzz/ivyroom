import 'dart:convert';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../../app/config.dart';

// El Client ID web de Google se pasa como `serverClientId` para que el ID
// token salga con esa audiencia, que es la que comprueba el servidor. Las
// URLs y el ID vienen de [AppConfig].
const googleWebClientId = AppConfig.googleWebClientId;
const convexSiteUrl = AppConfig.convexSiteUrl;

/// La sesion de la app.
///
/// Google se usa solo para entrar. Su ID token dura una hora y renovarlo en
/// Android ensena "Accediendo como..." cada vez, asi que se canjea en el
/// servidor por una sesion propia de 30 dias, que se guarda en el movil y se
/// renueva sola sin ensenar nada. Mientras la app se abra una vez al mes, no
/// vuelve a pedir Google.
class AuthService {
  AuthService({
    required this.directory,
    GoogleSignIn? signIn,
    http.Client? httpClient,
  })  : _signIn = signIn ?? GoogleSignIn.instance,
        _http = httpClient ?? http.Client();

  /// Donde se guarda la sesion. Inyectable para los tests.
  final Future<Directory> Function() directory;
  final GoogleSignIn _signIn;
  final http.Client _http;
  Future<void>? _init;
  String? _token;

  bool get signedIn => _token != null;

  Future<File> get _file async =>
      File('${(await directory()).path}/session.json');

  /// Recupera la sesion guardada. No habla con Google: si no hay sesion o
  /// caduco, devuelve false y hay que entrar a mano.
  Future<bool> restore() async {
    try {
      final file = await _file;
      if (!file.existsSync()) return false;
      final token = (jsonDecode(await file.readAsString()) as Map)['token'];
      if (token is! String) return false;
      final exp = _expiry(token);
      if (exp == null || exp.isBefore(DateTime.now())) {
        await _forget();
        return false;
      }
      _token = token;
      // A una semana de caducar se renueva ya, con margen por si no hay red.
      if (exp.isBefore(DateTime.now().add(const Duration(days: 7)))) {
        await _refresh();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Entra con Google (aqui si sale el selector de cuentas) y canjea el
  /// token por una sesion propia.
  Future<void> signIn() async {
    await (_init ??= _signIn.initialize(serverClientId: googleWebClientId));
    final account = await _signIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) throw Exception('Google no devolvió un token');
    final res = await _http.post(
      Uri.parse('$convexSiteUrl/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );
    await _store(_tokenFrom(res));
  }

  Future<void> signOut() async {
    await _forget();
    try {
      await (_init ??= _signIn.initialize(serverClientId: googleWebClientId));
      await _signIn.signOut();
    } catch (_) {
      // Sin servicios de Google la sesion propia ya esta borrada, que es lo
      // que importa.
    }
  }

  /// Token para las llamadas a Convex, o null sin sesion.
  Future<String?> token() async {
    final t = _token;
    if (t == null) return null;
    final exp = _expiry(t);
    if (exp != null &&
        exp.isBefore(DateTime.now().add(const Duration(days: 1)))) {
      await _refresh();
    }
    return _token;
  }

  Future<void> _refresh() async {
    try {
      final res = await _http.post(
        Uri.parse('$convexSiteUrl/auth/refresh'),
        headers: {'Authorization': 'Bearer $_token'},
      );
      if (res.statusCode == 401) {
        await _forget();
        return;
      }
      await _store(_tokenFrom(res));
    } catch (_) {
      // Sin red: se sigue con el token actual mientras valga.
    }
  }

  String _tokenFrom(http.Response res) {
    final body = jsonDecode(utf8.decode(res.bodyBytes));
    if (res.statusCode != 200 || body is! Map || body['token'] is! String) {
      throw Exception(body is Map && body['error'] != null
          ? body['error']
          : 'No se pudo iniciar sesión (${res.statusCode})');
    }
    return body['token'] as String;
  }

  Future<void> _store(String token) async {
    _token = token;
    final file = await _file;
    await file.writeAsString(jsonEncode({'token': token}), flush: true);
  }

  Future<void> _forget() async {
    _token = null;
    try {
      final file = await _file;
      if (file.existsSync()) await file.delete();
    } on FileSystemException {
      // No importa.
    }
  }

  static DateTime? _expiry(String jwt) {
    try {
      final parts = jwt.split('.');
      final payload =
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final exp = (jsonDecode(payload) as Map)['exp'] as num;
      return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
    } catch (_) {
      return null;
    }
  }
}
