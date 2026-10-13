import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ivyroom/data/weather/weather_repository.dart';
import 'package:ivyroom/data/weather/weather_service.dart';

const bogota = Place(
  name: 'Bogotá',
  latitude: 4.61,
  longitude: -74.08,
  admin: 'Bogotá D.C.',
  country: 'Colombia',
);

/// Cliente que responde lo que se le diga, sin salir a internet.
MockClient respondWith(
  Object body, {
  int status = 200,
  void Function(Uri)? onRequest,
}) {
  return MockClient((request) async {
    onRequest?.call(request.url);
    return http.Response(
      body is String ? body : jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );
  });
}

void main() {
  group('forecast', () {
    test('lee la temperatura actual, la mínima y la lluvia', () async {
      final service = WeatherService(
        client: respondWith({
          'current': {'temperature_2m': 19.4},
          'daily': {
            'temperature_2m_min': [11.2],
            'temperature_2m_max': [23.8],
            'precipitation_probability_max': [65],
          },
        }),
      );

      final w = await service.forecast(bogota);

      expect(w.tempC, 19.4);
      expect(w.minC, 11.2);
      expect(w.maxC, 23.8);
      expect(w.rainChance, 65);
      expect(w.place, 'Bogotá');
    });

    test('pide las coordenadas del sitio indicado', () async {
      Uri? seen;
      final service = WeatherService(
        client: respondWith(
          {
            'current': {'temperature_2m': 20},
            'daily': {
              'temperature_2m_min': [10],
              'temperature_2m_max': [25],
              'precipitation_probability_max': [0],
            },
          },
          onRequest: (uri) => seen = uri,
        ),
      );

      await service.forecast(bogota);

      expect(seen!.queryParameters['latitude'], '4.61');
      expect(seen!.queryParameters['longitude'], '-74.08');
      // Sin API key: es la razón de haber elegido Open-Meteo.
      expect(seen!.queryParameters.keys, isNot(contains('apikey')));
      expect(seen!.queryParameters.keys, isNot(contains('key')));
    });

    test('la temperatura para vestirse pondera la mínima del día', () async {
      // El caso que motiva la regla: sales con 22 y vuelves de noche con 12.
      final service = WeatherService(
        client: respondWith({
          'current': {'temperature_2m': 22.0},
          'daily': {
            'temperature_2m_min': [12.0],
            'temperature_2m_max': [24.0],
            'precipitation_probability_max': [0],
          },
        }),
      );

      final w = await service.forecast(bogota);

      expect(w.dressingTempC, 17.0);
      expect(w.dressingTempC, lessThan(w.tempC));
    });

    test('sin red da un mensaje entendible, no una excepción cruda',
        () async {
      final service = WeatherService(
        client: MockClient((_) async => throw const SocketException('nope')),
      );

      await expectLater(
        service.forecast(bogota),
        throwsA(isA<WeatherException>()
            .having((e) => e.message, 'mensaje', contains('conexión'))),
      );
    });

    test('un error del servidor se reporta con su código', () async {
      final service = WeatherService(client: respondWith({}, status: 503));

      await expectLater(
        service.forecast(bogota),
        throwsA(isA<WeatherException>()
            .having((e) => e.message, 'mensaje', contains('503'))),
      );
    });

    test('una respuesta ilegible no revienta la app', () async {
      final service = WeatherService(client: respondWith('<html>uy</html>'));

      await expectLater(
        service.forecast(bogota),
        throwsA(isA<WeatherException>()),
      );
    });

    test('una respuesta sin los campos esperados se rechaza', () async {
      final service = WeatherService(client: respondWith({'algo': 1}));

      await expectLater(
        service.forecast(bogota),
        throwsA(isA<WeatherException>()),
      );
    });
  });

  group('buscar sitios', () {
    test('devuelve los resultados con su región y país', () async {
      final service = WeatherService(
        client: respondWith({
          'results': [
            {
              'name': 'Medellín',
              'latitude': 6.25,
              'longitude': -75.56,
              'admin1': 'Antioquia',
              'country': 'Colombia',
            },
          ],
        }),
      );

      final places = await service.searchPlaces('Medellín');

      expect(places, hasLength(1));
      expect(places.single.label, 'Medellín, Antioquia, Colombia');
      expect(places.single.latitude, 6.25);
    });

    test('no llama al servicio con menos de dos letras', () async {
      var called = false;
      final service = WeatherService(
        client: MockClient((_) async {
          called = true;
          return http.Response('{}', 200);
        }),
      );

      expect(await service.searchPlaces('m'), isEmpty);
      expect(await service.searchPlaces('  '), isEmpty);
      expect(called, isFalse);
    });

    test('sin resultados devuelve una lista vacía, no un error', () async {
      final service = WeatherService(client: respondWith({}));
      expect(await service.searchPlaces('xyzzy'), isEmpty);
    });
  });

  group('persistencia', () {
    late Directory dir;
    late WeatherRepository repo;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('ivyroom_weather_');
      repo = WeatherRepository(directory: () async => dir);
    });

    tearDown(() => dir.deleteSync(recursive: true));

    test('sin fichero previo el clima está apagado', () async {
      final state = await repo.load();
      expect(state.mode, LocationMode.off);
      expect(state.weather, isNull);
    });

    test('guarda y recupera el sitio y el último clima', () async {
      final state = WeatherState(
        mode: LocationMode.manual,
        place: bogota,
        weather: DayWeather(
          tempC: 18,
          minC: 11,
          maxC: 22,
          rainChance: 40,
          place: 'Bogotá',
          fetchedAt: DateTime(2026, 8, 22, 10),
        ),
      );

      await repo.save(state);
      final loaded = await repo.load();

      expect(loaded.mode, LocationMode.manual);
      expect(loaded.place!.name, 'Bogotá');
      expect(loaded.place!.latitude, 4.61);
      expect(loaded.weather!.tempC, 18);
      expect(loaded.weather!.rainChance, 40);
    });

    test('un fichero corrupto no impide arrancar', () async {
      File('${dir.path}/weather.json').writeAsStringSync('{roto');
      final state = await repo.load();
      expect(state.mode, LocationMode.off);
    });

    test('el clima caduca a las tres horas', () {
      DayWeather at(Duration ago) => DayWeather(
            tempC: 18,
            minC: 11,
            maxC: 22,
            rainChance: 0,
            place: 'x',
            fetchedAt: DateTime.now().subtract(ago),
          );

      expect(
        WeatherState(weather: at(const Duration(minutes: 30))).isStale,
        isFalse,
      );
      expect(
        WeatherState(weather: at(const Duration(hours: 5))).isStale,
        isTrue,
      );
      expect(const WeatherState().isStale, isTrue);
    });
  });
}
