import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialise le service de notifications
  Future<void> initialize() async {
    if (_initialized) return;

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

    _initialized = true;
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
    // TODO: Gérer la navigation selon le type de notification
    print('Notification tapée: ${response.payload}');
  }

  /// Affiche une notification locale
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationDetails? notificationDetails,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final details = notificationDetails ??
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'teranga_pass_channel',
            'Teranga Pass Notifications',
            channelDescription: 'Notifications pour Teranga Pass',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  /// Affiche une notification d'alerte SOS
  Future<void> showSOSNotification({
    required String title,
    required String body,
  }) async {
    await showNotification(
      id: 1,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'sos_channel',
          'Alertes SOS',
          channelDescription: 'Notifications d\'urgence SOS',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFCE1126), // Rouge
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Affiche une notification d'alerte médicale
  Future<void> showMedicalAlertNotification({
    required String title,
    required String body,
  }) async {
    await showNotification(
      id: 2,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'medical_channel',
          'Alertes Médicales',
          channelDescription: 'Notifications d\'alertes médicales',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFFF8C00), // Orange
          playSound: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Affiche une notification de sécurité
  Future<void> showSecurityNotification({
    required String title,
    required String body,
  }) async {
    await showNotification(
      id: 3,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'security_channel',
          'Alertes Sécurité',
          channelDescription: 'Notifications de sécurité',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Affiche une notification générale
  Future<void> showGeneralNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    await showNotification(
      id: id,
      title: title,
      body: body,
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
