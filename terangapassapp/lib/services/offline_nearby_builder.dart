import 'location_service.dart';

/// Construit une liste de lieux façon `/nearby` à partir du JSON POI hors ligne.
class OfflineNearbyBuilder {
  OfflineNearbyBuilder._();

  static String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static String _guessKeyFromCategoryLabel(String label) {
    final l = label.toLowerCase();
    if (l.contains('hôtel') || l.contains('hotel')) return 'hotel';
    if (l.contains('restaurant')) return 'restaurant';
    if (l.contains('pharm')) return 'pharmacy';
    if (l.contains('hôpital') || l.contains('hopital')) return 'hospital';
    if (l.contains('ambassade') || l.contains('consul')) return 'embassy';
    if (l.contains('banque')) return 'bank';
    if (l.contains('station') || l.contains('essence')) return 'gas_station';
    if (l.contains('boutique') || l.contains('shop')) return 'shop';
    if (l.contains('notaire')) return 'notary';
    if (l.contains('avocat')) return 'lawyer';
    if (l.contains('médecin') || l.contains('medecin')) return 'doctor';
    if (l.contains('clinique')) return 'clinic';
    if (l.contains('école') || l.contains('ecole')) return 'school';
    if (l.contains('université') || l.contains('universite')) {
      return 'university';
    }
    if (l.contains('média') || l.contains('media')) return 'media';
    if (l.contains('culte') || l.contains('relig')) return 'religious_site';
    if (l.contains('administr') || l.contains('état') || l.contains('etat')) {
      return 'government';
    }
    if (l.contains('professionnel')) return 'professional_service';
    return 'other';
  }

  static List<Map<String, dynamic>> build({
    required double userLat,
    required double userLng,
    required int radiusMeters,
    required List<Map<String, dynamic>> poi,
  }) {
    final ls = LocationService();
    final out = <Map<String, dynamic>>[];

    for (final p in poi) {
      final lat = (p['latitude'] as num?)?.toDouble();
      final lng = (p['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;

      final d = ls.calculateDistance(userLat, userLng, lat, lng);
      if (d > radiusMeters) continue;

      var key = (p['category_key'] ?? '').toString().trim().toLowerCase();
      if (key.isEmpty) {
        key = _guessKeyFromCategoryLabel((p['category'] ?? '').toString());
      }

      final row = Map<String, dynamic>.from(p);
      row['category_key'] = key;
      row['distance_meters'] = d;
      row['distance'] = _formatDistance(d);
      if (!row.containsKey('is_sponsor')) {
        row['is_sponsor'] = false;
      }

      out.add(row);
    }

    out.sort((a, b) {
      final sa = a['is_sponsor'] == true;
      final sb = b['is_sponsor'] == true;
      if (sa != sb) {
        return sb ? 1 : -1;
      }
      final da = (a['distance_meters'] as num).toDouble();
      final db = (b['distance_meters'] as num).toDouble();
      return da.compareTo(db);
    });

    return out;
  }
}
