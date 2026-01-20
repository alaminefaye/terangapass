import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Vérifie et demande les permissions de localisation
  Future<bool> checkAndRequestPermissions() async {
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

  /// Obtient la position actuelle de l'utilisateur
  Future<Position> getCurrentPosition() async {
    await checkAndRequestPermissions();

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 10),
    );
  }

  /// Obtient la position actuelle avec une précision élevée (pour SOS)
  Future<Position> getHighAccuracyPosition() async {
    await checkAndRequestPermissions();

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      timeLimit: const Duration(seconds: 15),
    );
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
