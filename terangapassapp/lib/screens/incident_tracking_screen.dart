import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_placeholders.dart';

class IncidentTrackingScreen extends StatefulWidget {
  final int incidentId;

  const IncidentTrackingScreen({super.key, required this.incidentId});

  @override
  State<IncidentTrackingScreen> createState() => _IncidentTrackingScreenState();
}

class _IncidentTrackingScreenState extends State<IncidentTrackingScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic> _tracking = {};

  @override
  void initState() {
    super.initState();
    _loadTracking();
  }

  Future<void> _loadTracking() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService().getIncidentTracking(widget.incidentId);
      if (!mounted) return;
      setState(() => _tracking = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'resolved':
      case 'closed':
        return AppTheme.primaryGreen;
      case 'in_progress':
        return const Color(0xFFD4A017);
      default:
        return const Color(0xFFC73E1D);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress':
        return 'EN COURS - POLICE TOURISTIQUE';
      case 'resolved':
      case 'closed':
        return 'TRAITE';
      default:
        return 'EN ATTENTE';
    }
  }

  List<Map<String, String>> _fallbackTimeline() {
    return const [
      {
        'time': '09:24 · IL Y A 12 MIN',
        'title': 'Signalement recu',
        'desc': 'Votre signalement a ete enregistre et chiffre.',
        'authority': 'Centre Reception',
      },
      {
        'time': '09:24 · IL Y A 12 MIN',
        'title': 'Tri automatique IA',
        'desc': 'Categorise: Securite · Gravite 3/5 · Route.',
        'authority': 'CIVI-VOX',
      },
      {
        'time': '09:25 · IL Y A 11 MIN',
        'title': 'Notifie a l autorite',
        'desc': 'Commissariat Plateau alerte avec preuves.',
        'authority': 'Police Nationale',
      },
      {
        'time': '09:32 · IL Y A 4 MIN',
        'title': 'Patrouille depechee',
        'desc': 'Une equipe se rend sur place. ETA 6 min.',
        'authority': 'Police Touristique',
      },
      {
        'time': 'A venir',
        'title': 'Prise en charge sur place',
        'desc': 'L equipe vous contactera a l arrivee.',
        'authority': '',
      },
    ];
  }

  String _timeLabel(Object? value) {
    final s = (value ?? '').toString().trim();
    if (s.isEmpty) return 'A venir';
    final dt = DateTime.tryParse(s);
    if (dt == null) return 'À venir';
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final status = (_tracking['status'] ?? 'pending').toString();
    final timeline = (_tracking['timeline'] is List)
        ? (_tracking['timeline'] as List)
              .whereType<Map>()
              .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
              .toList()
        : const <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0),
      body: SafeArea(
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
            : Column(
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
                          'Mon signalement',
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
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      children: [
                        Text(
                          'Vol sur la Corniche',
                          style: GoogleFonts.robotoSlab(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1F2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dossier TP-2026-04-${widget.incidentId.toString().padLeft(6, '0')}',
                          style: GoogleFonts.robotoMono(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5EE),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _statusColor(status),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _statusLabel(status),
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2E8B57),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTimelineWithDesign(timeline),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTimelineWithDesign(List<Map<String, dynamic>> apiTimeline) {
    final fallback = _fallbackTimeline();
    final hasReal = apiTimeline.isNotEmpty;
    final rows = hasReal
        ? apiTimeline.asMap().entries.map((entry) {
            final i = entry.key;
            final step = entry.value;
            return {
              'time': _timeLabel(step['at']),
              'title': (step['label'] ?? '').toString(),
              'desc': i < fallback.length ? fallback[i]['desc']! : '',
              'authority': i < fallback.length ? fallback[i]['authority']! : '',
              'done': step['completed'] == true ? '1' : '0',
              'current':
                  (i == apiTimeline.indexWhere((e) => e['completed'] != true) &&
                          step['completed'] != true)
                      ? '1'
                      : '0',
            };
          }).toList()
        : fallback
              .asMap()
              .entries
              .map(
                (entry) => {
                  ...entry.value,
                  'done': entry.key < 3 ? '1' : '0',
                  'current': entry.key == 3 ? '1' : '0',
                },
              )
              .toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Stack(
        children: [
          Positioned(
            left: 9,
            top: 10,
            bottom: 18,
            child: Container(width: 2, color: const Color(0xFFE5DFD3)),
          ),
          Column(
            children: rows
                .map(
                  (row) => _timelineStep(
                    label: (row['title'] ?? '').toString(),
                    time: (row['time'] ?? '').toString(),
                    desc: (row['desc'] ?? '').toString(),
                    authority: (row['authority'] ?? '').toString(),
                    done: (row['done'] ?? '0') == '1',
                    current: (row['current'] ?? '0') == '1',
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _timelineStep({
    required String label,
    required String time,
    required String desc,
    required String authority,
    required bool done,
    required bool current,
  }) {
    final dotColor = done
        ? const Color(0xFF2E8B57)
        : (current ? const Color(0xFFC73E1D) : const Color(0xFFE5DFD3));
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? dotColor : Colors.white,
              border: Border.all(color: dotColor, width: 2),
            ),
            child: done
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: GoogleFonts.robotoMono(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.robotoSlab(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1F2E),
                  ),
                ),
                if (desc.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                if (authority.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    authority,
                    style: GoogleFonts.robotoMono(
                      fontSize: 10,
                      color: const Color(0xFF1A1F2E),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

