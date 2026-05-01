import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';

enum _MapFilter { all, help, sites, hotels, restaurants, pharmacies, hospitals }

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  _MapFilter _selectedFilter = _MapFilter.all;
  bool _isLocating = false;
  double? _currentLat;
  double? _currentLng;
  bool _isLoadingPoints = true;
  String? _pointsErrorMessage;
  List<Map<String, dynamic>> _pointsOfInterest = [];

  @override
  void initState() {
    super.initState();
    _loadPointsOfInterest();
  }

  String? _categoryForFilter(_MapFilter filter) {
    switch (filter) {
      case _MapFilter.all:
        return null;
      case _MapFilter.help:
        return 'Secours';
      case _MapFilter.sites:
        return 'Sites JOJ';
      case _MapFilter.hotels:
        return 'Hôtels';
      case _MapFilter.restaurants:
        return 'Restaurants';
      case _MapFilter.pharmacies:
        return 'Pharmacies';
      case _MapFilter.hospitals:
        return 'Hôpitaux';
    }
  }

  Future<void> _loadPointsOfInterest() async {
    setState(() {
      _isLoadingPoints = true;
      _pointsErrorMessage = null;
    });

    try {
      final apiService = ApiService();
      final points = await apiService.getPointsOfInterest(
        category: _categoryForFilter(_selectedFilter),
        latitude: _currentLat,
        longitude: _currentLng,
      );
      if (!mounted) return;
      setState(() {
        _pointsOfInterest = points
            .map((p) => p as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pointsOfInterest = [];
        _pointsErrorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPoints = false;
        });
      }
    }
  }

  IconData _iconForCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains('secours') || c.contains('urgence')) {
      return Icons.emergency_rounded;
    }
    if (c.contains('hôpital') || c.contains('hopital')) {
      return Icons.local_hospital_rounded;
    }
    if (c.contains('pharm')) return Icons.local_pharmacy_rounded;
    if (c.contains('hôtel') || c.contains('hotel')) return Icons.hotel_rounded;
    if (c.contains('restaurant')) return Icons.restaurant_rounded;
    if (c.contains('site') || c.contains('joj') || c.contains('stade')) {
      return Icons.stadium_rounded;
    }
    return Icons.place_rounded;
  }

  Color _colorForCategory(String category) {
    final c = category.toLowerCase();
    if (c.contains('secours') || c.contains('urgence')) {
      return AppTheme.primaryRed;
    }
    if (c.contains('hôpital') || c.contains('hopital')) {
      return AppTheme.primaryRed;
    }
    if (c.contains('pharm')) return Colors.blue;
    if (c.contains('hôtel') || c.contains('hotel')) return Colors.purple;
    if (c.contains('restaurant')) return Colors.orange;
    if (c.contains('site') || c.contains('joj') || c.contains('stade')) {
      return AppTheme.primaryGreen;
    }
    return AppTheme.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EA),
      body: SafeArea(
        child: Stack(
          children: [
            // Carte visuelle style maquette (placeholder design)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD8E4D2), Color(0xFFC8D8C0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 140),
                    Expanded(
                      child: Center(
                        child: Text(
                          l10n.mapPlaceholderTitle,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.mapPlaceholderSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 68,
              left: 16,
              right: 16,
              child: SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip(_MapFilter.all, l10n),
                    const SizedBox(width: 6),
                    _buildFilterChip(_MapFilter.help, l10n),
                    const SizedBox(width: 6),
                    _buildFilterChip(_MapFilter.sites, l10n),
                    const SizedBox(width: 6),
                    _buildFilterChip(_MapFilter.hotels, l10n),
                    const SizedBox(width: 6),
                    _buildFilterChip(_MapFilter.restaurants, l10n),
                    const SizedBox(width: 6),
                    _buildFilterChip(_MapFilter.pharmacies, l10n),
                    const SizedBox(width: 6),
                    _buildFilterChip(_MapFilter.hospitals, l10n),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 16,
              bottom: 250,
              child: FloatingActionButton.small(
                heroTag: 'map_locate',
                backgroundColor: Colors.white,
                onPressed: _centerOnCurrentLocation,
                child: Icon(
                  Icons.my_location_rounded,
                  color: _isLocating ? AppTheme.primaryGreen : AppTheme.textPrimary,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 240,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.mapNearbyPointsTitle,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _isLoadingPoints
                          ? const Center(child: CircularProgressIndicator())
                          : _pointsErrorMessage != null
                          ? Center(
                              child: Text(
                                _pointsErrorMessage!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : _pointsOfInterest.isEmpty
                          ? Center(
                              child: Text(
                                l10n.mapNoPoints,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: _pointsOfInterest.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                return _buildPointOfInterestFromData(
                                  _pointsOfInterest[index],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(_MapFilter filter, AppLocalizations l10n) {
    final isSelected = _selectedFilter == filter;
    final label = switch (filter) {
      _MapFilter.all => l10n.mapFilterAll,
      _MapFilter.help => l10n.mapFilterHelp,
      _MapFilter.sites => l10n.mapFilterSites,
      _MapFilter.hotels => l10n.mapFilterHotels,
      _MapFilter.restaurants => l10n.mapFilterRestaurants,
      _MapFilter.pharmacies => l10n.mapFilterPharmacies,
      _MapFilter.hospitals => l10n.mapFilterHospitals,
    };

    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: isSelected ? Colors.white : AppTheme.textPrimary,
        ),
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = filter;
        });
        _loadPointsOfInterest();
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF1A1F2E),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFF1A1F2E)
            : Colors.grey.withValues(alpha: 0.3),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }

  Widget _buildPointOfInterestFromData(Map<String, dynamic> point) {
    final l10n = AppLocalizations.of(context)!;
    final name = (point['name'] ?? '').toString().trim();
    final category = (point['category'] ?? '').toString().trim();
    final distance = (point['distance'] ?? '').toString().trim();
    final lat = point['latitude'] ?? point['lat'];
    final lng = point['longitude'] ?? point['lng'] ?? point['lon'];
    final latitude = lat is num ? lat.toDouble() : double.tryParse('$lat');
    final longitude = lng is num ? lng.toDouble() : double.tryParse('$lng');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (latitude != null && longitude != null) {
            _openInMaps(latitude: latitude, longitude: longitude);
            return;
          }
          _openInMaps(query: name);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF7F0),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _colorForCategory(category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconForCategory(category),
                  color: _colorForCategory(category),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isEmpty ? l10n.mapDefaultPointName : name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      distance.isNotEmpty
                          ? distance
                          : (category.isNotEmpty ? category : '—'),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _centerOnCurrentLocation() async {
    final l10n = AppLocalizations.of(context)!;
    if (_isLocating) return;
    setState(() {
      _isLocating = true;
    });
    try {
      final locationService = LocationService();
      final pos = await locationService.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _currentLat = pos.latitude;
        _currentLng = pos.longitude;
      });
      _loadPointsOfInterest();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.mapPositionUpdated, style: GoogleFonts.poppins()),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.mapCannotGetPosition,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  Future<void> _openInMaps({
    String? query,
    double? latitude,
    double? longitude,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = (latitude != null && longitude != null)
        ? Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
          )
        : Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query ?? l10n.jojDefaultLocation)}',
          );

    final ok = await canLaunchUrl(uri);
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.mapOpenGoogleMapsError,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
