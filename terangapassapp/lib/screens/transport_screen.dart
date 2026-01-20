import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  List<Map<String, dynamic>> _shuttles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShuttles();
  }

  Future<void> _loadShuttles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final shuttles = await apiService.getShuttleSchedules();
      setState(() {
        _shuttles = shuttles.map((s) => s as Map<String, dynamic>).toList();
      });
    } catch (e) {
      // Données de démonstration
      setState(() {
        _shuttles = [
          {
            'id': 1,
            'name': 'Navettes Gratuites JOJ 2026',
            'period': '16-23 AOÛT',
            'schedule': 'Aujourd\'hui (tous les 20min): 08:30 à 19:30',
            'days': 'Navettes gratuites lundi au dimanche',
            'location': 'Dakar Centre',
            'next_departure': '08:30',
            'is_secure': true,
            'type': 'bus',
          },
          {
            'id': 2,
            'name': 'Ligne Express-JOJ',
            'period': '16-18 AOÛT',
            'route': 'Gare des Baux Maraîchers - Blaise Diagne',
            'terminus': 'Acapes DK-13',
            'schedule': 'Aujourd\'hui: 07:00 - 20:00',
            'is_secure': true,
            'type': 'train',
          },
        ];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _getTransportIcon(String type) {
    switch (type) {
      case 'bus':
        return Icons.directions_bus_rounded;
      case 'train':
        return Icons.train_rounded;
      case 'boat':
        return Icons.directions_boat_rounded;
      default:
        return Icons.directions_transit_rounded;
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
          'Transport & Navettes',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ..._shuttles.map((shuttle) => _buildShuttleCard(shuttle)),
              ],
            ),
    );
  }

  Widget _buildShuttleCard(Map<String, dynamic> shuttle) {
    final icon = _getTransportIcon(shuttle['type'] as String? ?? 'bus');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: AppTheme.primaryGreen,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shuttle['name'] as String,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shuttle['period'] as String? ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (shuttle['is_secure'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppTheme.primaryGreen,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Sécurisé',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (shuttle['route'] != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.route,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shuttle['route'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (shuttle['terminus'] != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.place,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Terminus: ${shuttle['terminus']}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    shuttle['schedule'] as String? ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            if (shuttle['days'] != null) ...[
              const SizedBox(height: 8),
              Text(
                shuttle['days'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
            if (shuttle['next_departure'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppTheme.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Prochain départ: ${shuttle['next_departure']}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (shuttle['location'] != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    shuttle['location'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
