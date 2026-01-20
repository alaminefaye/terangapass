import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import 'sos_screen.dart';
import 'medical_alert_screen.dart';
import 'incident_report_screen.dart';
import 'profile_screen.dart';
import 'audio_announcements_screen.dart';
import 'joj_info_screen.dart';
import 'transport_screen.dart';
import 'tourism_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Image de fond en haut
          _buildHeaderImage(context),

          // Contenu scrollable
          SingleChildScrollView(
            child: Column(
              children: [
                // Espace pour l'image header
                const SizedBox(height: 280),

                // Contenu principal
                Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Boutons d'urgence horizontaux
                        _buildEmergencyButtonsRow(context),
                        const SizedBox(height: 0),

                        // Grille de fonctionnalités
                        _buildMainFeaturesSection(context),
                        const SizedBox(height: 8),

                        // Annonce officielle
                        _buildOfficialAnnouncementSection(context),
                        const SizedBox(height: 8),

                        // Infos JOJ avec carte
                        _buildJOJInfoSection(context),
                        const SizedBox(height: 80), // Espace pour la bottom nav
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildHeaderImage(BuildContext context) {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: const AssetImage('assets/images/africaine.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.3),
            BlendMode.darken,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Overlay avec contenu
          SafeArea(
            child: Stack(
              children: [
                // Notifications en haut à droite
                Positioned(
                  top: 8,
                  right: 16,
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryRed,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Logo et titre tout en haut
                Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Drapeau du Sénégal avec étoile
                        _buildSenegalFlag(),
                        const SizedBox(width: 10),
                        // Titre avec "Teranga" en blanc et "Pass" en rouge
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Teranga ',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const TextSpan(
                                text: 'Pass',
                                style: TextStyle(
                                  color: AppTheme.primaryRed,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tagline en bas (position actuelle - ne pas toucher)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Text(
                    AppConstants.appTagline,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSenegalFlag() {
    return Container(
      width: 28,
      height: 18,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
      child: Row(
        children: [
          // Bande verte
          Expanded(child: Container(color: AppTheme.primaryGreen)),
          // Bande jaune avec étoile
          Expanded(
            child: Container(
              color: AppTheme.primaryYellow,
              child: Center(
                child: Icon(Icons.star, color: AppTheme.primaryGreen, size: 10),
              ),
            ),
          ),
          // Bande rouge
          Expanded(child: Container(color: AppTheme.primaryRed)),
        ],
      ),
    );
  }

  Widget _buildSenegalFlagSmall() {
    return Container(
      width: 20,
      height: 14,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(2)),
      child: Row(
        children: [
          // Bande verte
          Expanded(child: Container(color: AppTheme.primaryGreen)),
          // Bande jaune avec étoile
          Expanded(
            child: Container(
              color: AppTheme.primaryYellow,
              child: Center(
                child: Icon(Icons.star, color: AppTheme.primaryGreen, size: 7),
              ),
            ),
          ),
          // Bande rouge
          Expanded(child: Container(color: AppTheme.primaryRed)),
        ],
      ),
    );
  }

  Widget _buildEmergencyButtonsRow(BuildContext context) {
    return Row(
      children: [
        // Bouton SOS Urgence
        Expanded(
          child: _buildHorizontalEmergencyButton(
            context,
            icon: Icons.warning_amber_rounded,
            title: 'SOS Urgence',
            color: AppTheme.emergencyRed,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SOSScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 12),

        // Bouton Alerte Médicale
        Expanded(
          child: _buildHorizontalEmergencyButton(
            context,
            icon: Icons.medical_services_rounded,
            title: 'Alerte Médicale',
            color: AppTheme.medicalRed,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicalAlertScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalEmergencyButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    // Dégradé rouge pour le fond
    final gradientColors = [
      color,
      Color.fromRGBO(
        (color.red - 25).clamp(0, 255),
        (color.green - 15).clamp(0, 255),
        (color.blue - 15).clamp(0, 255),
        1.0,
      ),
    ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Cercle avec icône plus grande
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainFeaturesSection(BuildContext context) {
    final features = [
      {
        'icon': Icons.graphic_eq_rounded,
        'title': 'Annonces Audio',
        'color': AppTheme.primaryGreen,
        'gradient': [AppTheme.primaryGreen, const Color(0xFF00A86B)],
      },
      {
        'icon': Icons.explore_rounded,
        'title': 'Infos Touriste',
        'color': AppTheme.primaryGreen,
        'gradient': [AppTheme.primaryGreen, const Color(0xFF00C97A)],
      },
      {
        'icon': Icons.stadium_rounded,
        'title': 'Sites Compétitions',
        'color': AppTheme.primaryYellow,
        'gradient': [AppTheme.primaryYellow, const Color(0xFFFFD700)],
      },
      {
        'icon': Icons.workspace_premium_rounded,
        'title': 'Compétitions',
        'color': AppTheme.primaryGreen,
        'gradient': [AppTheme.primaryGreen, const Color(0xFF00B86B)],
      },
      {
        'icon': Icons.directions_bus_filled_rounded,
        'title': 'Navettes & Transports',
        'color': AppTheme.primaryYellow,
        'gradient': [AppTheme.primaryYellow, const Color(0xFFFFE135)],
      },
      {
        'icon': Icons.warning_rounded,
        'title': 'Signaler Incident',
        'color': AppTheme.warningYellow,
        'gradient': [AppTheme.warningYellow, const Color(0xFFFF8C00)],
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];

        // Tous les boutons utilisent maintenant le même style avec cercles colorés

        return InkWell(
          onTap: () {
            final title = feature['title'] as String;
            if (title == 'Signaler Incident') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IncidentReportScreen(),
                ),
              );
            } else if (title == 'Annonces Audio') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AudioAnnouncementsScreen(),
                ),
              );
            } else if (title == 'Infos Touriste') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TourismScreen()),
              );
            } else if (title == 'Sites Compétitions' ||
                title == 'Compétitions') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const JOJInfoScreen()),
              );
            } else if (title == 'Navettes & Transports') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransportScreen(),
                ),
              );
            } else {
              _showComingSoon(context, title);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cercle avec dégradé et icône blanche
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: (feature['gradient'] as List<Color>),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (feature['gradient'] as List<Color>)[0]
                          .withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                feature['title'] as String,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOfficialAnnouncementSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Drapeau du Sénégal
                _buildSenegalFlagSmall(),
                const SizedBox(width: 8),
                Text(
                  'Annonce Officielle',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Suivez les consignes de sécurité JOJ Dakar',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            // Lecteur audio
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: 0.15,
                        backgroundColor: AppTheme.backgroundColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '0:15',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '1:02',
                            style: Theme.of(context).textTheme.bodySmall,
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
    );
  }

  Widget _buildJOJInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Drapeau du Sénégal
                Container(
                  width: 20,
                  height: 14,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primaryGreen,
                        AppTheme.primaryYellow,
                        AppTheme.primaryRed,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'INFOS JOJ: Sites Compétitions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JOJInfoScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.calendar_today, size: 14),
                  label: const Text(
                    'Calendrier',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    minimumSize: const Size(0, 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Carte placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.textSecondary.withOpacity(0.2),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Carte des sites',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  // Légende de la carte
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMapLegendItem(
                          Icons.location_on,
                          AppTheme.primaryGreen,
                          'JOJ Villages',
                        ),
                        _buildMapLegendItem(
                          Icons.sports_soccer,
                          Colors.blue,
                          'Sites Sportifs',
                        ),
                        _buildMapLegendItem(
                          Icons.restaurant,
                          AppTheme.primaryRed,
                          'Hôtels & Restos',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapLegendItem(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(context, Icons.home_rounded, 'Accueil', false),
              _buildNavItem(
                context,
                Icons.medical_services_rounded,
                'Alerte Médicale',
                false,
              ),
              _buildNavItem(
                context,
                Icons.warning_amber_rounded,
                'SOS',
                true,
                isSOS: true,
              ),
              _buildNavItem(
                context,
                Icons.report_problem_rounded,
                'Signalement',
                false,
              ),
              _buildNavItem(context, Icons.person_outline, 'Profil', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive, {
    bool isSOS = false,
  }) {
    if (isSOS) {
      // Bouton SOS spécial - plus grand et mis en avant
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SOSScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(35),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.primaryRed,
                        Color.fromRGBO(
                          (AppTheme.primaryRed.red - 25).clamp(0, 255),
                          (AppTheme.primaryRed.green - 15).clamp(0, 255),
                          (AppTheme.primaryRed.blue - 15).clamp(0, 255),
                          1.0,
                        ),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryRed.withOpacity(0.6),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: AppTheme.primaryRed.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'SOS',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Autres boutons normaux
    final circleSize = 40.0;
    final iconSize = 20.0;

    return InkWell(
      onTap: () {
        if (label == 'Accueil') {
          // Déjà sur l'accueil, ne rien faire
        } else if (label == 'Alerte Médicale') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MedicalAlertScreen()),
          );
        } else if (label == 'SOS') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SOSScreen()),
          );
        } else if (label == 'Signalement') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const IncidentReportScreen(),
            ),
          );
        } else if (label == 'Profil') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryGreen.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cercle vert avec icône blanche
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryGreen,
                    Color.fromRGBO(
                      (AppTheme.primaryGreen.red - 20).clamp(0, 255),
                      (AppTheme.primaryGreen.green - 20).clamp(0, 255),
                      (AppTheme.primaryGreen.blue - 20).clamp(0, 255),
                      1.0,
                    ),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: iconSize),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive
                    ? AppTheme.primaryGreen
                    : AppTheme.textSecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: const Text(
          'Cette fonctionnalité sera disponible prochainement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
