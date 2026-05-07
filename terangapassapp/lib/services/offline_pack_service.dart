import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import 'api_service.dart';

/// Cache local du manifeste pack hors ligne ([ApiService.getOfflineManifest]) et
/// téléchargement des fichiers JSON dans le répertoire documents de l’app.
class OfflinePackService {
  OfflinePackService._();
  static final OfflinePackService _instance = OfflinePackService._();
  factory OfflinePackService() => _instance;

  static const String _kCatalogVersion = 'offline_pack_catalog_version';
  static const String _kManifestJson = 'offline_pack_manifest_json';
  static const String _kLastSyncMs = 'offline_pack_last_sync_ms';
  static const String _kDownloadedPackVersion = 'offline_downloaded_pack_version';
  static const String _kToastVersion = 'offline_pack_ready_toast_version';

  /// Intervalle minimum entre deux sync automatiques (ex. accueil).
  static const Duration defaultStaleInterval = Duration(hours: 6);

  static const String packDirName = 'offline_packs';

  Future<String?> cachedCatalogVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kCatalogVersion);
  }

  /// Version du catalogue dont les bundles ont été écrits sur disque.
  Future<String?> downloadedPackVersion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kDownloadedPackVersion);
  }

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

  /// Appelle l’API et met à jour le cache ; lance le téléchargement des bundles en arrière-plan.
  Future<void> refresh(ApiService api) async {
    final prefs = await SharedPreferences.getInstance();
    final manifest = await api.getOfflineManifest();
    final v = (manifest['pack_version'] ?? '').toString().trim();
    if (v.isNotEmpty) {
      await prefs.setString(_kCatalogVersion, v);
    }
    await prefs.setString(_kManifestJson, jsonEncode(manifest));
    await prefs.setInt(_kLastSyncMs, DateTime.now().millisecondsSinceEpoch);
    unawaited(_maybeDownloadBundles(manifest));
  }

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

  Future<void> _maybeDownloadBundles(Map<String, dynamic> manifest) async {
    final rawPack = (manifest['pack_version'] ?? '').toString().trim();
    final prefs = await SharedPreferences.getInstance();
    final prevDl = (prefs.getString(_kDownloadedPackVersion) ?? '').trim();
    final bundles = manifest['bundles'];
    if (rawPack.isEmpty ||
        bundles is! List ||
        bundles.isEmpty ||
        rawPack == prevDl) {
      return;
    }

    final baseDir = await getApplicationDocumentsDirectory();
    final packDir = Directory('${baseDir.path}/$packDirName');
    await packDir.create(recursive: true);

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(seconds: 90),
        responseType: ResponseType.plain,
        validateStatus: (s) => s != null && s >= 200 && s < 300,
      ),
    );

    try {
      for (final item in bundles) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(
          item.map((k, v) => MapEntry(k.toString(), v)),
        );
        final id = (map['id'] ?? '').toString().trim();
        final url = (map['url'] ?? '').toString().trim();
        final expectedSha = (map['sha256'] ?? '').toString().trim();
        if (id.isEmpty || url.isEmpty) continue;

        final res = await dio.get<String>(url);
        final body = res.data ?? '';
        if (expectedSha.isNotEmpty) {
          final digest = sha256.convert(utf8.encode(body));
          if (digest.toString() != expectedSha) {
            debugPrint(
              '[OfflinePack] sha256 mismatch for $id — skip write.',
            );
            continue;
          }
        }

        final safeId = id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
        final file = File('${packDir.path}/$safeId.json');
        await file.writeAsString(body, flush: true);
      }
      await prefs.setString(_kDownloadedPackVersion, rawPack);
      await prefs.setString(_kToastVersion, rawPack);
      debugPrint('[OfflinePack] bundles saved for pack_version=$rawPack');
    } catch (e, st) {
      debugPrint('[OfflinePack] download failed: $e\n$st');
    }
  }

  /// Contenu du fichier `poi.json` (liste `data`), ou liste vide.
  Future<List<Map<String, dynamic>>> readOfflinePoiList() async =>
      await _readBundleDataList('poi') ?? [];

  /// Contenu du fichier `competition_sites.json`, ou liste vide.
  Future<List<Map<String, dynamic>>> readOfflineCompetitionSitesList() async =>
      await _readBundleDataList('competition_sites') ?? [];

  Future<List<Map<String, dynamic>>> readOfflineEmbassiesList() async =>
      await _readBundleDataList('embassies') ?? [];

  Future<List<Map<String, dynamic>>> readOfflineCalendarList() async =>
      await _readBundleDataList('competition_calendar') ?? [];

  Future<List<Map<String, dynamic>>> readOfflineAudioAnnouncementsList() async =>
      await _readBundleDataList('audio_announcements') ?? [];

  /// Après téléchargement réussi des bundles, affiche un toast une fois (accueil).
  Future<void> maybeShowPackUpdatedToast(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_kToastVersion);
    if (v == null || v.isEmpty) return;
    await prefs.remove(_kToastVersion);
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(
        content: Text(l10n.offlinePackUpdated(v)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<List<Map<String, dynamic>>?> _readBundleDataList(String bundleId) async {
    try {
      final baseDir = await getApplicationDocumentsDirectory();
      final safeId = bundleId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final file = File('${baseDir.path}/$packDirName/$safeId.json');
      if (!await file.exists()) return null;
      final raw = await file.readAsString();
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final data = decoded['data'];
      if (data is! List) return null;
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e, st) {
      debugPrint('[OfflinePack] read bundle $bundleId: $e\n$st');
      return null;
    }
  }
}
