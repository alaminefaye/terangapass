import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/poi_category_filters.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../utils/poi_media_helpers.dart';
import '../screens/place_detail_screen.dart';

/// Carrousel horizontal des lieux recommandés (hôtels, restaurants, etc.).
class RecommendedPlacesSection extends StatefulWidget {
  const RecommendedPlacesSection({
    super.key,
    this.categoryKey,
    this.limit = 12,
    this.compact = false,
  });

  /// Filtre catégorie API (`hotel`, `restaurant`, …) ou null = toutes.
  final String? categoryKey;
  final int limit;
  final bool compact;

  @override
  State<RecommendedPlacesSection> createState() => _RecommendedPlacesSectionState();
}

class _RecommendedPlacesSectionState extends State<RecommendedPlacesSection> {
  List<Map<String, dynamic>> _places = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant RecommendedPlacesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryKey != widget.categoryKey ||
        oldWidget.limit != widget.limit) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      double? lat;
      double? lng;
      final pos = await LocationService().getCurrentPositionIfAllowed();
      if (pos != null) {
        lat = pos.latitude;
        lng = pos.longitude;
      }
      final list = await ApiService().getRecommendedPlaces(
        category: widget.categoryKey,
        latitude: lat,
        longitude: lng,
        limit: widget.limit,
      );
      if (!mounted) return;
      setState(() {
        _places = list;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _places = [];
        _loading = false;
      });
    }
  }

  void _openPlace(Map<String, dynamic> point) {
    final color = PoiCategoryFilters.colorForPoint(point);
    final icon = PoiCategoryFilters.iconForPoint(point);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaceDetailScreen(
          point: point,
          color: color,
          icon: icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: widget.compact ? 8 : 12),
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }
    if (_places.isEmpty) return const SizedBox.shrink();

    final cardWidth = widget.compact ? 200.0 : 240.0;
    final imageHeight = widget.compact ? 100.0 : 120.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.recommend_rounded,
              size: 20,
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Nos recommandations',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: widget.compact ? 15 : 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Sélection Teranga Pass · hôtels, restaurants et adresses de confiance',
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: widget.compact ? 168 : 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _places.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final place = _places[index];
              return _RecommendedPlaceCard(
                place: place,
                width: cardWidth,
                imageHeight: imageHeight,
                onTap: () => _openPlace(place),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecommendedPlaceCard extends StatelessWidget {
  const _RecommendedPlaceCard({
    required this.place,
    required this.width,
    required this.imageHeight,
    required this.onTap,
  });

  final Map<String, dynamic> place;
  final double width;
  final double imageHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = (place['name'] ?? '').toString();
    final category = (place['category'] ?? '').toString();
    final distance = (place['distance'] ?? '').toString();
    final pitch = (place['recommendation_pitch'] ?? '').toString().trim();
    final rating = place['rating'];
    final imageUrl = PoiMediaHelpers.thumbnailUrl(place);
    final color = PoiCategoryFilters.colorForPoint(place);
    final icon = PoiCategoryFilters.iconForPoint(place);

    return SizedBox(
      width: width,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8F5EE), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(15),
                      ),
                      child: SizedBox(
                        height: imageHeight,
                        width: double.infinity,
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _imageFallback(icon, color);
                                },
                              )
                            : _imageFallback(icon, color),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Recommandé',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pitch.isNotEmpty ? pitch : category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            if (rating != null) ...[
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '$rating',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            if (distance.isNotEmpty && distance != 'N/A')
                              Expanded(
                                child: Text(
                                  distance,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
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

  Widget _imageFallback(IconData icon, Color color) {
    return Container(
      color: color.withValues(alpha: 0.12),
      child: Center(child: Icon(icon, color: color, size: 36)),
    );
  }
}
