import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/promo_popup_service.dart';
import '../theme/app_theme.dart';

/// Pop-up plein écran type interstitiel (fond assombri + visuel + fermer).
class PromotionPopupDialog extends StatelessWidget {
  const PromotionPopupDialog({super.key, required this.promo});

  final Map<String, dynamic> promo;

  static Future<void> show(BuildContext context, Map<String, dynamic> promo) {
    final id = promo['id'];
    if (id is int) {
      PromoPopupService.instance.recordImpression(id);
    } else if (id is num) {
      PromoPopupService.instance.recordImpression(id.toInt());
    }

    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Fermer la publicité',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      pageBuilder: (ctx, animation, secondaryAnimation) {
        return PromotionPopupDialog(promo: promo);
      },
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
    );
  }

  int? get _promoId {
    final id = promo['id'];
    if (id is int) return id;
    if (id is num) return id.toInt();
    return int.tryParse(id?.toString() ?? '');
  }

  Future<void> _close(BuildContext context) async {
    await PromoPopupService.instance.markDismissed(promo);
    if (context.mounted) Navigator.of(context).pop();
  }

  Future<void> _onTapVisual(BuildContext context) async {
    final url = promo['link_url']?.toString().trim();
    final promoId = _promoId;
    if (promoId != null) {
      await PromoPopupService.instance.recordClick(promoId);
    }
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = promo['image_url']?.toString();
    final sponsor = promo['sponsor_name']?.toString();
    final linkLabel = (promo['link_label']?.toString().trim().isNotEmpty == true)
        ? promo['link_label'].toString().trim()
        : 'En savoir plus';
    final hasLink = promo['link_url']?.toString().trim().isNotEmpty == true;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Material(
            color: Colors.transparent,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  onTap: () => _onTapVisual(context),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (imageUrl != null && imageUrl.isNotEmpty)
                            AspectRatio(
                              aspectRatio: 4 / 5,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: const Color(0xFFF0F0F0),
                                  child: const Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 48,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: AppTheme.primaryGreen,
                                    ),
                                  );
                                },
                              ),
                            ),
                          if (hasLink)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                              child: SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () => _onTapVisual(context),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppTheme.primaryGreen,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    linkLabel,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          if (sponsor != null && sponsor.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                bottom: hasLink ? 0 : 14,
                              ),
                              child: Text(
                                'Publicité · $sponsor',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 4,
                    child: InkWell(
                      onTap: () => _close(context),
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: Color(0xFF1A1F2E),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
