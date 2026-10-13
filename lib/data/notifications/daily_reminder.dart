import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// El aviso de la manana: "¿que me pongo hoy?".
///
/// Se programan los proximos [days] avisos uno a uno, y no un aviso diario
/// repetido, porque el texto cambia: si ese dia hay un outfit planificado,
/// el aviso dice cual. Se reprograma cada vez que cambia la planificacion o
/// se abre la app, asi que siempre hay una semana por delante.
class DailyReminder {
  DailyReminder([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  static const days = 7;
  static const _channel = AndroidNotificationDetails(
    'daily_outfit',
    'Outfit del día',
    channelDescription: 'Un aviso por la mañana con qué ponerte.',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  Future<void> _init() async {
    if (_ready) return;
    // Solo hace falta la base de zonas para construir instantes; se programa
    // en UTC a partir de la hora local de cada dia, asi que no hace falta
    // saber el nombre de la zona del movil y el cambio de horario cuadra
    // solo.
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _ready = true;
  }

  /// Pide permiso para notificar (Android 13+). Devuelve si se concedio.
  Future<bool> requestPermission() async {
    await _init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await android?.requestNotificationsPermission() ?? true;
  }

  /// Cancela lo programado y, si [enabled], programa la proxima semana.
  ///
  /// [plannedByDay] es, para cada dia a medianoche, la lista de prendas
  /// planificada (por nombre). Los dias sin plan reciben un texto generico.
  Future<void> reschedule({
    required bool enabled,
    required int minutes,
    required Map<DateTime, List<String>> plannedByDay,
    DateTime? now,
  }) async {
    await _init();
    await _plugin.cancelAll();
    if (!enabled) return;

    final clock = now ?? DateTime.now();
    for (var i = 0; i < days; i++) {
      final day = DateTime(clock.year, clock.month, clock.day + i);
      final at = day.add(Duration(minutes: minutes));
      if (!at.isAfter(clock)) continue;

      final planned = plannedByDay[day] ?? const [];
      await _plugin.zonedSchedule(
        id: i + 1,
        title: planned.isEmpty ? '¿Qué te pones hoy?' : 'Hoy toca',
        body: planned.isEmpty
            ? 'Mira el outfit que te propone Ivyroom para el clima de hoy.'
            : _join(planned),
        scheduledDate: tz.TZDateTime.from(at, tz.UTC),
        notificationDetails: const NotificationDetails(android: _channel),
        // Inexacto a proposito: unos minutos de margen no importan y el
        // exacto exige un permiso especial que Android pide justificar.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  static String _join(List<String> names) {
    if (names.length == 1) return names.single;
    return '${names.sublist(0, names.length - 1).join(', ')} y ${names.last}';
  }
}
