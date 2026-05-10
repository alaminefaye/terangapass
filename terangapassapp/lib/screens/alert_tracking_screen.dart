import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Détail d’une alerte SOS ou médicale : même structure visuelle que
/// [IncidentTrackingScreen], à partir des données renvoyées par l’API.
class AlertTrackingScreen extends StatelessWidget {
  const AlertTrackingScreen({super.key, required this.alert});

  /// Carte brute issue de `alerts/history` (champs `id`, `type`, `status`, etc.).
  final Map<String, dynamic> alert;

  static const String _kindMedical = 'alert_medical';

  int? _parseId(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  bool _isMedical(Map<String, dynamic> a) {
    final k = (a['_historyKind'] ?? '').toString();
    if (k == _kindMedical) return true;
    return (a['type'] ?? '').toString().toLowerCase().trim() == 'medical';
  }

  String? _medicalEmergencyLabel(AppLocalizations l10n, String? code) {
    final c = (code ?? '').trim().toLowerCase();
    switch (c) {
      case 'accident':
        return l10n.medicalTypeAccident;
      case 'fainting':
      case 'malaise':
        return l10n.medicalTypeFainting;
      case 'injury':
      case 'blessure':
        return l10n.medicalTypeInjury;
      case 'other':
      case 'autre':
        return l10n.medicalTypeOther;
      default:
        return code?.trim().isEmpty ?? true ? null : code;
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
      case 'cancelled':
      case 'canceled':
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
      case 'cancelled':
      case 'canceled':
        return l10n.incidentStatusCancelled;
      case 'pending':
      default:
        return l10n.incidentStatusPending;
    }
  }

  String _dossierRef(Map<String, dynamic> a) {
    final id = _parseId(a['id']) ?? 0;
    final created = DateTime.tryParse((a['created_at'] ?? '').toString());
    if (created != null) {
      final y = created.year;
      final m = created.month.toString().padLeft(2, '0');
      return 'Dossier TP-$y-$m-${id.toString().padLeft(6, '0')}';
    }
    return 'Dossier #$id';
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

  List<Map<String, dynamic>> _timelineRows(AppLocalizations l10n) {
    final st = (alert['status'] ?? 'pending').toString();
    final created = (alert['created_at'] ?? '').toString();
    final updated = (alert['updated_at'] ?? '').toString();
    final resolvedAt = (alert['resolved_at'] ?? '').toString();

    final s2Done = st != 'pending';
    final s3Done = const {
      'resolved',
      'closed',
      'validated',
      'rejected',
      'cancelled',
      'canceled',
    }.contains(st);

    final String step3Label;
    if (st == 'rejected') {
      step3Label = l10n.alertTimelineRejected;
    } else if (st == 'cancelled' || st == 'canceled') {
      step3Label = l10n.alertTimelineCancelled;
    } else {
      step3Label = l10n.alertTimelineClosed;
    }

    final steps = <Map<String, dynamic>>[
      {
        'at': created,
        'label': l10n.alertTimelineRecorded,
        'completed': true,
      },
      {
        'at': s2Done ? (updated.isNotEmpty ? updated : created) : '',
        'label': l10n.alertTimelineDispatched,
        'completed': s2Done,
      },
      {
        'at': s3Done
            ? (resolvedAt.isNotEmpty
                  ? resolvedAt
                  : (updated.isNotEmpty ? updated : created))
            : '',
        'label': step3Label,
        'completed': s3Done,
      },
    ];

    final firstIncomplete = steps.indexWhere((e) => e['completed'] != true);
    final anchor = firstIncomplete >= 0 ? firstIncomplete : -1;

    return steps.asMap().entries.map((entry) {
      final i = entry.key;
      final step = entry.value;
      final done = step['completed'] == true;
      final current = !done && i == anchor;
      return {
        'time': _timeLabel(step['at']),
        'title': (step['label'] ?? '').toString(),
        'done': done,
        'current': current,
      };
    }).toList();
  }

  DateTime? _sortDate(Map<String, dynamic> a) {
    final s =
        (a['created_at'] ?? a['createdAt'] ?? a['updated_at'] ?? '').toString();
    return DateTime.tryParse(s.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = (alert['status'] ?? 'pending').toString();
    final medical = _isMedical(alert);
    final kindTitle =
        medical ? l10n.historyKindMedical : l10n.historyKindSos;
    final emergencyLabel = medical
        ? _medicalEmergencyLabel(
            l10n,
            (alert['emergency_type'] ?? alert['emergencyType'])?.toString(),
          )
        : null;
    final notes =
        (alert['notes'] ?? alert['description'] ?? '').toString().trim();
    final address = (alert['address'] ?? '').toString().trim();
    final lat = alert['latitude'];
    final lon = alert['longitude'];
    final rows = _timelineRows(l10n);
    final created = _sortDate(alert);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0),
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
                    l10n.alertTrackingNavTitle,
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
                    kindTitle,
                    style: GoogleFonts.robotoSlab(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1F2E),
                    ),
                  ),
                  if (emergencyLabel != null && emergencyLabel.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      emergencyLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.45,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      notes,
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
                  if (lat != null && lon != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.explore_outlined,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${l10n.historyFieldCoords}: ${lat.toString()}, ${lon.toString()}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (created != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.historyFieldDate}: ${DateFormat('d MMM yyyy, HH:mm', Localizations.localeOf(context).languageCode).format(created.toLocal())}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    _dossierRef(alert),
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
