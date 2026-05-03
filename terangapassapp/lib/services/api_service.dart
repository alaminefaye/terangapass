import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  static const bool _enableVerboseDebugLogs = false;

  // Utilise ApiConstants pour la configuration centralisée
  static String get baseUrl => ApiConstants.baseUrl;

  /// Configure l'URL de base de l'API (override de ApiConstants)
  static String? _customBaseUrl;
  static void setBaseUrl(String url) {
    _customBaseUrl = url;
  }

  static String get _effectiveBaseUrl => _customBaseUrl ?? ApiConstants.baseUrl;

  late Dio _dio;

  void _debugLog(Object? message) {
    assert(() {
      if (!_enableVerboseDebugLogs) {
        return true;
      }
      debugPrint(message?.toString() ?? '');
      return true;
    }());
  }

  ApiService._internal() {
    // Calcul de l'URL de base pour les headers
    final baseUrlForHeaders = _effectiveBaseUrl.replaceAll('/api/v1', '');

    // Log de l'URL de base utilisée
    _debugLog('=== API SERVICE INITIALIZATION ===');
    _debugLog('Base URL: $_effectiveBaseUrl');
    _debugLog('Base URL for headers: $baseUrlForHeaders');
    _debugLog(
      'Mode: ${ApiConstants.baseUrl == _effectiveBaseUrl ? "ApiConstants" : "Custom"}',
    );
    _debugLog('==================================');

    _dio = Dio(
      BaseOptions(
        baseUrl: _effectiveBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
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
          // Laisser Dio gérer les erreurs (codes >= 400 sont considérés comme erreurs)
          // On les capture dans le catch et on les gère dans _handleError
          return status != null && status < 400;
        },
      ),
    );

    // Intercepteur pour ajouter le token d'authentification et logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          // Log détaillé de la requête pour debugging
          _debugLog('=== API REQUEST ===');
          _debugLog('URL: ${options.method} ${options.baseUrl}${options.path}');
          _debugLog('Headers: ${options.headers}');
          _debugLog('Data: ${options.data}');
          _debugLog('==================');
          return handler.next(options);
        },
        onResponse: (response, handler) {
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
          // Gestion des erreurs
          if (error.response?.statusCode == 401) {
            // Token expiré ou invalide
            _clearToken();
          }
          return handler.next(error);
        },
      ),
    );
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
  }

  // ==================== AUTHENTIFICATION ====================

  /// Connexion
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      // Gérer le nouveau format de réponse standardisé (comme chantix)
      final responseData = response.data as Map<String, dynamic>;

      if (responseData['success'] == true && responseData['token'] != null) {
        await _saveToken(responseData['token'] as String);
        return responseData;
      } else if (responseData['token'] != null) {
        // Compatibilité avec l'ancien format
        await _saveToken(responseData['token'] as String);
        return responseData;
      }

      throw Exception(responseData['message'] ?? 'Échec de la connexion');
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
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );

      // Gérer le nouveau format de réponse standardisé (comme chantix)
      final responseData = response.data as Map<String, dynamic>;

      if (responseData['success'] == true && responseData['token'] != null) {
        await _saveToken(responseData['token'] as String);
        return responseData;
      } else if (responseData['token'] != null) {
        // Compatibilité avec l'ancien format
        await _saveToken(responseData['token'] as String);
        return responseData;
      }

      throw Exception(responseData['message'] ?? 'Échec de l\'inscription');
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
      await _dio.post('/auth/logout');
    } catch (e) {
      // Même en cas d'erreur, on supprime le token local
    } finally {
      await _clearToken();
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
        '/sos/alert',
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
        '/medical/alert',
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
      final response = await _dio.get('/alerts/history');
      return response.data['data'] ?? [];
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

      final response = await _dio.post('/incidents/report', data: formData);

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère l'historique des signalements
  Future<List<dynamic>> getIncidentsHistory() async {
    try {
      final response = await _dio.get('/incidents/history');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le suivi détaillé d'un incident.
  Future<Map<String, dynamic>> getIncidentTracking(int incidentId) async {
    try {
      final response = await _dio.get('/incidents/$incidentId/tracking');
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
        '/notifications',
        queryParameters: zone != null ? {'zone': zone} : null,
      );
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Marque une notification comme lue
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _dio.put('/notifications/$notificationId/read');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== ANNONCES AUDIO ====================

  /// Récupère les annonces audio
  Future<List<dynamic>> getAudioAnnouncements() async {
    try {
      final response = await _dio.get('/announcements/audio');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== SITES JOJ ====================

  /// Récupère les sites de compétition
  Future<List<dynamic>> getCompetitionSites() async {
    try {
      final response = await _dio.get('/sites/competitions');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le calendrier des compétitions
  Future<List<dynamic>> getCompetitionCalendar() async {
    try {
      final response = await _dio.get('/sites/calendar');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== TRANSPORT ====================

  /// Récupère les horaires des navettes
  Future<List<dynamic>> getShuttleSchedules() async {
    try {
      final response = await _dio.get('/transport/shuttles');

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
  Future<List<dynamic>> getNearby({
    required double latitude,
    required double longitude,
    int radiusMeters = 2000,
    String? category,
  }) async {
    try {
      final response = await _dio.get(
        '/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radiusMeters,
          if (category != null && category.isNotEmpty) 'category': category,
        },
      );
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère les points d'intérêt (hôtels, restaurants, etc.)
  Future<List<dynamic>> getPointsOfInterest({
    String? category,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _dio.get(
        '/tourism/points-of-interest',
        queryParameters: {
          if (category != null) 'category': category,
          if (latitude != null) 'latitude': latitude,
          if (longitude != null) 'longitude': longitude,
        },
      );
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère la liste des ambassades (catégorie dédiée).
  Future<List<dynamic>> getEmbassies() async {
    try {
      final response = await _dio.get('/tourism/embassies');
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Récupère le compteur officiel JOJ.
  Future<Map<String, dynamic>> getJojCountdown() async {
    try {
      final response = await _dio.get('/joj/countdown');
      return (response.data['data'] as Map<String, dynamic>? ?? {});
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
        '/utility/currency/convert',
        queryParameters: {
          'amount': amount,
          'from': from,
          'to': to,
        },
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
      final response = await _dio.get('/user/profile');
      return response.data['data'] ?? {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Met à jour le profil utilisateur
  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put('/user/profile', data: data);
      return response.data['data'] ?? {};
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
        '/device-tokens/register',
        data: {'token': token, 'platform': platform},
      );
    } on DioException catch (e) {
      // Erreur silencieuse (non bloquante) - on log juste l'erreur
      _debugLog('Erreur enregistrement token: ${_handleError(e)}');
      // Ne pas throw pour ne pas bloquer l'application
    }
  }

  /// Désenregistre le token de device
  Future<void> unregisterDeviceToken(String token) async {
    try {
      await _dio.post('/device-tokens/unregister', data: {'token': token});
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
      final response = await _dio.post('/ai/chat', data: payload);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      throw Exception('Réponse IA invalide');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== GESTION DES ERREURS ====================

  Exception _handleError(DioException error) {
    // Erreur avec réponse du serveur
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      // Si le serveur retourne un message d'erreur, l'utiliser
      String message;
      if (data is Map && data.containsKey('message')) {
        message = data['message'] as String;
      } else if (data is Map && data.containsKey('error')) {
        message = data['error'] as String;
      } else {
        switch (statusCode) {
          case 400:
            message = 'Requête invalide';
            break;
          case 401:
            message = 'Non autorisé. Veuillez vous reconnecter.';
            break;
          case 403:
            message = 'Accès refusé';
            break;
          case 404:
            message = 'Ressource non trouvée';
            break;
          case 422:
            message = 'Données invalides';
            break;
          case 500:
            message = 'Erreur serveur. Veuillez réessayer plus tard.';
            break;
          case 502:
            message =
                'Bad Gateway. Le serveur est temporairement indisponible.';
            break;
          case 503:
            message =
                'Service temporairement indisponible. Veuillez réessayer dans quelques instants.';
            break;
          case 504:
            message =
                'Gateway Timeout. Le serveur prend trop de temps à répondre.';
            break;
          default:
            message = 'Une erreur est survenue ($statusCode)';
        }
      }
      return Exception(message);
    }
    // Erreurs de connexion sans réponse
    else {
      String message;
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          message =
              'Délai de connexion dépassé. Vérifiez votre connexion internet.';
          break;
        case DioExceptionType.sendTimeout:
          message =
              'Délai d\'envoi dépassé. Vérifiez votre connexion internet.';
          break;
        case DioExceptionType.receiveTimeout:
          message =
              'Délai de réception dépassé. Le serveur prend trop de temps à répondre.';
          break;
        case DioExceptionType.connectionError:
          message =
              'Erreur de connexion. Vérifiez votre connexion internet et réessayez.';
          break;
        case DioExceptionType.badCertificate:
          message =
              'Erreur de certificat SSL. Vérifiez la configuration du serveur.';
          break;
        case DioExceptionType.badResponse:
          message = 'Réponse invalide du serveur.';
          break;
        case DioExceptionType.cancel:
          message = 'Requête annulée.';
          break;
        default:
          message =
              'Une erreur est survenue: ${error.message ?? "Erreur inconnue"}';
      }
      return Exception(message);
    }
  }
}
