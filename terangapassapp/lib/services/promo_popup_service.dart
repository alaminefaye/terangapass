import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// Campagnes pop-up publicitaires (interstitiel type Orange Max it).
class PromoPopupService {
  PromoPopupService._();
  static final PromoPopupService instance = PromoPopupService._();

  static const _dismissPrefix = 'promo_popup_dismissed_';

  Future<Map<String, dynamic>?> fetchActive(String placement) =>
      ApiService().getActivePromoPopup(placement: placement);

  Future<bool> shouldShow(Map<String, dynamic> popup) async {
    final id = popup['id']?.toString();
    if (id == null || id.isEmpty) return false;

    final frequency = (popup['frequency'] ?? 'once_per_day').toString();
    if (frequency == 'always') return true;

    final prefs = await SharedPreferences.getInstance();
    final key = _dismissKey(id, frequency);

    if (frequency == 'every_open') {
      final sessionKey = '${key}_session';
      if (prefs.getBool(sessionKey) == true) return false;
      return true;
    }

    final dismissedAt = prefs.getString(key);
    if (dismissedAt == null) return true;
    final dismissed = DateTime.tryParse(dismissedAt);
    if (dismissed == null) return true;
    final now = DateTime.now();
    return dismissed.year != now.year ||
        dismissed.month != now.month ||
        dismissed.day != now.day;
  }

  Future<void> markDismissed(Map<String, dynamic> popup) async {
    final id = popup['id']?.toString();
    if (id == null) return;
    final frequency = (popup['frequency'] ?? 'once_per_day').toString();
    final prefs = await SharedPreferences.getInstance();
    final key = _dismissKey(id, frequency);

    if (frequency == 'every_open') {
      await prefs.setBool('${key}_session', true);
      return;
    }

    await prefs.setString(key, DateTime.now().toIso8601String());
  }

  Future<void> clearSessionDismissals() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where(
      (k) => k.startsWith(_dismissPrefix) && k.endsWith('_session'),
    );
    for (final k in keys) {
      await prefs.remove(k);
    }
  }

  Future<void> recordImpression(int id) =>
      ApiService().recordPromoPopupImpression(id);

  Future<void> recordClick(int id) => ApiService().recordPromoPopupClick(id);

  String _dismissKey(String id, String frequency) =>
      '$_dismissPrefix${frequency}_$id';
}
