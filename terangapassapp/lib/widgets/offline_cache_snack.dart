import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

void showOfflineCacheSnackBar(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  if (l10n == null) return;
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    SnackBar(
      content: Text(l10n.offlineUsingCache),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ),
  );
}
