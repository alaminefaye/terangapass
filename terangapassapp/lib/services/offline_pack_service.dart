import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';

/// Cache local du manifeste pack hors ligne ([ApiService.getOfflineManifest]).
class OfflinePackService {
  OfflinePackService._();
  static final OfflinePackService _instance = OfflinePackService._();
  factory OfflinePackService() => _instance;

  static const String _kCatalogVersion = 'offline_pack_catalog_version';
  static const String _kManifestJson = 'offline_pack_manifest_json';
  static const String _kLastSyncMs = 'offline_pack_last_sync_ms';

  /// Intervalle minimum entre deux sync automatiques (ex. accueil).
  static const Duration defaultStaleInterval = Duration(hours: 6);

  Future<String?> cachedCatalogVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kCatalogVersion);
  }

  /// Lecture du dernier manifeste reçu (pour futur téléchargement de bundles).
  Future<Map<String, dynamic>?> cachedManifest() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kManifestJson);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return null;
  }

  /// Appelle l’API et met à jour le cache ; en échec, le cache existant est conservé.
  Future<void> refresh(ApiService api) async {
    final prefs = await SharedPreferences.getInstance();
    final manifest = await api.getOfflineManifest();
    final v = (manifest['pack_version'] ?? '').toString().trim();
    if (v.isNotEmpty) {
      await prefs.setString(_kCatalogVersion, v);
    }
    await prefs.setString(_kManifestJson, jsonEncode(manifest));
    await prefs.setInt(_kLastSyncMs, DateTime.now().millisecondsSinceEpoch);
  }

  /// Sync uniquement si aucune sync récente selon [staleAfter] — usage accueil.
  Future<void> refreshIfStale(
    ApiService api, {
    Duration staleAfter = defaultStaleInterval,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getInt(_kLastSyncMs) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (last > 0 && now - last < staleAfter.inMilliseconds) {
      return;
    }
    try {
      await refresh(api);
    } catch (e, st) {
      debugPrint('[OfflinePack] refreshIfStale: $e\n$st');
    }
  }
}
