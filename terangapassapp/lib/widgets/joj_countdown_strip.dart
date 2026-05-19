import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';

/// Bandeau compte à rebours JOJ — textes alignés sur l’écran Infos JOJ.
class JojCountdownStrip extends StatefulWidget {
  const JojCountdownStrip({
    super.key,
    required this.daysRemaining,
  });

  final int daysRemaining;

  @override
  State<JojCountdownStrip> createState() => _JojCountdownStripState();
}

class _JojCountdownStripState extends State<JojCountdownStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _numberScaleAnimation;

  static const Color _gold = Color(0xFFD4A017);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    _glowAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _numberScaleAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glow = _glowAnimation.value;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Color.lerp(const Color(0xFF1A1F2E), const Color(0xFF243456), glow)!,
                Color.lerp(const Color(0xFF2A2F4E), const Color(0xFF364878), glow)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: _gold.withValues(alpha: 0.12 + glow * 0.2),
                blurRadius: 10 + glow * 12,
                spreadRadius: glow * 1.5,
                offset: Offset(0, 2 + glow * 2),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _numberScaleAnimation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _gold.withValues(alpha: 0.35)),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Text(
                  widget.daysRemaining.toString(),
                  key: ValueKey<int>(widget.daysRemaining),
                  style: const TextStyle(
                    fontSize: 34,
                    color: _gold,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeJojCountdownLabel,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.homeJojOlympicSubtitle,
                  style: GoogleFonts.poppins(
                    color: _gold,
                    fontSize: 10,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.homeJojCityLine,
                  style: GoogleFonts.robotoSlab(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.homeJojDateRange,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
