import 'package:flutter/material.dart';
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
  int? _playingIndex;
  bool _isPlaying = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
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
      // En cas d'erreur, utiliser des données de démonstration
      setState(() {
        _announcements = [
          {
            'id': 1,
            'title': 'Consignes de sécurité JOJ',
            'content': 'Suivez les consignes de sécurité pour les Jeux Olympiques de la Jeunesse.',
            'language': 'fr',
            'created_at': '2025-01-19T10:00:00Z',
            'audio_url': null,
          },
          {
            'id': 2,
            'title': 'Navettes gratuites disponibles',
            'content': 'Les navettes gratuites sont disponibles tous les jours de 08:30 à 19:30.',
            'language': 'fr',
            'created_at': '2025-01-19T08:00:00Z',
            'audio_url': null,
          },
        ];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _togglePlay(int index) {
    setState(() {
      if (_playingIndex == index && _isPlaying) {
        _isPlaying = false;
      } else {
        _playingIndex = index;
        _isPlaying = true;
        // TODO: Implémenter la lecture audio réelle
      }
    });
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
          'Annonces Audio',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              // TODO: Sélection de langue
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _announcements.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.volume_off_rounded,
                        size: 64,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune annonce disponible',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _announcements.length,
                  itemBuilder: (context, index) {
                    final announcement = _announcements[index];
                    final isPlaying = _playingIndex == index && _isPlaying;
                    final createdAt = DateTime.parse(
                        announcement['created_at'] as String);

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
                                // Drapeau/langue
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryGreen.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    announcement['language'] == 'fr'
                                        ? '🇫🇷 FR'
                                        : announcement['language'] == 'en'
                                            ? '🇬🇧 EN'
                                            : '🇪🇸 ES',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryGreen,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatTime(createdAt),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
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
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Lecteur audio
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      // Bouton play/pause
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _togglePlay(index),
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: isPlaying
                                                  ? AppTheme.primaryRed
                                                  : AppTheme.primaryGreen,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: Colors.white,
                                              size: 28,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Barre de progression
                                      Expanded(
                                        child: Column(
                                          children: [
                                            LinearProgressIndicator(
                                              value: isPlaying ? _progress : 0.0,
                                              backgroundColor:
                                                  Colors.grey[300],
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                AppTheme.primaryGreen,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  '0:00',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color:
                                                        AppTheme.textSecondary,
                                                  ),
                                                ),
                                                Text(
                                                  '1:30',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color:
                                                        AppTheme.textSecondary,
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
    );
  }
}
