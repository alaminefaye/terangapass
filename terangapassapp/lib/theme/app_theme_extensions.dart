import 'package:flutter/material.dart';

/// Couleurs sémantiques Teranga Pass (clair / sombre).
class TpColors {
  const TpColors(this.brightness);

  final Brightness brightness;

  factory TpColors.forBrightness(Brightness brightness) => TpColors(brightness);

  bool get isDark => brightness == Brightness.dark;

  Color get scaffold => isDark ? const Color(0xFF0F1218) : const Color(0xFFFAF7F0);

  Color get scaffoldAlt => isDark ? const Color(0xFF141820) : const Color(0xFFF4F1EA);

  Color get surface => isDark ? const Color(0xFF1A2030) : Colors.white;

  Color get surfaceElevated => isDark ? const Color(0xFF232B3A) : Colors.white;

  Color get textPrimary => isDark ? const Color(0xFFF3F4F6) : const Color(0xFF1A1F2E);

  Color get textSecondary => isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

  Color get border => isDark ? const Color(0xFF2D3544) : const Color(0xFFE5DFD3);

  Color get divider => isDark ? const Color(0xFF2A3140) : const Color(0xFFE8E5DE);

  Color get chipBackground =>
      isDark ? const Color(0xFF252D3D) : const Color(0xFFF0EDE6);

  Color get skeleton => isDark ? const Color(0xFF2A3140) : const Color(0xFFE5E7EB);

  Color get bottomBar =>
      isDark ? const Color(0xFF1A2030).withValues(alpha: 0.96) : Colors.white.withValues(alpha: 0.96);

  static TpColors of(BuildContext context) =>
      TpColors(Theme.of(context).brightness);
}

extension TerangaPassTheme on BuildContext {
  TpColors get tp => TpColors.of(this);
}
