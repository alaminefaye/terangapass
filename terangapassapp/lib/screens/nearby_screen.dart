import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_placeholders.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _ChipDef {
  const _ChipDef(this.label, this.categoryKey);
  final String label;
  final String? categoryKey;
}

class _NearbyScreenState extends State<NearbyScreen> {
  static const int _radiusM = 2000;

  final MapController _mapController = MapController();

  double? _userLat;
  double? _userLng;
  String? _locationError;
  List<Map<String, dynamic>> _places = [];
  bool _loading = true;
  String? _apiError;
  int _chipIndex = 0;

  List<_ChipDef> _chips(AppLocalizations l10n) => [
    _ChipDef(l10n.nearbyAll, null),
    const _ChipDef('Restos', 'restaurant'),
    const _ChipDef('Banques', 'bank'),
    const _ChipDef('Stations', 'gas_station'),
    const _ChipDef('Boutiques', 'shop'),
    const _ChipDef('Pharmacies', 'pharmacy'),
  ];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _apiError = null;
    });

    try {
      double? lat;
      double? lng;
      String? locErr;
      try {
        final pos = await LocationService().getCurrentPosition();
        lat = pos.latitude;
        lng = pos.longitude;
      } catch (e) {
        locErr = e.toString().replaceAll('Exception: ', '').trim();
      }

      if (!mounted) return;
      if (lat == null || lng == null) {
        setState(() {
          _userLat = null;
          _userLng = null;
          _locationError = locErr;
          _places = [];
          _loading = false;
        });
        return;
      }

      final chips = _chips(AppLocalizations.of(context)!);
      final cat = chips[_chipIndex.clamp(0, chips.length - 1)].categoryKey;

      final raw = await ApiService().getNearby(
        latitude: lat,
        longitude: lng,
        radiusMeters: _radiusM,
        category: cat,
      );

      if (!mounted) return;
      setState(() {
        _userLat = lat;
        _userLng = lng;
        _locationError = null;
        _places = raw.map((e) => e as Map<String, dynamic>).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _onChipSelected(int i) async {
    if (_chipIndex == i) return;
    setState(() => _chipIndex = i);
    await _refresh();
  }

  String? _phoneUri(Object? phone) {
    final s = phone?.toString().trim();
    if (s == null || s.isEmpty) return null;
    final cleaned = s.replaceAll(RegExp(r'\s'), '');
    return 'tel:$cleaned';
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
                              label: Text(chips[i].label),
                              selected: selected,
                              onSelected: (_) => _onChipSelected(i),
                              selectedColor: Colors.white,
                              labelStyle: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected ? AppTheme.primaryGreen : Colors.white,
                              ),
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.35),
                              ),
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
                ? const CardListLoadingSkeleton()
                : _buildBody(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_locationError != null || _userLat == null || _userLng == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off_rounded, size: 48, color: Colors.grey[500]),
              const SizedBox(height: 12),
              Text(
                l10n.nearbyLocationError,
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

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 200,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(_userLat!, _userLng!),
                  initialZoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.terangapass.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(_userLat!, _userLng!),
                        width: 36,
                        height: 36,
                        child: const Icon(Icons.person_pin_circle, color: Color(0xFF1565C0), size: 36),
                      ),
                      ..._places.map((p) {
                        final lat = (p['latitude'] as num?)?.toDouble();
                        final lng = (p['longitude'] as num?)?.toDouble();
                        if (lat == null || lng == null) return null;
                        return Marker(
                          point: LatLng(lat, lng),
                          width: 32,
                          height: 32,
                          child: Icon(
                            Icons.place_rounded,
                            color: (p['is_sponsor'] == true) ? Colors.amber[800] : AppTheme.primaryGreen,
                            size: 32,
                          ),
                        );
                      }).whereType<Marker>(),
                    ],
                  ),
                ],
              ),
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = (place['name'] ?? '').toString();
    final category = (place['category'] ?? '').toString();
    final distance = (place['distance'] ?? '').toString();
    final address = (place['address'] ?? '').toString();
    final sponsor = place['is_sponsor'] == true;
    final phoneUri = phoneUriBuilder(place['phone']);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: phoneUri == null
            ? null
            : () async {
                final u = Uri.parse(phoneUri);
                if (await canLaunchUrl(u)) await launchUrl(u);
              },
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
            ],
          ),
        ),
      ),
    );
  }
}
