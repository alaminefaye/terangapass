import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/poi_category_filters.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_placeholders.dart';
import '../widgets/map_legend_strip.dart';
import '../services/offline_pack_service.dart';
import '../services/offline_nearby_builder.dart';
import '../widgets/offline_cache_snack.dart';
import 'map_screen.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  static const int _radiusM = 2000;

  double? _userLat;
  double? _userLng;
  String? _locationError;
  List<Map<String, dynamic>> _allPlaces = [];
  List<Map<String, dynamic>> _places = [];
  Map<String, int> _categoryCounts = const {};
  bool _loading = true;
  bool _fallbackOutOfRadius = false;
  String? _apiError;
  int _chipIndex = 0;

  List<PoiCategoryFilter> _chips(AppLocalizations l10n) =>
      PoiCategoryFilters.standard(l10n);

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Set<Marker> _buildNearbyMarkers() {
    if (_userLat == null || _userLng == null) return {};
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('user'),
        position: LatLng(_userLat!, _userLng!),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Vous'),
      ),
    };
    var i = 0;
    for (final p in _places) {
      final lat = _toDouble(p['latitude']);
      final lng = _toDouble(p['longitude']);
      if (lat == null || lng == null) continue;
      final isSponsor = p['is_sponsor'] == true;
      markers.add(
        Marker(
          markerId: MarkerId('place_$i'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSponsor
                ? BitmapDescriptor.hueOrange
                : BitmapDescriptor.hueGreen,
          ),
        ),
      );
      i++;
    }
    return markers;
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _apiError = null;
      _locationError = null;
    });

    try {
      double? lat;
      double? lng;
      String? locErr;
      try {
        final pos = await LocationService().getPositionForListings();
        if (pos != null) {
          lat = pos.latitude;
          lng = pos.longitude;
        }
      } catch (e) {
        locErr = e.toString().replaceAll('Exception: ', '').trim();
        debugPrint('[Nearby] location error: $locErr');
      }

      if (!mounted) return;
      if (lat == null || lng == null) {
        locErr ??= 'Impossible d’obtenir votre position (cause inconnue).';
        setState(() {
          _userLat = null;
          _userLng = null;
          _locationError = locErr;
          _places = [];
          _loading = false;
        });
        return;
      }

      List<Map<String, dynamic>> allPlaces;
      var usedOffline = false;
      var fallbackOutOfRadius = false;
      Map<String, int> counts = const {};
      try {
        final result = await ApiService().getNearby(
          latitude: lat,
          longitude: lng,
          radiusMeters: _radiusM,
          limit: 80,
        );
        allPlaces = result.data
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        fallbackOutOfRadius = result.fallbackOutOfRadius;
        counts = result.categoryCounts.isNotEmpty
            ? result.categoryCounts
            : _computeCategoryCounts(allPlaces);
      } catch (_) {
        final offline = await OfflinePackService().readOfflinePoiList();
        if (offline.isEmpty) rethrow;
        allPlaces = OfflineNearbyBuilder.build(
          userLat: lat,
          userLng: lng,
          radiusMeters: _radiusM,
          poi: offline,
        );
        counts = _computeCategoryCounts(allPlaces);
        usedOffline = true;
      }

      if (!mounted) return;
      setState(() {
        _userLat = lat;
        _userLng = lng;
        _locationError = null;
        _allPlaces = allPlaces;
        _categoryCounts = counts;
        _fallbackOutOfRadius = fallbackOutOfRadius;
        _places = _filterPlacesForChip(_chipIndex);
        _loading = false;
      });
      if (usedOffline) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) showOfflineCacheSnackBar(context);
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _onChipSelected(int i) {
    if (_chipIndex == i) return;
    setState(() {
      _chipIndex = i;
      _places = _filterPlacesForChip(i);
    });
  }

  List<Map<String, dynamic>> _filterPlacesForChip(int chipIndex) {
    final chips = _chips(AppLocalizations.of(context)!);
    final selectedCat =
        chips[chipIndex.clamp(0, chips.length - 1)].categoryKey;
    return _allPlaces
        .where((p) => PoiCategoryFilters.matchesCategory(p, selectedCat))
        .toList();
  }

  String? _phoneUri(Object? phone) {
    final s = phone?.toString().trim();
    if (s == null || s.isEmpty) return null;
    final cleaned = s.replaceAll(RegExp(r'\s'), '');
    return 'tel:$cleaned';
  }

  double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  String _normalizeCategory(Object? value) =>
      value?.toString().trim().toLowerCase() ?? '';

  Map<String, int> _computeCategoryCounts(List<Map<String, dynamic>> places) {
    final counts = <String, int>{};
    for (final p in places) {
      final key = _normalizeCategory(p['category_key'] ?? p['category']);
      if (key.isEmpty) continue;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts;
  }

  int _chipCount(PoiCategoryFilter chip) {
    if (chip.categoryKey == null) {
      return _categoryCounts.values.fold(0, (sum, c) => sum + c);
    }
    return _categoryCounts[chip.categoryKey!] ?? 0;
  }

  String _friendlyLocationError(AppLocalizations l10n) {
    final raw = _locationError?.trim();
    if (raw == null || raw.isEmpty) return l10n.nearbyLocationError;

    final msg = raw.toLowerCase();
    if (msg.contains('services de localisation sont desactives') ||
        msg.contains('services de localisation sont désactivés') ||
        msg.contains('location services are disabled')) {
      return 'La localisation du téléphone est désactivée. Activez le GPS puis réessayez.';
    }
    if (msg.contains('permission') ||
        msg.contains('refuse') ||
        msg.contains('refus') ||
        msg.contains('denied')) {
      return 'La permission de localisation pour Teranga Pass est refusée. Autorisez-la dans les réglages de l’app.';
    }
    if (msg.contains('timeout') ||
        msg.contains('time limit') ||
        msg.contains('timed out')) {
      return 'Position introuvable pour le moment. Vérifiez le GPS et réessayez.';
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chips = _chips(l10n);

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
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: Text(
                            l10n.nearbyTitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.nearbyNearMeTooltip,
                          icon: const Icon(Icons.my_location_rounded, color: Colors.white),
                          onPressed: _refresh,
                        ),
                      ],
                    ),
                    Text(
                      l10n.nearbyRadiusLabel(_radiusM),
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(chips.length, (i) {
                          final selected = _chipIndex == i;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('${chips[i].label} (${_chipCount(chips[i])})'),
                              selected: selected,
                              onSelected: (_) => _onChipSelected(i),
                              selectedColor: const Color(0xFFE6F4EC),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1D603D),
                              ),
                              backgroundColor: Colors.white.withValues(alpha: 0.95),
                              side: BorderSide(
                                color: Colors.white,
                              ),
                              showCheckmark: false,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const TerangaBrandedLoading()
                : _buildBody(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_apiError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_apiError!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _refresh, child: Text(l10n.retry)),
            ],
          ),
        ),
      );
    }

    if (_userLat == null || _userLng == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off_rounded, size: 48, color: Colors.grey[500]),
              const SizedBox(height: 12),
              Text(
                _friendlyLocationError(l10n),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary),
              ),
              if (_locationError != null && _locationError!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _locationError!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (_fallbackOutOfRadius)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8C547)),
              ),
              child: Text(
                'Aucun lieu dans un rayon de $_radiusM m. Voici les plus proches.',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF5C4A00),
                ),
              ),
            ),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(_userLat!, _userLng!),
                  zoom: 13,
                ),
                markers: _buildNearbyMarkers(),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const MapLegendStrip.nearby(),
          const SizedBox(height: 14),
          if (_places.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                l10n.nearbyEmpty,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.textSecondary),
              ),
            )
          else
            ..._places.map((p) => _PlaceCard(place: p, phoneUriBuilder: _phoneUri)),
        ],
      ),
    );
  }
}

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place, required this.phoneUriBuilder});

  final Map<String, dynamic> place;
  final String? Function(Object? phone) phoneUriBuilder;

  double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = (place['name'] ?? '').toString();
    final category = (place['category'] ?? '').toString();
    final distance = (place['distance'] ?? '').toString();
    final address = (place['address'] ?? '').toString();
    final openingHours = (place['opening_hours'] ?? '').toString().trim();
    final isOpenNow = place['is_open_now'] as bool?;
    final sponsor = place['is_sponsor'] == true;
    final phoneUri = phoneUriBuilder(place['phone']);

    final lat = _toDouble(place['latitude']);
    final lng = _toDouble(place['longitude']);
    final hasCoords = lat != null && lng != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: const Color(0xFF1A1F2E),
                    ),
                  ),
                ),
                if (sponsor)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.nearbySponsorBadge,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$category · $distance',
              style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary),
            ),
            if (address.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(address, style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textPrimary)),
            ],
            if (openingHours.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: isOpenNow == true
                        ? Colors.green[700]
                        : (isOpenNow == false ? Colors.red[700] : AppTheme.textSecondary),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${isOpenNow == true ? "Ouvert" : (isOpenNow == false ? "Fermé" : "Horaires")} · $openingHours',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: isOpenNow == true
                            ? Colors.green[700]
                            : (isOpenNow == false ? Colors.red[700] : AppTheme.textSecondary),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                if (hasCoords)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MapScreen(
                              initialLatLng: LatLng(lat, lng),
                              focusedPlaceName: name,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.map_rounded, size: 16),
                      label: const Text('Voir sur la carte'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E8B57),
                        side: const BorderSide(color: Color(0xFF2E8B57)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                if (hasCoords && phoneUri != null) const SizedBox(width: 8),
                if (phoneUri != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final u = Uri.parse(phoneUri);
                        if (await canLaunchUrl(u)) await launchUrl(u);
                      },
                      icon: const Icon(Icons.phone_rounded, size: 16),
                      label: const Text('Appeler'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3A7CA5),
                        side: const BorderSide(color: Color(0xFF3A7CA5)),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
  }
}
