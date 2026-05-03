import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/loading_placeholders.dart';
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
  String? _selectedDayKey;

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
        _selectedDayKey = _buildDayChips(_calendar).firstOrNull?['key'];
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

  String? _eventDateKey(Map<String, dynamic> event) {
    final startRaw = (event['start_date'] ?? event['date'] ?? '').toString().trim();
    if (startRaw.isEmpty) return null;
    final parsed = DateTime.tryParse(startRaw);
    if (parsed != null) {
      final mm = parsed.month.toString().padLeft(2, '0');
      final dd = parsed.day.toString().padLeft(2, '0');
      return '$mm-$dd';
    }
    if (startRaw.length >= 10) {
      final sliced = startRaw.substring(5, 10);
      return RegExp(r'^\d{2}-\d{2}$').hasMatch(sliced) ? sliced : null;
    }
    return null;
  }

  List<Map<String, String>> _buildDayChips(List<Map<String, dynamic>> events) {
    const fallback = [
      {'key': '10-29', 'day': 'MER', 'num': '29'},
      {'key': '10-30', 'day': 'JEU', 'num': '30'},
      {'key': '10-31', 'day': 'VEN', 'num': '31'},
      {'key': '11-01', 'day': 'SAM', 'num': '01'},
      {'key': '11-02', 'day': 'DIM', 'num': '02'},
      {'key': '11-03', 'day': 'LUN', 'num': '03'},
    ];

    if (events.isEmpty) return fallback;

    const weekdayFr = {
      1: 'LUN',
      2: 'MAR',
      3: 'MER',
      4: 'JEU',
      5: 'VEN',
      6: 'SAM',
      7: 'DIM',
    };

    final seen = <String>{};
    final dates = <DateTime>[];
    for (final e in events) {
      final raw = (e['start_date'] ?? e['date'] ?? '').toString().trim();
      final dt = DateTime.tryParse(raw);
      if (dt == null) continue;
      final key = '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      if (seen.add(key)) dates.add(DateTime(dt.year, dt.month, dt.day));
    }
    dates.sort((a, b) => a.compareTo(b));
    if (dates.isEmpty) return fallback;

    return dates.map((d) {
      final key = '${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      return {
        'key': key,
        'day': weekdayFr[d.weekday] ?? '---',
        'num': d.day.toString().padLeft(2, '0'),
      };
    }).toList();
  }

  List<Map<String, dynamic>> _filteredCalendar() {
    if (_selectedDayKey == null || _selectedDayKey!.isEmpty) return _calendar;
    return _calendar.where((e) => _eventDateKey(e) == _selectedDayKey).toList();
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
    final topInset = MediaQuery.of(context).padding.top;
    final dayChips = _buildDayChips(_calendar);
    final selectedKey = _selectedDayKey ?? dayChips.firstOrNull?['key'];
    final filteredCalendar = _filteredCalendar();
    // Keep legacy builders referenced while migration finalizes.
    final keepLegacyBuilders = [_buildCalendarTab, _buildSportsTab, _buildAccessTab];
    assert(keepLegacyBuilders.isNotEmpty);
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EA),
      body: _isLoading
            ? const CardListLoadingSkeleton()
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
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    padding: EdgeInsets.fromLTRB(14, topInset + 10, 14, 16),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(22),
                        bottomRight: Radius.circular(22),
                      ),
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
                            const SizedBox(width: 2),
                            Text(
                              l10n.jojTitle,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
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
                          style: GoogleFonts.robotoSlab(
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
                      children: dayChips
                          .map(
                            (chip) => _JojDayChip(
                              day: chip['day'] ?? '---',
                              num: chip['num'] ?? '--',
                              active: (chip['key'] ?? '') == selectedKey,
                              onTap: () {
                                setState(() {
                                  _selectedDayKey = chip['key'];
                                });
                              },
                            ),
                          )
                          .toList(),
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
                          : filteredCalendar.isEmpty
                          ? [
                              Padding(
                                padding: const EdgeInsets.only(top: 24),
                                child: Text(
                                  'Aucun evenement pour cette date',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ]
                          : filteredCalendar
                                .map((e) => _buildCalendarEvent(e))
                                .toList(),
                    ),
                  ),
                ],
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
    final rawDate = (event['date'] ?? '').toString();
    final startDate = (event['start_date'] ?? '').toString();
    final timeLabel = startDate.length >= 10 ? startDate.substring(5, 10) : '--:--';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5DFD3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 6),
            blurRadius: 12,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showEventDetails(event),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 62,
                  padding: const EdgeInsets.only(right: 10),
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: Color(0xFFE5DFD3))),
                  ),
                  child: Column(
                    children: [
                      Text(
                        timeLabel,
                        style: GoogleFonts.robotoSlab(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'EVENT',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (event['sport'] ?? event['title'] ?? l10n.jojDefaultEventTitle)
                            .toString()
                            .toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFD4A017),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (event['title'] ?? l10n.jojDefaultEventTitle).toString(),
                        style: GoogleFonts.robotoSlab(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            '📍 ${(event['location'] ?? l10n.jojDefaultLocation).toString()}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            rawDate,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEventDetails(Map<String, dynamic> event) {
    final l10n = AppLocalizations.of(context)!;
    final title = (event['title'] ?? l10n.jojDefaultEventTitle).toString();
    final sport = (event['sport'] ?? event['discipline'] ?? '').toString();
    final location = (event['location'] ?? l10n.jojDefaultLocation).toString();
    final startDate = (event['start_date'] ?? event['date'] ?? '').toString();
    final endDate = (event['end_date'] ?? '').toString();
    final description = (event['description'] ?? '').toString().trim();

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
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
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
                const SizedBox(height: 14),
                Text(
                  sport.isEmpty ? title.toUpperCase() : sport.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD4A017),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.robotoSlab(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1F2E),
                  ),
                ),
                const SizedBox(height: 12),
                _detailRow(Icons.location_on_outlined, location),
                _detailRow(
                  Icons.calendar_today_outlined,
                  endDate.isNotEmpty ? '$startDate -> $endDate' : startDate,
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _openEventInMaps(event);
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: Text(
                      l10n.jojSeeOnMap,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1F2E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
  }

  Widget _detailRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEventInMaps(Map<String, dynamic> event) async {
    final query = [
      (event['title'] ?? '').toString().trim(),
      (event['location'] ?? '').toString().trim(),
      'Dakar',
    ].where((e) => e.isNotEmpty).join(' ');
    final encoded = Uri.encodeComponent(query.isEmpty ? 'Dakar' : query);
    final web = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encoded',
    );
    try {
      await launchUrl(web, mode: LaunchMode.externalApplication);
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
    required this.onTap,
    this.active = false,
  });

  final String day;
  final String num;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
