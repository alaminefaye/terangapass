import 'package:flutter/material.dart';

/// Écran minimal au démarrage (session / locale) — évite un spinner nu (P0 sprint).
class AuthGateLoadingScaffold extends StatelessWidget {
  const AuthGateLoadingScaffold({super.key, this.backgroundColor});

  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xFFFAF7F0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/app_logo.png',
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.verified_user_rounded,
                    size: 56,
                    color: Colors.green.shade800,
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 168,
              child: LinearProgressIndicator(minHeight: 3),
            ),
          ],
        ),
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

  static Widget _bar(double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Container(
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border(
              left: BorderSide(color: Colors.grey.shade300, width: 4),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _bar(100, 14),
                  const Spacer(),
                  _bar(40, 12),
                ],
              ),
              const SizedBox(height: 12),
              _bar(double.infinity, 16),
              const SizedBox(height: 8),
              _bar(double.infinity, 12),
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
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
