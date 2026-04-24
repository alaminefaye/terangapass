import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedZone = 'Toutes les zones';
  List<String> _zones = const ['Toutes les zones'];
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      final notifications = await apiService.getNotifications(
        zone: _selectedZone == 'Toutes les zones' ? null : _selectedZone,
      );
      setState(() {
        _notifications = notifications
            .map((n) => n as Map<String, dynamic>)
            .toList();
        _zones = [
          'Toutes les zones',
          ...{
            for (final n in _notifications) (n['zone'] ?? '').toString().trim(),
          }.where((z) => z.isNotEmpty),
        ];
      });
    } catch (e) {
      setState(() {
        _notifications = [];
        _zones = const ['Toutes les zones'];
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
    final dt = _parseDate(createdAt);
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt.isAfter(now) ? now : dt);
    if (diff.inMinutes < 1) return 'À l’instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    return 'Il y a ${diff.inDays} j';
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
          'Notifications',
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
                  'Zone:',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedZone,
                    isExpanded: true,
                    underline: Container(),
                    items: _zones.map((String zone) {
                      return DropdownMenuItem<String>(
                        value: zone,
                        child: Text(
                          zone,
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedZone = newValue;
                        });
                        _loadNotifications();
                      }
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
                              'Réessayer',
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
                          'Aucune notification',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
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

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildNotificationCard(
                          type: type.isEmpty ? 'Notification' : type,
                          title: title.isEmpty ? 'Notification' : title,
                          description: description,
                          time: time,
                          zone: zone.isEmpty ? '—' : zone,
                          icon: icon,
                          color: color,
                        ),
                      );
                    },
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
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                Text(
                  zone,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite_border, size: 20),
                      color: AppTheme.textSecondary,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.comment_outlined, size: 20),
                      color: AppTheme.textSecondary,
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 20),
                      color: AppTheme.textSecondary,
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showZoneFilterSheet() async {
    final zones = [
      'Toutes les zones',
      'Dakar Centre',
      'M\'Bour 4 Stadium',
      'Plateau',
    ];

    final selected = await showModalBottomSheet<String>(
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
              ...zones.map(
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

    if (selected == null) return;
    if (selected == _selectedZone) return;
    setState(() {
      _selectedZone = selected;
    });
    await _loadNotifications();
  }
}
