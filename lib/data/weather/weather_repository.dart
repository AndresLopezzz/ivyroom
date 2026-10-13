import 'dart:convert';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';

import 'weather_service.dart';

/// De dónde salen las coordenadas.
enum LocationMode {
  /// GPS del teléfono. Requiere permiso.
  automatic,

  /// Un sitio que el usuario eligió a mano buscándolo por nombre.
  manual,

  /// Sin clima: el usuario pone la temperatura con el deslizador, como antes.
  off,
}

/// Estado del clima tal como lo ve la interfaz.
class WeatherState {
  const WeatherState({
    this.mode = LocationMode.off,
    this.place,
    this.weather,
    this.error,
    this.loading = false,
  });

  final LocationMode mode;
  final Place? place;
  final DayWeather? weather;
  final String? error;
  final bool loading;

  /// El dato en caché sirve, pero pasadas unas horas conviene refrescarlo.
  bool get isStale {
    final w = weather;
    if (w == null) return true;
    return DateTime.now().difference(w.fetchedAt) > const Duration(hours: 3);
  }

  WeatherState copyWith({
    LocationMode? mode,
    Place? place,
    DayWeather? weather,
    String? error,
    bool? loading,
    bool clearError = false,
    bool clearWeather = false,
    bool clearPlace = false,
  }) {
    return WeatherState(
      mode: mode ?? this.mode,
      place: clearPlace ? null : (place ?? this.place),
      weather: clearWeather ? null : (weather ?? this.weather),
      error: clearError ? null : (error ?? this.error),
      loading: loading ?? this.loading,
    );
  }
}

/// Guarda la preferencia de ubicación y el último clima conocido.
///
/// Se persiste en un JSON suelto y no en la base: no tiene relación con el
/// armario, no hace falta consultarlo ni filtrarlo, y meterlo en drift
/// obligaría a una migración de esquema por un par de campos.
class WeatherRepository {
  WeatherRepository({
    WeatherService? service,
    Future<Directory> Function()? directory,
  })  : _service = service ?? const WeatherService(),
        _directory = directory ?? getApplicationDocumentsDirectory;

  final WeatherService _service;
  final Future<Directory> Function() _directory;

  static const _fileName = 'weather.json';

  Future<File> get _file async =>
      File('${(await _directory()).path}/$_fileName');

  // ---- persistencia ------------------------------------------------------

  Future<WeatherState> load() async {
    final file = await _file;
    if (!file.existsSync()) return const WeatherState();

    try {
      final json = jsonDecode(await file.readAsString());
      if (json is! Map<String, dynamic>) return const WeatherState();

      final modeName = json['mode'] as String?;
      final mode = LocationMode.values
          .where((m) => m.name == modeName)
          .firstOrNull;

      return WeatherState(
        mode: mode ?? LocationMode.off,
        place: json['place'] is Map<String, dynamic>
            ? Place.fromJson(json['place'] as Map<String, dynamic>)
            : null,
        weather: json['weather'] is Map<String, dynamic>
            ? DayWeather.fromJson(json['weather'] as Map<String, dynamic>)
            : null,
      );
    } catch (_) {
      // Un fichero corrupto solo significa perder la preferencia del clima:
      // no vale la pena propagar el error hasta la pantalla.
      return const WeatherState();
    }
  }

  Future<void> save(WeatherState state) async {
    final file = await _file;
    await file.writeAsString(
      jsonEncode({
        'mode': state.mode.name,
        'place': state.place?.toJson(),
        'weather': state.weather?.toJson(),
      }),
      flush: true,
    );
  }

  // ---- consulta ----------------------------------------------------------

  Future<List<Place>> searchPlaces(String query) =>
      _service.searchPlaces(query);

  Future<DayWeather> forecast(Place place) => _service.forecast(place);

  /// Pide el permiso y devuelve la posición actual.
  ///
  /// Lanza [WeatherException] con un texto explicando qué hacer, en vez de
  /// devolver null: "no se pudo" sin más deja al usuario sin saber si es
  /// culpa del permiso, del GPS apagado o de la red.
  Future<Place> currentPlace() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const WeatherException(
          'La ubicación del teléfono está apagada.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const WeatherException(
          'Negaste el permiso de ubicación. Puedes buscar tu ciudad a mano.');
    }
    if (permission == LocationPermission.denied) {
      throw const WeatherException(
          'Sin permiso de ubicación. Puedes buscar tu ciudad a mano.');
    }

    final Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          // Para saber qué tiempo hace no hace falta precisión de metros, y
          // pedir menos precisión gasta bastante menos batería.
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (e) {
      throw const WeatherException('No se pudo obtener la ubicación.');
    }

    return Place(
      name: 'Mi ubicación',
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}
