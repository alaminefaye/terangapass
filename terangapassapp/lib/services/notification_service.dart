// Son : `android/.../raw/teranga_notification.mp3`, iOS `Runner/teranga_notification.caf` (afconvert depuis le MP3 source).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'user_preferences.dart';

class NotificationService {
  NotificationService._internal();
  factory NotificationService() => _instance;
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  GlobalKey<NavigatorState>? _navigatorKey;

  /// Fichier dans `android/app/src/main/res/raw/teranga_notification.mp3`
  /// (nom de ressource sans extension).
  static const String _androidSoundResourceName = 'teranga_notification';

  /// Fichier `ios/Runner/teranga_notification.caf` (converti depuis le MP3 source).
  static const String _iosNotificationSound = 'teranga_notification.caf';

  static const RawResourceAndroidNotificationSound _androidSound =
      RawResourceAndroidNotificationSound(_androidSoundResourceName);

  /// Supprime les anciens canaux une fois pour appliquer la sonnerie personnalisée (Android O+).
  static const String _androidChannelSoundMigrationKey =
      'notif_android_channels_sound_v1';

  /// Initialise le service de notifications
  Future<void> initialize({GlobalKey<NavigatorState>? navigatorKey}) async {
    if (_initialized) return;
    _navigatorKey = navigatorKey;

    // Demander les permissions
    await _requestPermissions();

    // Configuration Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuration iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _ensureAndroidNotificationChannels();

    _initialized = true;
  }

  /// Les notifications FCM affichées par le système (app en arrière-plan) utilisent ces IDs.
  /// Les créer au démarrage évite un canal inexistant ⇒ aucune heads-up sous Android 8+.
  Future<void> _ensureAndroidNotificationChannels() async {
    if (!Platform.isAndroid) return;
    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_androidChannelSoundMigrationKey) != true) {
      for (final id in <String>[
        'teranga_pass_channel',
        'sos_channel',
        'medical_channel',
        'security_channel',
      ]) {
        try {
          await android.deleteNotificationChannel(id);
        } catch (_) {}
      }
      await prefs.setBool(_androidChannelSoundMigrationKey, true);
    }

    Future<void> create(
      String id,
      String name,
      String description,
      Importance importance,
    ) {
      return android.createNotificationChannel(
        AndroidNotificationChannel(
          id,
          name,
          description: description,
          importance: importance,
          playSound: true,
          sound: _androidSound,
        ),
      );
    }

    await create(
      'teranga_pass_channel',
      'Teranga Pass Notifications',
      'Notifications pour Teranga Pass',
      Importance.high,
    );
    await create(
      'sos_channel',
      'Alertes SOS',
      'Notifications d\'urgence SOS',
      Importance.max,
    );
    await create(
      'medical_channel',
      'Alertes Médicales',
      'Notifications d\'alertes médicales',
      Importance.max,
    );
    await create(
      'security_channel',
      'Alertes Sécurité',
      'Notifications de sécurité',
      Importance.high,
    );
  }

  /// Demande les permissions nécessaires
  Future<void> _requestPermissions() async {
    // Android 13+
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  /// Callback lorsqu'une notification est tapée
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    final nav = _navigatorKey?.currentState;
    if (nav == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (payload != null && payload.startsWith('/')) {
        nav.pushNamed(payload);
      } else {
        nav.pushNamed('/home');
      }
    });
  }

  static DarwinNotificationDetails get _iosDetailsWithSound =>
      const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: _iosNotificationSound,
      );

  static AndroidNotificationDetails _androidDetails({
    required String channelId,
    required String channelName,
    required String channelDescription,
    required Importance importance,
    required Priority priority,
    Color? color,
    bool enableVibration = false,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: importance,
      priority: priority,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      sound: _androidSound,
      color: color,
      enableVibration: enableVibration,
    );
  }

  /// Affiche une notification locale
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationDetails? notificationDetails,
  }) async {
    if (!await UserPreferences.notificationsEnabled()) {
      return;
    }

    if (!_initialized) {
      await initialize();
    }

    final details = notificationDetails ??
        NotificationDetails(
          android: _androidDetails(
            channelId: 'teranga_pass_channel',
            channelName: 'Teranga Pass Notifications',
            channelDescription: 'Notifications pour Teranga Pass',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: _iosDetailsWithSound,
        );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  /// Affiche une notification d'alerte SOS
  Future<void> showSOSNotification({
    required String title,
    required String body,
    int notificationId = 1,
    String? payloadOverride,
  }) async {
    await showNotification(
      id: notificationId,
      title: title,
      body: body,
      payload: payloadOverride,
      notificationDetails: NotificationDetails(
        android: _androidDetails(
          channelId: 'sos_channel',
          channelName: 'Alertes SOS',
          channelDescription: 'Notifications d\'urgence SOS',
          importance: Importance.max,
          priority: Priority.max,
          color: const Color(0xFFCE1126),
          enableVibration: true,
        ),
        iOS: _iosDetailsWithSound,
      ),
    );
  }

  /// Affiche une notification d'alerte médicale
  Future<void> showMedicalAlertNotification({
    required String title,
    required String body,
    int notificationId = 2,
    String? payloadOverride,
  }) async {
    await showNotification(
      id: notificationId,
      title: title,
      body: body,
      payload: payloadOverride,
      notificationDetails: NotificationDetails(
        android: _androidDetails(
          channelId: 'medical_channel',
          channelName: 'Alertes Médicales',
          channelDescription: 'Notifications d\'alertes médicales',
          importance: Importance.max,
          priority: Priority.max,
          color: const Color(0xFFFF8C00),
          enableVibration: true,
        ),
        iOS: _iosDetailsWithSound,
      ),
    );
  }

  /// Affiche une notification de sécurité
  Future<void> showSecurityNotification({
    required String title,
    required String body,
    int notificationId = 3,
    String? payloadOverride,
  }) async {
    await showNotification(
      id: notificationId,
      title: title,
      body: body,
      payload: payloadOverride,
      notificationDetails: NotificationDetails(
        android: _androidDetails(
          channelId: 'security_channel',
          channelName: 'Alertes Sécurité',
          channelDescription: 'Notifications de sécurité',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: _iosDetailsWithSound,
      ),
    );
  }

  /// Affiche une notification générale
  Future<void> showGeneralNotification({
    required String title,
    required String body,
    int id = 0,
    String? payloadOverride,
  }) async {
    await showNotification(
      id: id,
      title: title,
      body: body,
      payload: payloadOverride,
    );
  }

  /// Annule une notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Annule toutes les notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Récupère les notifications en attente
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }
}
