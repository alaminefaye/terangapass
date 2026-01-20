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
    _dio = Dio(
      BaseOptions(
        baseUrl: _effectiveBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Intercepteur pour ajouter le token d'authentification
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
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
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data['token'] != null) {
        await _saveToken(response.data['token']);
      }

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Inscription
  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      if (response.data['token'] != null) {
        await _saveToken(response.data['token']);
      }

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
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

      final response = await _dio.post(
        '/incidents/report',
        data: formData,
      );

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
      Map<String, dynamic> data) async {
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
        data: {
          'token': token,
          'platform': platform,
        },
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
      await _dio.post(
        '/device-tokens/unregister',
        data: {
          'token': token,
        },
      );
    } on DioException catch (e) {
      // Erreur silencieuse (non bloquante)
      print('Erreur désenregistrement token: ${_handleError(e)}');
    }
  }

  // ==================== GESTION DES ERREURS ====================

  String _handleError(DioException error) {
    if (error.response != null) {
      // Erreur avec réponse du serveur
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }

      switch (statusCode) {
        case 400:
          return 'Requête invalide';
        case 401:
          return 'Non autorisé. Veuillez vous reconnecter.';
        case 403:
          return 'Accès refusé';
        case 404:
          return 'Ressource non trouvée';
        case 422:
          return 'Données invalides';
        case 500:
          return 'Erreur serveur. Veuillez réessayer plus tard.';
        default:
          return 'Une erreur est survenue (${statusCode})';
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Timeout. Vérifiez votre connexion internet.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Erreur de connexion. Vérifiez votre connexion internet.';
    } else {
      return 'Une erreur est survenue: ${error.message}';
    }
  }
}
