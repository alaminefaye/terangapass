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
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
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
      });
    } catch (e) {
      // Données de démonstration en cas d'erreur
      setState(() {
        _notifications = [
          {
            'id': 1,
            'type': 'Sécurité',
            'title': 'Alerte Sécurité: Stadium Assane vigilance!',
            'description':
                'Renforcement de la sécurité autour du stade. Soyez vigilant.',
            'time': 'Il y a 5 min',
            'zone': 'Dakar Centre',
            'icon': Icons.security_rounded,
            'color': AppTheme.primaryRed,
          },
          {
            'id': 2,
            'type': 'Transport',
            'title': 'Navettes Gratuites JOJ 2026',
            'description':
                'Navettes gratuites disponibles tous les jours de 08:30 à 19:30.',
            'time': 'Il y a 15 min',
            'zone': 'Dakar Centre',
            'icon': Icons.directions_bus_rounded,
            'color': AppTheme.primaryGreen,
          },
          {
            'id': 3,
            'type': 'Météo',
            'title': 'Météo: Chaleur importante ce midi',
            'description': 'Température: 35°C. Pensez à vous hydrater.',
            'time': 'Il y a 1h',
            'zone': 'Toutes les zones',
            'icon': Icons.wb_sunny_rounded,
            'color': Colors.orange,
          },
          {
            'id': 4,
            'type': 'Sécurité routière',
            'title': 'Sécurité routière: Pose de dispositifs de sécurité',
            'description':
                'Travaux en cours sur la route principale. Ralentissez.',
            'time': 'Il y a 2h',
            'zone': 'Plateau',
            'icon': Icons.construction_rounded,
            'color': Colors.blue,
          },
        ];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
              // TODO: Ouvrir le filtre
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
                    items: [
                      'Toutes les zones',
                      'Dakar Centre',
                      'M\'Bour 4 Stadium',
                      'Plateau',
                    ].map((String zone) {
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
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildNotificationCard(
                              type: notification['type'] as String,
                              title: notification['title'] as String,
                              description: notification['description'] as String,
                              time: notification['time'] as String,
                              zone: notification['zone'] as String,
                              icon: notification['icon'] as IconData,
                              color: notification['color'] as Color,
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                    color: color.withOpacity(0.1),
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
}
