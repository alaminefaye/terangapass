import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class JOJInfoScreen extends StatefulWidget {
  const JOJInfoScreen({super.key});

  @override
  State<JOJInfoScreen> createState() => _JOJInfoScreenState();
}

class _JOJInfoScreenState extends State<JOJInfoScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _sites = [];
  List<Map<String, dynamic>> _sports = [];
  List<Map<String, dynamic>> _calendar = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final sites = await apiService.getCompetitionSites();
      final calendar = await apiService.getCompetitionCalendar();

      setState(() {
        _sites = sites.map((s) => s as Map<String, dynamic>).toList();
        _calendar = calendar.map((c) => c as Map<String, dynamic>).toList();
        // Sports de démonstration
        _sports = List.generate(26, (index) => {
          'id': index + 1,
          'name': 'Sport ${index + 1}',
          'icon': Icons.sports_soccer,
        });
      });
    } catch (e) {
      // Données de démonstration
      setState(() {
        _sites = [
          {
            'id': 1,
            'name': 'Stade Olympique',
            'location': 'Dakar Centre',
            'dates': '16-23 AOÛT',
            'description': 'Stade principal des compétitions',
          },
          {
            'id': 2,
            'name': 'Dakar Arena',
            'location': 'Dakar Centre',
            'dates': '16-18 AOÛT',
            'description': 'Arène pour les compétitions intérieures',
          },
        ];
        _calendar = [];
        _sports = List.generate(26, (index) => {
          'id': index + 1,
          'name': 'Sport ${index + 1}',
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          'Infos JOJ',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          labelStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'Calendrier'),
            Tab(text: 'Sports (26)'),
            Tab(text: 'Accès'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildCalendarTab(),
                _buildSportsTab(),
                _buildAccessTab(),
              ],
            ),
    );
  }

  Widget _buildCalendarTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_calendar.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Calendrier à venir',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ..._calendar.map((event) => _buildCalendarEvent(event)),
      ],
    );
  }

  Widget _buildCalendarEvent(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.event,
            color: AppTheme.primaryGreen,
          ),
        ),
        title: Text(
          event['title'] ?? 'Événement',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          event['date'] ?? '',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSportsTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: _sports.length,
      itemBuilder: (context, index) {
        final sport = _sports[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_soccer,
                  size: 40,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(height: 8),
                Text(
                  sport['name'] as String,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccessTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._sites.map((site) => _buildSiteCard(site)),
      ],
    );
  }

  Widget _buildSiteCard(Map<String, dynamic> site) {
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.stadium_rounded,
                    color: AppTheme.primaryGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        site['name'] as String,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        site['location'] as String? ?? 'Dakar',
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                site['dates'] as String? ?? 'Dates à venir',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryYellow,
                ),
              ),
            ),
            if (site['description'] != null) ...[
              const SizedBox(height: 12),
              Text(
                site['description'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Ouvrir la carte avec la localisation
              },
              icon: const Icon(Icons.map, size: 18),
              label: Text(
                'Voir sur la carte',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
