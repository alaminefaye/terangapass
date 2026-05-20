import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../theme/app_theme_extensions.dart';

/// Logo Teranga Pass avec animation « respiration » (échelle + opacité).
class AnimatedTerangaLogo extends StatefulWidget {
  const AnimatedTerangaLogo({
    super.key,
    this.size = 80,
    this.borderRadius = 20,
  });

  final double size;
  final double borderRadius;

  @override
  State<AnimatedTerangaLogo> createState() => _AnimatedTerangaLogoState();
}

class _AnimatedTerangaLogoState extends State<AnimatedTerangaLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _opacity = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Opacity(
            opacity: _opacity.value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGreen.withValues(alpha: 0.28),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Image.asset(
              'assets/images/app_logo.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return ColoredBox(
                  color: AppTheme.primaryGreen.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.verified_user_rounded,
                    size: widget.size * 0.55,
                    color: AppTheme.primaryGreen,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Chargement brandé : logo + texte + barre **centrés** ; squelette en fond discret.
class TerangaBrandedLoading extends StatelessWidget {
  const TerangaBrandedLoading({
    super.key,
    this.showSkeletonList = true,
    this.skeletonItemCount = 6,
    this.skeletonOpacity = 0.2,
    this.dense = false,
    this.message,
  });

  /// Texte par défaut (auth, listes).
  static const String defaultLoadingMessage = 'Patientez un instant…';

  /// Squelette en arrière-plan (léger, ne pousse plus le bloc vers le haut).
  final bool showSkeletonList;

  final int skeletonItemCount;

  /// Opacité des cartes fantômes (0 = invisible).
  final double skeletonOpacity;

  /// Logo un peu plus petit (ex. panneau carte embarqué).
  final bool dense;

  /// Texte sous le logo (défaut : [defaultLoadingMessage]).
  final String? message;

  @override
  Widget build(BuildContext context) {
    final logoSize = dense ? 72.0 : 92.0;
    final logoRadius = dense ? 18.0 : 22.0;
    final label = message ?? defaultLoadingMessage;

    Widget brandedContent({
      required double logo,
      required double radius,
      required double gapAfterLogo,
      required double gapAfterText,
      required double fontSize,
      required double barWidth,
    }) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedTerangaLogo(size: logo, borderRadius: radius),
          SizedBox(height: gapAfterLogo),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: context.tp.textPrimary,
              height: 1.25,
            ),
          ),
          SizedBox(height: gapAfterText),
          SizedBox(
            width: barWidth,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: AppTheme.primaryGreen.withValues(alpha: 0.14),
                color: AppTheme.primaryGreen,
              ),
            ),
          ),
        ],
      );
    }

    Widget brandedForConstraints(BoxConstraints constraints) {
      final maxH = constraints.maxHeight;
      final tight = maxH.isFinite && maxH < 128;
      if (tight) {
        return brandedContent(
          logo: 52,
          radius: 14,
          gapAfterLogo: 8,
          gapAfterText: 8,
          fontSize: 12,
          barWidth: 120,
        );
      }
      return brandedContent(
        logo: logoSize,
        radius: logoRadius,
        gapAfterLogo: dense ? 12 : 22,
        gapAfterText: dense ? 10 : 14,
        fontSize: dense ? 13 : 15,
        barWidth: dense ? 148 : 172,
      );
    }

    if (!showSkeletonList) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: LayoutBuilder(
            builder: (context, constraints) => FittedBox(
              fit: BoxFit.scaleDown,
              child: brandedForConstraints(constraints),
            ),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.hardEdge,
      children: [
        IgnorePointer(
          child: Opacity(
            opacity: skeletonOpacity.clamp(0.0, 1.0),
            child: CardListLoadingSkeleton(itemCount: skeletonItemCount),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: LayoutBuilder(
              builder: (context, constraints) => FittedBox(
                fit: BoxFit.scaleDown,
                child: brandedForConstraints(constraints),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Écran minimal au démarrage (session / locale) — évite un spinner nu (P0 sprint).
class AuthGateLoadingScaffold extends StatelessWidget {
  const AuthGateLoadingScaffold({super.key, this.backgroundColor});

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? context.tp.scaffold,
      body: const Center(
        child: TerangaBrandedLoading(showSkeletonList: false, dense: true),
      ),
    );
  }
}

/// Squelettes pour listes de cartes (tourisme, proximité, ambassades, etc.).
class CardListLoadingSkeleton extends StatelessWidget {
  const CardListLoadingSkeleton({
    super.key,
    this.itemCount = 7,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 24),
  });

  final int itemCount;
  final EdgeInsets padding;

  static Widget _bar(double w, double h, Color color) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.tp;
    return ListView.separated(
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Container(
          height: 96,
          decoration: BoxDecoration(
            color: tp.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(color: tp.border, width: 4),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _bar(100, 14, tp.skeleton),
                  const Spacer(),
                  _bar(40, 12, tp.skeleton),
                ],
              ),
              const SizedBox(height: 12),
              _bar(double.infinity, 16, tp.skeleton),
              const SizedBox(height: 8),
              _bar(double.infinity, 12, tp.skeleton),
            ],
          ),
        );
      },
    );
  }
}

/// Bandeau à hauteur fixe (ex. aperçu carte JOJ sur l’accueil).
class CompactRowSkeleton extends StatelessWidget {
  const CompactRowSkeleton({super.key, this.rowCount = 4});

  final int rowCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rowCount; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Container(
              height: 34,
              decoration: BoxDecoration(
                color: context.tp.skeleton,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Logo animé compact + squelette de lignes (aperçu carte sur l’accueil).
class CompactMapPreviewLoading extends StatelessWidget {
  const CompactMapPreviewLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, right: 12),
          child: AnimatedTerangaLogo(size: 40, borderRadius: 12),
        ),
        const Expanded(
          child: CompactRowSkeleton(rowCount: 4),
        ),
      ],
    );
  }
}
