import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../models/poi_api_result.dart';
import 'api_error_messages.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  static const bool _enableVerboseDebugLogs = false;
  static const String _cookiePrefsKey = 'auth_cookie';

  // Utilise ApiConstants pour la configuration centralisée
  static String get baseUrl => ApiConstants.baseUrl;

  /// Configure l'URL de base de l'API (override de ApiConstants)
  static String? _customBaseUrl;
  static void setBaseUrl(String url) {
    _customBaseUrl = url;
  }

  static String get _effectiveBaseUrl => _customBaseUrl ?? ApiConstants.baseUrl;

  late Dio _dio;
  String? _cookieHeader;

  void _debugLog(Object? message) {
    assert(() {
      if (!_enableVerboseDebugLogs) {
        return true;
      }
      debugPrint(message?.toString() ?? '');
      return true;
    }());
  }

  Map<String, dynamic> _decodeMapResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) {
        throw Exception(ApiErrorMessages.serverEmpty);
      }
      try {
        final decoded = jsonDecode(trimmed);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } on FormatException {
        throw Exception(ApiErrorMessages.serverInvalid);
      }
    }
    throw Exception(ApiErrorMessages.serverInvalid);
  }

  Future<void> _loadCookie() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_cookiePrefsKey);
    _cookieHeader = (value == null || value.trim().isEmpty)
        ? null
        : value.trim();
  }

  Future<void> _saveCookie(String cookieHeader) async {
    final trimmed = cookieHeader.trim();
    if (trimmed.isEmpty) return;
    _cookieHeader = trimmed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cookiePrefsKey, trimmed);
  }

  String? _extractCookieHeaderFromResponse(Headers headers) {
    final setCookies = headers.map['set-cookie'];
    if (setCookies == null || setCookies.isEmpty) return null;

    final map = <String, String>{};

    if (_cookieHeader != null && _cookieHeader!.isNotEmpty) {
      for (final part in _cookieHeader!.split(';')) {
        final p = part.trim();
        if (p.isEmpty) continue;
        final idx = p.indexOf('=');
        if (idx <= 0) continue;
        map[p.substring(0, idx).trim()] = p.substring(idx + 1).trim();
      }
    }

    for (final raw in setCookies) {
      final first = raw.split(';').first.trim();
      final idx = first.indexOf('=');
      if (idx <= 0) continue;
      map[first.substring(0, idx).trim()] = first.substring(idx + 1).trim();
    }

    if (map.isEmpty) return null;
    return map.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  String? _extractTokenFromHeaders(Headers headers) {
    final auth =
        headers.value('authorization') ?? headers.value('Authorization');
    if (auth != null && auth.trim().isNotEmpty) {
      final parts = auth.trim().split(' ');
      if (parts.length == 2 && parts.first.toLowerCase() == 'bearer') {
        return parts[1].trim().isEmpty ? null : parts[1].trim();
      }
      return auth.trim();
    }

    final xAuthToken =
        headers.value('x-auth-token') ?? headers.value('X-Auth-Token');
    if (xAuthToken != null && xAuthToken.trim().isNotEmpty) {
      return xAuthToken.trim();
    }

    return null;
  }

  String? _coerceTokenValue(Object? raw) {
    if (raw == null) return null;
    if (raw is String) {
      final t = raw.trim();
      return t.isEmpty ? null : t;
    }
    if (raw is num) {
      return raw.toString();
    }
    return null;
  }

  /// Clés fréquentes : Laravel custom, Sanctum (`plainTextToken`).
  String? _extractTokenFromBody(Map<String, dynamic> body) {
    const topKeys = [
      'token',
      'access_token',
      'plainTextToken',
      'accessToken',
      'auth_token',
    ];
    for (final k in topKeys) {
      final v = _coerceTokenValue(body[k]);
      if (v != null) return v;
    }

    final data = body['data'];
    if (data is Map) {
      final m = Map<String, dynamic>.from(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );
      for (final k in topKeys) {
        final v = _coerceTokenValue(m[k]);
        if (v != null) return v;
      }
    }

    return null;
  }

  /// Dio assemble base + chemin comme [Uri.resolve] : un chemin commençant par
  /// `/` repart de la racine du domaine (on perd `/api/v1`). Sans slash final
  /// sur la base, `…/api/v1` + `auth/login` devient `…/api/auth/login`.
  static String _normalizedDioBaseUrl(String url) {
    final t = url.trim();
    if (t.isEmpty) return t;
    return t.endsWith('/') ? t : '$t/';
  }

  ApiService._internal() {
    // Calcul de l'URL du site (sans `/api/v1`) pour Origin / Referer
    final baseUrlForHeaders = _effectiveBaseUrl.replaceFirst(
      RegExp(r'/api/v1/?$'),
      '',
    );

    // Log de l'URL de base utilisée
    _debugLog('=== API SERVICE INITIALIZATION ===');
    _debugLog('Base URL: $_effectiveBaseUrl');
    _debugLog('Base URL for headers: $baseUrlForHeaders');
    _debugLog(
      'Mode: ${ApiConstants.baseUrl == _effectiveBaseUrl ? "ApiConstants" : "Custom"}',
    );
    _debugLog('==================================');

    debugPrint('[API] baseUrl effectif = ${_normalizedDioBaseUrl(_effectiveBaseUrl)}');

    _dio = Dio(
      BaseOptions(
        baseUrl: _normalizedDioBaseUrl(_effectiveBaseUrl),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        followRedirects: true,
        maxRedirects: 5,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // User-Agent de navigateur pour contourner Tiger Protect (o2switch)
          'User-Agent':
              'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1',
          'Accept-Language': 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7',
          'Accept-Encoding': 'gzip, deflate, br',
          'Origin': baseUrlForHeaders,
          'Referer': '$baseUrlForHeaders/',
        },
        validateStatus: (status) {
          // Exclure les 3xx : sinon une redirection / page HTML peut être traitée comme succès.
          // Les erreurs 4xx/5xx passent par DioException et [_handleError].
          return status != null && status >= 200 && status < 300;
        },
      ),
    );

    // Intercepteur pour ajouter le token d'authentification et logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_cookieHeader == null) {
            await _loadCookie();
          }
          final token = await _getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (_cookieHeader != null && _cookieHeader!.isNotEmpty) {
            options.headers['Cookie'] = _cookieHeader;
          }
          final lang =
              AppConstants.localeNotifier.value?.languageCode ??
              AppConstants.defaultLanguage;
          options.headers['Accept-Language'] = lang == 'en'
              ? 'en-US,en;q=0.9,fr-FR;q=0.8,fr;q=0.7'
              : 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7';
          // Log détaillé de la requête pour debugging
          _debugLog('=== API REQUEST ===');
          _debugLog('URL: ${options.method} ${options.baseUrl}${options.path}');
          _debugLog('Headers: ${options.headers}');
          _debugLog('Data: ${options.data}');
          _debugLog('==================');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final cookieHeader = _extractCookieHeaderFromResponse(
            response.headers,
          );
          if (cookieHeader != null && cookieHeader.isNotEmpty) {
            _saveCookie(cookieHeader);
          }
          // Log de la réponse pour debugging
          _debugLog(
            'API Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          // Log détaillé de l'erreur pour debugging
          _debugLog('=== API ERROR ===');
          _debugLog('Status Code: ${error.response?.statusCode}');
          _debugLog('Path: ${error.requestOptions.path}');
          _debugLog(
            'Full URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}',
          );
          _debugLog('Error Type: ${error.type}');
          _debugLog('Error Message: ${error.message}');
          _debugLog('Error toString: ${error.toString()}');
          _debugLog('Request Headers: ${error.requestOptions.headers}');
          _debugLog('Request Data: ${error.requestOptions.data}');
          if (error.response != null) {
            _debugLog('Response Status Code: ${error.response?.statusCode}');
            _debugLog('Response Headers: ${error.response?.headers}');
            _debugLog('Response Data: ${error.response?.data}');
            _debugLog(
              'Response Status Message: ${error.response?.statusMessage}',
            );
          } else {
            _debugLog('No response received - connection issue');
            _debugLog('Error Type Details:');
            _debugLog(
              '  - connectionTimeout: ${error.type == DioExceptionType.connectionTimeout}',
            );
            _debugLog(
              '  - sendTimeout: ${error.type == DioExceptionType.sendTimeout}',
            );
            _debugLog(
              '  - receiveTimeout: ${error.type == DioExceptionType.receiveTimeout}',
            );
            _debugLog(
              '  - connectionError: ${error.type == DioExceptionType.connectionError}',
            );
            _debugLog(
              '  - badCertificate: ${error.type == DioExceptionType.badCertificate}',
            );
            _debugLog(
              '  - badResponse: ${error.type == DioExceptionType.badResponse}',
            );
            _debugLog('  - cancel: ${error.type == DioExceptionType.cancel}');
            _debugLog('  - unknown: ${error.type == DioExceptionType.unknown}');
          }
          _debugLog('Stack Trace: ${error.stackTrace}');
          _debugLog('==================');
          // Gestion des erreurs — session invalide ou compte refusé (ex. suspendu)
          final errCode = error.response?.statusCode;
          if (errCode == 401 || errCode == 403) {
            _clearToken();
          }
          return handler.next(error);
        },
      ),
    );

    // Hébergeurs (nginx, o2switch, Cloudflare) renvoient parfois 301/307 sans que l’adapter suive
    // le POST ; on retente une fois vers `Location` (ex. apex → www).
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException err, ErrorInterceptorHandler handler) async {
          await _retryOnceAfterHttpRedirect(err, handler);
        },
      ),
    );
  }

  static const String _kRedirectRetryExtra = '_teranga_redirect_retry_done';

  static Uri _absoluteRedirectUri(Uri requestUri, String locationHeader) {
    final t = locationHeader.trim();
    if (t.isEmpty) {
      return requestUri;
    }
    if (t.startsWith('http://') || t.startsWith('https://')) {
      return Uri.parse(t);
    }
    return requestUri.resolve(t);
  }

  Future<void> _retryOnceAfterHttpRedirect(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.requestOptions.extra[_kRedirectRetryExtra] == true) {
      handler.next(err);
      return;
    }
    if (err.type != DioExceptionType.badResponse) {
      handler.next(err);
      return;
    }
    final code = err.response?.statusCode;
    if (code != 301 &&
        code != 302 &&
        code != 303 &&
        code != 307 &&
        code != 308) {
      handler.next(err);
      return;
    }
    final loc = err.response?.headers.value('location') ??
        err.response?.headers.value('Location');
    if (loc == null || loc.trim().isEmpty) {
      debugPrint('[API] 307/redirect sans Location header — abandon');
      handler.next(err);
      return;
    }
    // Tiger Protect (o2switch WAF) : renvoie un 307 vers la MÊME URL avec un
    // cookie de challenge. Il faut extraire ce cookie et le renvoyer dans le
    // retry pour que le WAF laisse passer la requête.
    final redirectCookie = _extractCookieHeaderFromResponse(err.response!.headers);
    if (redirectCookie != null && redirectCookie.isNotEmpty) {
      _cookieHeader = redirectCookie;
      await _saveCookie(redirectCookie);
      debugPrint('[API] cookie WAF extrait du 307 : $redirectCookie');
    }

    try {
      final target = _absoluteRedirectUri(err.requestOptions.uri, loc);
      debugPrint('[API] retry redirection: ${err.requestOptions.uri} → $target');

      // Construire les en-têtes avec le cookie WAF inclus
      final retryHeaders = Map<String, dynamic>.from(err.requestOptions.headers);
      if (_cookieHeader != null && _cookieHeader!.isNotEmpty) {
        retryHeaders['Cookie'] = _cookieHeader;
      }

      final next = err.requestOptions.copyWith(
        baseUrl: '${target.scheme}://${target.host}',
        path: target.hasQuery
            ? '${target.path}?${target.query}'
            : target.path,
        queryParameters: null,
        headers: retryHeaders,
        extra: <String, dynamic>{
          ...err.requestOptions.extra,
          _kRedirectRetryExtra: true,
        },
      );
      final response = await _dio.fetch(next);
      handler.resolve(response);
    } catch (e, st) {
      debugPrint('[API] redirection HTTP suivie sans succès: $e\n$st');
      // Propager l'erreur RÉELLE du retry (ex: 422 validation Laravel),
      // pas l'erreur 307 d'origine qui n'a plus de sens pour l'appelant.
      if (e is DioException) {
        handler.next(e);
      } else {
        handler.next(err);
      }
    }
  }

  /// Récupère le token d'authentification depuis le stockage local
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Sauvegarde le token d'authentification
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  /// Supprime le token d'authentification
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove(_cookiePrefsKey);
    _cookieHeader = null;
  }

  /// Réinitialise tout stockage local d’auth (jeton + cookie) sans appeler l’API.
  Future<void> clearLocalAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.authPersistSessionKey);
    await _clearToken();
  }

  /// Vérifie que le jeton stocké est encore accepté par l’API (profil).
  /// En cas de **401** ou **403** (refus / compte suspendu), efface le stockage local.
  /// Les erreurs réseau ou 5xx ne suppriment pas le jeton (évite déconnexion fortuite).
  /// Timeouts connect / envoi / réponse abrégés pour cette requête uniquement (puis restauration).
  Future<void> validateStoredSession() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) return;
    final previousConnect = _dio.options.connectTimeout;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    try {
      await _dio.get(
        'user/profile',
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) {
        await clearLocalAuth();
      }
    } finally {
      _dio.options.connectTimeout = previousConnect;
    }
  }

  // ==================== AUTHENTIFICATION ====================

  /// Connexion (identifiant = email ou numéro, envoyé dans le champ `email` pour l’API).
  Future<Map<String, dynamic>> login(
    String emailOrPhone,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        'auth/login',
        data: {'email': emailOrPhone, 'password': password},
      );

      final data = response.data;
      if (data == null ||
          (data is String && data.trim().isEmpty) ||
          response.statusCode == 204) {
        final headerToken = _extractTokenFromHeaders(response.headers);
        if (headerToken != null && headerToken.isNotEmpty) {
          await _saveToken(headerToken);
          return {'success': true, 'token': headerToken};
        }
        final cookieHeader = _extractCookieHeaderFromResponse(response.headers);
        if (cookieHeader != null && cookieHeader.isNotEmpty) {
          await _saveCookie(cookieHeader);
        }
        // Un cookie seul ne remplace pas un Bearer : l’API doit renvoyer un jeton (JSON ou en-tête).
        throw Exception(ApiErrorMessages.loginEmptyOrNoToken);
      }

      final responseData = _decodeMapResponse(data);
      var token =
          _extractTokenFromBody(responseData) ??
          _extractTokenFromHeaders(response.headers);

      final successFlag = responseData['success'];
      final success =
          successFlag == true ||
          successFlag == 'true' ||
          successFlag == 1;

      if (token != null && token.isNotEmpty) {
        await _saveToken(token);
        responseData['token'] = token;
        return responseData;
      }

      if (success) {
        throw Exception(ApiErrorMessages.loginIncompleteNoToken);
      }

      throw Exception(
        responseData['message']?.toString() ?? ApiErrorMessages.loginFailed,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  /// Inscription
  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password, {
    String? phone,
    String country = 'SN',
  }) async {
    try {
      final response = await _dio.post(
        'auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'country': country.trim().toUpperCase(),
          if (phone != null && phone.trim().isNotEmpty) ...{
            'phone': phone.trim(),
            'telephone': phone.trim(),
          },
        },
      );

      final data = response.data;
      if (data == null ||
          (data is String && data.trim().isEmpty) ||
          response.statusCode == 204) {
        // Ne pas accepter cookie / en-têtes seuls : souvent une page HTML ou une redirection
        // → l’app affichait « connecté » sans compte créé côté Laravel.
        throw Exception(ApiErrorMessages.registerEmptyOrHtml);
      }

      // Gérer le nouveau format de réponse standardisé (comme chantix)
      final responseData = _decodeMapResponse(data);
      final token =
          _extractTokenFromBody(responseData) ??
          _extractTokenFromHeaders(response.headers);

      if (responseData['success'] == true && token != null && token.isNotEmpty) {
        await _saveToken(token);
        responseData['token'] = token;
        return responseData;
      }
      // Ne pas traiter comme inscription réussie sans jeton exploitable par l’API.
      if (responseData['success'] == true &&
          (token == null || token.isEmpty)) {
        throw Exception(
          responseData['message'] ?? ApiErrorMessages.registerIncompleteToken,
        );
      }
      if (token != null && token.isNotEmpty) {
        await _saveToken(token);
        responseData['token'] = token;
        responseData['success'] = true;
        return responseData;
      }

      throw Exception(
        responseData['message'] ?? ApiErrorMessages.registerFailed,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static String _aiChatPrefsKeyForToken(String token) =>
      'ai_assistant_conv_${token.hashCode}';

  /// Clé SharedPreferences pour l’historique du chat IA (dépend du compte / token).
  static Future<String> aiConversationPrefsKey() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('auth_token');
    return _aiChatPrefsKeyForToken(t ?? '');
  }

  /// Déconnexion
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      await prefs.remove(_aiChatPrefsKeyForToken(token));
    }
    try {
      await _dio.post('auth/logout');
    } catch (e) {
      // Même en cas d'erreur, on supprime le token local
    } finally {
      await clearLocalAuth();
    }
  }

  // ==================== SOS & ALERTES ====================

  /// Envoie une alerte SOS
  Future<Map<String, dynamic>> sendSOSAlert({
    required double latitude,
    required double longitude,
    double? accuracy,
    String? address,
  }) async {
    try {
      final response = await _dio.post(
        'sos/alert',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'accuracy': accuracy,
          'address': address,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Envoie une alerte médicale
  Future<Map<String, dynamic>> sendMedicalAlert({
    required double latitude,
    required double longitude,
    required String emergencyType,
    double? accuracy,
    String? address,
  }) async {
    try {
      final response = await _dio.post(
        'medical/alert',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'emergency_type': emergencyType,
          'accuracy': accuracy,
          'address': address,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère l'historique des alertes
  Future<List<dynamic>> getAlertsHistory() async {
    try {
      final response = await _dio.get('alerts/history');
      final body = response.data;
      if (body is Map<String, dynamic>) {
        final d = body['data'];
        if (d is List<dynamic>) {
          return d;
        }
        if (d is List) {
          return List<dynamic>.from(d);
        }
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== SIGNALEMENTS ====================

  /// Envoie un signalement d'incident
  Future<Map<String, dynamic>> reportIncident({
    required String incidentType,
    required String description,
    required double latitude,
    required double longitude,
    List<String>? photos,
    List<String>? videos,
    String? audioPath,
    String? audioUrl,
    double? accuracy,
    String? address,
  }) async {
    try {
      final formData = FormData();

      formData.fields.addAll([
        MapEntry('incident_type', incidentType),
        MapEntry('description', description),
        MapEntry('latitude', latitude.toString()),
        MapEntry('longitude', longitude.toString()),
        if (accuracy != null) MapEntry('accuracy', accuracy.toString()),
        if (address != null) MapEntry('address', address),
        if (audioUrl != null) MapEntry('audio_url', audioUrl),
      ]);

      if (audioPath != null) {
        formData.files.add(
          MapEntry(
            'audio',
            await MultipartFile.fromFile(
              audioPath,
              filename: audioPath.split('/').last,
            ),
          ),
        );
      }

      if (photos != null && photos.isNotEmpty) {
        for (final photo in photos) {
          formData.files.add(
            MapEntry('photos[]', await MultipartFile.fromFile(photo)),
          );
        }
      }

      if (videos != null && videos.isNotEmpty) {
        for (final video in videos) {
          formData.files.add(
            MapEntry('videos[]', await MultipartFile.fromFile(video)),
          );
        }
      }

      final response = await _dio.post('incidents/report', data: formData);

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère l'historique des signalements
  Future<List<dynamic>> getIncidentsHistory() async {
    try {
      final response = await _dio.get('incidents/history');
      final body = response.data;
      if (body is Map<String, dynamic>) {
        final d = body['data'];
        if (d is List<dynamic>) {
          return d;
        }
        if (d is List) {
          return List<dynamic>.from(d);
        }
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le suivi détaillé d'un incident.
  Future<Map<String, dynamic>> getIncidentTracking(int incidentId) async {
    try {
      final response = await _dio.get('incidents/$incidentId/tracking');
      return response.data['data'] ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== NOTIFICATIONS ====================

  /// Récupère les notifications
  Future<List<dynamic>> getNotifications({String? zone}) async {
    try {
      final response = await _dio.get(
        'notifications',
        queryParameters: zone != null ? {'zone': zone} : null,
      );
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Marque une notification comme lue (supporte id préfixé "user_X" ou "admin_X" ou entier brut)
  Future<void> markNotificationAsRead(dynamic notificationId) async {
    try {
      final idStr = notificationId.toString();
      if (idStr.startsWith('user_')) {
        final rawId = idStr.replaceFirst('user_', '');
        await _dio.put('my-notifications/$rawId/read');
      } else {
        final rawId = idStr.replaceFirst('admin_', '');
        await _dio.put('notifications/$rawId/read');
      }
    } on DioException catch (e) {
      _debugLog('markNotificationAsRead error: ${_handleError(e)}');
    }
  }

  /// Marque une notification personnelle comme non lue
  Future<void> markNotificationAsUnread(dynamic notificationId) async {
    try {
      final idStr = notificationId.toString();
      if (idStr.startsWith('user_')) {
        final rawId = idStr.replaceFirst('user_', '');
        await _dio.put('my-notifications/$rawId/unread');
      }
      // Les notifications admin n'ont pas de statut lu/non-lu par utilisateur
    } on DioException catch (e) {
      _debugLog('markNotificationAsUnread error: ${_handleError(e)}');
    }
  }

  /// Marque toutes les notifications personnelles comme lues
  Future<void> markAllNotificationsAsRead() async {
    try {
      await _dio.put('my-notifications/read-all');
    } on DioException catch (e) {
      _debugLog('markAllNotificationsAsRead error: ${_handleError(e)}');
    }
  }

  /// Supprime une notification personnelle (user_X uniquement)
  Future<void> deleteNotification(dynamic notificationId) async {
    try {
      final idStr = notificationId.toString();
      if (idStr.startsWith('user_')) {
        final rawId = idStr.replaceFirst('user_', '');
        await _dio.delete('my-notifications/$rawId');
      }
    } on DioException catch (e) {
      _debugLog('deleteNotification error: ${_handleError(e)}');
    }
  }

  /// Supprime toutes les notifications personnelles
  Future<void> clearAllNotifications() async {
    try {
      await _dio.delete('my-notifications/clear-all');
    } on DioException catch (e) {
      _debugLog('clearAllNotifications error: ${_handleError(e)}');
    }
  }

  // ==================== ANNONCES AUDIO ====================

  /// Récupère les annonces audio
  Future<List<dynamic>> getAudioAnnouncements() async {
    try {
      final response = await _dio.get('announcements/audio');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== SITES JOJ ====================

  /// Récupère les sites de compétition
  Future<List<dynamic>> getCompetitionSites() async {
    try {
      final response = await _dio.get('sites/competitions');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le calendrier des compétitions
  Future<List<dynamic>> getCompetitionCalendar() async {
    try {
      final response = await _dio.get('sites/calendar');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== TRANSPORT ====================

  /// Récupère les horaires des navettes
  Future<List<dynamic>> getShuttleSchedules() async {
    try {
      final response = await _dio.get('transport/shuttles');

      // Log pour debugging
      _debugLog('=== SHUTTLES RESPONSE ===');
      _debugLog('Status: ${response.statusCode}');
      _debugLog('Data: ${response.data}');
      _debugLog('Data type: ${response.data.runtimeType}');
      _debugLog('=======================');

      if (response.data == null) {
        _debugLog('Warning: response.data is null');
        return [];
      }

      // Gérer différents formats de réponse
      if (response.data is Map) {
        return response.data['data'] ?? [];
      } else if (response.data is List) {
        return response.data;
      }

      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== TOURISME ====================

  /// Lieux à proximité (rayon en mètres, défaut 2000).
  Future<NearbyApiResult> getNearby({
    required double latitude,
    required double longitude,
    int radiusMeters = 2000,
    int limit = 60,
    String? category,
  }) async {
    final params = {
      'latitude': latitude,
      'longitude': longitude,
      'radius': radiusMeters,
      'limit': limit,
      if (category != null && category.isNotEmpty) 'category': category,
    };

    try {
      final response = await _dio.get('nearby', queryParameters: params);
      final body = _decodeMapResponse(response.data);
      return _parseNearbyResponse(body);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      final routeMissing =
          data is Map &&
          data['message'] is String &&
          (data['message'] as String).toLowerCase().contains('route') &&
          (data['message'] as String).toLowerCase().contains('nearby') &&
          (data['message'] as String).toLowerCase().contains(
            'could not be found',
          );

      // Fallback compatibilité: certains backends n'exposent pas /nearby
      // mais gardent l'endpoint tourisme plus ancien.
      if (status == 404 || routeMissing) {
        try {
          final poi = await getPointsOfInterest(
            latitude: latitude,
            longitude: longitude,
            limit: limit,
            category: category,
          );
          return NearbyApiResult(
            data: poi.data,
            fallbackOutOfRadius: true,
            categoryCounts: _categoryCountsFromPoiList(poi.data),
          );
        } on DioException {
          // On laisse ensuite remonter l'erreur d'origine pour garder le contexte.
        }
      }
      throw _handleError(e);
    }
  }

  NearbyApiResult _parseNearbyResponse(Map<String, dynamic> body) {
    final meta = body['meta'];
    final counts = <String, int>{};
    var fallback = false;
    int? inRadiusTotal;

    if (meta is Map) {
      fallback = meta['fallback_out_of_radius'] == true;
      final rawCounts = meta['category_counts'];
      if (rawCounts is Map) {
        rawCounts.forEach((key, value) {
          final k = key.toString();
          if (value is num) {
            counts[k] = value.toInt();
          }
        });
      }
      final rawInRadius = meta['in_radius_total'];
      if (rawInRadius is num) {
        inRadiusTotal = rawInRadius.toInt();
      }
    }

    if (counts.isEmpty) {
      final data = body['data'] is List ? body['data'] as List : const [];
      return NearbyApiResult(
        data: data,
        fallbackOutOfRadius: fallback,
        categoryCounts: _categoryCountsFromPoiList(data),
        inRadiusTotal: inRadiusTotal,
      );
    }

    return NearbyApiResult(
      data: body['data'] is List ? body['data'] as List : const [],
      fallbackOutOfRadius: fallback,
      categoryCounts: counts,
      inRadiusTotal: inRadiusTotal,
    );
  }

  Map<String, int> _categoryCountsFromPoiList(List<dynamic> items) {
    final counts = <String, int>{};
    for (final item in items) {
      if (item is! Map) continue;
      final key = (item['category_key'] ?? item['category'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
      if (key.isEmpty) continue;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  /// Récupère les points d'intérêt (hôtels, restaurants, etc.)
  Future<PointsOfInterestApiResult> getPointsOfInterest({
    String? category,
    double? latitude,
    double? longitude,
    int limit = 80,
    String? query,
  }) async {
    try {
      final response = await _dio.get(
        'tourism/points-of-interest',
        queryParameters: {
          'limit': limit,
          if (category != null) 'category': category,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
          if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
        },
      );
      final body = _decodeMapResponse(response.data);
      final meta = body['meta'];
      final counts = <String, int>{};
      final countsByKey = <String, int>{};
      int? total;
      int? returned;
      int? responseLimit;

      if (meta is Map) {
        final rawTotal = meta['total'];
        if (rawTotal is num) total = rawTotal.toInt();
        final rawReturned = meta['returned'];
        if (rawReturned is num) returned = rawReturned.toInt();
        final rawLimit = meta['limit'];
        if (rawLimit is num) responseLimit = rawLimit.toInt();
        final rawCounts = meta['category_counts'];
        if (rawCounts is Map) {
          rawCounts.forEach((key, value) {
            if (value is num) {
              counts[key.toString()] = value.toInt();
            }
          });
        }
        final rawCountsByKey = meta['category_counts_by_key'];
        if (rawCountsByKey is Map) {
          rawCountsByKey.forEach((key, value) {
            if (value is num) {
              countsByKey[key.toString()] = value.toInt();
            }
          });
        }
      }

      final data = body['data'] is List ? body['data'] as List : const [];

      return PointsOfInterestApiResult(
        data: data,
        total: total,
        returned: returned,
        limit: responseLimit ?? limit,
        categoryCounts: counts,
        categoryCountsByKey: countsByKey,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les avis d'un point d'intérêt.
  Future<Map<String, dynamic>> getPoiReviews(int partnerId) async {
    try {
      final response = await _dio.get(
        'tourism/points-of-interest/$partnerId/reviews',
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Soumet ou met à jour un avis sur un point d'intérêt.
  Future<Map<String, dynamic>> addPoiReview(
    int partnerId, {
    required int rating,
    String? comment,
  }) async {
    try {
      final response = await _dio.post(
        'tourism/points-of-interest/$partnerId/reviews',
        data: {
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère la liste des ambassades (catégorie dédiée).
  Future<List<dynamic>> getEmbassies() async {
    try {
      final response = await _dio.get('tourism/embassies');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le compteur officiel JOJ.
  Future<Map<String, dynamic>> getJojCountdown() async {
    try {
      final response = await _dio.get('joj/countdown');
      return (response.data['data'] as Map<String, dynamic>? ?? {});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Manifeste du futur pack hors ligne (version catalogue, bundles, etc.).
  Future<Map<String, dynamic>> getOfflineManifest() async {
    try {
      final response = await _dio.get(ApiConstants.offlineManifest);
      return Map<String, dynamic>.from(
        response.data['data'] as Map? ?? {},
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Convertit un montant via endpoint backend utilitaire.
  Future<Map<String, dynamic>> convertCurrency({
    required double amount,
    required String from,
    required String to,
  }) async {
    try {
      final response = await _dio.get(
        'utility/currency/convert',
        queryParameters: {'amount': amount, 'from': from, 'to': to},
      );
      return (response.data['data'] as Map<String, dynamic>? ?? {});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== PROFIL ====================

  /// Récupère les informations du profil utilisateur
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _dio.get('user/profile');
      final raw = response.data;
      if (raw == null || (raw is String && raw.trim().isEmpty)) {
        return {};
      }
      if (raw is Map) {
        final map = Map<String, dynamic>.from(raw);
        final data = map['data'];
        if (data is Map) return Map<String, dynamic>.from(data);
        return map;
      }
      final map = _decodeMapResponse(raw);
      final data = map['data'];
      if (data is Map) return Map<String, dynamic>.from(data);
      return map;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Met à jour le profil utilisateur
  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('user/profile', data: data);
      final raw = response.data;
      if (raw == null || (raw is String && raw.trim().isEmpty)) {
        return {};
      }
      if (raw is Map) {
        final map = Map<String, dynamic>.from(raw);
        final d = map['data'];
        if (d is Map) return Map<String, dynamic>.from(d);
        return map;
      }
      final map = _decodeMapResponse(raw);
      final d = map['data'];
      if (d is Map) return Map<String, dynamic>.from(d);
      return map;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Billet Pass Teranga — QR signé (pilote, sans paiement in-app).
  Future<Map<String, dynamic>> getPassTicket() async {
    try {
      final response = await _dio.get('pass/ticket');
      final raw = response.data;
      if (raw is Map) {
        final map = Map<String, dynamic>.from(raw);
        final data = map['data'];
        if (data is Map) return Map<String, dynamic>.from(data);
        return map;
      }
      final map = _decodeMapResponse(raw);
      final data = map['data'];
      if (data is Map) return Map<String, dynamic>.from(data);
      return map;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== DEVICE TOKENS (PUSH NOTIFICATIONS) ====================

  /// Enregistre le token de device pour les push notifications
  Future<void> registerDeviceToken({
    required String token,
    String? platform,
  }) async {
    try {
      await _dio.post(
        'device-tokens/register',
        data: {'token': token, 'platform': platform},
      );
      if (kDebugMode) {
        debugPrint(
          '[FCM] device-tokens/register OK (${token.length} chars, '
          '${platform ?? '?'})',
        );
      }
    } on DioException catch (e) {
      // Erreur silencieuse (non bloquante) — toujours visible en debug dans logcat.
      _debugLog('Erreur enregistrement token: ${_handleError(e)}');
      if (kDebugMode) {
        debugPrint(
          '[FCM] device-tokens/register FAILED: '
          '${e.response?.statusCode} ${e.response?.data}',
        );
      }
      // Ne pas throw pour ne pas bloquer l'application
    }
  }

  /// Désenregistre le token de device
  Future<void> unregisterDeviceToken(String token) async {
    try {
      await _dio.post('device-tokens/unregister', data: {'token': token});
    } on DioException catch (e) {
      // Erreur silencieuse (non bloquante)
      _debugLog('Erreur désenregistrement token: ${_handleError(e)}');
    }
  }

  // ==================== ASSISTANT IA ====================

  /// Envoie un message au backend IA TerangaPass.
  /// [conversationHistory] : tours précédents `{role: user|assistant, content}` (sans le message courant).
  Future<Map<String, dynamic>> sendAiMessage(
    String message, {
    List<Map<String, String>>? conversationHistory,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
  }) async {
    try {
      final payload = <String, dynamic>{'message': message};
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        payload['conversation_history'] = conversationHistory;
      }
      if (latitude != null && longitude != null) {
        payload['latitude'] = latitude;
        payload['longitude'] = longitude;
        if (accuracyMeters != null) {
          payload['accuracy'] = accuracyMeters;
        }
      }
      final response = await _dio.post('ai/chat', data: payload);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw Exception(ApiErrorMessages.aiInvalidResponse);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== GESTION DES ERREURS ====================

  Exception _handleError(DioException error) {
    // Erreur avec réponse du serveur
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final rawData = error.response!.data;
      final data = rawData is String
          ? (() {
              try {
                return jsonDecode(rawData);
              } catch (_) {
                return rawData;
              }
            })()
          : rawData;

      // Si le serveur retourne un message d'erreur, l'utiliser
      String message;
      final validationDetail = _firstValidationErrorDetail(data);
      if (validationDetail != null && validationDetail.isNotEmpty) {
        message = validationDetail;
      } else if (data is Map && data.containsKey('message')) {
        message = data['message'] as String;
      } else if (data is Map && data.containsKey('error')) {
        message = data['error'] as String;
      } else {
        message = ApiErrorMessages.httpStatusFallback(statusCode ?? 500);
      }
      return Exception(message);
    }
    // Erreurs de connexion sans réponse
    else {
      final message = ApiErrorMessages.dioTypeMessage(
        error.type,
        rawMessage: error.message,
      );
      return Exception(message);
    }
  }

  /// Premier message Laravel `errors.{field}[0]` si présent.
  String? _firstValidationErrorDetail(dynamic data) {
    if (data is! Map) {
      return null;
    }
    final map = Map<String, dynamic>.from(data);
    final errors = map['errors'];
    if (errors is! Map) {
      return null;
    }
    for (final dynamic v in errors.values) {
      if (v is List && v.isNotEmpty && v.first is String) {
        final s = (v.first as String).trim();
        if (s.isNotEmpty) {
          return s;
        }
      }
      if (v is String && v.trim().isNotEmpty) {
        return v.trim();
      }
    }
    return null;
  }
}
