import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';

class MedicalAlertScreen extends StatefulWidget {
  const MedicalAlertScreen({super.key});

  @override
  State<MedicalAlertScreen> createState() => _MedicalAlertScreenState();
}

class _MedicalAlertScreenState extends State<MedicalAlertScreen> {
  bool _isAlerting = false;
  String? _currentLocation;
  String? _selectedEmergencyType;

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
      });
    } catch (e) {
      setState(() {
        _currentLocation = "Dakar Plateau, 9 Rue Carnot";
      });
    }
  }

  Future<void> _sendMedicalAlert() async {
    if (_selectedEmergencyType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez sélectionner un type d\'urgence médicale',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return;
    }

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
      await apiService.sendMedicalAlert(
        latitude: location.latitude,
        longitude: location.longitude,
        emergencyType: _selectedEmergencyType!,
        accuracy: location.accuracy,
        address: address,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Alerte Médicale Envoyée',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
            content: Text(
              'Votre alerte médicale a été envoyée aux services médicaux.\n\nUne ambulance est en route.',
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
  }

  void _callSAMU() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Appeler SAMU',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Voulez-vous appeler le SAMU au 15 ?',
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
          'Alerte Médicale',
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
            // Bouton Alerte Médicale principal
            Container(
              margin: const EdgeInsets.only(bottom: 30),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isAlerting ? null : _sendMedicalAlert,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange,
                          Color.fromRGBO(
                            (Colors.orange.red - 30).clamp(0, 255),
                            (Colors.orange.green - 20).clamp(0, 255),
                            (Colors.orange.blue - 20).clamp(0, 255),
                            1.0,
                          ),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.4),
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
                                  Icons.medical_services_rounded,
                                  size: 60,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  'ALERTE MÉDICALE',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Appuyez pour alerter les services médicaux',
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

            // Type d'urgence médicale
            Text(
              'Type d\'urgence médicale',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 15),

            _buildEmergencyTypeOption('Accident', Icons.car_crash_rounded),
            const SizedBox(height: 12),
            _buildEmergencyTypeOption('Malaise', Icons.sick_rounded),
            const SizedBox(height: 12),
            _buildEmergencyTypeOption('Blessure', Icons.healing_rounded),
            const SizedBox(height: 12),
            _buildEmergencyTypeOption('Autre', Icons.help_outline_rounded),

            const SizedBox(height: 30),

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
                            color: Colors.orange,
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
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // SAMU
            _buildEmergencyServiceCard(
              context,
              'SAMU',
              '15',
              Icons.medical_services_rounded,
              AppTheme.primaryRed,
              _callSAMU,
            ),

            const SizedBox(height: 20),

            // Hôpitaux à proximité
            Text(
              'Hôpitaux à proximité',
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
                    'Chargement des hôpitaux...',
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

  Widget _buildEmergencyTypeOption(String type, IconData icon) {
    final isSelected = _selectedEmergencyType == type;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedEmergencyType = type;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.orange.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.orange
                  : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.orange : AppTheme.textSecondary,
                size: 28,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  type,
                  style: GoogleFonts.poppins(
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 16,
                    color: isSelected
                        ? Colors.orange
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Colors.orange,
                  size: 24,
                ),
            ],
          ),
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
