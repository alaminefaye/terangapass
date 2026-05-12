import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'map_screen.dart';
import 'package:latlong2/latlong.dart';

class PlaceDetailScreen extends StatefulWidget {
  const PlaceDetailScreen({
    super.key,
    required this.point,
    required this.color,
    required this.icon,
  });

  final Map<String, dynamic> point;
  final Color color;
  final IconData icon;

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final _api = ApiService();

  List<Map<String, dynamic>> _reviews = [];
  double? _averageRating;
  int _reviewCount = 0;
  bool _reviewsLoaded = false;
  bool _reviewsLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  int? get _partnerId {
    final id = widget.point['id'];
    if (id == null) return null;
    return int.tryParse(id.toString());
  }

  Future<void> _loadReviews() async {
    final id = _partnerId;
    if (id == null) {
      setState(() => _reviewsLoaded = true);
      return;
    }
    setState(() => _reviewsLoading = true);
    try {
      final result = await _api.getPoiReviews(id);
      final list = (result['data'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [];
      if (mounted) {
        setState(() {
          _reviews = list;
          _averageRating = (result['average'] as num?)?.toDouble();
          _reviewCount = (result['count'] as num?)?.toInt() ?? list.length;
          _reviewsLoaded = true;
          _reviewsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _reviewsLoaded = true;
          _reviewsLoading = false;
        });
      }
    }
  }

  Future<void> _openMaps() async {
    final name = widget.point['name']?.toString().trim() ?? '';
    final address = widget.point['address']?.toString().trim() ?? '';
    final lat = _toDouble(widget.point['latitude'] ?? widget.point['lat']);
    final lng = _toDouble(widget.point['longitude'] ?? widget.point['lng']);

    if (lat != null && lng != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MapScreen(
            initialLatLng: LatLng(lat, lng),
            focusedPlaceName: name,
          ),
        ),
      );
    } else {
      final query = address.isNotEmpty ? address : name;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MapScreen(
            initialQuery: query.isEmpty ? 'Dakar' : query,
          ),
        ),
      );
    }
  }

  Future<void> _callPhone(String phone) async {
    try {
      await launchUrl(Uri(scheme: 'tel', path: phone));
    } catch (_) {}
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  void _openPhotoPreview(List<String> photos, int initialIndex) {
    if (photos.isEmpty) return;
    final safe = initialIndex.clamp(0, photos.length - 1);
    final pageController = PageController(initialPage: safe);
    int current = safe;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setS) {
            return Material(
              color: Colors.transparent,
              child: SafeArea(
                child: Stack(
                  children: [
                    PageView.builder(
                      controller: pageController,
                      itemCount: photos.length,
                      onPageChanged: (i) => setS(() => current = i),
                      itemBuilder: (context, index) => Center(
                        child: InteractiveViewer(
                          minScale: 1,
                          maxScale: 4,
                          child: Image.network(
                            photos[index],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.broken_image_rounded,
                              color: Colors.white70,
                              size: 70,
                            ),
                          ),
                        ),
                      ),
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
                          icon: const Icon(Icons.close_rounded,
                              color: Colors.white),
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
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${current + 1}/${photos.length}',
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

  void _openAddReviewDialog() {
    final id = _partnerId;
    if (id == null) return;

    int selectedRating = 0;
    final commentController = TextEditingController();
    bool submitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setD) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Laisser un avis',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.point['name']?.toString() ?? '',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppTheme.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    // Star picker
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (i) {
                          return GestureDetector(
                            onTap: () => setD(() => selectedRating = i + 1),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                i < selectedRating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 36,
                                color: Colors.amber,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Votre commentaire (optionnel)…',
                        hintStyle: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFFF5F7FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(14),
                      ),
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.of(dialogContext).pop(),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F7FA),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  'Annuler',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: submitting || selectedRating == 0
                                ? null
                                : () async {
                                    setD(() => submitting = true);
                                    try {
                                      await _api.addPoiReview(
                                        id,
                                        rating: selectedRating,
                                        comment: commentController.text.trim(),
                                      );
                                      if (dialogContext.mounted) {
                                        Navigator.of(dialogContext).pop();
                                      }
                                      _loadReviews();
                                    } catch (e) {
                                      setD(() => submitting = false);
                                      if (dialogContext.mounted) {
                                        ScaffoldMessenger.of(dialogContext)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                            'Erreur : impossible de publier l\'avis.',
                                            style: GoogleFonts.poppins(
                                                fontSize: 13),
                                          ),
                                          backgroundColor: Colors.red,
                                        ));
                                      }
                                    }
                                  },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                gradient: selectedRating == 0
                                    ? const LinearGradient(
                                        colors: [Colors.grey, Colors.grey])
                                    : const LinearGradient(
                                        colors: [
                                          AppTheme.primaryGreen,
                                          Color(0xFF008C5E),
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: submitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Publier',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _infoTile({
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

  @override
  Widget build(BuildContext context) {
    final point = widget.point;
    final color = widget.color;

    final name = (point['name'] as String? ?? '').trim();
    final category = (point['category'] as String? ?? '').trim();
    final address = point['address'] as String?;
    final phone = point['phone'] as String?;
    final description = point['description'] as String?;
    final openingHours = point['opening_hours'] as String?;
    final website = point['website'] as String?;
    final transport = point['transport'] as String?;
    final duration = point['duration'] as String?;
    final rawTags = point['tags'];
    final tags = rawTags is List
        ? rawTags.map((e) => e.toString()).toList()
        : <String>[];
    final rawPhotos = point['photos'];
    final photos = rawPhotos is List
        ? rawPhotos.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : <String>[];
    final iconUrl = point['icon_url'] as String?;
    final distanceVal = point['distance'] as String?;

    // Utilise la note backend si disponible, sinon celle du point
    final displayRating = _averageRating ?? _toDouble(point['rating']);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // ── App bar avec dégradé ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: color,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 16),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color,
                      color.withValues(alpha: 0.75),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: iconUrl != null
                              ? Image.network(
                                  iconUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(widget.icon,
                                          color: Colors.white, size: 36),
                                )
                              : Icon(widget.icon,
                                  color: Colors.white, size: 36),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Contenu ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + category + rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                category,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (displayRating != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 18, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(
                                    displayRating.toStringAsFixed(1),
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              if (_reviewCount > 0)
                                Text(
                                  '$_reviewCount avis',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Tags
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: color.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            tag,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: color,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Photo gallery
                  if (photos.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Galerie photos',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 110,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: photos.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () => _openPhotoPreview(photos, index),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Image.network(
                                photos[index],
                                width: 150,
                                height: 110,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  width: 150,
                                  height: 110,
                                  color: Colors.white,
                                  child: const Icon(Icons.image),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  // Info tiles
                  const SizedBox(height: 20),
                  if (distanceVal != null && distanceVal.isNotEmpty)
                    _infoTile(
                      icon: Icons.near_me_rounded,
                      color: AppTheme.primaryGreen,
                      label: 'Distance',
                      value: distanceVal,
                    ),
                  if (address != null && address.isNotEmpty)
                    _infoTile(
                      icon: Icons.location_on_rounded,
                      color: Colors.red,
                      label: 'Adresse',
                      value: address,
                    ),
                  if (phone != null && phone.isNotEmpty)
                    _infoTile(
                      icon: Icons.phone_rounded,
                      color: Colors.blue,
                      label: 'Téléphone',
                      value: phone,
                    ),
                  if (openingHours != null && openingHours.isNotEmpty)
                    _infoTile(
                      icon: Icons.access_time_rounded,
                      color: Colors.orange,
                      label: 'Horaires',
                      value: openingHours,
                    ),
                  if (duration != null && duration.isNotEmpty)
                    _infoTile(
                      icon: Icons.hourglass_bottom_rounded,
                      color: Colors.purple,
                      label: 'Durée estimée',
                      value: duration,
                    ),
                  if (transport != null && transport.isNotEmpty)
                    _infoTile(
                      icon: Icons.directions_rounded,
                      color: Colors.teal,
                      label: 'Comment s\'y rendre',
                      value: transport,
                    ),
                  if (website != null && website.isNotEmpty)
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri.tryParse(website);
                        if (uri != null) {
                          try {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          } catch (_) {}
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.language_rounded,
                                  size: 15, color: Colors.indigo),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Site web',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    website,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.indigo,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.open_in_new_rounded,
                                size: 16, color: Colors.indigo),
                          ],
                        ),
                      ),
                    ),

                  // Description
                  if (description != null && description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Description',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
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
                  ],

                  // Action buttons
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _openMaps,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryGreen, Color(0xFF008C5E)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.map_outlined,
                              color: Colors.white, size: 20),
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
                      onTap: () => _callPhone(phone),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.blue.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.phone_rounded,
                                color: Colors.blue, size: 20),
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

                  // ── Reviews section ───────────────────────────────────
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Avis & commentaires',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (_reviewsLoaded && _reviews.isNotEmpty)
                        Text(
                          '${_averageRating?.toStringAsFixed(1) ?? ''} ★  $_reviewCount avis',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_reviewsLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (_partnerId == null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Les avis ne sont pas disponibles pour ce lieu.',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    )
                  else if (_reviewsLoaded && _reviews.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Aucun avis pour le moment.\nSoyez le premier à laisser un commentaire !',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ..._reviews.map((review) {
                      final r =
                          (review['rating'] as num?)?.toInt() ?? 0;
                      final comment =
                          review['comment'] as String? ?? '';
                      final author =
                          review['author'] as String? ?? 'Anonyme';
                      final dateStr =
                          review['created_at'] as String? ?? '';
                      String formattedDate = '';
                      try {
                        final dt =
                            DateTime.parse(dateStr).toLocal();
                        formattedDate =
                            '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
                      } catch (_) {}
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      author.isNotEmpty
                                          ? author[0].toUpperCase()
                                          : '?',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        author,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          ...List.generate(
                                            5,
                                            (i) => Icon(
                                              i < r
                                                  ? Icons.star_rounded
                                                  : Icons
                                                      .star_outline_rounded,
                                              size: 13,
                                              color: Colors.amber,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                if (formattedDate.isNotEmpty)
                                  Text(
                                    formattedDate,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                            if (comment.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                comment,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppTheme.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 10),
                  if (_partnerId != null)
                    GestureDetector(
                      onTap: _openAddReviewDialog,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Laisser un avis',
                              style: GoogleFonts.poppins(
                                color: Colors.amber.shade700,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
