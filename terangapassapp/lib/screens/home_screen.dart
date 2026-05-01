import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../constants/api_constants.dart';
import '../services/api_service.dart';
import 'sos_screen.dart';
import 'medical_alert_screen.dart';
import 'incident_report_screen.dart';
import 'profile_screen.dart';
import 'audio_announcements_screen.dart';
import 'joj_info_screen.dart';
import 'transport_screen.dart';
import 'tourism_screen.dart';
import 'map_screen.dart';
import 'notifications_screen.dart';
import 'ai_assistant_screen.dart';
import 'embassies_screen.dart';
import 'currency_converter_screen.dart';

enum _HomeFeatureId {
  audioAnnouncements,
  touristInfo,
  competitionSites,
  competitions,
  transport,
  incidentReport,
}

enum _HomeNavId { home, medicalAlert, aiAssistant, incidentReport, profile }
enum _HomePillarId { discover, move, joj, help }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  static const String _readNotificationIdsKey = 'read_notification_ids';

  Map<String, dynamic>? _officialAnnouncement;
  bool _isLoadingOfficialAnnouncement = false;
  final AudioPlayer _officialPlayer = AudioPlayer();
  bool _isOfficialPlaying = false;
  Duration _officialDuration = Duration.zero;
  Duration _officialPosition = Duration.zero;
  double _officialProgress = 0.0;
  String? _officialAudioUrl;
  List<Map<String, dynamic>> _competitionSites = [];
  bool _isLoadingCompetitionSites = false;
  String? _competitionSitesError;
  final MapController _jojMapController = MapController();
  int _unreadNotificationsCount = 0;
  late final AnimationController _aiPulseController;
  bool _isNavigating = false;
  int _jojDaysRemaining = 183;
  String _jojDateLabel = 'Dakar 2026 - 31 oct -> 13 nov';
  final TextEditingController _homeSearchController = TextEditingController();

  Future<void> _navigateTo(BuildContext context, _HomeNavId id) async {
    if (_isNavigating) return;
    setState(() {
      _isNavigating = true;
    });
    try {
      switch (id) {
        case _HomeNavId.home:
          return;
        case _HomeNavId.medicalAlert:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MedicalAlertScreen()),
          );
          return;
        case _HomeNavId.aiAssistant:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AIAssistantScreen()),
          );
          return;
        case _HomeNavId.incidentReport:
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const IncidentReportScreen(),
            ),
          );
          return;
        case _HomeNavId.profile:
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
          return;
      }
    } catch (e, st) {
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st));
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _aiPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _aiPulseController.repeat(reverse: true);
    _bindOfficialPlayerListeners();
    _loadOfficialAnnouncement();
    _loadCompetitionSites();
    _loadUnreadNotificationsCount();
    _loadJojCountdown();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _homeSearchController.dispose();
    _aiPulseController.dispose();
    _officialPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadOfficialAnnouncement();
      _loadCompetitionSites();
      _loadUnreadNotificationsCount();
      _loadJojCountdown();
    }
  }

  Future<void> _loadJojCountdown() async {
    try {
      final api = ApiService();
      final data = await api.getJojCountdown();
      if (!mounted) return;
      final days = data['days_remaining'];
      final label = (data['label'] ?? '').toString().trim();
      setState(() {
        if (days is int) {
          _jojDaysRemaining = days;
        } else if (days is num) {
          _jojDaysRemaining = days.toInt();
        }
        if (label.isNotEmpty) {
          _jojDateLabel = label;
        }
      });
    } catch (_) {
      // Garde les valeurs fallback de maquette.
    }
  }

  Future<void> _loadOfficialAnnouncement() async {
    if (_isLoadingOfficialAnnouncement) return;
    setState(() {
      _isLoadingOfficialAnnouncement = true;
    });

    try {
      final apiService = ApiService();
      final announcements = await apiService.getAudioAnnouncements();
      if (mounted) {
        setState(() {
          final next = announcements.isNotEmpty
              ? (announcements.first as Map<String, dynamic>)
              : null;

          final nextUrl = _extractAudioUrl(next);
          if (nextUrl != null && nextUrl != _officialAudioUrl) {
            _resetOfficialPlayer();
            _officialAudioUrl = nextUrl;
          } else if (next == null && _officialAnnouncement != null) {
            _resetOfficialPlayer();
            _officialAudioUrl = null;
          }

          _officialAnnouncement = next;
        });
      }
    } catch (_) {
      if (mounted) {
        _resetOfficialPlayer();
        _officialAudioUrl = null;
        setState(() {
          _officialAnnouncement = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOfficialAnnouncement = false;
        });
      }
    }
  }

  Future<void> _loadCompetitionSites() async {
    if (_isLoadingCompetitionSites) return;
    setState(() {
      _isLoadingCompetitionSites = true;
      _competitionSitesError = null;
    });

    try {
      final apiService = ApiService();
      final sites = await apiService.getCompetitionSites();
      if (mounted) {
        setState(() {
          _competitionSites = sites
              .map((s) => s as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _competitionSites = [];
          _competitionSitesError = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCompetitionSites = false;
        });
      }
    }
  }

  Future<void> _loadUnreadNotificationsCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readIds = (prefs.getStringList(_readNotificationIdsKey) ?? const [])
          .toSet();
      final apiService = ApiService();
      final notifications = await apiService.getNotifications();
      if (!mounted) return;
      final unread = notifications
          .whereType<Map<String, dynamic>>()
          .where((n) => n['id'] != null)
          .map((n) => n['id'].toString())
          .where((id) => !readIds.contains(id))
          .length;
      setState(() {
        _unreadNotificationsCount = unread;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _unreadNotificationsCount = 0;
      });
    }
  }

  void _bindOfficialPlayerListeners() {
    _officialPlayer.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() {
        _officialDuration = d;
        _officialProgress = _officialDuration.inMilliseconds == 0
            ? 0.0
            : (_officialPosition.inMilliseconds /
                      _officialDuration.inMilliseconds)
                  .clamp(0.0, 1.0);
      });
    });

    _officialPlayer.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() {
        _officialPosition = p;
        _officialProgress = _officialDuration.inMilliseconds == 0
            ? 0.0
            : (_officialPosition.inMilliseconds /
                      _officialDuration.inMilliseconds)
                  .clamp(0.0, 1.0);
      });
    });

    _officialPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isOfficialPlaying = false;
        _officialPosition = Duration.zero;
        _officialProgress = 0.0;
      });
    });
  }

  void _resetOfficialPlayer() {
    _officialPlayer.stop();
    _isOfficialPlaying = false;
    _officialDuration = Duration.zero;
    _officialPosition = Duration.zero;
    _officialProgress = 0.0;
  }

  String? _extractAudioUrl(Map<String, dynamic>? announcement) {
    if (announcement == null) return null;
    final raw =
        (announcement['audio_url'] ??
                announcement['audioUrl'] ??
                announcement['audio_path'] ??
                announcement['audioPath'])
            ?.toString()
            .trim();
    if (raw == null || raw.isEmpty) return null;
    return _normalizeAudioUrl(raw);
  }

  String? _normalizeAudioUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('https://')) return trimmed;
    if (trimmed.startsWith('http://')) {
      return 'https://${trimmed.substring('http://'.length)}';
    }
    final baseDomain = ApiConstants.baseUrl.replaceAll('/api/v1', '');
    if (trimmed.startsWith('/')) {
      return '${baseDomain.replaceAll(RegExp(r"/+$"), "")}$trimmed';
    }
    return '${baseDomain.replaceAll(RegExp(r"/+$"), "")}/${trimmed.replaceAll(RegExp(r"^/+"), "")}';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  double? _toDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

  LatLng? _siteLatLng(Map<String, dynamic> site) {
    final lat = _toDouble(site['latitude'] ?? site['lat']);
    final lng = _toDouble(site['longitude'] ?? site['lng']);
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  List<Marker> _buildSiteMarkers(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final markers = <Marker>[];
    for (final site in _competitionSites) {
      final pos = _siteLatLng(site);
      if (pos == null) continue;
      final name = (site['name'] ?? '').toString().trim();
      markers.add(
        Marker(
          point: pos,
          width: 40,
          height: 40,
          child: Tooltip(
            message: name.isEmpty ? l10n.homeSiteFallback : name,
            child: const Icon(
              Icons.location_on_rounded,
              color: AppTheme.primaryGreen,
              size: 38,
            ),
          ),
        ),
      );
    }
    return markers;
  }

  Future<void> _toggleOfficialPlayback() async {
    final url = _officialAudioUrl;
    if (url == null) return;

    if (_isOfficialPlaying) {
      await _officialPlayer.pause();
      if (!mounted) return;
      setState(() {
        _isOfficialPlaying = false;
      });
      return;
    }

    await _officialPlayer.play(UrlSource(url));
    if (!mounted) return;
    setState(() {
      _isOfficialPlaying = true;
    });
  }

  String _formatSeconds(Object? value) {
    if (value is int && value > 0) {
      final minutes = value ~/ 60;
      final seconds = value % 60;
      return "$minutes:${seconds.toString().padLeft(2, '0')}";
    }
    return '--:--';
  }

  @override
  Widget build(BuildContext context) {
    final keepLegacySections = [
      _buildMainFeaturesSection,
      _buildOfficialAnnouncementSection,
      _buildJOJInfoSection,
    ];
    assert(keepLegacySections.isNotEmpty);
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _buildMaquetteTopHeader(context),
              ),
              const SizedBox(height: 12),
              _buildHeroBanner(context),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildQuickSearchBar(context),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildPillarsSection(context),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildJojCountdownStrip(context),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildMaquetteTopHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              image: AssetImage('assets/images/app_logo.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Teranga Pass',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1F2E),
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsScreen()),
            );
            await _loadUnreadNotificationsCount();
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5DFD3)),
                ),
                child: const Icon(Icons.notifications_none_rounded),
              ),
              if (_unreadNotificationsCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC73E1D),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _unreadNotificationsCount > 99
                          ? '99+'
                          : _unreadNotificationsCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        image: DecorationImage(
          image: const AssetImage('assets/images/home_header_dakar.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.3),
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 14,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenue au Senegal,',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.homeTagline,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSenegalFlagSmall() {
    return Container(
      width: 20,
      height: 14,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
      child: Row(
        children: [
          // Bande verte
          Expanded(child: Container(color: AppTheme.primaryGreen)),
          // Bande jaune avec étoile
          Expanded(
            child: Container(
              color: AppTheme.primaryYellow,
              child: Center(
                child: Icon(Icons.star, color: AppTheme.primaryGreen, size: 7),
              ),
            ),
          ),
          // Bande rouge
          Expanded(child: Container(color: AppTheme.primaryRed)),
        ],
      ),
    );
  }

  Widget _buildQuickSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: AppTheme.textSecondary.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _homeSearchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _openMapFromHomeSearch(context),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Restaurants, sites, hotels, evenements...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _openMapFromHomeSearch(context),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  void _openMapFromHomeSearch(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MapScreen(initialQuery: _homeSearchController.text.trim()),
      ),
    );
  }

  Widget _buildPillarsSection(BuildContext context) {
    final pillars = [
      (
        id: _HomePillarId.discover,
        icon: Icons.explore_rounded,
        title: 'Decouvrir',
        subtitle: 'Sites - Restos - Hotels',
        color: const Color(0xFF2E8B57),
      ),
      (
        id: _HomePillarId.move,
        icon: Icons.alt_route_rounded,
        title: 'Se deplacer',
        subtitle: 'Carte - Navettes - Taxis',
        color: const Color(0xFF3A7CA5),
      ),
      (
        id: _HomePillarId.joj,
        icon: Icons.emoji_events_rounded,
        title: 'JOJ 2026',
        subtitle: 'Calendrier - Medailles',
        color: const Color(0xFFD4A017),
      ),
      (
        id: _HomePillarId.help,
        icon: Icons.health_and_safety_rounded,
        title: 'Etre aide',
        subtitle: 'SOS - Medical - Ambassade',
        color: const Color(0xFFC73E1D),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: pillars.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        final pillar = pillars[index];
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _openPillar(context, pillar.id),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: pillar.color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(pillar.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  pillar.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: pillar.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  pillar.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildJojCountdownStrip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1F2E), Color(0xFF2A2F4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Text(
            _jojDaysRemaining.toString(),
            style: TextStyle(
              fontSize: 34,
              color: Color(0xFFD4A017),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jours avant les JOJ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  _jojDateLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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

  void _openPillar(BuildContext context, _HomePillarId id) {
    switch (id) {
      case _HomePillarId.discover:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TourismScreen()),
        );
        break;
      case _HomePillarId.move:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MapScreen()),
        );
        break;
      case _HomePillarId.joj:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JOJInfoScreen()),
        );
        break;
      case _HomePillarId.help:
        _openHelpHub(context);
        break;
    }
  }

  Future<void> _openHelpHub(BuildContext context) async {
    final rootContext = context;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const Text(
                  'Etre aide',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1F2E),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choisissez une action rapide',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 12),
                _buildHelpActionTile(
                  context: context,
                  icon: Icons.sos_rounded,
                  color: const Color(0xFFC73E1D),
                  title: l10n.sosEmergencyTitle,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      rootContext,
                      MaterialPageRoute(builder: (context) => const SOSScreen()),
                    );
                  },
                ),
                _buildHelpActionTile(
                  context: context,
                  icon: Icons.local_hospital_rounded,
                  color: const Color(0xFFD4A017),
                  title: l10n.medicalAlertTitle,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      rootContext,
                      MaterialPageRoute(
                        builder: (context) => const MedicalAlertScreen(),
                      ),
                    );
                  },
                ),
                _buildHelpActionTile(
                  context: context,
                  icon: Icons.report_problem_rounded,
                  color: const Color(0xFF2E8B57),
                  title: l10n.homeFeatureReportIncident,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      rootContext,
                      MaterialPageRoute(
                        builder: (context) => const IncidentReportScreen(),
                      ),
                    );
                  },
                ),
                _buildHelpActionTile(
                  context: context,
                  icon: Icons.account_balance_rounded,
                  color: const Color(0xFF3A7CA5),
                  title: l10n.tourismCategoryEmbassies,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      rootContext,
                      MaterialPageRoute(
                        builder: (context) => const EmbassiesScreen(),
                      ),
                    );
                  },
                ),
                _buildHelpActionTile(
                  context: context,
                  icon: Icons.currency_exchange_rounded,
                  color: const Color(0xFFD4A017),
                  title: 'Convertisseur',
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      rootContext,
                      MaterialPageRoute(
                        builder: (context) => const CurrencyConverterScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHelpActionTile({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF1A1F2E),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      ),
    );
  }

  Widget _buildMainFeaturesSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final features = [
      {
        'id': _HomeFeatureId.audioAnnouncements,
        'icon': Icons.graphic_eq_rounded,
        'title': l10n.homeFeatureAudioAnnouncements,
        'color': AppTheme.primaryGreen,
        'gradient': [AppTheme.primaryGreen, const Color(0xFF00A86B)],
      },
      {
        'id': _HomeFeatureId.touristInfo,
        'icon': Icons.explore_rounded,
        'title': l10n.homeFeatureTouristInfo,
        'color': AppTheme.primaryGreen,
        'gradient': [AppTheme.primaryGreen, const Color(0xFF00C97A)],
      },
      {
        'id': _HomeFeatureId.competitionSites,
        'icon': Icons.stadium_rounded,
        'title': l10n.homeFeatureCompetitionSites,
        'color': AppTheme.primaryYellow,
        'gradient': [AppTheme.primaryYellow, const Color(0xFFFFD700)],
      },
      {
        'id': _HomeFeatureId.competitions,
        'icon': Icons.workspace_premium_rounded,
        'title': l10n.homeFeatureCompetitions,
        'color': AppTheme.primaryGreen,
        'gradient': [AppTheme.primaryGreen, const Color(0xFF00B86B)],
      },
      {
        'id': _HomeFeatureId.transport,
        'icon': Icons.directions_bus_filled_rounded,
        'title': l10n.homeFeatureTransport,
        'color': AppTheme.primaryYellow,
        'gradient': [AppTheme.primaryYellow, const Color(0xFFFFE135)],
      },
      {
        'id': _HomeFeatureId.incidentReport,
        'icon': Icons.warning_rounded,
        'title': l10n.homeFeatureReportIncident,
        'color': AppTheme.warningYellow,
        'gradient': [AppTheme.warningYellow, const Color(0xFFFF8C00)],
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];

        // Tous les boutons utilisent maintenant le même style avec cercles colorés

        return InkWell(
          onTap: () {
            final id = feature['id'] as _HomeFeatureId;
            if (id == _HomeFeatureId.incidentReport) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IncidentReportScreen(),
                ),
              );
            } else if (id == _HomeFeatureId.audioAnnouncements) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AudioAnnouncementsScreen(),
                ),
              );
            } else if (id == _HomeFeatureId.touristInfo) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TourismScreen()),
              );
            } else if (id == _HomeFeatureId.competitionSites ||
                id == _HomeFeatureId.competitions) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JOJInfoScreen()),
              );
            } else if (id == _HomeFeatureId.transport) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransportScreen(),
                ),
              );
            } else {
              _showComingSoon(context, feature['title'] as String);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cercle avec dégradé et icône blanche
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: (feature['gradient'] as List<Color>),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (feature['gradient'] as List<Color>)[0].withValues(
                        alpha: 0.4,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36, // Hauteur fixe pour 2 lignes de texte
                child: Text(
                  feature['title'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOfficialAnnouncementSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final announcement = _officialAnnouncement;
    if (announcement == null) return const SizedBox.shrink();

    final title =
        (announcement['title'] ?? l10n.homeOfficialAnnouncementDefaultTitle)
            .toString()
            .trim();
    final content = (announcement['content'] ?? '').toString().trim();
    final durationLabel = _officialDuration.inSeconds > 0
        ? _formatDuration(_officialDuration)
        : _formatSeconds(announcement['duration']);
    final positionLabel = _formatDuration(_officialPosition);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AudioAnnouncementsScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildSenegalFlagSmall(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title.isEmpty
                          ? l10n.homeOfficialAnnouncementDefaultTitle
                          : title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const AudioAnnouncementsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              if (content.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  InkWell(
                    onTap: _toggleOfficialPlayback,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isOfficialPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: _officialProgress,
                          backgroundColor: AppTheme.backgroundColor,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              positionLabel,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              durationLabel,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJOJInfoSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final markers = _buildSiteMarkers(context);
    final hasCoords = markers.isNotEmpty;
    final previewSites = _competitionSites.take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Drapeau du Sénégal
                Container(
                  width: 20,
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryGreen,
                        AppTheme.primaryYellow,
                        AppTheme.primaryRed,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.homeJojInfoTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JOJInfoScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today, size: 14),
                  label: Text(
                    l10n.homeCalendar,
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.textSecondary.withValues(alpha: 0.2),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isLoadingCompetitionSites
                    ? const Center(child: CircularProgressIndicator())
                    : _competitionSitesError != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wifi_off_rounded,
                                size: 40,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _competitionSitesError!,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: _loadCompetitionSites,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryGreen,
                                ),
                                child: Text(l10n.retry),
                              ),
                            ],
                          ),
                        ),
                      )
                    : hasCoords
                    ? FlutterMap(
                        mapController: _jojMapController,
                        options: MapOptions(
                          initialCenter: markers.first.point,
                          initialZoom: 12,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.terangapass.teranga_pass',
                          ),
                          MarkerLayer(markers: markers),
                        ],
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 48,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _competitionSites.isEmpty
                                    ? l10n.homeNoActiveSites
                                    : l10n.homeAddLatLngHint,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
            if (previewSites.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...previewSites.map((site) {
                final name = (site['name'] ?? '').toString().trim();
                final location = (site['location'] ?? '').toString().trim();
                final dates = (site['dates'] ?? '').toString().trim();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.place_rounded,
                        size: 18,
                        color: AppTheme.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isEmpty ? l10n.homeSiteFallback : name,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              [
                                if (location.isNotEmpty) location,
                                if (dates.isNotEmpty) dates,
                              ].join(' • '),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 98,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 12,
              right: 12,
              bottom: 8,
              child: Container(
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.96),
                  border: Border(
                    top: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context,
                      Icons.home_rounded,
                      _HomeNavId.home,
                      l10n.homeNavHome,
                      true,
                    ),
                    _buildNavDiscoverItem(context),
                    _buildNavJojItem(context),
                    _buildNavItem(
                      context,
                      Icons.person_outline_rounded,
                      _HomeNavId.profile,
                      l10n.homeNavProfile,
                      false,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 22,
              bottom: 56,
              child: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavDiscoverItem(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TourismScreen()),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.public_rounded, color: Color(0xFF2E8B57), size: 20),
            const SizedBox(height: 2),
            Text(
              'Decouvrir',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavJojItem(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const JOJInfoScreen()),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFD4A017),
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              'JOJ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    _HomeNavId id,
    String label,
    bool isActive,
  ) {
    final circleSize = 34.0;
    final iconSize = 18.0;

    return InkWell(
      onTap: () {
        _navigateTo(context, id);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryGreen.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.primaryGreen
                    : AppTheme.primaryGreen.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : AppTheme.primaryGreen,
                size: iconSize,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                height: 1.0,
                color: isActive
                    ? AppTheme.primaryGreen
                    : AppTheme.textSecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text(l10n.homeComingSoon),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
