import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Filtre catégorie POI partagé (Tourisme, À deux pas, Se déplacer).
class PoiCategoryFilter {
  const PoiCategoryFilter({required this.label, this.categoryKey});

  final String label;

  /// `null` = tous · `__help__` / `__sites__` = filtres carte · sinon clé partner.
  final String? categoryKey;
}

class PoiCategoryFilters {
  PoiCategoryFilters._();

  static const String helpKey = '__help__';
  static const String sitesKey = '__sites__';

  /// Catégories communes (sans Secours / Sites JOJ).
  static List<PoiCategoryFilter> standard(AppLocalizations l10n) => [
    PoiCategoryFilter(label: l10n.nearbyAll, categoryKey: null),
    PoiCategoryFilter(label: l10n.mapFilterRestaurants, categoryKey: 'restaurant'),
    PoiCategoryFilter(label: l10n.mapFilterBanks, categoryKey: 'bank'),
    PoiCategoryFilter(label: l10n.mapFilterGasStations, categoryKey: 'gas_station'),
    PoiCategoryFilter(label: l10n.nearbyChipHotels, categoryKey: 'hotel'),
    PoiCategoryFilter(label: l10n.mapFilterPharmacies, categoryKey: 'pharmacy'),
    PoiCategoryFilter(label: l10n.nearbyChipHospitals, categoryKey: 'hospital'),
    PoiCategoryFilter(label: l10n.nearbyChipClinics, categoryKey: 'clinic'),
    PoiCategoryFilter(label: l10n.nearbyChipNotaries, categoryKey: 'notary'),
    PoiCategoryFilter(label: l10n.nearbyChipLawyers, categoryKey: 'lawyer'),
    PoiCategoryFilter(label: l10n.nearbyChipDoctors, categoryKey: 'doctor'),
    PoiCategoryFilter(label: l10n.nearbyChipGovernment, categoryKey: 'government'),
    PoiCategoryFilter(label: l10n.nearbyChipSchools, categoryKey: 'school'),
    PoiCategoryFilter(label: l10n.nearbyChipUniversities, categoryKey: 'university'),
    PoiCategoryFilter(label: l10n.nearbyChipMedia, categoryKey: 'media'),
    PoiCategoryFilter(
      label: l10n.nearbyChipProfessionalServices,
      categoryKey: 'professional_service',
    ),
    PoiCategoryFilter(
      label: l10n.nearbyChipReligiousSites,
      categoryKey: 'religious_site',
    ),
    PoiCategoryFilter(label: l10n.mapFilterShops, categoryKey: 'shop'),
    PoiCategoryFilter(label: l10n.tourismCategoryEmbassies, categoryKey: 'embassy'),
    PoiCategoryFilter(label: l10n.mapFilterConsulates, categoryKey: 'consulate'),
  ];

  /// Carte « Se déplacer » : Secours + Sites JOJ + toutes les catégories.
  static List<PoiCategoryFilter> forMap(AppLocalizations l10n) => [
    PoiCategoryFilter(label: l10n.mapFilterAll, categoryKey: null),
    PoiCategoryFilter(label: l10n.mapFilterHelp, categoryKey: helpKey),
    PoiCategoryFilter(label: l10n.mapFilterSites, categoryKey: sitesKey),
    ...standard(l10n).skip(1),
  ];

  static String? partnerCategoryKey(String? categoryKey) {
    if (categoryKey == null ||
        categoryKey == helpKey ||
        categoryKey == sitesKey) {
      return null;
    }
    return categoryKey;
  }

  static bool matchesCategory(Map<String, dynamic> point, String? categoryKey) {
    if (categoryKey == null) return true;

    final catLabel = (point['category'] ?? '').toString().toLowerCase();
    final catKey = (point['category_key'] ?? '').toString().toLowerCase();
    final id = point['id']?.toString() ?? '';

    switch (categoryKey) {
      case helpKey:
        return catKey == 'hospital' ||
            catKey == 'pharmacy' ||
            catKey == 'embassy' ||
            catKey == 'consulate' ||
            catKey == 'clinic' ||
            catKey == 'doctor' ||
            catLabel.contains('hôpital') ||
            catLabel.contains('hopital') ||
            catLabel.contains('pharm') ||
            catLabel.contains('ambass') ||
            catLabel.contains('consul') ||
            catLabel.contains('clinique') ||
            catLabel.contains('médecin');
      case sitesKey:
        return id.startsWith('site_') ||
            catLabel.contains('site') ||
            catLabel.contains('joj');
      default:
        return catKey == categoryKey;
    }
  }

