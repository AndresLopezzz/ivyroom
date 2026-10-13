import 'dart:convert';

import 'package:http/http.dart' as http;

/// El tiempo de hoy en un sitio concreto.
class DayWeather {
  const DayWeather({
    required this.tempC,
    required this.minC,
    required this.maxC,
    required this.rainChance,
    required this.place,
    required this.fetchedAt,
  });

  /// Temperatura actual.
  final double tempC;

  final double minC;
  final double maxC;

  /// Probabilidad de lluvia del día, 0–100.
  final int rainChance;

  /// Nombre legible del sitio, o null si solo se conocen las coordenadas.
  final String? place;

  final DateTime fetchedAt;

  /// La temperatura con la que el motor decide cuánto abrigo hace falta.
  ///
  /// Se usa la mínima del día ponderada con la actual, no la actual a secas:
  /// alguien que sale a las 8 de la mañana con 22 grados y vuelve a las 11
  /// de la noche con 12 necesita el abrigo, y mirar solo el termómetro de
  /// ahora se lo dejaría en casa.
  double get dressingTempC => (tempC + minC) / 2;

  Map<String, dynamic> toJson() => {
        'tempC': tempC,
        'minC': minC,
        'maxC': maxC,
        'rainChance': rainChance,
        'place': place,
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  static DayWeather? fromJson(Map<String, dynamic> json) {
    final fetched = DateTime.tryParse(json['fetchedAt'] as String? ?? '');
    if (fetched == null) return null;
    return DayWeather(
      tempC: (json['tempC'] as num?)?.toDouble() ?? 0,
      minC: (json['minC'] as num?)?.toDouble() ?? 0,
      maxC: (json['maxC'] as num?)?.toDouble() ?? 0,
      rainChance: (json['rainChance'] as num?)?.toInt() ?? 0,
      place: json['place'] as String?,
      fetchedAt: fetched,
    );
  }
}

/// Un sitio del mundo. Se guarda para poder consultar el tiempo sin volver a
/// pedir permiso de ubicación cada vez.
class Place {
  const Place({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.admin,
    this.country,
  });

  final String name;
  final double latitude;
  final double longitude;

  /// Región o departamento, para distinguir los homónimos.
  final String? admin;
  final String? country;

  String get label => [name, admin, country]
      .where((e) => e != null && e.isNotEmpty)
      .join(', ');

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'admin': admin,
        'country': country,
      };

  static Place? fromJson(Map<String, dynamic> json) {
    final lat = (json['latitude'] as num?)?.toDouble();
    final lon = (json['longitude'] as num?)?.toDouble();
    final name = json['name'] as String?;
    if (lat == null || lon == null || name == null) return null;
    return Place(
      name: name,
      latitude: lat,
      longitude: lon,
      admin: json['admin'] as String?,
      country: json['country'] as String?,
    );
  }
}

class WeatherException implements Exception {
  const WeatherException(this.message);
  final String message;
  @override
  String toString() => 'WeatherException: $message';
}

/// Consulta el tiempo en Open-Meteo.
///
/// Se eligió Open-Meteo por una razón concreta: no pide API key ni registro.
/// Cualquier otra opción obligaría a incrustar una clave en la app, donde
/// cualquiera puede sacarla, o a montar un servidor intermedio — y el
/// proyecto entero se apoya en no tener backend.
class WeatherService {
  const WeatherService({this.client});

  /// Inyectable para los tests, que no deben salir a internet.
  final http.Client? client;

  static const _forecastHost = 'api.open-meteo.com';
  static const _geocodeHost = 'geocoding-api.open-meteo.com';

  http.Client get _http => client ?? http.Client();

  Future<DayWeather> forecast(Place place) async {
    final uri = Uri.https(_forecastHost, '/v1/forecast', {
      'latitude': '${place.latitude}',
      'longitude': '${place.longitude}',
      'current': 'temperature_2m',
      'daily': 'temperature_2m_min,temperature_2m_max,'
          'precipitation_probability_max',
      'timezone': 'auto',
      'forecast_days': '1',
    });

    final json = await _get(uri);
    final current = json['current'] as Map<String, dynamic>?;
    final daily = json['daily'] as Map<String, dynamic>?;
    if (current == null || daily == null) {
      throw const WeatherException('El servicio del clima respondió raro.');
    }

    double firstNum(String key) {
      final list = daily[key];
      if (list is List && list.isNotEmpty && list.first is num) {
        return (list.first as num).toDouble();
      }
      return 0;
    }

    return DayWeather(
      tempC: (current['temperature_2m'] as num?)?.toDouble() ??
          firstNum('temperature_2m_max'),
      minC: firstNum('temperature_2m_min'),
      maxC: firstNum('temperature_2m_max'),
      rainChance: firstNum('precipitation_probability_max').round(),
      place: place.name,
      fetchedAt: DateTime.now(),
    );
  }

  /// Busca sitios por nombre.
  ///
  /// Es la vía alternativa cuando el usuario no quiere dar el permiso de
  /// ubicación, que es una petición razonable en una app de armario.
  Future<List<Place>> searchPlaces(String query) async {
    final text = query.trim();
    if (text.length < 2) return const [];

    final uri = Uri.https(_geocodeHost, '/v1/search', {
      'name': text,
      'count': '8',
      'language': 'es',
      'format': 'json',
    });

    final json = await _get(uri);
    final results = json['results'];
    if (results is! List) return const [];

    return [
      for (final r in results)
        if (r is Map<String, dynamic>)
          Place(
            name: '${r['name']}',
            latitude: (r['latitude'] as num).toDouble(),
            longitude: (r['longitude'] as num).toDouble(),
            admin: r['admin1'] as String?,
            country: r['country'] as String?,
          ),
    ];
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final http.Response response;
    try {
      response = await _http.get(uri).timeout(const Duration(seconds: 10));
    } catch (e) {
      // Sin red no es un error del que haya que informar con dramatismo: la
      // app funciona igual, solo que con la temperatura manual.
      throw const WeatherException('Sin conexión para consultar el clima.');
    }

    if (response.statusCode != 200) {
      throw WeatherException(
          'El servicio del clima devolvió ${response.statusCode}.');
    }

    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw const WeatherException('Respuesta ilegible del clima.');
    }
  }
}
