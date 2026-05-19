import 'package:flutter/material.dart';

import '../theme/app_theme_extensions.dart';

/// Carte / conteneur avec couleurs adaptées au mode clair ou sombre.
class TpSurface extends StatelessWidget {
  const TpSurface({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.onTap,
    this.elevated = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final tp = context.tp;
    final decoration = BoxDecoration(
      color: elevated ? tp.surfaceElevated : tp.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: tp.border),
      boxShadow: elevated && !tp.isDark
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );

    Widget content = Container(
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      );
    }

    return content;
  }
}
