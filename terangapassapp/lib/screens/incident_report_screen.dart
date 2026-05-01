import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'dart:io';
import '../l10n/app_localizations.dart';
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
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _audioPath;
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
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationService = LocationService();
      final location = await locationService.getCurrentLocationWithAddress();
      if (!mounted) return;
      setState(() {
        _currentLocation =
            location['address'] as String? ??
            AppLocalizations.of(context)!.unknownPosition;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _currentLocation = "Dakar Plateau, 9 Rue Carnot";
      });
    }
  }

  Future<void> _addPhoto() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: Text(l10n.incidentGallery, style: GoogleFonts.poppins()),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded),
                title: Text(l10n.incidentCamera, style: GoogleFonts.poppins()),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      if (source == ImageSource.gallery) {
        final images = await _imagePicker.pickMultiImage(imageQuality: 85);
        if (images.isEmpty) return;
        setState(() {
          _photos.addAll(images.map((x) => x.path));
        });
      } else {
        final image = await _imagePicker.pickImage(
          source: source,
          imageQuality: 85,
        );
        if (image == null) return;
        setState(() {
          _photos.add(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.incidentAddPhotoError,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
    }
  }

  Future<void> _recordAudio() async {
    if (_isRecording) {
      try {
        final path = await _audioRecorder.stop();
        if (!mounted) return;
        setState(() {
          _isRecording = false;
          _audioPath = path ?? _audioPath;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isRecording = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.incidentStopRecordingError,
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
      return;
    }

    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.incidentMicPermissionDenied,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return;
    }

    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.incidentMicPermissionDenied,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/incident_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _audioPath = path;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isRecording = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.incidentStartRecordingError,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
    }
  }

  Future<void> _submitReport() async {
    if (_selectedIncidentType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.incidentSelectTypeError,
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
            AppLocalizations.of(context)!.incidentDescribeError,
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
        audioPath: _audioPath,
        accuracy: location.accuracy,
        address: address,
      );

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context)!.incidentSentTitle,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            content: Text(
              AppLocalizations.of(context)!.incidentSentBody,
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppLocalizations.of(context)!.ok,
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0),
      body: Stack(
        children: [
          // En-tête maquette
          Container(
            height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFC73E1D),
                  Color.fromRGBO(
                    ((AppTheme.primaryRed.r * 255).round() - 20).clamp(
                      0,
                      255,
                    ),
                    ((AppTheme.primaryRed.g * 255).round() - 20).clamp(
                      0,
                      255,
                    ),
                    ((AppTheme.primaryRed.b * 255).round() - 20).clamp(
                      0,
                      255,
                    ),
                    1.0,
                  ),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFC73E1D).withValues(alpha: 0.3),
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
                        l10n.incidentReportTitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
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
                        const SizedBox(height: 6),

                        // Section Type d'incident
                        Text(
                          l10n.incidentTypeTitle,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 15),

                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.75,
                          children: [
                            _buildIncidentTypeTile(
                              'perte',
                              l10n.incidentTypeLoss,
                              Icons.search_rounded,
                            ),
                            _buildIncidentTypeTile(
                              'accident',
                              l10n.incidentTypeAccident,
                              Icons.car_crash_rounded,
                            ),
                            _buildIncidentTypeTile(
                              'suspect',
                              l10n.incidentTypeSuspicious,
                              Icons.warning_rounded,
                            ),
                            _buildIncidentTypeTile(
                              'autre',
                              'Autre',
                              Icons.campaign_rounded,
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // Section Description
                        Text(
                          l10n.incidentDescriptionTitle,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 15),

                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE5DFD3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _descriptionController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              hintText: l10n.incidentDescriptionHint,
                              hintStyle: GoogleFonts.poppins(
                                color: AppTheme.textSecondary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            style: GoogleFonts.poppins(),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Section Photos
                        Text(
                          l10n.incidentPhotosTitle,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 15),

                        Row(
                          children: [
                            if (_photos.isNotEmpty)
                              ..._photos.map(
                                (photo) => Container(
                                  margin: const EdgeInsets.only(right: 15),
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: photo.startsWith('http')
                                        ? Image.network(
                                            photo,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(Icons.image),
                                          )
                                        : Image.file(
                                            File(photo),
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    const Icon(Icons.image),
                                          ),
                                  ),
                                ),
                              ),
                            GestureDetector(
                              onTap: _addPhoto,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFC73E1D).withValues(alpha: 0.45),
                                    style: BorderStyle.solid,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryGreen.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo_rounded,
                                      color: const Color(0xFFC73E1D),
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.incidentAdd,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: const Color(0xFFC73E1D),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // Section Audio
                        Text(
                          l10n.incidentAudioTitle,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 15),

                        GestureDetector(
                          onTap: _recordAudio,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _isRecording
                                  ? AppTheme.primaryRed.withValues(alpha: 0.05)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isRecording
                                    ? AppTheme.primaryRed.withValues(alpha: 0.5)
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _isRecording
                                      ? AppTheme.primaryRed.withValues(
                                          alpha: 0.1,
                                        )
                                      : Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: _isRecording
                                        ? AppTheme.primaryRed.withValues(
                                            alpha: 0.1,
                                          )
                                        : AppTheme.primaryGreen.withValues(
                                            alpha: 0.1,
                                          ),
                                    borderRadius: BorderRadius.circular(15),
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _isRecording
                                            ? l10n.incidentRecordingInProgress
                                            : l10n.incidentAddVoiceMessage,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: _isRecording
                                              ? AppTheme.primaryRed
                                              : AppTheme.textPrimary,
                                        ),
                                      ),
                                      if (!_isRecording)
                                        Text(
                                          _audioPath == null
                                              ? l10n.incidentTapToRecord
                                              : l10n.incidentAudioAdded,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                if (_isRecording)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryRed,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'REC',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Localisation
                        if (_currentLocation != null)
                          Container(
                            padding: const EdgeInsets.all(16),
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
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    color: AppTheme.primaryGreen,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.incidentLocationTitle,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
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
                              ],
                            ),
                          ),

                        const SizedBox(height: 30),

                        // Bouton Envoyer
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isSubmitting
                                  ? [Colors.grey, Colors.grey]
                                  : [
                                      AppTheme.primaryGreen,
                                      Color.fromRGBO(
                                        ((AppTheme.primaryGreen.r * 255)
                                                    .round() -
                                                20)
                                            .clamp(0, 255),
                                        ((AppTheme.primaryGreen.g * 255)
                                                    .round() -
                                                20)
                                            .clamp(0, 255),
                                        ((AppTheme.primaryGreen.b * 255)
                                                    .round() -
                                                20)
                                            .clamp(0, 255),
                                        1.0,
                                      ),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: _isSubmitting
                                    ? Colors.transparent
                                    : AppTheme.primaryGreen.withValues(
                                        alpha: 0.3,
                                      ),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isSubmitting ? null : _submitReport,
                              borderRadius: BorderRadius.circular(20),
                              child: Center(
                                child: _isSubmitting
                                    ? const SizedBox(
                                        height: 25,
                                        width: 25,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : Text(
                                        l10n.incidentSendReport,
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                              ),
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

  Widget _buildIncidentTypeTile(String value, String label, IconData icon) {
    final isSelected = _selectedIncidentType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIncidentType = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFC73E1D) : const Color(0xFFE5DFD3),
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFC73E1D).withValues(alpha: 0.14)
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
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFFC73E1D),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 13,
                  color: isSelected
                      ? const Color(0xFFC73E1D)
                      : AppTheme.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFC73E1D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }
}
