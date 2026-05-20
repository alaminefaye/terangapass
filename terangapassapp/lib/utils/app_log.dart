import 'package:flutter/foundation.dart';

/// Logs réservés au mode debug (aucune sortie en release store).
void appLog(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}
