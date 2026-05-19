import 'package:dio/dio.dart';

import 'api_service.dart';

/// Météo locale : API Teranga Pass si disponible, sinon Open-Meteo direct (gratuit).
class WeatherService {
  WeatherService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const _openMeteoUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<Map<String, dynamic>> fetch({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final data = await ApiService().getWeather(
        latitude: latitude,
        longitude: longitude,
      );
      if (data.isNotEmpty && data['temperature_c'] != null) {
        return data;
      }
    } catch (_) {
      // Backend absent ou erreur — repli direct.
    }
    return _fetchOpenMeteoDirect(latitude, longitude);
  }

  Future<Map<String, dynamic>> _fetchOpenMeteoDirect(
    double latitude,
    double longitude,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _openMeteoUrl,
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'current': 'temperature_2m,weather_code',
        'timezone': 'auto',
      },
      options: Options(
        receiveTimeout: const Duration(seconds: 12),
        sendTimeout: const Duration(seconds: 12),
      ),
    );

    final json = response.data;
    final current = json?['current'] as Map<String, dynamic>? ?? {};
    final code = (current['weather_code'] as num?)?.toInt() ?? -1;
    final temp = current['temperature_2m'];

    if (temp == null) {
      throw Exception('Météo indisponible');
    }

    return {
      'temperature_c': (temp as num).round(),
      'weather_code': code,
      'label': _labelFr(code),
      'icon': _iconKey(code),
      'source': 'open-meteo-direct',
    };
  }

  static String _labelFr(int code) {
    if (code == 0) return 'Ensoleillé';
    if (code >= 1 && code <= 3) return 'Partiellement nuageux';
    if (code == 45 || code == 48) return 'Brume';
    if ([51, 53, 55, 56, 57].contains(code)) return 'Bruine';
    if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code)) return 'Pluie';
    if ([71, 73, 75, 77, 85, 86].contains(code)) return 'Neige';
    if ([95, 96, 99].contains(code)) return 'Orage';
    return 'Nuageux';
  }

  static String _iconKey(int code) {
    if (code == 0) return 'sunny';
    if (code >= 1 && code <= 3) return 'partly_cloudy';
    if (code == 45 || code == 48) return 'fog';
    if ([51, 53, 55, 61, 63, 65, 80, 81, 82].contains(code)) return 'rain';
    if ([95, 96, 99].contains(code)) return 'thunderstorm';
    return 'cloudy';
  }
}
