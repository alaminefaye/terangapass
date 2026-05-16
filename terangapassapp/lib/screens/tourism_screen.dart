import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/offline_pack_service.dart';
import '../widgets/loading_placeholders.dart';
import '../widgets/offline_cache_snack.dart';
import 'embassies_screen.dart';
import 'nearby_screen.dart';
import 'place_detail_screen.dart';

class TourismScreen extends StatefulWidget {
  const TourismScreen({super.key});

  @override
  State<TourismScreen> createState() => _TourismScreenState();
}

class _TourismScreenState extends State<TourismScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _categories = [
    'Tous',
    'Hôtels',
    'Restaurants',
    'Pharmacies',
    'Hôpitaux',
    'Ambassades',
  ];

  List<Map<String, dynamic>> _pointsOfInterest = [];
  int? _poiTotal;
  Map<String, int> _categoryLabelCounts = const {};
  bool _isLoading = true;
  String? _errorMessage;
  double? _userLatitude;
  double? _userLongitude;
  String? _locationError;
  bool _locationDeniedForever = false;
  bool _locationServiceDisabled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _loadPointsOfInterest();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPointsOfInterest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      String? locationError;
      bool locationDeniedForever = false;
      bool locationServiceDisabled = false;
      double? latitude;
      double? longitude;
      try {
        final position = await LocationService().getPositionForListings();
        if (position != null) {
          latitude = position.latitude;
          longitude = position.longitude;
        }
      } catch (e) {
        latitude = null;
        longitude = null;
        locationError = e.toString().replaceAll('Exception: ', '').trim();
        final msg = locationError.toLowerCase();
        locationDeniedForever = msg.contains('définitivement');
        locationServiceDisabled = msg.contains('désactivés');
      }

      final result = await apiService.getPointsOfInterest(
        latitude: latitude,
        longitude: longitude,
        limit: 100,
      );
      if (!mounted) return;
      setState(() {
        _userLatitude = latitude;
        _userLongitude = longitude;
        _locationError = locationError;
        _locationDeniedForever = locationDeniedForever;
        _locationServiceDisabled = locationServiceDisabled;
        _poiTotal = result.total;
        _categoryLabelCounts = result.categoryCounts;
        _pointsOfInterest = result.data
            .map((p) => p as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      final offline = await OfflinePackService().readOfflinePoiList();
      if (offline.isNotEmpty) {
        setState(() {
          _pointsOfInterest = offline;
          _errorMessage = null;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) showOfflineCacheSnackBar(context);
        });
      } else {
        setState(() {
          _pointsOfInterest = [];
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getFiltered(String category) {
    if (category == 'Tous') return _pointsOfInterest;
    return _pointsOfInterest
        .where((p) => p['category'].toString().trim() == category)
        .toList();
  }

  String? _normalizeMediaUrl(Object? value) {
    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) return null;

    if (raw.startsWith('https://')) return raw;
    if (raw.startsWith('http://')) {
      return 'https://${raw.substring('http://'.length)}';
    }

    if (raw.startsWith('/')) {
      final base = ApiService.baseUrl.replaceAll('/api/v1', '');
      return '${base.replaceAll(RegExp(r"/+$"), "")}$raw';
    }

    if (raw.startsWith('storage/') || raw.startsWith('public/')) {
      final base = ApiService.baseUrl.replaceAll('/api/v1', '');
      return '${base.replaceAll(RegExp(r"/+$"), "")}/${raw.replaceAll(RegExp(r"^/+"), "")}';
    }

    return null;
  }

  String? _getPointIconUrl(Map<String, dynamic> point) {
    return _normalizeMediaUrl(
      point['icon_url'] ??
          point['iconUrl'] ??
          point['icon_path'] ??
          point['iconPath'] ??
          point['logo_url'] ??
          point['logoUrl'],
    );
  }


  double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  String _formatDistanceMeters(double meters) {
    if (meters.isNaN || meters.isInfinite) return '—';
    if (meters < 1000) return '${meters.round()} m';
    final km = meters / 1000.0;
    return '${km.toStringAsFixed(1)} km';
  }

  String _distanceLabelForPoint(Map<String, dynamic> point) {
    final pointLat = _toDouble(point['latitude'] ?? point['lat']);
    final pointLng = _toDouble(point['longitude'] ?? point['lng']);
    if (pointLat == null || pointLng == null) {
      return 'Coordonnées manquantes';
    }
    if (_userLatitude == null || _userLongitude == null) {
      return 'Activer la localisation';
    }

    final meters = LocationService().calculateDistance(
      _userLatitude!,
      _userLongitude!,
      pointLat,
      pointLng,
    );
    return _formatDistanceMeters(meters);
  }

  Widget _buildLocationBanner() {
    final message =
        (_locationError ?? 'Activer la localisation').toString().trim().isEmpty
        ? 'Activer la localisation'
        : (_locationError ?? 'Activer la localisation').toString().trim();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: Colors.orange,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Distance indisponible',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: _loadPointsOfInterest,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreen,
                        side: BorderSide(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.35),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Réessayer', style: GoogleFonts.poppins()),
                    ),
                    if (_locationDeniedForever)
                      ElevatedButton(
                        onPressed: () async {
                          await Geolocator.openAppSettings();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Paramètres', style: GoogleFonts.poppins()),
                      ),
                    if (_locationServiceDisabled && !_locationDeniedForever)
                      ElevatedButton(
                        onPressed: () async {
                          await Geolocator.openLocationSettings();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Activer GPS',
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Hôtels':
        return Icons.hotel_rounded;
      case 'Restaurants':
        return Icons.restaurant_rounded;
      case 'Pharmacies':
        return Icons.local_pharmacy_rounded;
      case 'Hôpitaux':
        return Icons.local_hospital_rounded;
      case 'Ambassades':
        return Icons.account_balance_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Hôtels':
        return Colors.blue;
      case 'Restaurants':
        return Colors.orange;
      case 'Pharmacies':
        return Colors.purple;
      case 'Hôpitaux':
        return AppTheme.primaryRed;
      case 'Ambassades':
        return Colors.indigo;
      default:
        return AppTheme.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EA),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2D8A56),
                  const Color(0xFF25744A),
                  const Color(0xFF1D603D),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E8B57).withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.17),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Tourisme & Services',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.17),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            tooltip: 'À deux pas',
                            icon: const Icon(
                              Icons.near_me_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NearbyScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.17),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            tooltip: 'Ambassades',
                            icon: const Icon(
                              Icons.account_balance_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EmbassiesScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      labelColor: const Color(0xFF2E8B57),
                      unselectedLabelColor: Colors.white.withValues(alpha: 0.8),
                      dividerColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 4,
                      ),
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      labelStyle: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                      unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: _categories
                          .map(
                            (cat) => Tab(
                              text: cat == 'Tous'
                                  ? 'Tous (${_poiTotal ?? _pointsOfInterest.length})'
                                  : '$cat (${_categoryLabelCounts[cat] ?? _getFiltered(cat).length})',
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const TerangaBrandedLoading()
                : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadPointsOfInterest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                            child: Text(
                              'Réessayer',
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: _categories
                        .map((cat) => _buildCategoryTab(cat))
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String category) {
    final points = _getFiltered(category);
    final showLimitedHint = category == 'Tous' &&
        _poiTotal != null &&
        _poiTotal! > _pointsOfInterest.length;

    if (points.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  size: 60,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Aucun résultat',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final showBanner = _locationError != null;
    final extraHeaders = (showBanner ? 1 : 0) + (showLimitedHint ? 1 : 0);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: points.length + extraHeaders,
      itemBuilder: (context, index) {
        if (showBanner && index == 0) {
          return _buildLocationBanner();
        }
        if (showLimitedHint && index == (showBanner ? 1 : 0)) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_pointsOfInterest.length} lieux les plus proches affichés sur $_poiTotal au total.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF1D603D),
              ),
            ),
          );
        }

        final point = points[index - extraHeaders];
        final cat = (point['category'] ?? '').toString().trim();
        final icon = _getCategoryIcon(cat);
        final color = _getCategoryColor(cat);
        final iconUrl = _getPointIconUrl(point);
        final distanceLabel = _distanceLabelForPoint(point);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFECE6DC)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _showPointDetails(point),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      width: 48,
                      height: 48,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: iconUrl == null
                            ? Center(child: Icon(icon, color: color, size: 23))
                            : Image.network(
                                iconUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(icon, color: color, size: 23),
                                  );
                                },
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (point['name'] ?? '').toString().trim(),
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 13,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                distanceLabel,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          if (point['rating'] != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${point['rating']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6F2EA),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey[400],
                        size: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPointDetails(Map<String, dynamic> point) {
    // Enrichit le point avec la distance calculée localement
    final enriched = Map<String, dynamic>.from(point);
    final d = _distanceLabelForPoint(point);
    if (d.isNotEmpty) enriched['distance'] = d;

    final category = (point['category'] as String? ?? '').trim();
    final color = _getCategoryColor(category);
    final icon = _getCategoryIcon(category);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceDetailScreen(
          point: enriched,
          color: color,
          icon: icon,
        ),
      ),
    );
  }

}
