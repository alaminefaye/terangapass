import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_placeholders.dart';

class EmbassiesScreen extends StatefulWidget {
  const EmbassiesScreen({super.key});

  @override
  State<EmbassiesScreen> createState() => _EmbassiesScreenState();
}

class _EmbassiesScreenState extends State<EmbassiesScreen> {
  static const double _fallbackLat = 14.6937;
  static const double _fallbackLng = -17.4441;

  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _embassies = [];
  final TextEditingController _searchController = TextEditingController();
  String _sortMode = 'distance';
  double? _userLat;
  double? _userLng;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
    _loadEmbassies();
  }

  Future<void> _loadUserLocation() async {
    try {
      final position = await LocationService().getCurrentPositionIfAllowed();
      if (!mounted || position == null) return;
      setState(() {
        _userLat = position.latitude;
        _userLng = position.longitude;
      });
    } catch (_) {
      // fallback silently to Dakar center
    }
  }

  double? _distanceKm(Map<String, dynamic> item) {
    final lat = double.tryParse((item['latitude'] ?? '').toString());
    final lng = double.tryParse((item['longitude'] ?? '').toString());
    if (lat == null || lng == null) return null;

    final originLat = _userLat ?? _fallbackLat;
    final originLng = _userLng ?? _fallbackLng;
    final meters = LocationService().calculateDistance(
      originLat,
      originLng,
      lat,
      lng,
    );
    return meters / 1000;
  }

  Future<void> _loadEmbassies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService().getEmbassies();
      if (!mounted) return;
      setState(() {
        _embassies = data.map((e) => e as Map<String, dynamic>).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _openMap(Map<String, dynamic> embassy) async {
    final lat = double.tryParse((embassy['latitude'] ?? '').toString());
    final lng = double.tryParse((embassy['longitude'] ?? '').toString());
    final q = (embassy['address'] ?? embassy['name'] ?? 'Dakar').toString().trim();
    final query = (lat != null && lng != null) ? '$lat,$lng' : q;
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _call(String phone) async {
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  Future<void> _openWebsite(String website) async {
    final uri = Uri.tryParse(website);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showMissionDetails(Map<String, dynamic> item) {
    final name = (item['name'] ?? '-').toString();
    final address = (item['address'] ?? '-').toString();
    final phone = (item['phone'] ?? '').toString().trim();
    final website = (item['website'] ?? '').toString().trim();
    final email = (item['email'] ?? '').toString().trim();
    final missionType = (item['mission_type'] ?? 'embassy').toString();
    final openingHours = (item['opening_hours'] ?? '').toString().trim();
    final rating = double.tryParse((item['rating'] ?? '').toString());
    final lat = (item['latitude'] ?? '').toString();
    final lng = (item['longitude'] ?? '').toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF4F1EA),
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8D2C7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  missionType == 'consulate' ? 'Consulat' : 'Ambassade',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5C5243),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  address,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (openingHours.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Horaires: $openingHours',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
                if (rating != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Note: ${rating.toStringAsFixed(1)} / 5',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
                if (lat.isNotEmpty && lng.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Coordonnees: $lat, $lng',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Tel: $phone',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Email: $email',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _pill('Carte', icon: Icons.map_rounded, onTap: () => _openMap(item)),
                    if (phone.isNotEmpty)
                      _pill('Appeler', icon: Icons.phone_rounded, onTap: () => _call(phone)),
                    if (website.isNotEmpty)
                      _pill('Site web', icon: Icons.language_rounded, onTap: () => _openWebsite(website)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _searchController.text.trim().toLowerCase();
    final filtered = _embassies.where((e) {
      if (q.isEmpty) return true;
      final name = (e['name'] ?? '').toString().toLowerCase();
      final address = (e['address'] ?? '').toString().toLowerCase();
      return name.contains(q) || address.contains(q);
    }).toList()
      ..sort((a, b) {
        if (_sortMode == 'rating') {
          final ar = double.tryParse((a['rating'] ?? '').toString()) ?? -1;
          final br = double.tryParse((b['rating'] ?? '').toString()) ?? -1;
          return br.compareTo(ar);
        }
        if (_sortMode == 'distance') {
          final ad = _distanceKm(a) ?? 999999;
          final bd = _distanceKm(b) ?? 999999;
          return ad.compareTo(bd);
        }
        final an = (a['name'] ?? '').toString().toLowerCase();
        final bn = (b['name'] ?? '').toString().toLowerCase();
        return an.compareTo(bn);
      });
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EA),
      body: SafeArea(
        child: _isLoading
            ? const CardListLoadingSkeleton()
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                  ),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFF1A1F2E),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Ambassades',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: const Color(0xFF1A1F2E),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                      itemCount: filtered.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFE5DFD3)),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (_) => setState(() {}),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: const Icon(Icons.search_rounded, size: 18),
                                      hintText: 'Rechercher un pays...',
                                      hintStyle: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _sortPill(
                                      label: 'Distance',
                                      active: _sortMode == 'distance',
                                      onTap: () => setState(() => _sortMode = 'distance'),
                                    ),
                                    const SizedBox(width: 6),
                                    _sortPill(
                                      label: 'Note',
                                      active: _sortMode == 'rating',
                                      onTap: () => setState(() => _sortMode = 'rating'),
                                    ),
                                    const SizedBox(width: 6),
                                    _sortPill(
                                      label: 'A-Z',
                                      active: _sortMode == 'name',
                                      onTap: () => setState(() => _sortMode = 'name'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }

                        final item = filtered[index - 1];
                        final name = (item['name'] ?? '-').toString();
                        final address = (item['address'] ?? '-').toString();
                        final phone = (item['phone'] ?? '').toString().trim();
                        final missionType = (item['mission_type'] ?? 'embassy').toString();
                        final openingHours = (item['opening_hours'] ?? '').toString().trim();
                        final rating = double.tryParse((item['rating'] ?? '').toString());
                        final distKm = _distanceKm(item);

                        return GestureDetector(
                          onTap: () => _showMissionDetails(item),
                          child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (missionType == 'consulate')
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECE6DC),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        'Consulat',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF5C5243),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                address,
                                style: GoogleFonts.poppins(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (openingHours.isNotEmpty)
                                Text(
                                  openingHours,
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              if (rating != null)
                                Text(
                                  'Note: ${rating.toStringAsFixed(1)} / 5',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              if (distKm != null)
                                Text(
                                  'Distance: ${distKm.toStringAsFixed(1)} km',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              if (phone.isNotEmpty)
                                Text(
                                  'Tel: $phone',
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _pill('Urgence', urgent: true),
                                  _pill('Carte', icon: Icons.map_rounded, onTap: () => _openMap(item)),
                                  if (phone.isNotEmpty)
                                    _pill('Appeler', icon: Icons.phone_rounded, onTap: () => _call(phone)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Spacer(),
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                                ],
                              ),
                            ],
                          ),
                        ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _pill(
    String text, {
    IconData? icon,
    bool urgent = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: urgent ? const Color(0xFFFAE6E1) : const Color(0xFFF4F1EA),
          borderRadius: BorderRadius.circular(999),
          border: urgent ? null : Border.all(color: const Color(0xFFE5DFD3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: urgent ? const Color(0xFFC73E1D) : const Color(0xFF1A1F2E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortPill({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1A1F2E) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE5DFD3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : const Color(0xFF1A1F2E),
          ),
        ),
      ),
    );
  }
}

