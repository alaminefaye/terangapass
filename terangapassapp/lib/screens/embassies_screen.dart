import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../services/offline_pack_service.dart';
import '../widgets/offline_cache_snack.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_theme_extensions.dart';
import '../widgets/loading_placeholders.dart';
import 'map_screen.dart';

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
      final offline = await OfflinePackService().readOfflineEmbassiesList();
      if (offline.isNotEmpty) {
        setState(() {
          _embassies = offline;
          _error = null;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) showOfflineCacheSnackBar(context);
        });
      } else {
        setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openMap(Map<String, dynamic> embassy) {
    final lat = double.tryParse((embassy['latitude'] ?? '').toString());
    final lng = double.tryParse((embassy['longitude'] ?? '').toString());
    final name = (embassy['name'] ?? '').toString().trim();
    final address = (embassy['address'] ?? '').toString().trim();
    if (lat != null && lng != null) {
      MapScreen.push(
        context,
        initialLatLng: LatLng(lat, lng),
        focusedPlaceName: name,
      );
    } else {
      MapScreen.push(
        context,
        initialQuery: address.isNotEmpty ? address : name,
        requireAuth: true,
      );
    }
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
    final l10n = AppLocalizations.of(context)!;
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
        final sheetTp = context.tp;
        return Container(
          decoration: BoxDecoration(
            color: sheetTp.scaffoldAlt,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            border: Border(top: BorderSide(color: sheetTp.border)),
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
                      color: sheetTp.border,
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
                    color: sheetTp.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  missionType == 'consulate'
                      ? l10n.embassyTypeConsulate
                      : l10n.embassyTypeEmbassy,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: sheetTp.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  address,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: sheetTp.textSecondary,
                  ),
                ),
                if (openingHours.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.embassyOpeningHours(openingHours),
                    style: GoogleFonts.poppins(fontSize: 12, color: sheetTp.textSecondary),
                  ),
                ],
                if (rating != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.embassyRating(rating.toStringAsFixed(1)),
                    style: GoogleFonts.poppins(fontSize: 12, color: sheetTp.textSecondary),
                  ),
                ],
                if (lat.isNotEmpty && lng.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.embassyCoordinates('$lat, $lng'),
                    style: GoogleFonts.poppins(fontSize: 12, color: sheetTp.textSecondary),
                  ),
                ],
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.embassyPhone(phone),
                    style: GoogleFonts.poppins(fontSize: 12, color: sheetTp.textSecondary),
                  ),
                ],
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.embassyEmail(email),
                    style: GoogleFonts.poppins(fontSize: 12, color: sheetTp.textSecondary),
                  ),
                ],
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _pill(l10n.embassyActionMap, icon: Icons.map_rounded, onTap: () => _openMap(item)),
                    if (phone.isNotEmpty)
                      _pill(l10n.call, icon: Icons.phone_rounded, onTap: () => _call(phone)),
                    if (website.isNotEmpty)
                      _pill(l10n.embassyActionWebsite, icon: Icons.language_rounded, onTap: () => _openWebsite(website)),
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
    final l10n = AppLocalizations.of(context)!;
    final tp = context.tp;
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
      backgroundColor: tp.scaffoldAlt,
      body: SafeArea(
        child: _isLoading
            ? const TerangaBrandedLoading()
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: tp.textSecondary),
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
                          icon: Icon(
                            Icons.arrow_back_rounded,
                            color: tp.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          l10n.embassiesTitle,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: tp.textPrimary,
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
                                    color: tp.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: tp.border),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (_) => setState(() {}),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(Icons.search_rounded, size: 18, color: tp.textSecondary),
                                      hintText: l10n.embassiesSearchHint,
                                      hintStyle: GoogleFonts.poppins(fontSize: 12, color: tp.textSecondary),
                                    ),
                                    style: GoogleFonts.poppins(fontSize: 13, color: tp.textPrimary),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _sortPill(
                                      label: l10n.embassiesSortDistance,
                                      active: _sortMode == 'distance',
                                      onTap: () => setState(() => _sortMode = 'distance'),
                                    ),
                                    const SizedBox(width: 6),
                                    _sortPill(
                                      label: l10n.embassiesSortRating,
                                      active: _sortMode == 'rating',
                                      onTap: () => setState(() => _sortMode = 'rating'),
                                    ),
                                    const SizedBox(width: 6),
                                    _sortPill(
                                      label: l10n.embassiesSortName,
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
                            color: tp.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: tp.border),
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
                                        color: tp.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (missionType == 'consulate')
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: tp.chipBackground,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        l10n.embassyTypeConsulate,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: tp.textSecondary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                address,
                                style: GoogleFonts.poppins(
                                  color: tp.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (openingHours.isNotEmpty)
                                Text(
                                  openingHours,
                                  style: GoogleFonts.poppins(
                                    color: tp.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              if (rating != null)
                                Text(
                                  l10n.embassyRating(rating.toStringAsFixed(1)),
                                  style: GoogleFonts.poppins(
                                    color: tp.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              if (distKm != null)
                                Text(
                                  l10n.embassyDistanceLabel(
                                    '${distKm.toStringAsFixed(1)} km',
                                  ),
                                  style: GoogleFonts.poppins(
                                    color: tp.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              if (phone.isNotEmpty)
                                Text(
                                  l10n.embassyPhone(phone),
                                  style: GoogleFonts.poppins(
                                    color: tp.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _pill(l10n.embassyUrgent, urgent: true),
                                  _pill(l10n.embassyActionMap, icon: Icons.map_rounded, onTap: () => _openMap(item)),
                                  if (phone.isNotEmpty)
                                    _pill(l10n.call, icon: Icons.phone_rounded, onTap: () => _call(phone)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Spacer(),
                                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: tp.textSecondary),
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
    final tp = context.tp;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: urgent
              ? AppTheme.primaryRed.withValues(alpha: tp.isDark ? 0.2 : 0.12)
              : tp.chipBackground,
          borderRadius: BorderRadius.circular(999),
          border: urgent ? null : Border.all(color: tp.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: urgent ? AppTheme.primaryRed : tp.textPrimary),
              const SizedBox(width: 4),
            ],
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: urgent ? AppTheme.primaryRed : tp.textPrimary,
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
    final tp = context.tp;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryGreen : tp.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: active ? AppTheme.primaryGreen : tp.border),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : tp.textPrimary,
          ),
        ),
      ),
    );
  }
}

