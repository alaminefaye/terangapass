import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import 'api_service.dart';

/// Progrès d’un téléchargement de bundle (fichier unique ou reprise depuis cache).
class OfflinePackDownloadProgress {
  const OfflinePackDownloadProgress({
    required this.bundleIndex,
    required this.bundleTotal,
    required this.bundleId,
    required this.receivedBytes,
    this.totalBytes,
  });

  final int bundleIndex;
  final int bundleTotal;
  final String bundleId;
  final int receivedBytes;
  final int? totalBytes;

  double get _fractionInBundle {
    if (totalBytes != null && totalBytes! > 0) {
      return (receivedBytes / totalBytes!).clamp(0.0, 1.0);
    }
    return receivedBytes > 0 ? 1.0 : 0.0;
  }

  /// Avancement global entre 0 et 1 (approximatif si pas de `Content-Length`).
  double get overallFraction {
    if (bundleTotal <= 0) return 0;
    return ((bundleIndex + _fractionInBundle) / bundleTotal).clamp(0.0, 1.0);
  }
}

/// Résultat d’une synchronisation des fichiers du pack.
enum OfflinePackSyncResult {
  success,
  upToDate,
  partialFailure,
  error,
}

class _BundleSpec {
  const _BundleSpec({
    required this.id,
    required this.url,
    required this.expectedSha,
  });

  final String id;
  final String url;
  final String expectedSha;
}

/// Cache local du manifeste pack hors ligne ([ApiService.getOfflineManifest]) et
/// téléchargement des fichiers JSON dans le répertoire documents de l’app.
class OfflinePackService {
  OfflinePackService._();
  static final OfflinePackService _instance = OfflinePackService._();
  factory OfflinePackService() => _instance;

  static const String _kCatalogVersion = 'offline_pack_catalog_version';
  static const String _kManifestJson = 'offline_pack_manifest_json';
  static const String _kLastSyncMs = 'offline_pack_last_sync_ms';
  static const String _kDownloadedPackVersion =
      'offline_downloaded_pack_version';
  static const String _kToastVersion = 'offline_pack_ready_toast_version';

  /// Intervalle minimum entre deux sync automatiques (ex. accueil).
  static const Duration defaultStaleInterval = Duration(hours: 6);

  static const String packDirName = 'offline_packs';

