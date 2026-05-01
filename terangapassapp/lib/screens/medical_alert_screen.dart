import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
    try {
      final locationService = LocationService();
      final location = await locationService.getCurrentLocationWithAddress();
      if (!mounted) return;
      setState(() {
        _currentLocation =
            location['address'] as String? ?? l10n.unknownPosition;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentLocation = l10n.unknownPosition;
      });
    }
  }

  Future<void> _sendMedicalAlert() async {
    if (_selectedEmergencyType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.medicalSelectTypeError,
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
              AppLocalizations.of(context)!.medicalSentTitle,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryRed,
              ),
            ),
            content: Text(
              AppLocalizations.of(context)!.medicalSentBody,
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  AppLocalizations.of(context)!.ok,
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.callServiceTitle('SAMU'),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.callServicePrompt('SAMU', '15'),
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel, style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _launchDialer('15');
            },
            child: Text(
              l10n.call,
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

  Future<void> _launchDialer(String number) async {
    final uri = Uri(scheme: 'tel', path: number);
    try {
      await launchUrl(uri);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.openPhoneError,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // En-tête 3D avec dégradé (Background)
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A1F2E),
                  const Color(0xFF2A2F4E),
                  const Color(0xFFC73E1D),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),

          // Cercles décoratifs
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            top: 50,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // Body Content
          SafeArea(
            child: Column(
              children: [
                // Barre de navigation
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        l10n.medicalAlertTitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Bouton Alerte Médicale principal
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isAlerting ? null : _sendMedicalAlert,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              height: 220,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: const [
                                    Color(0xFFC73E1D),
                                    Color(0xFFAA3419),
                                    Color(0xFF8B2515),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                  color: const Color(0xFFC73E1D).withValues(alpha: 0.32),
                                    blurRadius: 25,
                                    offset: const Offset(0, 15),
                                    spreadRadius: -5,
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    blurRadius: 20,
                                    offset: const Offset(-5, -5),
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Decorative circles
                                  Positioned(
                                    top: -20,
                                    right: -20,
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: -30,
                                    left: -30,
                                    child: Container(
                                      width: 150,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: _isAlerting
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 3,
                                              ),
                                              const SizedBox(height: 20),
                                              Text(
                                                l10n.medicalSending,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  20,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.2),
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.1,
                                                          ),
                                                      blurRadius: 10,
                                                      offset: const Offset(
                                                        0,
                                                        5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons
                                                      .medical_services_rounded,
                                                  size: 50,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Text(
                                                l10n.medicalAlertTitle
                                                    .toUpperCase(),
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 1.5,
                                                  shadows: [
                                                    Shadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.2,
                                                          ),
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                      blurRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                l10n.medicalTapToAlert,
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.9),
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Type d'urgence médicale
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Text(
                            l10n.medicalEmergencyTypeTitle,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),

                        _buildEmergencyTypeOption(
                          'accident',
                          l10n.medicalTypeAccident,
                          Icons.car_crash_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildEmergencyTypeOption(
                          'malaise',
                          l10n.medicalTypeFainting,
                          Icons.sick_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildEmergencyTypeOption(
                          'blessure',
                          l10n.medicalTypeInjury,
                          Icons.healing_rounded,
                        ),
                        const SizedBox(height: 12),
                        _buildEmergencyTypeOption(
                          'autre',
                          l10n.medicalTypeOther,
                          Icons.help_outline_rounded,
                        ),

                        const SizedBox(height: 30),

                        // Informations de localisation
                        if (_currentLocation != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.08),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFC73E1D).withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.location_on,
                                        color: const Color(0xFFC73E1D),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      l10n.medicalYourPosition,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Text(
                                    _currentLocation!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // SAMU
                        _buildEmergencyServiceCard(
                          context,
                          'SAMU',
                          '15',
                          Icons.medical_services_rounded,
                          AppTheme.primaryRed,
                          _callSAMU,
                        ),

                        const SizedBox(height: 30),

                        // Hôpitaux à proximité
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 12),
                          child: Text(
                            l10n.medicalNearbyHospitals,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              l10n.medicalNoNearbyHospitals,
                              style: GoogleFonts.poppins(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
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

  Widget _buildEmergencyTypeOption(String value, String label, IconData icon) {
    final isSelected = _selectedEmergencyType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEmergencyType = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFC73E1D) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFC73E1D).withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isSelected ? 15 : 10,
              offset: isSelected ? const Offset(0, 8) : const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFC73E1D)
                    : const Color(0xFFFAE6E1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFFC73E1D),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 16,
                  color: isSelected ? const Color(0xFFC73E1D) : AppTheme.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Color(0xFFC73E1D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
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
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: -5,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.1),
                      color.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppLocalizations.of(
                          context,
                        )!.medicalEmergencyNumberLabel(number),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
