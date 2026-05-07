import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

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

    if (_variant == _LegendVariant.mapHint ||
        _variant == _LegendVariant.homeJoj) {
      final joj = _variant == _LegendVariant.homeJoj;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
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
              color: joj ? AppTheme.primaryGreen : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                joj ? l10n.mapLegendJojSitesHint : l10n.mapLegendCategoriesHint,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  height: 1.35,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.98),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.mapLegendTitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _LegendRow(
            icon: Icons.person_pin_circle_rounded,
            color: _userBlue,
            label: l10n.mapLegendYou,
          ),
          const SizedBox(height: 6),
          _LegendRow(
            icon: Icons.place_rounded,
            color: AppTheme.primaryGreen,
            label: l10n.mapLegendPlace,
          ),
          const SizedBox(height: 6),
          _LegendRow(
            icon: Icons.place_rounded,
            color: Colors.amber[800]!,
            label: l10n.mapLegendSponsor,
          ),
        ],
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
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }
}
