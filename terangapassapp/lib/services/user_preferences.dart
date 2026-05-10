import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Préférences utilisateur (profil) — notifications et géolocalisation.
class UserPreferences {
  UserPreferences._();

  static Future<bool> notificationsEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(AppConstants.prefNotificationsEnabledKey) ?? true;
  }

  static Future<void> setNotificationsEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(AppConstants.prefNotificationsEnabledKey, value);
  }

  static Future<bool> geolocationEnabled() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(AppConstants.prefGeolocationEnabledKey) ?? true;
  }

  static Future<void> setGeolocationEnabled(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(AppConstants.prefGeolocationEnabledKey, value);
  }
}
