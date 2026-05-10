import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_placeholders.dart';

/// Suivi d'un signalement : données réelles API uniquement.
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

  /// Libellé localisé du type d'incident (`perte`, `accident`, `suspect`, `autre`).
  String _incidentTypeLabel(String type, AppLocalizations l10n) {
    switch (type.trim().toLowerCase()) {
      case 'perte':
        return l10n.incidentTypeLossLabel;
      case 'accident':
        return l10n.incidentTypeAccident;
      case 'suspect':
        return l10n.incidentTypeSuspiciousLabel;
      case 'autre':
        return l10n.incidentTypeOtherLabel;
      default:
        return type.isEmpty ? l10n.incidentReportTitle : type;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'resolved':
      case 'closed':
      case 'validated':
        return AppTheme.primaryGreen;
      case 'in_progress':
        return const Color(0xFFD4A017);
      case 'rejected':
        return AppTheme.textSecondary;
      default:
        return const Color(0xFFC73E1D);
    }
  }

  String _statusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'in_progress':
        return l10n.incidentStatusInProgress;
      case 'resolved':
      case 'closed':
        return l10n.incidentStatusProcessed;
      case 'validated':
        return l10n.incidentStatusValidated;
      case 'rejected':
        return l10n.incidentStatusRejected;
      case 'pending':
      default:
        return l10n.incidentStatusPending;
    }
  }

  String _dossierRef() {
    final created =
        DateTime.tryParse((_tracking['created_at'] ?? '').toString());
    if (created != null) {
      final y = created.year;
      final m = created.month.toString().padLeft(2, '0');
      return 'Dossier TP-$y-$m-${widget.incidentId.toString().padLeft(6, '0')}';
    }
    return 'Dossier #${widget.incidentId}';
  }

  String _timeLabel(Object? value) {
    final s = (value ?? '').toString().trim();
    if (s.isEmpty) return '—';
    final dt = DateTime.tryParse(s);
    if (dt == null) return '—';
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  List<Map<String, dynamic>> _timelineRows() {
    final raw = _tracking['timeline'];
    if (raw is! List) return [];
    final list = raw.whereType<Map>().map((e) {
      return Map<String, dynamic>.from(
        e.map((k, v) => MapEntry(k.toString(), v)),
      );
    }).toList();

    final firstIncomplete = list.indexWhere((e) => e['completed'] != true);

    return list.asMap().entries.map((entry) {
      final i = entry.key;
      final step = entry.value;
      final done = step['completed'] == true;
      final anchor = firstIncomplete >= 0 ? firstIncomplete : -1;
      final current = !done && i == anchor;
      return {
        'time': _timeLabel(step['at']),
        'title': (step['label'] ?? '').toString(),
        'done': done,
        'current': current,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = (_tracking['status'] ?? 'pending').toString();
    final type = (_tracking['type'] ?? '').toString();
    final description = (_tracking['description'] ?? '').toString().trim();
    final address = (_tracking['address'] ?? '').toString().trim();
    final typeTitle = _incidentTypeLabel(type, l10n);
    final rows = _timelineRows();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0),
      body: SafeArea(
        child: _isLoading
            ? const TerangaBrandedLoading()
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
                          l10n.incidentTrackingNavTitle,
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
                          typeTitle,
                          style: GoogleFonts.robotoSlab(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A1F2E),
                          ),
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            description,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              height: 1.45,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                        if (address.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 18,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  address,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          _dossierRef(),
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
                                _statusLabel(status, l10n).toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF2E8B57),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (rows.isEmpty)
                          Text(
                            l10n.incidentTrackingEmptyTimeline,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          )
                        else
                          _buildTimeline(rows),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTimeline(List<Map<String, dynamic>> rows) {
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
                    done: row['done'] == true,
                    current: row['current'] == true,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
