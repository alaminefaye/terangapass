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
      if (!mounted) return;
      setState(() {
        _currentLocation =
            location['address'] as String? ??
            AppLocalizations.of(context)!.sosUnknownPosition;
        _locationAccuracy = location['accuracy'] as double?;
      });
    } catch (e) {
      if (!mounted) return;
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
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                  Text(
                    l10n.sosEmergencyTitle,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'URGENCE - MAINTENEZ APPUYE',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFC73E1D),
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Vous etes\nen danger ?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.sosPressToAlert,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: (_isAlerting || _isCountdown) ? null : _startCountdown,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [Color(0xFFC73E1D), Color(0xFF8B2515)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFC73E1D).withValues(alpha: 0.45),
                        blurRadius: 35,
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFC73E1D).withValues(alpha: 0.35),
                      width: 6,
                    ),
                  ),
                  child: Center(
                    child: _isCountdown
                        ? Text(
                            '$_countdownValue',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 72,
                              fontWeight: FontWeight.w800,
                            ),
                          )
                        : _isAlerting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'SOS',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 46,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '3 SECONDES',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  letterSpacing: 2,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              if (_isCountdown) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _cancelCountdown,
                  child: Text(
                    l10n.sosCancelAlert,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 26),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded, color: Color(0xFF2E8B57)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        [
                          _currentLocation ?? l10n.sosUnknownPosition,
                          if (_locationAccuracy != null)
                            '(${_locationAccuracy!.toStringAsFixed(1)} m)',
                        ].join(' '),
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _callEmergency('17', l10n.sosServicePolice),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                        foregroundColor: Colors.white,
                        textStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      child: const Text('Police'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _callEmergency('18', l10n.sosServiceFirefighters),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                        foregroundColor: Colors.white,
                        textStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      child: const Text('Pompiers'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          _callEmergency('15', l10n.sosServiceAmbulance),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                        foregroundColor: Colors.white,
                        textStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      child: const Text('SAMU'),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

}
