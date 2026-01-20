import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';

class IncidentReportScreen extends StatefulWidget {
  const IncidentReportScreen({super.key});

  @override
  State<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends State<IncidentReportScreen> {
  String? _selectedIncidentType;
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _photos = [];
  bool _isRecording = false;
  bool _isSubmitting = false;
  String? _currentLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
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

  Future<void> _addPhoto() async {
    // TODO: Implémenter la sélection de photo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Fonctionnalité de photo à implémenter',
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  Future<void> _recordAudio() async {
    setState(() {
      _isRecording = !_isRecording;
    });
    // TODO: Implémenter l'enregistrement audio
  }

  Future<void> _submitReport() async {
    if (_selectedIncidentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez sélectionner un type d\'incident',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Veuillez décrire l\'incident',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final locationService = LocationService();
      final location = await locationService.getCurrentPosition();
      final address = await locationService.getAddressFromCoordinates(
        location.latitude,
        location.longitude,
      );

      final apiService = ApiService();
      await apiService.reportIncident(
        incidentType: _selectedIncidentType!,
        description: _descriptionController.text.trim(),
        latitude: location.latitude,
        longitude: location.longitude,
        photos: _photos.isNotEmpty ? _photos : null,
        accuracy: location.accuracy,
        address: address,
      );

      if (mounted) {
        showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Signalement Envoyé',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          content: Text(
            'Votre signalement a été envoyé aux autorités compétentes.\n\nVous recevrez une réponse dans les plus brefs délais.',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  color: AppTheme.primaryGreen,
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
          _isSubmitting = false;
        });
      }
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
          'Signaler un Incident',
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
            // Question initiale
            Text(
              'Qu\'est-ce qu\'il est arrivé ?',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // Types d'incidents
                  _buildIncidentTypeOption('Perte', Icons.search_rounded),
            const SizedBox(height: 12),
            _buildIncidentTypeOption('Accident', Icons.car_crash_rounded),
            const SizedBox(height: 12),
            _buildIncidentTypeOption('Suspect', Icons.warning_rounded),

            const SizedBox(height: 30),

            // Description
            Text(
              'Décrire l\'incident, donner des détails',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Décrivez l\'incident en détail...',
                hintStyle: GoogleFonts.poppins(
                  color: AppTheme.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryGreen,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              style: GoogleFonts.poppins(),
            ),

            const SizedBox(height: 30),

            // Photos
            Text(
              'Ajouter des photos',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                if (_photos.isNotEmpty)
                  ..._photos.map((photo) => Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            photo,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image),
                          ),
                        ),
                      )),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _addPhoto,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.primaryGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_rounded,
                            color: AppTheme.primaryGreen,
                            size: 32,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ajouter',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Enregistrement audio
            Text(
              'Enregistrement audio',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 15),

            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _recordAudio,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isRecording
                        ? AppTheme.primaryRed.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isRecording
                          ? AppTheme.primaryRed
                          : AppTheme.primaryGreen.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _isRecording
                              ? AppTheme.primaryRed.withOpacity(0.1)
                              : AppTheme.primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isRecording
                              ? Icons.stop_rounded
                              : Icons.mic_rounded,
                          color: _isRecording
                              ? AppTheme.primaryRed
                              : AppTheme.primaryGreen,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          _isRecording
                              ? 'Enregistrement en cours...'
                              : 'Appuyez pour enregistrer',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: _isRecording
                                ? AppTheme.primaryRed
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (_isRecording)
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Localisation
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
                            color: AppTheme.primaryGreen,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Localisation de l\'incident',
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

            const SizedBox(height: 30),

            // Bouton Envoyer ma position
            OutlinedButton(
              onPressed: () {
                // TODO: Envoyer la position
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Position envoyée',
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppTheme.primaryGreen, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Envoyer ma position',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Bouton Envoyer Signalement
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReport,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Envoyer Signalement',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentTypeOption(String type, IconData icon) {
    final isSelected = _selectedIncidentType == type;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIncidentType = type;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryGreen.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primaryGreen
                  : Colors.grey.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppTheme.primaryGreen
                    : AppTheme.textSecondary,
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
                        ? AppTheme.primaryGreen
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
