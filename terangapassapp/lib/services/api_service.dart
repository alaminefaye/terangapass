import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  // Utilise ApiConstants pour la configuration centralisée
  static String get baseUrl => ApiConstants.baseUrl;

  /// Configure l'URL de base de l'API (override de ApiConstants)
  static String? _customBaseUrl;
  static void setBaseUrl(String url) {
    _customBaseUrl = url;
  }

  static String get _effectiveBaseUrl => _customBaseUrl ?? ApiConstants.baseUrl;

  late Dio _dio;

  ApiService._internal() {
    // Calcul de l'URL de base pour les headers
    final baseUrlForHeaders = _effectiveBaseUrl.replaceAll('/api/v1', '');

    // Log de l'URL de base utilisée
    print('=== API SERVICE INITIALIZATION ===');
    print('Base URL: $_effectiveBaseUrl');
    print('Base URL for headers: $baseUrlForHeaders');
    print(
      'Mode: ${ApiConstants.baseUrl == _effectiveBaseUrl ? "ApiConstants" : "Custom"}',
    );
    print('==================================');

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
          print('=== API REQUEST ===');
          print('URL: ${options.method} ${options.baseUrl}${options.path}');
          print('Headers: ${options.headers}');
          print('Data: ${options.data}');
          print('==================');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log de la réponse pour debugging
          print(
            'API Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          // Log détaillé de l'erreur pour debugging
          print('=== API ERROR ===');
          print('Status Code: ${error.response?.statusCode}');
          print('Path: ${error.requestOptions.path}');
          print(
            'Full URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}',
          );
          print('Error Type: ${error.type}');
          print('Error Message: ${error.message}');
          print('Error toString: ${error.toString()}');
          print('Request Headers: ${error.requestOptions.headers}');
          print('Request Data: ${error.requestOptions.data}');
          if (error.response != null) {
            print('Response Status Code: ${error.response?.statusCode}');
            print('Response Headers: ${error.response?.headers}');
            print('Response Data: ${error.response?.data}');
            print('Response Status Message: ${error.response?.statusMessage}');
          } else {
            print('No response received - connection issue');
            print('Error Type Details:');
            print(
              '  - connectionTimeout: ${error.type == DioExceptionType.connectionTimeout}',
            );
            print(
              '  - sendTimeout: ${error.type == DioExceptionType.sendTimeout}',
            );
            print(
              '  - receiveTimeout: ${error.type == DioExceptionType.receiveTimeout}',
            );
            print(
              '  - connectionError: ${error.type == DioExceptionType.connectionError}',
            );
            print(
              '  - badCertificate: ${error.type == DioExceptionType.badCertificate}',
            );
            print(
              '  - badResponse: ${error.type == DioExceptionType.badResponse}',
            );
            print('  - cancel: ${error.type == DioExceptionType.cancel}');
            print('  - unknown: ${error.type == DioExceptionType.unknown}');
          }
          print('Stack Trace: ${error.stackTrace}');
          print('==================');
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

  /// Déconnexion
  Future<void> logout() async {
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
    String? audioUrl,
    double? accuracy,
    String? address,
  }) async {
    try {
      final formData = FormData.fromMap({
        'incident_type': incidentType,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'address': address,
        if (audioUrl != null) 'audio_url': audioUrl,
        if (photos != null)
          'photos': photos.map((photo) => MultipartFile.fromFileSync(photo)),
      });

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
      return response.data['data'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== TOURISME ====================

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
      print('Erreur enregistrement token: ${_handleError(e)}');
      // Ne pas throw pour ne pas bloquer l'application
    }
  }

  /// Désenregistre le token de device
  Future<void> unregisterDeviceToken(String token) async {
    try {
      await _dio.post('/device-tokens/unregister', data: {'token': token});
    } on DioException catch (e) {
      // Erreur silencieuse (non bloquante)
      print('Erreur désenregistrement token: ${_handleError(e)}');
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
            message = 'Une erreur est survenue (${statusCode})';
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
