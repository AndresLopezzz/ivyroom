import 'dart:convert';
import 'dart:io';

/// Preferencias de la app que no son datos del armario.
///
/// Van a un JSON aparte y no a la base porque no deben viajar en un respaldo:
/// restaurar el armario en otro movil no tiene por que traer la hora del
/// aviso ni volver a saltarse la bienvenida.
class AppPrefs {
  const AppPrefs({
    this.onboarded = false,
    this.reminderEnabled = false,
    this.reminderMinutes = 7 * 60 + 30,
  });

  /// Ya vio la bienvenida.
  final bool onboarded;

  /// Aviso diario "¿qué me pongo?".
  final bool reminderEnabled;

  /// Hora del aviso, en minutos desde medianoche.
  final int reminderMinutes;

  AppPrefs copyWith({
    bool? onboarded,
    bool? reminderEnabled,
    int? reminderMinutes,
  }) =>
      AppPrefs(
        onboarded: onboarded ?? this.onboarded,
        reminderEnabled: reminderEnabled ?? this.reminderEnabled,
        reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      );

  Map<String, Object?> toJson() => {
        'onboarded': onboarded,
        'reminderEnabled': reminderEnabled,
        'reminderMinutes': reminderMinutes,
      };

  factory AppPrefs.fromJson(Map<String, dynamic> j) => AppPrefs(
        onboarded: j['onboarded'] as bool? ?? false,
        reminderEnabled: j['reminderEnabled'] as bool? ?? false,
        reminderMinutes: (j['reminderMinutes'] as num?)?.toInt() ?? 7 * 60 + 30,
      );
}

/// Lee y escribe [AppPrefs] en un fichero.
class AppPrefsStore {
  AppPrefsStore(this._directory);

  final Future<Directory> Function() _directory;

  static const _fileName = 'prefs.json';

  Future<File> get _file async =>
      File('${(await _directory()).path}/$_fileName');

  /// Un fichero corrupto o ausente da los valores por defecto: unas
  /// preferencias rotas no pueden impedir que la app arranque.
  Future<AppPrefs> load() async {
    try {
      final file = await _file;
      if (!file.existsSync()) return const AppPrefs();
      final json = jsonDecode(await file.readAsString());
      return json is Map<String, dynamic>
          ? AppPrefs.fromJson(json)
          : const AppPrefs();
    } catch (_) {
      return const AppPrefs();
    }
  }

  Future<void> save(AppPrefs prefs) async {
    final file = await _file;
    await file.writeAsString(jsonEncode(prefs.toJson()), flush: true);
  }
}
