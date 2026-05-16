import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../constants/map_constants.dart';

/// Résultat d'un itinéraire Google Directions.
class GoogleDirectionsResult {
  const GoogleDirectionsResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.navSteps,
    this.distanceText,
    this.durationText,
  });

  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;
  final List<Map<String, dynamic>> navSteps;
  final String? distanceText;
  final String? durationText;
}

/// Appels à l'API Google Directions (distance / durée / tracé routier).
class GoogleDirectionsService {
  GoogleDirectionsService._();

  static const _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  /// Itinéraire voiture depuis [origin] vers [destination].
  /// Lance une exception si Google refuse ou ne trouve pas de route.
  static Future<GoogleDirectionsResult> fetchDrivingRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'mode': 'driving',
        'language': 'fr',
        'units': 'metric',
        'departure_time': 'now',
        'key': MapConstants.googleMapsApiKey,
      },
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw GoogleDirectionsException(
        'Google Directions HTTP ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final status = (data['status'] as String?) ?? 'UNKNOWN';
    if (status != 'OK') {
      final err = data['error_message'] as String?;
      throw GoogleDirectionsException(
        err ?? 'Google Directions: $status',
      );
    }

    final routes = data['routes'] as List?;
    if (routes == null || routes.isEmpty) {
      throw GoogleDirectionsException('Aucun itinéraire Google');
    }

    final route = routes.first as Map<String, dynamic>;
    final legs = route['legs'] as List?;
    if (legs == null || legs.isEmpty) {
      throw GoogleDirectionsException('Itinéraire Google sans étape');
    }

    final leg = legs.first as Map<String, dynamic>;
    final distanceM =
        (leg['distance']?['value'] as num?)?.toDouble() ?? 0.0;
    var durationS = (leg['duration']?['value'] as num?)?.toDouble() ?? 0.0;
    // Durée avec trafic si disponible (plus réaliste en voiture).
    final traffic = leg['duration_in_traffic']?['value'] as num?;
    if (traffic != null) {
      durationS = traffic.toDouble();
    }

    final encoded = route['overview_polyline']?['points'] as String?;
    if (encoded == null || encoded.isEmpty) {
      throw GoogleDirectionsException('Polyline Google manquante');
    }

    final points = _decodePolyline(encoded);
    final rawSteps = (leg['steps'] as List?) ?? [];
    final navSteps = rawSteps
        .whereType<Map>()
        .map((s) => _googleStepToNavStep(Map<String, dynamic>.from(s)))
        .toList();

    return GoogleDirectionsResult(
      points: points,
      distanceMeters: distanceM,
      durationSeconds: durationS,
      navSteps: navSteps,
      distanceText: leg['distance']?['text'] as String?,
      durationText: (leg['duration_in_traffic'] ?? leg['duration'])?['text']
          as String?,
    );
  }

  static String formatDistanceLabel(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static String formatDurationLabel(double seconds) {
    final totalMin = (seconds / 60).round();
    if (totalMin < 60) return '$totalMin min';
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    if (m == 0) return '$h h';
    return '$h h $m min';
  }

  /// Décode une polyline encodée Google (overview_polyline).
  static List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0;
    var lat = 0;
    var lng = 0;

    while (index < encoded.length) {
      var shift = 0;
      var result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  static Map<String, dynamic> _googleStepToNavStep(Map<String, dynamic> step) {
    final maneuverRaw = (step['maneuver'] as String? ?? '').toLowerCase();
    final html = (step['html_instructions'] as String? ?? '').trim();
    final name = _stripHtml(html);

    String type = 'continue';
    String modifier = '';

    if (maneuverRaw.contains('roundabout') || maneuverRaw.contains('rotary')) {
      type = 'roundabout';
    } else if (maneuverRaw.contains('uturn') || maneuverRaw.contains('u-turn')) {
      type = 'turn';
      modifier = 'uturn';
    } else if (maneuverRaw.contains('turn') || maneuverRaw.contains('ramp')) {
      type = 'turn';
      if (maneuverRaw.contains('sharp')) {
        modifier = maneuverRaw.contains('left') ? 'sharp left' : 'sharp right';
      } else if (maneuverRaw.contains('slight')) {
        modifier = maneuverRaw.contains('left') ? 'slight left' : 'slight right';
      } else if (maneuverRaw.contains('left')) {
        modifier = 'left';
      } else if (maneuverRaw.contains('right')) {
        modifier = 'right';
      }
    } else if (maneuverRaw.contains('merge')) {
      type = 'merge';
    } else if (maneuverRaw.contains('fork')) {
      type = 'fork';
      modifier = maneuverRaw.contains('left') ? 'left' : 'right';
    } else if (maneuverRaw.isEmpty || maneuverRaw.contains('straight')) {
      type = 'continue';
      modifier = 'straight';
    }

    final end = step['end_location'] as Map<String, dynamic>?;
    final lng = (end?['lng'] as num?)?.toDouble();
    final lat = (end?['lat'] as num?)?.toDouble();

    return {
      'instruction': name,
      'name': name,
      'maneuver': {
        'type': type,
        'modifier': modifier,
        if (lng != null && lat != null) 'location': [lng, lat],
      },
    };
  }

  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class GoogleDirectionsException implements Exception {
  GoogleDirectionsException(this.message);
  final String message;

  @override
  String toString() => message;
}
