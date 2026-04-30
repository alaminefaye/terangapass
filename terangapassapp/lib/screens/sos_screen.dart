import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
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
  bool _isCountdown = false;
  bool _cancelledCountdown = false;
  int _countdownValue = 3;
  String? _currentLocation;
  double? _locationAccuracy;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _countdownTimer;
  Timer? _alertSoundTimer;

  void _debugLog(Object? message) {
    assert(() {
      debugPrint(message?.toString() ?? '');
      return true;
    }());
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _alertSoundTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Jouer un son de bip pour le décompte
  Future<void> _playBeepSound() async {
    try {
      // Vibrations pour feedback tactile
      HapticFeedback.mediumImpact();

      // Essayer de jouer un son si disponible
      // Pour ajouter des sons: créer assets/sounds/beep.mp3 et mettre à jour pubspec.yaml
      try {
        await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
      } catch (e) {
        // Pas de fichier audio, on utilise juste les vibrations
        _debugLog(
          'Son beep non disponible, utilisation des vibrations uniquement',
        );
      }
    } catch (e) {
      _debugLog('Erreur lecture son: $e');
      HapticFeedback.mediumImpact();
    }
  }

  // Jouer le son d'alerte continu avec vibrations
  Future<void> _playAlertSound() async {
    try {
      // Vibrations répétitives pour simuler l'alerte
      HapticFeedback.heavyImpact();

      // Essayer de jouer un son d'alerte en boucle
      try {
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(AssetSource('sounds/alert.mp3'));
      } catch (e) {
        // Pas de fichier audio, on utilise des vibrations répétitives
        _debugLog(
          'Son alerte non disponible, utilisation des vibrations uniquement',
        );
        _alertSoundTimer = Timer.periodic(const Duration(milliseconds: 400), (
          timer,
        ) {
          HapticFeedback.heavyImpact();
        });
      }
    } catch (e) {
      _debugLog('Erreur lecture alerte: $e');
      // Fallback: vibrations répétitives
      _alertSoundTimer = Timer.periodic(const Duration(milliseconds: 400), (
        timer,
      ) {
        HapticFeedback.heavyImpact();
      });
    }
  }

  // Arrêter le son d'alerte
  Future<void> _stopAlertSound() async {
    _alertSoundTimer?.cancel();
    await _audioPlayer.stop();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationService = LocationService();
      final location = await locationService.getCurrentLocationWithAddress();
      setState(() {
        _currentLocation =
            location['address'] as String? ??
            AppLocalizations.of(context)!.sosUnknownPosition;
        _locationAccuracy = location['accuracy'] as double?;
      });
    } catch (e) {
      setState(() {
        _currentLocation = AppLocalizations.of(context)!.sosFallbackAddress;
        _locationAccuracy = 7.0;
      });
    }
  }

  Future<void> _startCountdown() async {
    setState(() {
      _isCountdown = true;
      _countdownValue = 3;
      _cancelledCountdown = false;
    });

    // Jouer un bip pour chaque nombre du décompte
    for (int i = 3; i >= 1; i--) {
      if (!mounted || _cancelledCountdown) break;

      setState(() {
        _countdownValue = i;
      });

      // Jouer un son de bip
      _playBeepSound();

      // Attendre 1 seconde avant le prochain nombre
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted) return;

    // L'utilisateur a annulé pendant le décompte
    if (_cancelledCountdown) {
      setState(() {
        _isCountdown = false;
        _cancelledCountdown = false;
      });
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.sosCancelled,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.grey.shade700,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isCountdown = false;
    });
    // Démarrer l'envoi de l'alerte avec le son d'alerte
    _sendSOSAlert();
  }

  void _cancelCountdown() {
    setState(() {
      _cancelledCountdown = true;
    });
  }

  Future<void> _sendSOSAlert() async {
    setState(() {
      _isAlerting = true;
    });

    // Démarrer le son d'alerte continu
    _playAlertSound();

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
      // Arrêter le son d'alerte
      await _stopAlertSound();

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
            AppLocalizations.of(context)!.sosSentTitle,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryRed,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.sosSentBody,
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
  }

  void _callEmergency(String number, String service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.callServiceTitle(service),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          AppLocalizations.of(context)!.callServicePrompt(service, number),
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: GoogleFonts.poppins(),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _launchDialer(number);
            },
            child: Text(
              AppLocalizations.of(context)!.call,
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
          // En-tête 3D avec dégradé
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryRed,
                  Color.fromRGBO(
                    ((AppTheme.primaryRed.r * 255.0).round() - 20).clamp(
                      0,
                      255,
                    ),
                    ((AppTheme.primaryRed.g * 255.0).round() - 20).clamp(
                      0,
                      255,
                    ),
                    ((AppTheme.primaryRed.b * 255.0).round() - 20).clamp(
                      0,
                      255,
                    ),
                    1.0,
                  ),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRed.withValues(alpha: 0.3),
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

          SafeArea(
            child: Column(
              children: [
                // Barre de navigation personnalisée
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
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
                        l10n.sosEmergencyTitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        // Bouton SOS principal 3D amélioré
                        GestureDetector(
                          onTap: (_isAlerting || _isCountdown)
                              ? null
                              : _startCountdown,
                          child: Container(
                            height: 220,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.primaryRed,
                                  Color.fromRGBO(
                                    ((AppTheme.primaryRed.r * 255.0).round() -
                                            40)
                                        .clamp(0, 255),
                                    ((AppTheme.primaryRed.g * 255.0).round() -
                                            40)
                                        .clamp(0, 255),
                                    ((AppTheme.primaryRed.b * 255.0).round() -
                                            40)
                                        .clamp(0, 255),
                                    1.0,
                                  ),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryRed.withValues(
                                    alpha: 0.4,
                                  ),
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
                                // Effet de brillance
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      gradient: RadialGradient(
                                        center: Alignment.topLeft,
                                        radius: 1.5,
                                        colors: [
                                          Colors.white.withValues(alpha: 0.3),
                                          Colors.transparent,
                                        ],
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: _isCountdown
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TweenAnimationBuilder<double>(
                                              tween: Tween(
                                                begin: 1.0,
                                                end: 1.5,
                                              ),
                                              duration: const Duration(
                                                milliseconds: 500,
                                              ),
                                              builder: (context, value, child) {
                                                return Transform.scale(
                                                  scale: value,
                                                  child: Container(
                                                    width: 100,
                                                    height: 100,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.2,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.white
                                                              .withValues(
                                                                alpha: 0.3,
                                                              ),
                                                          blurRadius: 20,
                                                          spreadRadius: 5,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '$_countdownValue',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 60,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w900,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              l10n.sosCountdown,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        )
                                      : _isAlerting
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TweenAnimationBuilder<double>(
                                              tween: Tween(
                                                begin: 1.0,
                                                end: 1.2,
                                              ),
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              curve: Curves.easeInOut,
                                              builder: (context, value, child) {
                                                return Transform.scale(
                                                  scale: value,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          20,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.white
                                                          .withValues(
                                                            alpha: 0.2,
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.warning_rounded,
                                                      size: 60,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              l10n.sosAlertSent,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withValues(
                                                  alpha: 0.15,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.1),
                                                    blurRadius: 10,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.touch_app_rounded,
                                                size: 50,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Text(
                                              l10n.sosUrgenceLabel,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontSize: 28,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 2,
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.2),
                                                    offset: const Offset(0, 2),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              l10n.sosPressToAlert,
                                              style: GoogleFonts.poppins(
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                                fontSize: 16,
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

                        const SizedBox(height: 25),

                        // Bouton Annuler (visible uniquement pendant le décompte)
                        if (_isCountdown)
                          GestureDetector(
                            onTap: _cancelCountdown,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppTheme.primaryRed.withValues(
                                    alpha: 0.4,
                                  ),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cancel_rounded,
                                    color: AppTheme.primaryRed,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    l10n.sosCancelAlert,
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.primaryRed,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: 25),
                        if (_currentLocation != null)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
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
                                        color: AppTheme.primaryRed.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.location_on,
                                        color: AppTheme.primaryRed,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Text(
                                      l10n.sosCurrentPosition,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  _currentLocation!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: AppTheme.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                                if (_locationAccuracy != null) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      l10n.sosAccuracy(
                                        _locationAccuracy!.toStringAsFixed(1),
                                      ),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                        const SizedBox(height: 25),

                        // Services de secours
                        Text(
                          l10n.sosEmergencyServices,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Police
                        _buildEmergencyServiceCard(
                          context,
                          l10n.sosServicePolice,
                          '17',
                          Icons.local_police_rounded,
                          Colors.blue,
                          () => _callEmergency('17', l10n.sosServicePolice),
                        ),

                        const SizedBox(height: 15),

                        // Pompiers
                        _buildEmergencyServiceCard(
                          context,
                          l10n.sosServiceFirefighters,
                          '18',
                          Icons.fire_truck_rounded,
                          Colors.orange,
                          () => _callEmergency('18', l10n.sosServiceFirefighters),
                        ),

                        const SizedBox(height: 15),

                        // SAMU
                        _buildEmergencyServiceCard(
                          context,
                          l10n.sosServiceAmbulance,
                          '15',
                          Icons.medical_services_rounded,
                          AppTheme.primaryRed,
                          () => _callEmergency('15', l10n.sosServiceAmbulance),
                        ),

                        const SizedBox(height: 30),

                        // Historique des alertes
                        Text(
                          l10n.sosHistory,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 15),

                        Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.history_rounded,
                                  size: 40,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  l10n.sosNoRecentAlerts,
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
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

  Widget _buildEmergencyServiceCard(
    BuildContext context,
    String service,
    String number,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                        color.withValues(alpha: 0.2),
                        color.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                      width: 1,
                    ),
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
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.sosNumber(number),
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
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
      ),
    );
  }
}