  static bool matchesSearch(Map<String, dynamic> point, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final name = (point['name'] ?? '').toString().toLowerCase();
    final address = (point['address'] ?? '').toString().toLowerCase();
    final category = (point['category'] ?? '').toString().toLowerCase();
    return name.contains(q) || address.contains(q) || category.contains(q);
  }

  static IconData iconForCategoryKey(String? categoryKey) {
    switch (categoryKey) {
      case 'hotel':
        return Icons.hotel_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'pharmacy':
        return Icons.local_pharmacy_rounded;
      case 'hospital':
      case 'clinic':
      case 'doctor':
        return Icons.local_hospital_rounded;
      case 'embassy':
      case 'consulate':
        return Icons.account_balance_rounded;
      case 'bank':
        return Icons.account_balance_wallet_rounded;
      case 'gas_station':
        return Icons.local_gas_station_rounded;
      case 'shop':
        return Icons.storefront_rounded;
      case 'notary':
        return Icons.gavel_rounded;
      case 'lawyer':
        return Icons.balance_rounded;
      case 'government':
        return Icons.apartment_rounded;
      case 'school':
      case 'university':
        return Icons.school_rounded;
      case 'media':
        return Icons.theaters_rounded;
      case 'professional_service':
        return Icons.work_rounded;
      case 'religious_site':
        return Icons.church_rounded;
      case helpKey:
        return Icons.medical_services_rounded;
      case sitesKey:
        return Icons.stadium_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  static IconData iconForPoint(Map<String, dynamic> point) {
    final key = (point['category_key'] ?? '').toString();
    if (key.isNotEmpty) return iconForCategoryKey(key);
    return iconForCategoryLabel((point['category'] ?? '').toString());
  }

  static IconData iconForCategoryLabel(String categoryLabel) {
    final c = categoryLabel.trim();
    if (c == 'Hôtels') return Icons.hotel_rounded;
    if (c == 'Restaurants') return Icons.restaurant_rounded;
    if (c == 'Pharmacies') return Icons.local_pharmacy_rounded;
    if (c == 'Hôpitaux') return Icons.local_hospital_rounded;
    if (c == 'Ambassades' || c == 'Consulats') {
      return Icons.account_balance_rounded;
    }
    return Icons.place_rounded;
  }

  static Color colorForCategoryKey(String? categoryKey) {
    switch (categoryKey) {
      case 'hotel':
        return Colors.blue;
      case 'restaurant':
        return Colors.orange;
      case 'pharmacy':
        return Colors.purple;
      case 'hospital':
      case 'clinic':
      case 'doctor':
        return AppTheme.primaryRed;
      case 'embassy':
      case 'consulate':
        return Colors.indigo;
      case 'bank':
        return Colors.teal;
      case 'gas_station':
        return Colors.amber.shade800;
      case helpKey:
        return Colors.red.shade700;
      case sitesKey:
        return Colors.deepPurple;
      default:
        return AppTheme.primaryGreen;
    }
  }

  static Color colorForPoint(Map<String, dynamic> point) {
    final key = (point['category_key'] ?? '').toString();
    if (key.isNotEmpty) return colorForCategoryKey(key);
    return colorForCategoryLabel((point['category'] ?? '').toString());
  }

  static Color colorForCategoryLabel(String categoryLabel) {
    return colorForCategoryKey(null);
  }

  /// Libellé français API → clé partner.
  static const Map<String, String> labelToCategoryKey = {
    'Hôtels': 'hotel',
    'Restaurants': 'restaurant',
    'Pharmacies': 'pharmacy',
    'Hôpitaux': 'hospital',
    'Ambassades': 'embassy',
    'Consulats': 'consulate',
    'Banques & DAB': 'bank',
    'Stations-service': 'gas_station',
    'Boutiques': 'shop',
    'Notaires': 'notary',
    'Avocats': 'lawyer',
    'Médecins': 'doctor',
    'Cliniques': 'clinic',
    'Services publics': 'government',
    'Écoles': 'school',
    'Universités': 'university',
    'Médias & culture': 'media',
    'Services professionnels': 'professional_service',
    'Lieux de culte': 'religious_site',
    'Autres': 'other',
  };

  static int countForFilter(
    PoiCategoryFilter filter,
    Map<String, int> labelCounts,
    List<Map<String, dynamic>> loaded, {
    int? total,
  }) {
    if (filter.categoryKey == null) {
      return total ?? loaded.length;
    }
    final fromMeta = labelCounts[filter.label];
    if (fromMeta != null) return fromMeta;
    final mapped = labelToCategoryKey[filter.label];
    final key = filter.categoryKey ?? mapped;
    if (key == null) return 0;
    return loaded
        .where((p) => matchesCategory(p, key))
        .length;
  }
}
