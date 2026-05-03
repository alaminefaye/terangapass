import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_placeholders.dart';
import 'incident_tracking_screen.dart';

class IncidentHistoryScreen extends StatefulWidget {
  const IncidentHistoryScreen({super.key});

  @override
  State<IncidentHistoryScreen> createState() => _IncidentHistoryScreenState();
}

class _IncidentHistoryScreenState extends State<IncidentHistoryScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _incidents = [];

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService().getIncidentsHistory();
      if (!mounted) return;
      setState(() {
        _incidents = data.map((e) => e as Map<String, dynamic>).toList();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress':
        return 'En traitement';
      case 'resolved':
      case 'closed':
        return 'Traite';
      default:
        return 'En attente';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'in_progress':
        return const Color(0xFFD4A017);
      case 'resolved':
      case 'closed':
        return AppTheme.primaryGreen;
      default:
        return const Color(0xFFC73E1D);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EA),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF1A1F2E),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Historique des incidents',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1A1F2E),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const CardListLoadingSkeleton()
                  : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                        ),
                      ),
                    )
                  : _incidents.isEmpty
                  ? Center(
                      child: Text(
                        'Aucun signalement',
                        style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadIncidents,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                        itemCount: _incidents.length,
                        itemBuilder: (context, index) {
                          final incident = _incidents[index];
                          final id = incident['id'];
                          final type = (incident['type'] ?? 'incident').toString();
                          final status = (incident['status'] ?? 'pending').toString();
                          final description = (incident['description'] ?? '')
                              .toString()
                              .trim();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              leading: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: _statusColor(status).withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.report_problem_rounded,
                                  color: _statusColor(status),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                '#${id ?? '-'} - $type',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    _statusLabel(status),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: _statusColor(status),
                                    ),
                                  ),
                                  if (description.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                              onTap: () {
                                if (id is! int) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        IncidentTrackingScreen(incidentId: id),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

