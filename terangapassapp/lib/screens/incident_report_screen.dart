import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'dart:io';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/app_theme_extensions.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import 'incident_history_screen.dart';
import 'incident_tracking_screen.dart';

class IncidentReportScreen extends StatefulWidget {
  const IncidentReportScreen({super.key});

  @override
  State<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends State<IncidentReportScreen> {
  String? _selectedIncidentType;
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _photos = [];
  final List<String> _videos = [];
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
      backgroundColor: context.tp.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final sheetTp = context.tp;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: sheetTp.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: Text(l10n.incidentGallery, style: GoogleFonts.poppins(color: sheetTp.textPrimary)),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_rounded),
                title: Text(l10n.incidentCamera, style: GoogleFonts.poppins(color: sheetTp.textPrimary)),
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

  Future<void> _addVideo() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.tp.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final sheetTp = context.tp;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: sheetTp.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.video_library_rounded),
                title: Text(l10n.incidentVideoGallery, style: GoogleFonts.poppins(color: sheetTp.textPrimary)),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.videocam_rounded),
                title: Text(l10n.incidentVideoCamera, style: GoogleFonts.poppins(color: sheetTp.textPrimary)),
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
      final picked = await _imagePicker.pickVideo(source: source);
      if (picked == null) return;
      setState(() {
        _videos.add(picked.path);
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.incidentAddVideoError,
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
      final response = await apiService.reportIncident(
        incidentType: _selectedIncidentType!,
        description: _descriptionController.text.trim(),
        latitude: location.latitude,
        longitude: location.longitude,
        photos: _photos.isNotEmpty ? _photos : null,
        videos: _videos.isNotEmpty ? _videos : null,
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
              TextButton(
                onPressed: () {
                  final incidentData =
                      response['data'] as Map<String, dynamic>? ?? {};
                  final id = incidentData['id'];
                  if (id is int) {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            IncidentTrackingScreen(incidentId: id),
                      ),
                    );
                    return;
                  }
                  Navigator.of(context).pop();
                },
                child: Text(
                  AppLocalizations.of(context)!.incidentTrackAction,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFC73E1D),
                    fontWeight: FontWeight.w700,
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
    final tp = context.tp;
    return Scaffold(
      backgroundColor: tp.scaffoldAlt,
      body: SafeArea(
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
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_rounded,
                          color: tp.textPrimary,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      Text(
                        l10n.incidentReportNavShort,
                        style: GoogleFonts.poppins(
                          color: tp.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: l10n.incidentHistoryTooltip,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const IncidentHistoryScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.history_rounded,
                          color: tp.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.incidentReportTitle,
                        style: GoogleFonts.robotoSlab(
                          fontSize: 35,
                          height: 1.02,
                          fontWeight: FontWeight.w700,
                          color: tp.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.incidentPrivacyNotice,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: tp.textSecondary,
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
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 1.8,
                            color: tp.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 2.2,
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
                              l10n.incidentTypeOtherLabel,
                              Icons.campaign_rounded,
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // Section Description
                        Text(
                          l10n.incidentDescriptionTitle,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 1.8,
                            color: tp.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Container(
                          decoration: BoxDecoration(
                            color: tp.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: tp.border),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: tp.isDark ? 0.2 : 0.05),
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
                                color: tp.textSecondary,
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
                              fillColor: tp.surface,
                            ),
                            style: GoogleFonts.poppins(color: tp.textPrimary),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Section Preuves (photo/video/audio)
                        Text(
                          l10n.incidentPhotosTitle,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                            letterSpacing: 1.8,
                            color: tp.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: _buildEvidenceCard(
                                label: l10n.incidentEvidencePhoto,
                                icon: Icons.photo_camera_rounded,
                                gradient: const [Color(0xFF3FA95E), Color(0xFF93B63D)],
                                onTap: _addPhoto,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildEvidenceCard(
                                label: l10n.incidentEvidenceVideo,
                                icon: Icons.videocam_rounded,
                                gradient: const [Color(0xFF3FA95E), Color(0xFFB2A92F)],
                                highlighted: _videos.isNotEmpty,
                                onTap: _addVideo,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildEvidenceCard(
                                label: l10n.incidentEvidenceAudio,
                                icon: _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                                isOutline: true,
                                highlighted: _audioPath != null || _isRecording,
                                onTap: _recordAudio,
                              ),
                            ),
                          ],
                        ),

                        if (_isRecording || _audioPath != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              color: tp.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isRecording
                                    ? AppTheme.primaryRed.withValues(alpha: 0.4)
                                    : tp.border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isRecording ? Icons.mic_rounded : Icons.check_circle_rounded,
                                  color: _isRecording
                                      ? AppTheme.primaryRed
                                      : AppTheme.primaryGreen,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _isRecording
                                        ? l10n.incidentRecordingInProgress
                                        : l10n.incidentAudioAdded,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: tp.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        if (_photos.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 72,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _photos.length,
                              separatorBuilder: (_, _) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final photo = _photos[index];
                                return Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: tp.border),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(11),
                                    child: photo.startsWith('http')
                                        ? Image.network(photo, fit: BoxFit.cover)
                                        : Image.file(File(photo), fit: BoxFit.cover),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                        if (_videos.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              color: tp.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: tp.border),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.videocam_rounded,
                                  size: 16,
                                  color: tp.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10n.incidentVideosAddedCount(_videos.length),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: tp.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 25),

                        // Localisation
                        if (_currentLocation != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: tp.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: tp.border),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: tp.isDark ? 0.2 : 0.05),
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
                                          color: tp.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        _currentLocation!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: tp.textSecondary,
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
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isSubmitting
                                  ? [Colors.grey, Colors.grey]
                                  : [
                                      const Color(0xFFD84A1B),
                                      const Color(0xFFC73E1D),
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: _isSubmitting
                                    ? Colors.transparent
                                    : const Color(0xFFD84A1B).withValues(
                                        alpha: 0.32,
                                      ),
                                blurRadius: 14,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _isSubmitting ? null : _submitReport,
                              borderRadius: BorderRadius.circular(14),
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
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
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
    );
  }

  Widget _buildIncidentTypeTile(String value, String label, IconData icon) {
    final isSelected = _selectedIncidentType == value;
    final tp = context.tp;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIncidentType = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: tp.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryRed : tp.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryRed
                    : AppTheme.primaryRed.withValues(alpha: tp.isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.primaryRed,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 12,
                  color: isSelected ? AppTheme.primaryRed : tp.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceCard({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    List<Color>? gradient,
    bool isOutline = false,
    bool highlighted = false,
  }) {
    final tp = context.tp;
    final hasGradient = gradient != null && gradient.isNotEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 86,
        decoration: BoxDecoration(
          gradient: hasGradient ? LinearGradient(colors: gradient) : null,
          color: hasGradient ? null : tp.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlighted
                ? AppTheme.primaryRed
                : (isOutline ? tp.border : Colors.transparent),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: tp.isDark ? 0.2 : 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: hasGradient ? Colors.white : tp.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: hasGradient ? Colors.white : tp.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
