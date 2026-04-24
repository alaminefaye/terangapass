import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class AudioAnnouncementsScreen extends StatefulWidget {
  const AudioAnnouncementsScreen({super.key});

  @override
  State<AudioAnnouncementsScreen> createState() =>
      _AudioAnnouncementsScreenState();
}

class _AudioAnnouncementsScreenState extends State<AudioAnnouncementsScreen> {
  List<Map<String, dynamic>> _announcements = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _playingIndex;
  bool _isPlaying = false;
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _progress = 0.0;
  String _selectedLanguage = 'all';

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
    _player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() {
        _duration = d;
        _progress = _duration.inMilliseconds == 0
            ? 0.0
            : (_position.inMilliseconds / _duration.inMilliseconds).clamp(
                0.0,
                1.0,
              );
      });
    });
    _player.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() {
        _position = p;
        _progress = _duration.inMilliseconds == 0
            ? 0.0
            : (_position.inMilliseconds / _duration.inMilliseconds).clamp(
                0.0,
                1.0,
              );
      });
    });
    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _playingIndex = null;
        _position = Duration.zero;
        _duration = Duration.zero;
        _progress = 0.0;
      });
    });
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = ApiService();
      final announcements = await apiService.getAudioAnnouncements();
      setState(() {
        _announcements = announcements
            .map((a) => a as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      setState(() {
        _announcements = [];
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final s = value.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _togglePlay(int index) async {
    final announcement = _filteredAnnouncements[index];
    final audioUrl = announcement['audio_url'] as String?;
    if (audioUrl == null || audioUrl.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Aucun audio disponible pour cette annonce',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
      return;
    }

    try {
      if (_playingIndex == index && _isPlaying) {
        await _player.pause();
        if (!mounted) return;
        setState(() {
          _isPlaying = false;
        });
        return;
      }

      if (_playingIndex != index) {
        await _player.stop();
        await _player.play(UrlSource(audioUrl));
        if (!mounted) return;
        setState(() {
          _playingIndex = index;
          _isPlaying = true;
          _position = Duration.zero;
          _duration = Duration.zero;
          _progress = 0.0;
        });
        return;
      }

      await _player.resume();
      if (!mounted) return;
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible de lire l\'audio',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppTheme.primaryRed,
        ),
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return 'Il y a ${difference.inDays} jours';
    }
  }

  @override
  Widget build(BuildContext context) {
    final announcements = _filteredAnnouncements;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Contenu principal
          Padding(
            padding: const EdgeInsets.only(top: 140),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadAnnouncements,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                            ),
                            child: Text(
                              'Réessayer',
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _announcements.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.volume_off_rounded,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Aucune annonce disponible',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    itemCount: announcements.length,
                    itemBuilder: (context, index) {
                      final announcement = announcements[index];
                      final isPlaying = _playingIndex == index && _isPlaying;
                      final createdAt = _parseDate(announcement['created_at']);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              offset: const Offset(0, 10),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  // Drapeau/langue
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppTheme.primaryGreen.withValues(
                                            alpha: 0.1,
                                          ),
                                          AppTheme.primaryGreen.withValues(
                                            alpha: 0.05,
                                          ),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      announcement['language'] == 'fr'
                                          ? '🇫🇷 FR'
                                          : announcement['language'] == 'en'
                                          ? '🇬🇧 EN'
                                          : '🇪🇸 ES',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryGreen,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: AppTheme.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          createdAt == null
                                              ? ''
                                              : _formatTime(createdAt),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                announcement['title'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                announcement['content'] as String,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Lecteur audio
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        // Bouton play/pause
                                        GestureDetector(
                                          onTap: () => _togglePlay(index),
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: isPlaying
                                                    ? [
                                                        const Color(0xFFFF5252),
                                                        const Color(0xFFD32F2F),
                                                      ]
                                                    : [
                                                        const Color(0xFF00A86B),
                                                        const Color(0xFF008C5E),
                                                      ],
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color:
                                                      (isPlaying
                                                              ? const Color(
                                                                  0xFFFF5252,
                                                                )
                                                              : const Color(
                                                                  0xFF00A86B,
                                                                ))
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Barre de progression
                                        Expanded(
                                          child: Column(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: LinearProgressIndicator(
                                                  value: isPlaying
                                                      ? _progress
                                                      : 0.0,
                                                  backgroundColor:
                                                      Colors.grey.shade200,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(AppTheme.primaryGreen),
                                                  minHeight: 6,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    isPlaying
                                                        ? _formatDuration(
                                                            _position,
                                                          )
                                                        : '0:00',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: AppTheme
                                                          .textSecondary,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  Text(
                                                    isPlaying
                                                        ? _formatDuration(
                                                            _duration,
                                                          )
                                                        : '0:00',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: AppTheme
                                                          .textSecondary,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // En-tête 3D
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF00A86B), // Primary Green
                    const Color(0xFF008C5E), // Darker Green
                    Colors.teal.shade700,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00A86B).withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Annonces Audio',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.language, color: Colors.white),
                          onPressed: () {
                            _showLanguagePicker();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredAnnouncements {
    if (_selectedLanguage == 'all') return _announcements;
    return _announcements
        .where((a) => (a['language'] as String?) == _selectedLanguage)
        .toList();
  }

  Future<void> _showLanguagePicker() async {
    final selected = await showModalBottomSheet<String>(
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
                leading: const Icon(Icons.public),
                title: Text('Toutes', style: GoogleFonts.poppins()),
                onTap: () => Navigator.of(context).pop('all'),
              ),
              ListTile(
                leading: const Text('FR'),
                title: Text('Français', style: GoogleFonts.poppins()),
                onTap: () => Navigator.of(context).pop('fr'),
              ),
              ListTile(
                leading: const Text('EN'),
                title: Text('English', style: GoogleFonts.poppins()),
                onTap: () => Navigator.of(context).pop('en'),
              ),
              ListTile(
                leading: const Text('ES'),
                title: Text('Español', style: GoogleFonts.poppins()),
                onTap: () => Navigator.of(context).pop('es'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selected == null) return;
    setState(() {
      _selectedLanguage = selected;
      _playingIndex = null;
      _isPlaying = false;
      _position = Duration.zero;
      _duration = Duration.zero;
      _progress = 0.0;
    });
    await _player.stop();
  }
}
