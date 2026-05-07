import 'dart:io';

class ApiConstants {
  // Configuration de l'URL de base selon l'environnement
  //
  // Quelle URL est vraiment utilisée ?
  // - Si [_mode] vaut 'production' → seule [_productionUrl] compte (lignes du dessous ignorées).
  // - Si [_mode] vaut 'android_emulator' / 'physical_device' → la constante du même nom.
  // - Si [_mode] vaut 'dev' ou autre → [_devUrl] ou émulateur selon la plateforme (voir [baseUrl]).
  //
  // Le back-office (dashboard) doit parler à la MÊME base Laravel que cette URL API
  // (sinon les inscriptions n’apparaîtront pas dans l’admin).
  //
  // Exemples d’URL locale (uniquement pour _mode != 'production') :
  // - Android Emulator : http://10.0.2.2:8000/api/v1
  // - iOS Simulator : http://localhost:8000/api/v1
  // - Appareil physique : http://<IP-de-ton-PC>:8000/api/v1

  // URL de développement local
  static const String _devUrl = 'http://localhost:8000/api/v1';

  // URL pour Android Emulator
  static const String _androidEmulatorUrl = 'http://10.0.2.2:8000/api/v1';

  // URL pour appareil physique (remplacez par votre IP locale)
  static const String _physicalDeviceUrl = 'http://192.168.1.100:8000/api/v1';

  /// API Laravel : toujours le schéma + domaine + **`/api/v1`** (sans slash final).
  static const String _productionUrl = 'https://terangapass.com/api/v1';

  // Mode de configuration
  // Options: 'dev', 'android_emulator', 'physical_device', 'production'
  static const String _mode = 'production';

  /// Retourne l'URL de base selon le mode configuré
  static String get baseUrl {
    switch (_mode) {
      case 'android_emulator':
        return _androidEmulatorUrl;
      case 'physical_device':
        return _physicalDeviceUrl;
      case 'production':
        return _productionUrl;
      case 'dev':
      default:
        // Détection automatique pour iOS/Android
        if (Platform.isAndroid) {
          // Sur Android, on suppose qu'on est sur un emulator par défaut
          // Changez manuellement si vous testez sur un appareil physique
          return _androidEmulatorUrl;
        } else {
          // iOS Simulator ou autre
          return _devUrl;
        }
    }
  }

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';

  static const String sosAlert = '/sos/alert';
  static const String medicalAlert = '/medical/alert';
  static const String alertsHistory = '/alerts/history';

  static const String reportIncident = '/incidents/report';
  static const String incidentsHistory = '/incidents/history';

  static const String notifications = '/notifications';
  static const String markNotificationRead = '/notifications';

  static const String audioAnnouncements = '/announcements/audio';

  static const String competitionSites = '/sites/competitions';
  static const String competitionCalendar = '/sites/calendar';

  static const String shuttleSchedules = '/transport/shuttles';

  static const String pointsOfInterest = '/tourism/points-of-interest';

  static const String userProfile = '/user/profile';
}
