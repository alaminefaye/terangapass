import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'currency_converter_screen.dart';

class JOJInfoScreen extends StatefulWidget {
  const JOJInfoScreen({super.key});

  @override
  State<JOJInfoScreen> createState() => _JOJInfoScreenState();
}

class _JOJInfoScreenState extends State<JOJInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _sites = [];
  List<Map<String, dynamic>> _sports = [];
  List<Map<String, dynamic>> _calendar = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      final sites = await apiService.getCompetitionSites();
      final calendar = await apiService.getCompetitionCalendar();

      if (!mounted) return;
      setState(() {
        _sites = sites.map((s) => s as Map<String, dynamic>).toList();
        _calendar = calendar.map((c) => c as Map<String, dynamic>).toList();
        _sports = _deriveSportsFromCalendar(_calendar);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sites = [];
        _calendar = [];
        _sports = [];
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

  List<Map<String, dynamic>> _deriveSportsFromCalendar(
    List<Map<String, dynamic>> calendar,
  ) {
    final names = <String>{};
    for (final event in calendar) {
      final raw =
          event['sport'] ?? event['sport_name'] ?? event['discipline'] ?? '';
      final name = raw.toString().trim();
      if (name.isNotEmpty) names.add(name);
    }
    final sorted = names.toList()..sort((a, b) => a.compareTo(b));
    return [
      for (var i = 0; i < sorted.length; i++) {'id': i + 1, 'name': sorted[i]},
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Keep legacy builders referenced while migration finalizes.
    final keepLegacyBuilders = [_buildCalendarTab, _buildSportsTab, _buildAccessTab];
    assert(keepLegacyBuilders.isNotEmpty);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EA),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                  ),
                ),
              )
            : Column(
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A1F2E), Color(0xFF2A2F4E)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              l10n.jojTitle,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: 'Convertisseur',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const CurrencyConverterScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.currency_exchange_rounded,
                                color: Color(0xFFD4A017),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'JEUX OLYMPIQUES DE LA JEUNESSE',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFD4A017),
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dakar 2026',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '31 octobre -> 13 novembre',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 58,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      scrollDirection: Axis.horizontal,
                      children: const [
                        _JojDayChip(day: 'MER', num: '29'),
                        _JojDayChip(day: 'JEU', num: '30'),
                        _JojDayChip(day: 'VEN', num: '31', active: true),
                        _JojDayChip(day: 'SAM', num: '01'),
                        _JojDayChip(day: 'DIM', num: '02'),
                        _JojDayChip(day: 'LUN', num: '03'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                      children: _calendar.isEmpty
                          ? [
                              Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: Text(
                                  l10n.jojCalendarComingSoon,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ]
                          : _calendar.map((e) => _buildCalendarEvent(e)).toList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCalendarTab() {
    final l10n = AppLocalizations.of(context)!;
    if (_calendar.isEmpty) {
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
                  Icons.calendar_today_outlined,
                  size: 64,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.jojCalendarComingSoon,
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      children: [..._calendar.map((event) => _buildCalendarEvent(event))],
    );
  }

  Widget _buildCalendarEvent(Map<String, dynamic> event) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFD4A017).withValues(alpha: 0.15),
                    const Color(0xFFD4A017).withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.event, color: Color(0xFFD4A017), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (event['title'] ?? l10n.jojDefaultEventTitle).toString(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event['date'] ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportsTab() {
    final l10n = AppLocalizations.of(context)!;
    if (_sports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
                  Icons.sports_rounded,
                  size: 64,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.jojNoSportsAvailable,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: _sports.length,
      itemBuilder: (context, index) {
        final sport = _sports[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, 8),
                blurRadius: 16,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A017).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sports_soccer,
                        size: 32,
                        color: const Color(0xFFD4A017),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      sport['name'] as String,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildAccessTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
      children: [..._sites.map((site) => _buildSiteCard(site))],
    );
  }

  Widget _buildSiteCard(Map<String, dynamic> site) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFD4A017).withValues(alpha: 0.15),
                        const Color(0xFFD4A017).withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.stadium_rounded,
                    color: const Color(0xFFD4A017),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        site['name'] as String,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            site['location'] as String? ??
                                l10n.jojDefaultLocation,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month,
                    size: 14,
                    color: AppTheme.primaryYellow,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    site['dates'] as String? ?? l10n.jojDatesComingSoon,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryYellow,
                    ),
                  ),
                ],
              ),
            ),
            if (site['description'] != null) ...[
              const SizedBox(height: 16),
              Text(
                site['description'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF1A1F2E), const Color(0xFF2A2F4E)],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _openSiteInMaps(site);
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.map_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          l10n.jojSeeOnMap,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSiteInMaps(Map<String, dynamic> site) async {
    final l10n = AppLocalizations.of(context)!;
    double? toDouble(Object? v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return double.tryParse(s);
    }

    final lat = toDouble(site['latitude'] ?? site['lat']);
    final lng = toDouble(site['longitude'] ?? site['lng']);

    final name = site['name']?.toString().trim();
    final location = site['location']?.toString().trim();
    final query = [
      if (name != null && name.isNotEmpty) name,
      if (location != null && location.isNotEmpty) location,
    ].join(' ');

    try {
      if (lat != null && lng != null) {
        final label = Uri.encodeComponent(
          query.isEmpty ? l10n.jojDestinationFallback : query,
        );
        final googleApp = Uri.parse(
          'comgooglemaps://?q=$lat,$lng($label)&center=$lat,$lng&zoom=16',
        );
        final geo = Uri.parse('geo:$lat,$lng?q=$lat,$lng($label)');
        final web = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
        );

        if (await canLaunchUrl(googleApp)) {
          await launchUrl(googleApp, mode: LaunchMode.externalApplication);
          return;
        }
        if (await canLaunchUrl(geo)) {
          await launchUrl(geo, mode: LaunchMode.externalApplication);
          return;
        }
        await launchUrl(web, mode: LaunchMode.externalApplication);
        return;
      }

      final q = Uri.encodeComponent(
        query.isEmpty ? l10n.jojDefaultLocation : query,
      );
      final googleWeb = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$q',
      );
      await launchUrl(googleWeb, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.openMapError,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
    }
  }
}

class _JojDayChip extends StatelessWidget {
  const _JojDayChip({
    required this.day,
    required this.num,
    this.active = false,
  });

  final String day;
  final String num;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF1A1F2E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5DFD3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: active ? Colors.white70 : AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            num,
            style: GoogleFonts.poppins(
              fontSize: 17,
              color: active ? Colors.white : const Color(0xFF1A1F2E),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
