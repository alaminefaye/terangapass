import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'user_preferences.dart';

/// Position + libellé de lieu pour la météo sur l’accueil.
class WeatherLocationResult {
  const WeatherLocationResult({
    required this.latitude,
    required this.longitude,
    required this.placeLabel,
    required this.isGpsBased,
  });

  final double latitude;
  final double longitude;
  final String placeLabel;
  final bool isGpsBased;
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Vérifie et demande les permissions de localisation
  Future<bool> checkAndRequestPermissions() async {
    if (!await UserPreferences.geolocationEnabled()) {
      throw Exception(
        'La géolocalisation est désactivée dans le profil (Paramètres). '
        'Activez-la pour utiliser cette fonctionnalité.',
      );
    }

    // Vérifier si le service de localisation est activé
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
          'Les services de localisation sont désactivés. Veuillez les activer dans les paramètres.');
    }

    // Vérifier les permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception(
            'Les permissions de localisation sont refusées. Veuillez les activer dans les paramètres.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Les permissions de localisation sont définitivement refusées. Veuillez les activer dans les paramètres de l\'application.');
    }

    return true;
  }

  /// Position actuelle si le service est actif et les permissions accordées ; sinon `null` (sans lever d’exception).
  /// Demande la permission « pendant l’usage » si elle n’est pas encore accordée.
  Future<Position?> getCurrentPositionIfAllowed() async {
    if (!await UserPreferences.geolocationEnabled()) {
      return null;
    }
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return null;
      }

      // Dernière position connue récente : évite d’attendre le fix GPS (carte, ambassades…).
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null &&
            DateTime.now().difference(last.timestamp) <=
                const Duration(minutes: 12)) {
          return last;
        }
      } catch (_) {}

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// Pour listes (tourisme, proximité) : **rapide** — dernière position pas trop vieille, sinon GPS medium court.
  /// Ne lève pas d’exception (retourne `null` si rien n’est disponible).
  Future<Position?> getPositionForListings({
    Duration maxKnownAge = const Duration(minutes: 25),
    Duration gpsTimeout = const Duration(seconds: 7),
  }) async {
    if (!await UserPreferences.geolocationEnabled()) {
      return null;
    }
    Position? last;
    try {
      last = await Geolocator.getLastKnownPosition();
    } catch (_) {}

    if (last != null &&
        DateTime.now().difference(last.timestamp) <= maxKnownAge) {
      return last;
    }

    try {
      await checkAndRequestPermissions();
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition() ?? last;
      } catch (_) {
        return last;
      }
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: gpsTimeout,
      );
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition() ?? last;
      } catch (_) {
        return last;
      }
    }
  }

  /// Obtient la position actuelle de l'utilisateur
  Future<Position> getCurrentPosition() async {
    await checkAndRequestPermissions();

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      // Fallback utile sur certains appareils (MIUI/Android) quand le fix GPS
      // est lent: on tente d'abord la dernière position connue.
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) return lastKnown;

      // Dernière tentative avec une précision plus permissive et un peu plus de temps.
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 20),
      );
    }
  }

  /// Obtient la position actuelle avec une précision élevée (pour SOS)
  Future<Position> getHighAccuracyPosition() async {
    await checkAndRequestPermissions();

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      timeLimit: const Duration(seconds: 15),
    );
  }

  static const _dakarLat = 14.6937;
  static const _dakarLng = -17.4441;

  /// Position GPS + nom de lieu réel pour la pastille météo.
  Future<WeatherLocationResult> resolveForWeather() async {
    if (!await UserPreferences.geolocationEnabled()) {
      return const WeatherLocationResult(
        latitude: _dakarLat,
        longitude: _dakarLng,
        placeLabel: '',
        isGpsBased: false,
      );
    }

    Position? position = await getPositionForListings(
      maxKnownAge: const Duration(minutes: 45),
      gpsTimeout: const Duration(seconds: 14),
    );
    position ??= await getCurrentPositionIfAllowed();

    if (position == null) {
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (_) {}
    }

    if (position == null) {
      return const WeatherLocationResult(
        latitude: _dakarLat,
        longitude: _dakarLng,
        placeLabel: '',
        isGpsBased: false,
      );
    }

    var label = await getShortPlaceLabel(
      position.latitude,
      position.longitude,
    );
    if (label.isEmpty) {
      label = await _reverseGeocodeNominatim(
            position.latitude,
            position.longitude,
            zoom: 11,
          ) ??
          '';
    }

    return WeatherLocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      placeLabel: label,
      isGpsBased: true,
    );
  }

  /// Libellé court (quartier / ville) via géocodage inverse fiable.
  Future<String> getShortPlaceLabel(double latitude, double longitude) async {
    final nominatim = await _reverseGeocodeNominatim(
      latitude,
      longitude,
      zoom: 14,
    );
    if (nominatim != null && nominatim.isNotEmpty) {
      return nominatim;
    }

    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final picked = _pickFromPlacemark(placemarks.first);
        if (picked != null) return picked;
      }
    } catch (_) {}

    return '';
  }

  Future<String?> _reverseGeocodeNominatim(
    double latitude,
    double longitude, {
    int zoom = 14,
  }) async {
    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'format': 'json',
        'accept-language': 'fr',
        'zoom': zoom.toString(),
      });
      final response = await http
          .get(
            uri,
            headers: const {
              'User-Agent': 'TerangaPass/1.0 (weather; contact@terangapass.com)',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>?;
      final address = json?['address'];
      if (address is Map<String, dynamic>) {
        return _pickFromNominatimAddress(address);
      }
    } catch (_) {}
    return null;
  }

  String? _pickFromNominatimAddress(Map<String, dynamic> address) {
    String? cityLevel;

    const neighborhoodKeys = [
      'quarter',
      'suburb',
      'neighbourhood',
      'city_district',
      'borough',
    ];
    const cityKeys = ['town', 'village', 'hamlet', 'municipality', 'city'];

    for (final key in neighborhoodKeys) {
      final value = address[key];
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty && !_isRejectedPlaceLabel(trimmed)) {
          return trimmed;
        }
      }
    }

    for (final key in cityKeys) {
      final value = address[key];
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty && !_isRejectedPlaceLabel(trimmed)) {
          cityLevel = trimmed;
          break;
        }
      }
    }

    if (cityLevel != null) return cityLevel;

    final county = address['county'];
    if (county is String) {
      final trimmed = county.trim();
      if (trimmed.isNotEmpty && !_isRejectedPlaceLabel(trimmed)) {
        return trimmed;
      }
    }

    return null;
  }

  String? _pickFromPlacemark(Placemark place) {
    for (final part in [
      place.subLocality,
      place.locality,
      place.name,
      place.subAdministrativeArea,
      place.administrativeArea,
    ]) {
      if (part == null) continue;
      final trimmed = part.trim();
      if (trimmed.isNotEmpty && !_isRejectedPlaceLabel(trimmed)) {
        return trimmed;
      }
    }
    return null;
  }

  bool _isRejectedPlaceLabel(String value) {
    final lower = value.toLowerCase().trim();
    if (lower.isEmpty) return true;
    if (lower == 'sénégal' || lower == 'senegal') return true;
    if (lower.contains('région de') || lower.contains('region of')) {
      return true;
    }
    if (lower.startsWith('département') || lower.startsWith('departement')) {
      return true;
    }
    return false;
  }

  /// Convertit les coordonnées en adresse
  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return _formatAddress(place);
      }
      return 'Position inconnue';
    } catch (e) {
      return 'Position inconnue';
    }
  }

  /// Formate l'adresse de manière lisible
  String _formatAddress(Placemark place) {
    List<String> addressParts = [];

    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }

    return addressParts.isNotEmpty
        ? addressParts.join(', ')
        : 'Position inconnue';
  }

  /// Obtient la position actuelle avec l'adresse formatée
  Future<Map<String, dynamic>> getCurrentLocationWithAddress() async {
    try {
      Position position = await getCurrentPosition();
      String address = await getAddressFromCoordinates(
          position.latitude, position.longitude);

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'address': address,
        'timestamp': position.timestamp.toIso8601String(),
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Calcule la distance entre deux points (en mètres)
  double calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Vérifie si la localisation est activée
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
