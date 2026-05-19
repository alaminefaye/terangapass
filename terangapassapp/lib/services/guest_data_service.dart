import '../utils/auth_guard.dart';
import 'api_service.dart';
import 'offline_pack_service.dart';

/// Prépare les données consultables sans compte (pack hors ligne POI).
class GuestDataService {
  GuestDataService._();

  static Future<void> warmUpOfflineCatalog({bool force = false}) async {
    if (await AuthGuard.isLoggedIn()) return;
    try {
      final api = ApiService();
      if (force) {
        await OfflinePackService().refresh(api);
      } else {
        await OfflinePackService().refreshIfStale(api);
      }
    } catch (_) {
      // Silencieux : la carte / le tourisme afficheront un message si vide.
    }
  }
}
