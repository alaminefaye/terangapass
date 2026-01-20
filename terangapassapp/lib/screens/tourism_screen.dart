import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class TourismScreen extends StatefulWidget {
  const TourismScreen({super.key});

  @override
  State<TourismScreen> createState() => _TourismScreenState();
}

class _TourismScreenState extends State<TourismScreen> {
  String _selectedCategory = 'Tous';
  final List<String> _categories = [
    'Tous',
    'Hôtels',
    'Restaurants',
    'Pharmacies',
    'Hôpitaux',
    'Ambassades',
  ];
  List<Map<String, dynamic>> _pointsOfInterest = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPointsOfInterest();
  }

  Future<void> _loadPointsOfInterest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final points = await apiService.getPointsOfInterest();
      setState(() {
        _pointsOfInterest =
            points.map((p) => p as Map<String, dynamic>).toList();
      });
    } catch (e) {
      // Données de démonstration
      setState(() {
        _pointsOfInterest = [
          {
            'id': 1,
            'name': 'Hôtel Radisson Dakar',
            'category': 'Hôtels',
            'distance': '6 min en voiture',
            'rating': 4.5,
          },
          {
            'id': 2,
            'name': 'Restaurant Chez Loutcha',
            'category': 'Restaurants',
            'distance': '4 min à pied',
            'rating': 4.2,
          },
          {
            'id': 3,
            'name': 'Pharmacie Medina',
            'category': 'Pharmacies',
            'distance': '3 min à pied',
          },
          {
            'id': 4,
            'name': 'Hôpital Principal de Dakar',
            'category': 'Hôpitaux',
            'distance': '10 min en voiture',
          },
          {
            'id': 5,
            'name': 'Ambassade de France',
            'category': 'Ambassades',
            'distance': '8 min en voiture',
          },
        ];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Hôtels':
        return Icons.hotel_rounded;
      case 'Restaurants':
        return Icons.restaurant_rounded;
      case 'Pharmacies':
        return Icons.local_pharmacy_rounded;
      case 'Hôpitaux':
        return Icons.local_hospital_rounded;
      case 'Ambassades':
        return Icons.account_balance_rounded;
      default:
        return Icons.place_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Hôtels':
        return Colors.blue;
      case 'Restaurants':
        return Colors.orange;
      case 'Pharmacies':
        return Colors.purple;
      case 'Hôpitaux':
        return AppTheme.primaryRed;
      case 'Ambassades':
        return Colors.indigo;
      default:
        return AppTheme.primaryGreen;
    }
  }

  List<Map<String, dynamic>> get _filteredPoints {
    if (_selectedCategory == 'Tous') {
      return _pointsOfInterest;
    }
    return _pointsOfInterest
        .where((point) => point['category'] == _selectedCategory)
        .toList();
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
          'Tourisme & Services',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filtres
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        category,
                        style: GoogleFonts.poppins(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textPrimary,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: Colors.white,
                      selectedColor: AppTheme.primaryGreen,
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.primaryGreen
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Liste
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPoints.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 64,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun résultat',
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
                        itemCount: _filteredPoints.length,
                        itemBuilder: (context, index) {
                          final point = _filteredPoints[index];
                          final category = point['category'] as String;
                          final icon = _getCategoryIcon(category);
                          final color = _getCategoryColor(category);

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
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(icon, color: color, size: 24),
                              ),
                              title: Text(
                                point['name'] as String,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        point['distance'] as String? ?? '',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (point['rating'] != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          size: 14,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${point['rating']}',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                              trailing: Icon(
                                Icons.chevron_right,
                                color: Colors.grey[400],
                              ),
                              onTap: () {
                                // TODO: Afficher les détails
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
