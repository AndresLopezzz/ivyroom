/// Configuracion que cambia de una instalacion a otra.
///
/// Llega al compilar con `--dart-define-from-file=config.json` (ver
/// `config.example.json`). Nada de esto es secreto —viaja dentro del APK—,
/// pero es de cada quien: sin `config.json` la app funciona entera en modo
/// local y la parte de cuenta y compartir se oculta.
class AppConfig {
  const AppConfig._();

  /// URL del despliegue de Convex, p. ej. `https://xxx.convex.cloud`.
  static const convexUrl = String.fromEnvironment('CONVEX_URL');

  /// URL de las acciones HTTP de Convex, p. ej. `https://xxx.convex.site`.
  static const convexSiteUrl = String.fromEnvironment('CONVEX_SITE_URL');

  /// Client ID *web* de Google Cloud (OAuth). Es la audiencia del token.
  static const googleWebClientId =
      String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  /// Frase de la primera pantalla de bienvenida.
  static const welcomeMessage = String.fromEnvironment(
    'WELCOME_MESSAGE',
    defaultValue: 'Cataloga tu ropa y deja que la app combine por ti.',
  );

  /// Hay backend configurado. Sin el, todo lo de la nube se oculta.
  static bool get cloudEnabled =>
      convexUrl.isNotEmpty &&
      convexSiteUrl.isNotEmpty &&
      googleWebClientId.isNotEmpty;
}
