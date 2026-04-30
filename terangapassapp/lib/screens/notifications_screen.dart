import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const String _readIdsKey = 'read_notification_ids';

  String? _selectedZone;
  List<String> _zones = const [];
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  Set<String> _readIds = {};

  @override
  void initState() {
    super.initState();
    _loadReadIds().then((_) => _loadNotifications());
  }

  Future<void> _loadReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_readIdsKey) ?? const [];
    if (!mounted) return;
    setState(() {
      _readIds = stored.map((s) => s.toString()).toSet();
    });
  }

  bool _isRead(Map<String, dynamic> notification) {
    final id = notification['id'];
    if (id == null) return false;
    return _readIds.contains(id.toString());
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      final notifications = await apiService.getNotifications(
        zone: _selectedZone,
      );
      setState(() {
        _notifications = notifications
            .map((n) => n as Map<String, dynamic>)
            .toList();
        final unique = {
          for (final n in _notifications) (n['zone'] ?? '').toString().trim(),
        }.where((z) => z.isNotEmpty).toList()..sort((a, b) => a.compareTo(b));
        _zones = unique;
      });
    } catch (e) {
      setState(() {
        _notifications = [];
        _zones = const [];
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(Map<String, dynamic> notification) async {
    final id = notification['id'];
    if (id == null) return;
    final idString = id.toString();
    if (_readIds.contains(idString)) return;

    setState(() {
      _readIds = {..._readIds, idString};
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_readIdsKey, _readIds.toList());

    if (id is int) {
      try {
        final apiService = ApiService();
        await apiService.markNotificationAsRead(id);
      } catch (_) {}
    }
  }

  Future<void> _openNotification(Map<String, dynamic> notification) async {
    await _markAsRead(notification);
    if (!mounted) return;

    final type = (notification['type'] ?? '').toString().trim();
    final title = (notification['title'] ?? '').toString().trim();
    final description = (notification['description'] ?? '').toString().trim();
    final zone = (notification['zone'] ?? '').toString().trim();
    final time = _displayTime(notification);
    final icon = _iconForType(type);
    final color = _colorForType(type);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title.isEmpty ? l10n.notificationsFallbackTitle : title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (type.isNotEmpty)
                      Text(
                        type,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    if (type.isNotEmpty) const SizedBox(width: 10),
                    if (time.isNotEmpty)
                      Text(
                        time,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
                if (zone.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          zone,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  description.isEmpty ? '—' : description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.close,
                          style: GoogleFonts.poppins(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _iconForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('sécur') || t.contains('secur')) {
      return Icons.security_rounded;
    }
    if (t.contains('transport') || t.contains('navette')) {
      return Icons.directions_bus_rounded;
    }
    if (t.contains('météo') || t.contains('meteo')) {
      return Icons.wb_sunny_rounded;
    }
    if (t.contains('rout')) return Icons.construction_rounded;
    if (t.contains('médic') || t.contains('medic')) {
      return Icons.medical_services_rounded;
    }
    return Icons.notifications_rounded;
  }

  Color _colorForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('sécur') || t.contains('secur')) return AppTheme.primaryRed;
    if (t.contains('transport') || t.contains('navette')) {
      return AppTheme.primaryGreen;
    }
    if (t.contains('météo') || t.contains('meteo')) return Colors.orange;
    if (t.contains('rout')) return Colors.blue;
    if (t.contains('médic') || t.contains('medic')) return Colors.purple;
    return AppTheme.textSecondary;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  String _relativeTimeFrom(dynamic createdAt) {
    final l10n = AppLocalizations.of(context)!;
    final dt = _parseDate(createdAt);
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt.isAfter(now) ? now : dt);
    if (diff.inMinutes < 1) return l10n.timeJustNow;
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    return l10n.timeDaysAgo(diff.inDays);
  }

  String _displayTime(Map<String, dynamic> notification) {
    final createdAt =
        notification['created_at'] ??
        notification['createdAt'] ??
        notification['date'];
    final rel = _relativeTimeFrom(createdAt);
    if (rel.isNotEmpty) return rel;
    final t = (notification['time'] ?? '').toString().trim();
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.notificationsTitle,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              _showZoneFilterSheet();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtre par zone
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  '${l10n.zoneLabel}:',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String?>(
                    value: _selectedZone,
                    isExpanded: true,
                    underline: Container(),
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(
                          l10n.allZones,
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ),
                      ..._zones.map(
                        (zone) => DropdownMenuItem<String?>(
                          value: zone,
                          child: Text(
                            zone,
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedZone = newValue;
                      });
                      _loadNotifications();
                    },
                  ),
                ),
              ],
            ),
          ),

          // Liste des notifications
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
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
                            _errorMessage!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadNotifications,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                            child: Text(
                              l10n.retry,
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_rounded,
                          size: 64,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noNotifications,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    color: AppTheme.primaryGreen,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        final type = (notification['type'] ?? '').toString();
                        final title = (notification['title'] ?? '').toString();
                        final description = (notification['description'] ?? '')
                            .toString();
                        final zone = (notification['zone'] ?? '').toString();
                        final time = _displayTime(notification);
                        final icon = _iconForType(type);
                        final color = _colorForType(type);
                        final isRead = _isRead(notification);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildNotificationCard(
                            type: type.isEmpty
                                ? l10n.notificationsFallbackTitle
                                : type,
                            title: title.isEmpty
                                ? l10n.notificationsFallbackTitle
                                : title,
                            description: description,
                            time: time,
                            zone: zone.isEmpty ? '—' : zone,
                            icon: icon,
                            color: color,
                            isRead: isRead,
                            onTap: () => _openNotification(notification),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required String type,
    required String title,
    required String description,
    required String time,
    required String zone,
    required IconData icon,
    required Color color,
    required bool isRead,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, color: color, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            type,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isRead) ...[
                      const SizedBox(width: 10),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        zone,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showZoneFilterSheet() async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
              ListTile(
                title: Text(l10n.allZones, style: GoogleFonts.poppins()),
                trailing: _selectedZone == null
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.of(context).pop(null),
              ),
              ..._zones.map(
                (z) => ListTile(
                  title: Text(z, style: GoogleFonts.poppins()),
                  trailing: z == _selectedZone
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.of(context).pop(z),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selected == _selectedZone) return;
    setState(() {
      _selectedZone = selected;
    });
    await _loadNotifications();
  }
}
