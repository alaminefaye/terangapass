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
import 'notifications_screen.dart';

enum _HomeFeatureId {
  audioAnnouncements,
  touristInfo,
  competitionSites,
  competitions,
  transport,
  incidentReport,
}

enum _HomeNavId { home, medicalAlert, sos, incidentReport, profile }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bindOfficialPlayerListeners();
    _loadOfficialAnnouncement();
    _loadCompetitionSites();
    _loadUnreadNotificationsCount();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _officialPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadOfficialAnnouncement();
      _loadCompetitionSites();
      _loadUnreadNotificationsCount();
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
    return Scaffold(
      body: Stack(
        children: [
          _buildHeaderImage(context),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 280),
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildEmergencyButtonsRow(context),
                        const SizedBox(height: 0),
                        _buildMainFeaturesSection(context),
                        const SizedBox(height: 8),
                        if (_officialAnnouncement != null) ...[
                          _buildOfficialAnnouncementSection(context),
                          const SizedBox(height: 8),
                        ],
                        _buildJOJInfoSection(context),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildHeaderImage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
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
          // Overlay avec contenu
          SafeArea(
            child: Stack(
              children: [
                // Notifications en haut à droite
                Positioned(
                  top: 8,
                  right: 16,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                      await _loadUnreadNotificationsCount();
                    },
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        if (_unreadNotificationsCount > 0)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryRed,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                _unreadNotificationsCount > 99
                                    ? '99+'
                                    : _unreadNotificationsCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 8,
                  left: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      height: 44,
                      width: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Tagline en bas (position actuelle - ne pas toucher)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    l10n.homeTagline,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
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

  Widget _buildEmergencyButtonsRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        // Bouton SOS Urgence
        Expanded(
          child: _buildHorizontalEmergencyButton(
            context,
            icon: Icons.warning_amber_rounded,
            title: l10n.sosEmergencyTitle,
            color: AppTheme.emergencyRed,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SOSScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),

        // Bouton Alerte Médicale
        Expanded(
          child: _buildHorizontalEmergencyButton(
            context,
            icon: Icons.medical_services_rounded,
            title: l10n.medicalAlertTitle,
            color: AppTheme.medicalRed,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicalAlertScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalEmergencyButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    // Dégradé rouge pour le fond
    final gradientColors = [
      color,
      Color.fromRGBO(
        ((color.r * 255).round() - 25).clamp(0, 255),
        ((color.g * 255).round() - 15).clamp(0, 255),
        ((color.b * 255).round() - 15).clamp(0, 255),
        1.0,
      ),
    ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Cercle avec icône plus grande
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context,
                Icons.home_rounded,
                _HomeNavId.home,
                l10n.homeNavHome,
                false,
              ),
              _buildNavItem(
                context,
                Icons.medical_services_rounded,
                _HomeNavId.medicalAlert,
                l10n.homeNavMedicalAlert,
                false,
              ),
              _buildNavItem(
                context,
                Icons.warning_amber_rounded,
                _HomeNavId.sos,
                l10n.homeNavSos,
                true,
                isSOS: true,
              ),
              _buildNavItem(
                context,
                Icons.report_problem_rounded,
                _HomeNavId.incidentReport,
                l10n.homeNavReport,
                false,
              ),
              _buildNavItem(
                context,
                Icons.person_outline,
                _HomeNavId.profile,
                l10n.homeNavProfile,
                false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    _HomeNavId id,
    String label,
    bool isActive, {
    bool isSOS = false,
  }) {
    if (isSOS) {
      // Bouton SOS spécial - plus grand et mis en avant
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SOSScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(35),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryRed,
                        Color.fromRGBO(
                          ((AppTheme.primaryRed.r * 255).round() - 25).clamp(
                            0,
                            255,
                          ),
                          ((AppTheme.primaryRed.g * 255).round() - 15).clamp(
                            0,
                            255,
                          ),
                          ((AppTheme.primaryRed.b * 255).round() - 15).clamp(
                            0,
                            255,
                          ),
                          1.0,
                        ),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryRed.withValues(alpha: 0.6),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: AppTheme.primaryRed.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'SOS',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Autres boutons normaux
    final circleSize = 40.0;
    final iconSize = 20.0;

    return InkWell(
      onTap: () {
        switch (id) {
          case _HomeNavId.home:
            break;
          case _HomeNavId.medicalAlert:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MedicalAlertScreen(),
              ),
            );
            break;
          case _HomeNavId.sos:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SOSScreen()),
            );
            break;
          case _HomeNavId.incidentReport:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const IncidentReportScreen(),
              ),
            );
            break;
          case _HomeNavId.profile:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
            break;
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryGreen.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cercle vert avec icône blanche
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryGreen,
                    Color.fromRGBO(
                      ((AppTheme.primaryGreen.r * 255).round() - 20).clamp(
                        0,
                        255,
                      ),
                      ((AppTheme.primaryGreen.g * 255).round() - 20).clamp(
                        0,
                        255,
                      ),
                      ((AppTheme.primaryGreen.b * 255).round() - 20).clamp(
                        0,
                        255,
                      ),
                      1.0,
                    ),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: iconSize),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive
                    ? AppTheme.primaryGreen
                    : AppTheme.textSecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
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
