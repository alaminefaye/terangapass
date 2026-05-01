import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

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
        final position = await LocationService().getCurrentPosition();
        latitude = position.latitude;
        longitude = position.longitude;
      } catch (e) {
        latitude = null;
        longitude = null;
        locationError = e.toString().replaceAll('Exception: ', '').trim();
        final msg = locationError.toLowerCase();
        locationDeniedForever = msg.contains('définitivement');
        locationServiceDisabled = msg.contains('désactivés');
      }

      final points = await apiService.getPointsOfInterest(
        latitude: latitude,
        longitude: longitude,
      );
      if (!mounted) return;
      setState(() {
        _userLatitude = latitude;
        _userLongitude = longitude;
        _locationError = locationError;
        _locationDeniedForever = locationDeniedForever;
        _locationServiceDisabled = locationServiceDisabled;
        _pointsOfInterest = points
            .map((p) => p as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pointsOfInterest = [];
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
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

  List<String> _getPointPhotos(Map<String, dynamic> point) {
    final raw = point['photos'];
    if (raw is! List) return const [];
    final urls = raw.map(_normalizeMediaUrl).whereType<String>().toList();
    return urls;
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
    final topPadding = MediaQuery.of(context).padding.top;
    final headerHeight = 170.0 + topPadding;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EA),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: headerHeight),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: headerHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF2E8B57),
                    const Color(0xFF1F6D44),
                    Color(0xFF155437),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E8B57).withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: topPadding),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Tourisme & Services',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      tabAlignment: TabAlignment.center,
                      labelColor: const Color(0xFF2E8B57),
                      unselectedLabelColor: Colors.white.withValues(alpha: 0.8),
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      unselectedLabelStyle: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: _categories
                          .map(
                            (cat) => Tab(
                              text: cat == 'Tous'
                                  ? 'Tous (${_pointsOfInterest.length})'
                                  : '$cat (${_getFiltered(cat).length})',
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(String category) {
    final points = _getFiltered(category);

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
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
      itemCount: points.length + (showBanner ? 1 : 0),
      itemBuilder: (context, index) {
        if (showBanner && index == 0) {
          return _buildLocationBanner();
        }

        final point = points[index - (showBanner ? 1 : 0)];
        final cat = (point['category'] ?? '').toString().trim();
        final icon = _getCategoryIcon(cat);
        final color = _getCategoryColor(cat);
        final iconUrl = _getPointIconUrl(point);
        final distanceLabel = _distanceLabelForPoint(point);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showPointDetails(point),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      width: 52,
                      height: 52,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: iconUrl == null
                            ? Center(child: Icon(icon, color: color, size: 26))
                            : Image.network(
                                iconUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(
                                    child: Icon(icon, color: color, size: 26),
                                  );
                                },
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (point['name'] ?? '').toString().trim(),
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
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
                                style: GoogleFonts.poppins(
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
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.grey[400],
                        size: 13,
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
    final name = (point['name'] as String? ?? '').trim();
    final category = (point['category'] as String? ?? '').trim();
    final distance = _distanceLabelForPoint(point);
    final rating = point['rating'];
    final address = point['address'] as String?;
    final phone = point['phone'] as String?;
    final description = point['description'] as String?;
    final openingHours = point['opening_hours'] as String?;
    final color = _getCategoryColor(category);
    final icon = _getCategoryIcon(category);
    final iconUrl = _getPointIconUrl(point);
    final photos = _getPointPhotos(point);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Poignée
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // En-tête
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          width: 62,
                          height: 62,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: iconUrl == null
                                ? Center(
                                    child: Icon(icon, color: color, size: 30),
                                  )
                                : Image.network(
                                    iconUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          icon,
                                          color: color,
                                          size: 30,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: GoogleFonts.poppins(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  category,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (rating != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '$rating',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  // Contenu scrollable
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                      children: [
                        if (photos.isNotEmpty) ...[
                          Text(
                            'Galerie photos',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 96,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: photos.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final url = photos[index];
                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () => _openPhotoPreview(
                                      photos: photos,
                                      initialIndex: index,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.network(
                                        url,
                                        width: 130,
                                        height: 96,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                width: 130,
                                                height: 96,
                                                color: Colors.white,
                                                child: const Icon(Icons.image),
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (distance.isNotEmpty)
                          _detailInfoTile(
                            icon: Icons.near_me_rounded,
                            color: AppTheme.primaryGreen,
                            label: 'Distance',
                            value: distance,
                          ),
                        if (address != null && address.isNotEmpty)
                          _detailInfoTile(
                            icon: Icons.location_on_rounded,
                            color: Colors.red,
                            label: 'Adresse',
                            value: address,
                          ),
                        if (phone != null && phone.isNotEmpty)
                          _detailInfoTile(
                            icon: Icons.phone_rounded,
                            color: Colors.blue,
                            label: 'Téléphone',
                            value: phone,
                          ),
                        if (openingHours != null && openingHours.isNotEmpty)
                          _detailInfoTile(
                            icon: Icons.access_time_rounded,
                            color: Colors.orange,
                            label: 'Horaires',
                            value: openingHours,
                          ),
                        if (description != null && description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Description',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              description,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 8),
                        // Bouton carte
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                            _openInMaps(point);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryGreen,
                                  const Color(0xFF008C5E),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGreen.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.map_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Voir sur la carte',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (phone != null && phone.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              _callPhone(phone);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.blue.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.phone_rounded,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Appeler',
                                    style: GoogleFonts.poppins(
                                      color: Colors.blue,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailInfoTile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openPhotoPreview({
    required List<String> photos,
    required int initialIndex,
  }) {
    if (photos.isEmpty) return;
    final safeInitialIndex = initialIndex.clamp(
      0,
      (photos.length - 1).clamp(0, 999999),
    );
    final pageController = PageController(initialPage: safeInitialIndex);
    int currentIndex = safeInitialIndex;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Material(
              color: Colors.transparent,
              child: SafeArea(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: pageController,
                      itemCount: photos.length,
                      onPageChanged: (i) => setState(() => currentIndex = i),
                      itemBuilder: (context, index) {
                        final url = photos[index];
                        return Center(
                          child: InteractiveViewer(
                            minScale: 1,
                            maxScale: 4,
                            child: Image.network(
                              url,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.broken_image_rounded,
                                  color: Colors.white70,
                                  size: 70,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 18,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${currentIndex + 1}/${photos.length}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openInMaps(Map<String, dynamic> point) async {
    final name = point['name']?.toString().trim() ?? '';
    final address = point['address']?.toString().trim() ?? '';
    final query = address.isNotEmpty ? address : name;
    final finalQuery = query.isEmpty ? 'Dakar' : query;
    final encoded = Uri.encodeComponent(finalQuery);
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encoded',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      await launchUrl(uri);
    } catch (_) {}
  }
}
