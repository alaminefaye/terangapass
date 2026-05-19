import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Vérifie la session et propose la connexion pour les fonctions réservées aux comptes.
class AuthGuard {
  AuthGuard._();

  static Future<bool> isLoggedIn() async {
    if (isAuthenticatedNotifier.value) return true;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.trim().isNotEmpty;
  }

  /// Retourne `true` si l'utilisateur est connecté ou vient de se connecter.
  static Future<bool> requireAuth(
    BuildContext context, {
    required String featureName,
    bool guestExplorationHint = true,
  }) async {
    if (await isLoggedIn()) {
      isAuthenticatedNotifier.value = true;
      return true;
    }

    final l10n = AppLocalizations.of(context)!;
    final body = guestExplorationHint
        ? '${l10n.authRequiredBody(featureName)}\n\n${l10n.authRequiredExploreHint}'
        : l10n.authRequiredBody(featureName);

    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.authRequiredTitle,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          body,
          style: GoogleFonts.poppins(fontSize: 14, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.authLater, style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'register'),
            child: Text(
              l10n.registerSignUp,
              style: GoogleFonts.poppins(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'login'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: Text(l10n.loginSignIn, style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );

    if (!context.mounted) return false;

    if (action == 'login') {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(returnOnSuccess: true),
        ),
      );
      return ok == true || await isLoggedIn();
    }
    if (action == 'register') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
      return await isLoggedIn();
    }
    return false;
  }

  /// Ouvre l'écran protégé seulement si connecté.
  static Future<void> openProtected(
    BuildContext context, {
    required String featureName,
    required Widget Function() screenBuilder,
  }) async {
    if (!await requireAuth(context, featureName: featureName)) return;
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screenBuilder()),
    );
  }
}
