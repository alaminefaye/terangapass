import '../services/api_service.dart';

/// URLs média pour les points d'intérêt (liste carte, tourisme, etc.).
class PoiMediaHelpers {
  PoiMediaHelpers._();

  static String? normalizeUrl(Object? value) {
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('google_photo:')) return null;

    if (raw.startsWith('https://')) return raw;
    if (raw.startsWith('http://')) {
      return 'https://${raw.substring('http://'.length)}';
    }

    final base = ApiService.baseUrl.replaceAll('/api/v1', '');
    final host = base.replaceAll(RegExp(r'/+$'), '');

    if (raw.startsWith('/')) {
      return '$host$raw';
    }

    if (raw.startsWith('storage/') || raw.startsWith('public/')) {
      return '$host/${raw.replaceAll(RegExp(r'^/+'), '')}';
    }

    return null;
  }

  static String? thumbnailUrl(Map<String, dynamic> point) {
    final icon = normalizeUrl(
      point['icon_url'] ??
          point['iconUrl'] ??
          point['logo_url'] ??
          point['logoUrl'],
    );
    if (icon != null) return icon;

    final photos = point['photos'];
    if (photos is List) {
      for (final item in photos) {
        final url = normalizeUrl(item);
        if (url != null) return url;
      }
    }

    return null;
  }
}
