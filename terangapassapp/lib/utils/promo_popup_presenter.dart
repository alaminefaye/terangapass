import 'package:flutter/material.dart';
import '../services/promo_popup_service.dart';
import '../widgets/promotion_popup_dialog.dart';

/// Affiche le pop-up pub actif pour un écran donné.
class PromoPopupPresenter {
  PromoPopupPresenter._();

  static Future<void> showForPlacement(
    BuildContext context,
    String placement,
  ) async {
    if (!context.mounted) return;

    final popup = await PromoPopupService.instance.fetchActive(placement);
    if (popup == null || !context.mounted) return;

    final show = await PromoPopupService.instance.shouldShow(popup);
    if (!show || !context.mounted) return;

    await PromotionPopupDialog.show(context, popup);
  }
}
