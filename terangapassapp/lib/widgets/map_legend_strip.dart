import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/app_theme_extensions.dart';

/// Légende compacte pour les cartes « près de moi » et carte interactive.
class MapLegendStrip extends StatelessWidget {
  const MapLegendStrip.nearby({super.key}) : _variant = _LegendVariant.nearby;

  const MapLegendStrip.mapHint({super.key}) : _variant = _LegendVariant.mapHint;

  /// Aperçu carte accueil JOJ : uniquement repères sites (vert).
  const MapLegendStrip.homeJoj({super.key}) : _variant = _LegendVariant.homeJoj;

  final _LegendVariant _variant;

  static const Color _userBlue = Color(0xFF1565C0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tp = context.tp;

    if (_variant == _LegendVariant.mapHint ||
        _variant == _LegendVariant.homeJoj) {
      final joj = _variant == _LegendVariant.homeJoj;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: tp.surface.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tp.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: tp.isDark ? 0.35 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              joj ? Icons.location_on_rounded : Icons.info_outline_rounded,
              size: joj ? 18 : 16,
              color: joj ? AppTheme.primaryGreen : tp.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                joj ? l10n.mapLegendJojSitesHint : l10n.mapLegendCategoriesHint,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  height: 1.35,
                  color: tp.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // « À deux pas » : carte légende lisible (sous la carte ou en overlay).
    return Material(
      color: Colors.transparent,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: tp.isDark ? 0.5 : 0.15),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: tp.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tp.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.mapLegendTitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: tp.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            _LegendRow(
              icon: Icons.person_pin_circle_rounded,
              color: _userBlue,
              label: l10n.mapLegendYou,
              textColor: tp.textPrimary,
            ),
            const SizedBox(height: 6),
            _LegendRow(
              icon: Icons.place_rounded,
              color: AppTheme.primaryGreen,
              label: l10n.mapLegendPlace,
              textColor: tp.textPrimary,
            ),
            const SizedBox(height: 6),
            _LegendRow(
              icon: Icons.place_rounded,
              color: Colors.amber[800]!,
              label: l10n.mapLegendSponsor,
              textColor: tp.textPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

enum _LegendVariant { nearby, mapHint, homeJoj }

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.textColor,
  });

  final IconData icon;
  final Color color;
  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: textColor),
          ),
        ),
      ],
    );
  }
}
