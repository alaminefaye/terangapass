import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import 'notification_service.dart';

/// FCM : foreground, ouverture depuis une notification, rafraîchissement du token.
class TerangaPushMessaging {
  TerangaPushMessaging._();

  static bool _handlersBound = false;

  static FirebaseMessaging get _fm => FirebaseMessaging.instance;

  @pragma('vm:entry-point')
  static Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
  }

  /// À appeler une fois après [Firebase.initializeApp] et [NotificationService.initialize].
  static Future<void> bindHandlers(GlobalKey<NavigatorState> navigatorKey) async {
    if (_handlersBound) return;
    _handlersBound = true;

    if (Platform.isIOS) {
      await _fm.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    FirebaseMessaging.onMessage.listen(_handleForegroundRemoteMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((m) {
      _handleTapFromRemote(m, navigatorKey);
    });

    try {
      final initial = await _fm.getInitialMessage();
      if (initial != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleTapFromRemote(initial, navigatorKey);
        });
      }
    } catch (_) {}

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await _sendTokenIfAuthed(newToken);
    });
  }

  static Future<void> registerDeviceTokenIfAuthed() async {
    try {
      await _fm.requestPermission(alert: true, badge: true, sound: true);
      final t = await _fm.getToken();
      if (kDebugMode && t != null && t.isNotEmpty) {
        debugPrint('[FCM] FirebaseMessaging token: ${t.substring(0, t.length.clamp(0, 32))}…');
      }
      if (t != null && t.isNotEmpty) {
        await _sendTokenIfAuthed(t);
      }
    } catch (e) {
      debugPrint('TerangaPushMessaging.registerDeviceTokenIfAuthed: $e');
    }
  }

  static Future<void> _sendTokenIfAuthed(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final auth = (prefs.getString('auth_token') ?? '').trim();
    if (auth.isEmpty) return;
    await ApiService().registerDeviceToken(
      token: token,
      platform: _platformLabel(),
    );
  }

  static String _platformLabel() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  static Future<void> _handleForegroundRemoteMessage(RemoteMessage message) async {
    /// Sur iOS, [setForegroundNotificationPresentationOptions] suffit avec le payload « notification »
    /// FCM pour éviter un doublon bannière + notification locale.
    if (Platform.isIOS) return;

    final notification = message.notification;
    final data = message.data;
    final title = '${notification?.title ?? data['title'] ?? ''}'.trim();
    final body = '${notification?.body ?? data['body'] ?? ''}'.trim();
    if (title.isEmpty && body.isEmpty) return;

    final type = '${data['type'] ?? ''}';
    final idBase = Object.hash(message.messageId, title, body, type);
    final notificationId = (idBase == 0 ? message.hashCode : idBase) & 0x7FFFFFFF;

    final payload = _routePayloadForPushData(data);
    switch (type) {
      case 'sos_sent':
      case 'sos_status_update':
      case 'medical_sent':
      case 'medical_status_update':
        await NotificationService().showSOSNotification(
          title: title.isEmpty ? 'Teranga Pass' : title,
          body: body.isEmpty ? title : body,
          notificationId: notificationId == 0 ? 90211 : notificationId,
          payloadOverride: payload,
        );
        return;
      case 'incident_reported':
      case 'incident_status':
        await NotificationService().showSecurityNotification(
          title: title.isEmpty ? 'Teranga Pass' : title,
          body: body.isEmpty ? title : body,
          notificationId: notificationId == 0 ? 90212 : notificationId,
          payloadOverride: payload,
        );
        return;
      default:
        await NotificationService().showGeneralNotification(
          title: title.isEmpty ? 'Teranga Pass' : title,
          body: body.isEmpty ? title : body,
          id: notificationId == 0 ? 90300 : notificationId,
          payloadOverride: payload,
        );
    }
  }

  static String? _routePayloadForPushData(Map<String, dynamic> data) {
    final type = '${data['type'] ?? ''}';
    if (type == 'incident_status' || type == 'incident_reported') {
      return '/incidents-history';
    }
    return '/notifications';
  }

  static void _handleTapFromRemote(
    RemoteMessage message,
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    final payload = _routePayloadForPushData(message.data);
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushNamed(payload ?? '/notifications');
    });
  }
}
