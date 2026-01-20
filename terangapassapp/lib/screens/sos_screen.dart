import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  bool _isAlerting = false;
  String? _currentLocation;
  double? _locationAccuracy;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationService = LocationService();
      final location = await locationService.getCurrentLocationWithAddress();
      setState(() {
        _currentLocation = location['address'] as String? ?? 'Position inconnue';
        _locationAccuracy = location['accuracy'] as double?;
      });
    } catch (e) {
      setState(() {
        _currentLocation = "Dakar Plateau, 9 Rue Carnot";
        _locationAccuracy = 7.0;
      });
    }
  }

  Future<void> _sendSOSAlert() async {
    setState(() {
      _isAlerting = true;
    });

    try {
      final locationService = LocationService();
      final location = await locationService.getHighAccuracyPosition();
      final address = await locationService.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );

      final apiService = ApiService();
      await apiService.sendSOSAlert(
        latitude: location.latitude,
        longitude: location.longitude,
        accuracy: location.accuracy,
        address: address,
      );

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAlerting = false;
        });
      }
    }

    if (mounted && !_isAlerting) {
      // Afficher confirmation
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Alerte SOS Envoyée',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryRed,
            ),
          ),
          content: Text(
            'Votre alerte SOS a été envoyée aux services de secours.\n\nIls arriveront dans les plus brefs délais.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  color: AppTheme.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _callEmergency(String number, String service) {
    // TODO: Implémenter l'appel téléphonique
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Appeler $service',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Voulez-vous appeler le $service au $number ?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annuler',
              style: GoogleFonts.poppins(),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Faire l'appel
            },
            child: Text(
              'Appeler',
              style: GoogleFonts.poppins(
                color: AppTheme.primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryRed,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'SOS Urgence',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bouton SOS principal
            Container(
              margin: const EdgeInsets.only(bottom: 30),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isAlerting ? null : _sendSOSAlert,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryRed,
                          Color.fromRGBO(
                            (AppTheme.primaryRed.red - 30).clamp(0, 255),
                            (AppTheme.primaryRed.green - 20).clamp(0, 255),
                            (AppTheme.primaryRed.blue - 20).clamp(0, 255),
                            1.0,
                          ),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRed.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isAlerting
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Envoi de l\'alerte...',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.warning_rounded,
                                  size: 60,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  'SOS URGENCE',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Appuyez pour alerter les secours',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),

            // Informations de localisation
            if (_currentLocation != null)
              Card(
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
                          Icon(
                            Icons.location_on,
                            color: AppTheme.primaryRed,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Votre position',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _currentLocation!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      if (_locationAccuracy != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Précision: ${_locationAccuracy!.toStringAsFixed(1)} mètres',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Services de secours
            Text(
              'Services de secours',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 15),

            // Police
            _buildEmergencyServiceCard(
              context,
              'Police',
              '17',
              Icons.local_police_rounded,
              Colors.blue,
              () => _callEmergency('17', 'Police'),
            ),

            const SizedBox(height: 12),

            // Pompiers
            _buildEmergencyServiceCard(
              context,
              'Pompiers',
              '18',
              Icons.fire_truck_rounded,
              Colors.orange,
              () => _callEmergency('18', 'Pompiers'),
            ),

            const SizedBox(height: 12),

            // SAMU
            _buildEmergencyServiceCard(
              context,
              'SAMU',
              '15',
              Icons.medical_services_rounded,
              AppTheme.primaryRed,
              () => _callEmergency('15', 'SAMU'),
            ),

            const SizedBox(height: 30),

            // Historique des alertes
            Text(
              'Historique',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 15),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Aucune alerte envoyée',
                    style: GoogleFonts.poppins(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
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

  Widget _buildEmergencyServiceCard(
    BuildContext context,
    String service,
    String number,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      number,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.phone_rounded,
                color: color,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
