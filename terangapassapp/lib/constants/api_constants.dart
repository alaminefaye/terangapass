import 'dart:io';

class ApiConstants {
  // Configuration de l'URL de base selon l'environnement
  //
  // IMPORTANT : Changez ces valeurs selon votre configuration :
  // - Pour Android Emulator : utilisez 'http://10.0.2.2:8000/api/v1'
  // - Pour iOS Simulator : utilisez 'http://localhost:8000/api/v1'
  // - Pour appareil physique : utilisez l'IP de votre machine (ex: 'http://192.168.1.100:8000/api/v1')
  // - Pour production : utilisez votre URL de production avec /api/v1 (ex: 'https://terangapass.universaltechnologiesafrica.com/api/v1')

  // URL de développement local
  static const String _devUrl = 'http://localhost:8000/api/v1';

  // URL pour Android Emulator
  static const String _androidEmulatorUrl = 'http://10.0.2.2:8000/api/v1';

  // URL pour appareil physique (remplacez par votre IP locale)
  static const String _physicalDeviceUrl = 'http://192.168.1.100:8000/api/v1';

  // URL de production
  static const String _productionUrl =
      'https://terangapass.universaltechnologiesafrica.com/api/v1';

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
