import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../widgets/loading_placeholders.dart';

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

  Future<void> _persistReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_readIdsKey, _readIds.toList());
  }

  bool _isRead(Map<String, dynamic> notification) {
    final id = notification['id'];
    if (id == null) return false;
    // Check local cache first; backend is source of truth for user_ notifs
    if (_readIds.contains(id.toString())) return true;
    // The API also returns is_read from the backend
    return notification['is_read'] == true;
  }

  bool _isPersonal(Map<String, dynamic> notification) {
    final id = notification['id']?.toString() ?? '';
    return id.startsWith('user_');
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
      if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        _notifications = [];
        _zones = const [];
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

  Future<void> _markAsRead(Map<String, dynamic> notification) async {
    final id = notification['id'];
    if (id == null) return;
    final idString = id.toString();
    if (_readIds.contains(idString)) return;

    setState(() {
      _readIds = {..._readIds, idString};
      notification['is_read'] = true;
    });
    await _persistReadIds();

    try {
      await ApiService().markNotificationAsRead(id);
    } catch (_) {}
  }

  Future<void> _markAsUnread(Map<String, dynamic> notification) async {
    final id = notification['id'];
    if (id == null) return;
    final idString = id.toString();

    setState(() {
      _readIds = _readIds.difference({idString});
      notification['is_read'] = false;
    });
    await _persistReadIds();

    try {
      await ApiService().markNotificationAsUnread(id);
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    final hasUnread = _notifications.any((n) => !_isRead(n));
    if (!hasUnread) return;

    setState(() {
      for (final n in _notifications) {
        final id = n['id'];
        if (id != null) _readIds = {..._readIds, id.toString()};
        n['is_read'] = true;
      }
    });
    await _persistReadIds();

    try {
      await ApiService().markAllNotificationsAsRead();
    } catch (_) {}
  }

  Future<void> _clearAll() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n.clearAllConfirmTitle,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(l10n.clearAllConfirmBody, style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
            ),
            child: Text(
              l10n.clearAll,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final personal = _notifications
        .where((n) => _isPersonal(n))
        .map((n) => n['id'].toString())
        .toSet();

    setState(() {
      _notifications.removeWhere((n) => _isPersonal(n));
      _readIds = _readIds.difference(personal);
    });
    await _persistReadIds();

    try {
      await ApiService().clearAllNotifications();
    } catch (_) {
      await _loadNotifications();
    }
  }

  Future<void> _deleteNotification(Map<String, dynamic> notification) async {
    final id = notification['id'];
    if (id == null) return;

    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });

    try {
      await ApiService().deleteNotification(id);
    } catch (_) {
      // Reload list if deletion failed
      await _loadNotifications();
    }
  }

  Future<void> _openNotification(Map<String, dynamic> notification) async {
    await _markAsRead(notification);
    if (!mounted) return;

    final type = (notification['type'] ?? '').toString().trim();
    final title = (notification['title'] ?? '').toString().trim();
    final description = (notification['description'] ??
            notification['body'] ??
            '')
        .toString()
        .trim();
    final zone = (notification['zone'] ?? '').toString().trim();
    final time = _displayTime(notification);
    final icon = _iconForType(type);
    final color = _colorForType(type);
    final isPersonal = _isPersonal(notification);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        final maxH = MediaQuery.sizeOf(ctx).height * 0.88;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.viewInsetsOf(ctx).bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
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
                        Flexible(
                          child: Text(
                            type,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
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
                      if (isPersonal) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              _deleteNotification(notification);
                            },
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                            ),
                            label: Text(
                              l10n.delete,
                              style: GoogleFonts.poppins(),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryRed,
                              side: BorderSide(color: AppTheme.primaryRed),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.close,
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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

  void _showContextMenu(Map<String, dynamic> notification) {
    final l10n = AppLocalizations.of(context)!;
    final isRead = _isRead(notification);
    final isPersonal = _isPersonal(notification);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRead)
                ListTile(
                  leading: const Icon(Icons.mark_email_unread_rounded),
                  title: Text(
                    l10n.markAsUnread,
                    style: GoogleFonts.poppins(),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _markAsUnread(notification);
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.mark_email_read_rounded),
                  title: Text(
                    l10n.markAsRead,
                    style: GoogleFonts.poppins(),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _markAsRead(notification);
                  },
                ),
              if (isPersonal)
                ListTile(
                  leading: Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.primaryRed,
                  ),
                  title: Text(
                    l10n.delete,
                    style: GoogleFonts.poppins(color: AppTheme.primaryRed),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _confirmDelete(notification);
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> notification) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n.deleteNotificationTitle,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.deleteNotificationBody,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
            ),
            child: Text(
              l10n.delete,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _deleteNotification(notification);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unreadCount = _notifications.where((n) => !_isRead(n)).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EA),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.notificationsTitle,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        if (unreadCount > 0)
                          Text(
                            l10n.unreadCount(unreadCount),
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (unreadCount > 0)
                    IconButton(
                      tooltip: l10n.markAllAsRead,
                      icon: const Icon(
                        Icons.done_all_rounded,
                        color: Colors.white,
                      ),
                      onPressed: _markAllAsRead,
                    ),
                  if (_notifications.any(_isPersonal))
                    IconButton(
                      tooltip: l10n.clearAll,
                      icon: const Icon(
                        Icons.delete_sweep_rounded,
                        color: Colors.white,
                      ),
                      onPressed: _clearAll,
                    ),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: _showZoneFilterSheet,
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
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

          Expanded(
            child: _isLoading
                ? const TerangaBrandedLoading()
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
                        final isPersonal = _isPersonal(notification);
                        final isRead = _isRead(notification);

                        final card = _buildNotificationCard(
                          notification: notification,
                          isRead: isRead,
                          isPersonal: isPersonal,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Dismissible(
                            key: ValueKey(notification['id']),
                            direction: isPersonal
                                ? DismissDirection.horizontal
                                : DismissDirection.startToEnd,
                            // Swipe gauche→droite : lu / non-lu
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              decoration: BoxDecoration(
                                color: isRead
                                    ? Colors.orange.shade600
                                    : AppTheme.primaryGreen,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                isRead
                                    ? Icons.mark_email_unread_rounded
                                    : Icons.mark_email_read_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            // Swipe droite→gauche : supprimer (perso uniquement)
                            secondaryBackground: isPersonal
                                ? Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryRed,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  )
                                : null,
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                // Toggle lu / non-lu, pas de suppression
                                if (isRead) {
                                  await _markAsUnread(notification);
                                } else {
                                  await _markAsRead(notification);
                                }
                                return false;
                              }
                              // endToStart = supprimer
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(
                                    l10n.deleteNotificationTitle,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    l10n.deleteNotificationBody,
                                    style: GoogleFonts.poppins(),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: Text(
                                        l10n.cancel,
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryRed,
                                      ),
                                      child: Text(
                                        l10n.delete,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                await _deleteNotification(notification);
                              }
                              return false;
                            },
                            child: card,
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
    required Map<String, dynamic> notification,
    required bool isRead,
    required bool isPersonal,
  }) {
    final type = (notification['type'] ?? '').toString();
    final title = (notification['title'] ?? '').toString();
    final description =
        (notification['description'] ?? notification['body'] ?? '').toString();
    final zone = (notification['zone'] ?? '').toString();
    final time = _displayTime(notification);
    final icon = _iconForType(type);
    final color = _colorForType(type);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFF0FFF4),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(14),
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openNotification(notification),
          onLongPress: () => _showContextMenu(notification),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(icon, color: color, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                type.isEmpty
                                    ? l10n.notificationsFallbackTitle
                                    : type,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                  title.isEmpty ? l10n.notificationsFallbackTitle : title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontWeight:
                        isRead ? FontWeight.w500 : FontWeight.bold,
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
                        zone.isEmpty ? '—' : zone,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isPersonal)
                      const Icon(
                        Icons.swipe_left_rounded,
                        size: 14,
                        color: AppTheme.textSecondary,
                      )
                    else
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
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
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
