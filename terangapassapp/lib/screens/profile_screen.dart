import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  int _alertsCount = 0;
  int _reportsCount = 0;
  String? _errorMessage;
  List<Map<String, dynamic>> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      _userProfile = await apiService.getUserProfile();

      // Charger les statistiques
      final alerts = await apiService.getAlertsHistory();
      final reports = await apiService.getIncidentsHistory();

      setState(() {
        _alertsCount = alerts.length;
        _reportsCount = reports.length;
        _recentActivities = _buildRecentActivities(alerts, reports);
      });
    } catch (e) {
      setState(() {
        _userProfile = null;
        _alertsCount = 0;
        _reportsCount = 0;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _recentActivities = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  String _relativeTime(DateTime dt) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(dt.isAfter(now) ? now : dt);
    if (diff.inMinutes < 1) return l10n.timeJustNow;
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    return l10n.timeDaysAgo(diff.inDays);
  }

  List<Map<String, dynamic>> _buildRecentActivities(
    List<dynamic> alerts,
    List<dynamic> reports,
  ) {
    final l10n = AppLocalizations.of(context)!;
    Map<String, dynamic> buildItem({
      required Map<String, dynamic> raw,
      required String defaultTitle,
      required IconData icon,
      required Color color,
    }) {
      final createdAt = _parseDate(
        raw['created_at'] ??
            raw['createdAt'] ??
            raw['date'] ??
            raw['timestamp'],
      );
      final title =
          (raw['title'] ?? raw['type'] ?? raw['category'] ?? defaultTitle)
              .toString()
              .trim();
      return {
        'title': title.isEmpty ? defaultTitle : title,
        'createdAt': createdAt,
        'icon': icon,
        'color': color,
      };
    }

    final items = <Map<String, dynamic>>[
      ...alerts.whereType<Map<String, dynamic>>().map(
        (a) => buildItem(
          raw: a,
          defaultTitle: l10n.profileDefaultSosTitle,
          icon: Icons.warning_rounded,
          color: AppTheme.primaryRed,
        ),
      ),
      ...reports.whereType<Map<String, dynamic>>().map(
        (r) => buildItem(
          raw: r,
          defaultTitle: l10n.profileDefaultReportTitle,
          icon: Icons.report_rounded,
          color: AppTheme.primaryGreen,
        ),
      ),
    ];

    items.sort((a, b) {
      final adt = a['createdAt'] as DateTime?;
      final bdt = b['createdAt'] as DateTime?;
      if (adt == null && bdt == null) return 0;
      if (adt == null) return 1;
      if (bdt == null) return -1;
      return bdt.compareTo(adt);
    });

    final trimmed = items.take(3).toList();
    return trimmed
        .map(
          (it) => {
            ...it,
            'time': (it['createdAt'] as DateTime?) == null
                ? ''
                : _relativeTime(it['createdAt'] as DateTime),
          },
        )
        .toList();
  }

  Future<void> _logout() async {
    try {
      final apiService = ApiService();
      await apiService.logout();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // Même en cas d'erreur, on déconnecte localement
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  String _languageLabel(String code, AppLocalizations l10n) {
    final c = code.trim().toLowerCase();
    if (c == 'fr') return l10n.languageFrench;
    if (c == 'en') return l10n.languageEnglish;
    if (c == 'es') return l10n.languageSpanish;
    return code;
  }

  Future<void> _pickAppLanguage() async {
    final current =
        (AppConstants.localeNotifier.value?.languageCode ??
                AppConstants.defaultLanguage)
            .trim()
            .toLowerCase();

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final options = [
          {'code': 'fr', 'label': l10n.languageFrench},
          {'code': 'en', 'label': l10n.languageEnglish},
        ];
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ...options.map((o) {
                final code = o['code']!;
                final label = o['label']!;
                return ListTile(
                  title: Text(label, style: GoogleFonts.poppins()),
                  trailing: code == current
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.of(context).pop(code),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selected == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.languageKey, selected);
    AppConstants.localeNotifier.value = Locale(selected);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(
          0xFFF5F7FA,
        ), // Light grey background for 3D effect
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _userProfile == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: AppTheme.primaryGreen,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            l10n.profileTitle,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 64,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  (_errorMessage ?? l10n.profileUnavailable).trim(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                  child: Text(l10n.retry, style: GoogleFonts.poppins()),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          l10n.profileTitle,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _userProfile == null ? null : _showEditProfileSheet,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header 3D Design
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Background Gradient with Curve
                Container(
                  height: 330, // Hauteur augmentée pour plus d'espace
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF00A86B), // Primary Green
                        const Color(0xFF008C5E), // Darker Green
                        Colors.teal.shade700,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00A86B).withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),

                // Profile Info
                Positioned(
                  top: 110, // Position ajustée pour ne pas toucher le titre
                  child: Column(
                    children: [
                      // 3D Profile Picture
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 55, // Taille augmentée
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person_rounded,
                            size:
                                80, // Icône beaucoup plus grande pour remplir le cercle
                            color: AppTheme.primaryGreen.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        ((_userProfile?['name'] ??
                                        _userProfile?['full_name'] ??
                                        _userProfile?['fullName']) ??
                                    '')
                                .toString()
                                .trim()
                                .isEmpty
                            ? '—'
                            : ((_userProfile?['name'] ??
                                          _userProfile?['full_name'] ??
                                          _userProfile?['fullName']) ??
                                      '')
                                  .toString()
                                  .trim(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24, // Taille police rétablie
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, // Padding horizontal augmenté
                          vertical: 6, // Padding vertical augmenté
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ((_userProfile?['email'] ?? _userProfile?['mail']) ??
                                      '')
                                  .toString()
                                  .trim()
                                  .isEmpty
                              ? '—'
                              : ((_userProfile?['email'] ??
                                            _userProfile?['mail']) ??
                                        '')
                                    .toString()
                                    .trim(),
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Content Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations personnelles
                  Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 10),
                    child: Text(
                      l10n.profilePersonalInfoSection,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF2D3436),
                      ),
                    ),
                  ),
                  _buildPersonalInfoBox(
                    identity: (() {
                      final firstName =
                          ((_userProfile?['first_name'] ??
                                      _userProfile?['firstName'] ??
                                      _userProfile?['prenom']) ??
                                  '')
                              .toString()
                              .trim();
                      final lastName =
                          ((_userProfile?['last_name'] ??
                                      _userProfile?['lastName'] ??
                                      _userProfile?['nom']) ??
                                  '')
                              .toString()
                              .trim();
                      final full = '$firstName $lastName'.trim();
                      return full.isEmpty ? '—' : full;
                    })(),
                    language: (() {
                      final lang =
                          ((_userProfile?['language'] ??
                                      _userProfile?['lang']) ??
                                  '')
                              .toString()
                              .trim();
                      return lang.isEmpty ? '—' : lang;
                    })(),
                    userType: (() {
                      final type =
                          ((_userProfile?['user_type'] ??
                                      _userProfile?['userType'] ??
                                      _userProfile?['type']) ??
                                  '')
                              .toString()
                              .trim();
                      return type.isEmpty ? '—' : type;
                    })(),
                  ),

                  const SizedBox(height: 30),

                  // Paramètres
                  Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 10),
                    child: Text(
                      l10n.settings,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF2D3436),
                      ),
                    ),
                  ),
                  _buildSettingTile(
                    l10n.profileNotificationsSetting,
                    Icons.notifications_outlined,
                    true,
                  ),
                  _buildSettingTile(
                    l10n.profileGeolocationSetting,
                    Icons.location_on_outlined,
                    true,
                  ),
                  _buildSettingTile(
                    l10n.appLanguage,
                    Icons.translate_rounded,
                    false,
                    value: _languageLabel(
                      AppConstants.localeNotifier.value?.languageCode ??
                          AppConstants.defaultLanguage,
                      l10n,
                    ),
                    onTap: _pickAppLanguage,
                  ),
                  _buildSettingTile(
                    l10n.profilePrivacySetting,
                    Icons.lock_outline_rounded,
                    false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const PrivacyScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // Statistiques
                  Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 10),
                    child: Text(
                      l10n.profileOverviewSection,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF2D3436),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          l10n.profileAlertsStat,
                          '$_alertsCount',
                          Icons.warning_amber_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          l10n.profileReportsStat,
                          '$_reportsCount',
                          Icons.report_gmailerrorred_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Historique
                  Padding(
                    padding: const EdgeInsets.only(left: 6, bottom: 10),
                    child: Text(
                      l10n.profileRecentActivitiesSection,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF2D3436),
                      ),
                    ),
                  ),
                  if (_recentActivities.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Center(
                        child: Text(
                          l10n.profileNoRecentActivity,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._recentActivities.map(
                      (a) => _buildHistoryTile(
                        (a['title'] ?? '').toString(),
                        (a['time'] ?? '').toString(),
                        a['icon'] as IconData,
                        a['color'] as Color,
                      ),
                    ),

                  const SizedBox(height: 40),

                  // Bouton Déconnexion 3D
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRed.withValues(alpha: 0.3),
                          offset: const Offset(0, 10),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryRed,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: AppTheme.primaryRed,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout_rounded,
                            color: AppTheme.primaryRed,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            l10n.profileLogout,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryRed,
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
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    IconData icon,
    bool hasSwitch, {
    VoidCallback? onTap,
    String? value,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            offset: const Offset(0, 6),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        onTap: hasSwitch ? null : onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppTheme.primaryGreen, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
        ),
        trailing: hasSwitch
            ? Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: true,
                  onChanged: (value) {},
                  activeThumbColor: Colors.white,
                  activeTrackColor: AppTheme.primaryGreen,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                  trackOutlineColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (value != null && value.trim().isNotEmpty)
                    Text(
                      value.trim(),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPersonalInfoBox({
    required String identity,
    required String language,
    required String userType,
  }) {
    final items = [
      _PersonalInfoRowData(
        icon: Icons.person_outline_rounded,
        label: 'Identité',
        value: identity,
      ),
      _PersonalInfoRowData(
        icon: Icons.language_rounded,
        label: 'Langue préférée',
        value: language,
      ),
      _PersonalInfoRowData(
        icon: Icons.badge_rounded,
        label: 'Type d\'utilisateur',
        value: userType,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            offset: const Offset(0, 6),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _buildPersonalInfoRow(items[i]),
            if (i != items.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.withValues(alpha: 0.08),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalInfoRow(_PersonalInfoRowData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: AppTheme.primaryGreen, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGreen.withValues(alpha: 0.1),
            offset: const Offset(0, 8),
            blurRadius: 16,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryGreen.withValues(alpha: 0.1),
                    AppTheme.primaryGreen.withValues(alpha: 0.05),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryGreen, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditProfileSheet() async {
    final profile = _userProfile ?? {};

    String normalizeLanguage(dynamic value) {
      final v = (value ?? '').toString().toLowerCase().trim();
      if (v == 'fr' || v.contains('fran')) return 'fr';
      if (v == 'en' || v.contains('eng')) return 'en';
      if (v == 'es' || v.contains('esp')) return 'es';
      return 'fr';
    }

    String normalizeUserType(dynamic value) {
      final v = (value ?? '').toString().toLowerCase().trim();
      if (v == 'athlete' || v.contains('athl')) return 'athlete';
      if (v == 'citizen' || v.contains('citoy')) return 'citizen';
      if (v == 'visitor' || v.contains('visit')) return 'visitor';
      return 'visitor';
    }

    final nameController = TextEditingController(
      text: profile['name']?.toString() ?? '',
    );
    final phoneController = TextEditingController(
      text: profile['phone']?.toString() ?? '',
    );

    var language = normalizeLanguage(profile['language']);
    var userType = normalizeUserType(profile['user_type']);
    var isSaving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.profileEditTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.profileNameLabel,
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: l10n.profilePhoneLabel,
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: language,
                    decoration: InputDecoration(
                      labelText: l10n.profileLanguageLabel,
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'fr',
                        child: Text(l10n.languageFrench),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(l10n.languageEnglish),
                      ),
                      DropdownMenuItem(
                        value: 'es',
                        child: Text(l10n.languageSpanish),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setModalState(() {
                        language = v;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: userType,
                    decoration: InputDecoration(
                      labelText: l10n.profileUserTypeLabel,
                      labelStyle: GoogleFonts.poppins(),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'visitor',
                        child: Text(l10n.profileUserTypeVisitor),
                      ),
                      DropdownMenuItem(
                        value: 'citizen',
                        child: Text(l10n.profileUserTypeCitizen),
                      ),
                      DropdownMenuItem(
                        value: 'athlete',
                        child: Text(l10n.profileUserTypeAthlete),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setModalState(() {
                        userType = v;
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () async {
                              final navigator = Navigator.of(context);
                              final messenger = ScaffoldMessenger.of(context);
                              final name = nameController.text.trim();
                              if (name.isEmpty) {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.profileNameRequired,
                                      style: GoogleFonts.poppins(),
                                    ),
                                    backgroundColor: AppTheme.primaryRed,
                                  ),
                                );
                                return;
                              }

                              setModalState(() {
                                isSaving = true;
                              });

                              try {
                                final apiService = ApiService();
                                final updated = await apiService
                                    .updateUserProfile({
                                      'name': name,
                                      'phone':
                                          phoneController.text.trim().isEmpty
                                          ? null
                                          : phoneController.text.trim(),
                                      'language': language,
                                      'user_type': userType,
                                    });
                                if (!mounted) return;
                                setState(() {
                                  _userProfile = updated;
                                });
                                setModalState(() {
                                  isSaving = false;
                                });
                                navigator.pop();
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.profileUpdated,
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (!mounted) return;
                                setModalState(() {
                                  isSaving = false;
                                });
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      e.toString().replaceAll(
                                        'Exception: ',
                                        '',
                                      ),
                                      style: GoogleFonts.poppins(),
                                    ),
                                    backgroundColor: AppTheme.primaryRed,
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isSaving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l10n.profileSave,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();
  }

  Widget _buildHistoryTile(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            offset: const Offset(0, 6),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: time.trim().isEmpty
            ? null
            : Text(
                time,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey[400],
            size: 14,
          ),
        ),
      ),
    );
  }
}

class _PersonalInfoRowData {
  const _PersonalInfoRowData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        title: Text(
          l10n.profilePrivacySetting,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  offset: const Offset(0, 6),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.privacyPersonalDataTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.privacyPersonalDataBody,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    height: 1.4,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  offset: const Offset(0, 6),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: AppTheme.primaryGreen,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    l10n.profileGeolocationSetting,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    l10n.privacyLocationSubtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.withValues(alpha: 0.08),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppTheme.primaryGreen,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    l10n.profileNotificationsSetting,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    l10n.privacyNotificationsSubtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