  Future<void> _persistManifest(
    Map<String, dynamic> manifest,
    SharedPreferences prefs,
  ) async {
    final v = (manifest['pack_version'] ?? '').toString().trim();
    if (v.isNotEmpty) {
      await prefs.setString(_kCatalogVersion, v);
    }
    await prefs.setString(_kManifestJson, jsonEncode(manifest));
    await prefs.setInt(
      _kLastSyncMs,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

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

  Future<T> _enqueue<T>(Future<T> Function() fn) {
    final completer = Completer<T>();
    _syncQueue = _syncQueue.then((_) async {
      try {
        final r = await fn();
        completer.complete(r);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  Future<void> _syncQueue = Future<void>.value();

  /// Appelle l’API et met à jour le cache ; lance le téléchargement des bundles en arrière-plan.
  Future<void> refresh(ApiService api) async {
    final prefs = await SharedPreferences.getInstance();
    final manifest = await api.getOfflineManifest();
    await _persistManifest(manifest, prefs);
    final rawPack = (manifest['pack_version'] ?? '').toString().trim();
    final prevDl =
        (prefs.getString(_kDownloadedPackVersion) ?? '').trim();
    if (rawPack.isNotEmpty && rawPack == prevDl) {
      return;
    }
    unawaited(
      _enqueue(() => _syncBundlesInternal(
            manifest,
            force: false,
            onProgress: null,
          )),
    );
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

  /// Téléchargement explicite depuis le profil : vérifie le manifeste, reprend les fichiers déjà valides.
  Future<OfflinePackSyncResult> downloadPackNow(
    ApiService api, {
    void Function(OfflinePackDownloadProgress)? onProgress,
  }) async {
    return _enqueue(() async {
      try {
        final manifest = await api.getOfflineManifest();
        final prefs = await SharedPreferences.getInstance();
        await _persistManifest(manifest, prefs);
        return _syncBundlesInternal(
          manifest,
          force: true,
          onProgress: onProgress,
        );
      } catch (e, st) {
        debugPrint('[OfflinePack] downloadPackNow: $e\n$st');
        return OfflinePackSyncResult.error;
      }
    });
  }

  static List<_BundleSpec> _parseBundles(Map<String, dynamic> manifest) {
    final bundles = manifest['bundles'];
    if (bundles is! List) return [];
    final list = <_BundleSpec>[];
    for (final item in bundles) {
      if (item is! Map) continue;
      final id = (item['id'] ?? '').toString().trim();
      final url = (item['url'] ?? '').toString().trim();
      final sha = (item['sha256'] ?? '').toString().trim();
      if (id.isEmpty || url.isEmpty) continue;
      list.add(_BundleSpec(id: id, url: url, expectedSha: sha));
    }
    return list;
  }

  Future<bool> _localFileMatches(String path, String expectedSha) async {
    if (expectedSha.isEmpty) return false;
    final f = File(path);
    if (!await f.exists()) return false;
    try {
      final raw = await f.readAsString();
      final digest = sha256.convert(utf8.encode(raw));
      return digest.toString() == expectedSha;
    } catch (_) {
      return false;
    }
  }

  Future<OfflinePackSyncResult> _syncBundlesInternal(
    Map<String, dynamic> manifest, {
    required bool force,
    void Function(OfflinePackDownloadProgress)? onProgress,
  }) async {
    final rawPack = (manifest['pack_version'] ?? '').toString().trim();
    final prefs = await SharedPreferences.getInstance();
    final prevDl =
        (prefs.getString(_kDownloadedPackVersion) ?? '').trim();
    final specs = _parseBundles(manifest);

    if (rawPack.isEmpty) {
      debugPrint('[OfflinePack] empty pack_version in manifest');
      return OfflinePackSyncResult.error;
    }

    if (specs.isEmpty) {
      return OfflinePackSyncResult.error;
    }

    if (!force && rawPack == prevDl) {
      return OfflinePackSyncResult.upToDate;
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

    final n = specs.length;
    var anyFailure = false;
    var didWrite = false;

    for (var i = 0; i < n; i++) {
      final spec = specs[i];
      final safeId = spec.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final path = '${packDir.path}/$safeId.json';

      if (await _localFileMatches(path, spec.expectedSha)) {
        onProgress?.call(
          OfflinePackDownloadProgress(
            bundleIndex: i,
            bundleTotal: n,
            bundleId: spec.id,
            receivedBytes: 1,
            totalBytes: 1,
          ),
        );
        continue;
      }

      try {
        onProgress?.call(
          OfflinePackDownloadProgress(
            bundleIndex: i,
            bundleTotal: n,
            bundleId: spec.id,
            receivedBytes: 0,
            totalBytes: null,
          ),
        );

        final res = await dio.get<String>(
          spec.url,
          onReceiveProgress: (rcv, tot) {
            onProgress?.call(
              OfflinePackDownloadProgress(
                bundleIndex: i,
                bundleTotal: n,
                bundleId: spec.id,
                receivedBytes: rcv,
                totalBytes: tot > 0 ? tot : null,
              ),
            );
          },
        );

        final body = res.data ?? '';
        if (spec.expectedSha.isNotEmpty) {
          final digest = sha256.convert(utf8.encode(body));
          if (digest.toString() != spec.expectedSha) {
            debugPrint(
              '[OfflinePack] sha256 mismatch for ${spec.id} — skip write.',
            );
            anyFailure = true;
            continue;
          }
        }

        await File(path).writeAsString(body, flush: true);
        didWrite = true;
      } catch (e, st) {
        debugPrint('[OfflinePack] bundle ${spec.id}: $e\n$st');
        anyFailure = true;
      }
    }

    if (anyFailure) {
      return OfflinePackSyncResult.partialFailure;
    }

    await prefs.setString(_kDownloadedPackVersion, rawPack);
    // Toast sur l’accueil seulement pour les sync en arrière-plan (pas après le dialogue Profil).
    if (didWrite && onProgress == null) {
      await prefs.setString(_kToastVersion, rawPack);
    }

    final nothingChanged = rawPack == prevDl && !didWrite;
    if (nothingChanged) {
      return OfflinePackSyncResult.upToDate;
    }
    return OfflinePackSyncResult.success;
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

  Future<List<Map<String, dynamic>>?> _readBundleDataList(
    String bundleId,
  ) async {
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
