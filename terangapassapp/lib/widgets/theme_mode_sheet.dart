import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../services/theme_mode_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_theme_extensions.dart';

/// Feuille pour choisir clair / sombre / système.
Future<void> showThemeModeSheet(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;
  final current = ThemeModeService.notifier.value;

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.tp.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ctx.tp.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.profileThemeSetting,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: ctx.tp.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.profileThemeSettingHint,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: ctx.tp.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _ThemeModeTile(
                icon: Icons.brightness_auto_rounded,
                label: l10n.profileThemeSystem,
                selected: current == ThemeMode.system,
                onTap: () => _pick(ctx, ThemeMode.system),
              ),
              _ThemeModeTile(
                icon: Icons.light_mode_rounded,
                label: l10n.profileThemeLight,
                selected: current == ThemeMode.light,
                onTap: () => _pick(ctx, ThemeMode.light),
              ),
              _ThemeModeTile(
                icon: Icons.dark_mode_rounded,
                label: l10n.profileThemeDark,
                selected: current == ThemeMode.dark,
                onTap: () => _pick(ctx, ThemeMode.dark),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _pick(BuildContext context, ThemeMode mode) async {
  await ThemeModeService.set(mode);
  if (context.mounted) Navigator.pop(context);
}

class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: selected ? AppTheme.primaryGreen : context.tp.textSecondary,
      ),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: context.tp.textPrimary,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen)
          : null,
      onTap: onTap,
    );
  }
}
