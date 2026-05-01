import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import 'auth/login_screen.dart';
import 'incident_history_screen.dart';
import 'incident_tracking_screen.dart';

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

      if (!mounted) return;
      setState(() {
        _alertsCount = alerts.length;
        _reportsCount = reports.length;
        _recentActivities = _buildRecentActivities(alerts, reports);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _userProfile = null;
        _alertsCount = 0;
        _reportsCount = 0;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _recentActivities = [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      required String kind,
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
        'kind': kind,
        'id': raw['id'],
      };
    }

    final items = <Map<String, dynamic>>[
      ...alerts.whereType<Map<String, dynamic>>().map(
        (a) => buildItem(
          raw: a,
          defaultTitle: l10n.profileDefaultSosTitle,
          icon: Icons.warning_rounded,
          color: AppTheme.primaryRed,
          kind: 'alert',
        ),
      ),
      ...reports.whereType<Map<String, dynamic>>().map(
        (r) => buildItem(
          raw: r,
          defaultTitle: l10n.profileDefaultReportTitle,
          icon: Icons.report_rounded,
          color: AppTheme.primaryGreen,
          kind: 'incident',
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
        backgroundColor: const Color(0xFFF4F1EA),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null || _userProfile == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F1EA),
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

    final displayName =
        ((_userProfile?['name'] ??
                    _userProfile?['full_name'] ??
                    _userProfile?['fullName']) ??
                '')
            .toString()
            .trim();
    final displayEmail =
        ((_userProfile?['email'] ?? _userProfile?['mail']) ?? '')
            .toString()
            .trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A1F2E)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.profileTitle,
          style: GoogleFonts.poppins(
            color: const Color(0xFF1A1F2E),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Color(0xFF1A1F2E)),
            onPressed: _showEditProfileSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF171E34), Color(0xFF2E3561)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF171E34).withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person_rounded,
                      size: 52,
                      color: AppTheme.primaryGreen.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName.isEmpty ? '—' : displayName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      displayEmail.isEmpty ? '—' : displayEmail,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          l10n.profileAlertsStat,
                          '$_alertsCount',
                          Icons.warning_amber_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          l10n.profileReportsStat,
                          '$_reportsCount',
                          Icons.report_gmailerrorred_rounded,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const IncidentHistoryScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.profilePersonalInfoSection,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: const Color(0xFF1A1F2E),
              ),
            ),
            const SizedBox(height: 8),
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
                    ((_userProfile?['language'] ?? _userProfile?['lang']) ?? '')
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
            const SizedBox(height: 18),
            Text(
              l10n.settings,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: const Color(0xFF1A1F2E),
              ),
            ),
            const SizedBox(height: 8),
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
                  MaterialPageRoute(builder: (context) => const PrivacyScreen()),
                );
              },
            ),
            const SizedBox(height: 18),
            Text(
              l10n.profileRecentActivitiesSection,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: const Color(0xFF1A1F2E),
              ),
            ),
            const SizedBox(height: 8),
            if (_recentActivities.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  l10n.profileNoRecentActivity,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
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
                  onTap: () {
                    if ((a['kind'] ?? '').toString() != 'incident') return;
                    final id = a['id'];
                    if (id is! int) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IncidentTrackingScreen(incidentId: id),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: Text(
                  l10n.profileLogout,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC73E1D),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
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

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
    {VoidCallback? onTap}
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
      backgroundColor: const Color(0xFFF4F1EA),
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
