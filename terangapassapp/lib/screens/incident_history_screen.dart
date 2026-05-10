import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_placeholders.dart';
import 'alert_tracking_screen.dart';
import 'incident_tracking_screen.dart';

/// Signalements + SOS + alertes médicales (même liste, tri par date).
class IncidentHistoryScreen extends StatefulWidget {
  const IncidentHistoryScreen({super.key});

  static const String _kindIncident = 'incident';
  static const String _kindSos = 'alert_sos';
  static const String _kindMedical = 'alert_medical';

  @override
  State<IncidentHistoryScreen> createState() => _IncidentHistoryScreenState();
}

class _IncidentHistoryScreenState extends State<IncidentHistoryScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final merged = <Map<String, dynamic>>[];
    Object? firstError;

    try {
      final raw = await ApiService().getIncidentsHistory();
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          merged.add({...e, '_historyKind': IncidentHistoryScreen._kindIncident});
        } else if (e is Map) {
          merged.add({
            ...Map<String, dynamic>.from(e),
            '_historyKind': IncidentHistoryScreen._kindIncident,
          });
        }
      }
    } catch (e) {
      firstError = e;
    }

    try {
      final raw = await ApiService().getAlertsHistory();
      for (final e in raw) {
        Map<String, dynamic> m;
        if (e is Map<String, dynamic>) {
          m = Map<String, dynamic>.from(e);
        } else if (e is Map) {
          m = Map<String, dynamic>.from(e);
        } else {
          continue;
        }
        final t = (m['type'] ?? '').toString().toLowerCase().trim();
        final kind = t == 'medical'
            ? IncidentHistoryScreen._kindMedical
            : IncidentHistoryScreen._kindSos;
        m['_historyKind'] = kind;
        merged.add(m);
      }
    } catch (e) {
      firstError ??= e;
    }

    merged.sort((a, b) {
      final da = _entrySortDate(a);
      final db = _entrySortDate(b);
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    if (!mounted) return;

    if (merged.isEmpty && firstError != null) {
      setState(() {
        _entries = [];
        _error = firstError.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _entries = merged;
      _error = null;
      _isLoading = false;
    });
  }

  DateTime? _entrySortDate(Map<String, dynamic> m) {
    final s =
        (m['created_at'] ?? m['createdAt'] ?? m['updated_at'] ?? '').toString();
    return DateTime.tryParse(s.trim());
  }

  int? _parseId(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'in_progress':
        return 'En traitement';
      case 'resolved':
      case 'closed':
        return 'Traité';
      case 'validated':
        return 'Validé';
      case 'rejected':
        return 'Refusé';
      case 'pending':
        return 'En attente';
      case 'cancelled':
      case 'canceled':
        return 'Annulé';
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
      case 'validated':
        return AppTheme.primaryGreen;
      case 'rejected':
      case 'cancelled':
      case 'canceled':
        return AppTheme.textSecondary;
      default:
        return const Color(0xFFC73E1D);
    }
  }

  String _kindLabel(AppLocalizations l10n, String kind) {
    switch (kind) {
      case IncidentHistoryScreen._kindSos:
        return l10n.historyKindSos;
      case IncidentHistoryScreen._kindMedical:
        return l10n.historyKindMedical;
      default:
        return l10n.historyKindReport;
    }
  }

  IconData _kindIcon(String kind) {
    switch (kind) {
      case IncidentHistoryScreen._kindSos:
        return Icons.emergency_rounded;
      case IncidentHistoryScreen._kindMedical:
        return Icons.medical_services_rounded;
      default:
        return Icons.report_problem_rounded;
    }
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

  String _entryTitle(AppLocalizations l10n, Map<String, dynamic> e) {
    final kind = (e['_historyKind'] ?? IncidentHistoryScreen._kindIncident)
        .toString();
    final id = _parseId(e['id']);
    final prefix = _kindLabel(l10n, kind);
    if (kind == IncidentHistoryScreen._kindIncident) {
      final t = (e['type'] ?? '').toString();
      return '#${id ?? '-'} · $t';
    }
    return '#${id ?? '-'} · $prefix';
  }

  String _entrySubtitleLine(AppLocalizations l10n, Map<String, dynamic> e) {
    final kind = (e['_historyKind'] ?? '').toString();
    if (kind == IncidentHistoryScreen._kindMedical) {
      final et = _medicalEmergencyLabel(
        l10n,
        (e['emergency_type'] ?? e['emergencyType'])?.toString(),
      );
      if (et != null && et.isNotEmpty) return et;
    }
    final addr = (e['address'] ?? '').toString().trim();
    if (addr.isNotEmpty) return addr;
    final desc = (e['description'] ?? '').toString().trim();
    if (desc.isNotEmpty) return desc;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                    l10n.historyUnifiedTitle,
                    textAlign: TextAlign.center,
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
                  : _entries.isEmpty
                  ? Center(
                      child: Text(
                        l10n.historyUnifiedEmpty,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: AppTheme.textSecondary),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAll,
                      color: AppTheme.primaryGreen,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                        itemCount: _entries.length,
                        itemBuilder: (context, index) {
                          final e = _entries[index];
                          final kind = (e['_historyKind'] ??
                                  IncidentHistoryScreen._kindIncident)
                              .toString();
                          final status =
                              (e['status'] ?? 'pending').toString();
                          final id = _parseId(e['id']);
                          final sub = _entrySubtitleLine(l10n, e);

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
                                  color: _statusColor(status)
                                      .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _kindIcon(kind),
                                  color: _statusColor(status),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                _entryTitle(l10n, e),
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
                                  if (sub.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      sub,
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
                              trailing: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                              ),
                              onTap: () {
                                if (kind == IncidentHistoryScreen._kindIncident) {
                                  if (id == null) return;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          IncidentTrackingScreen(
                                        incidentId: id,
                                      ),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AlertTrackingScreen(
                                        alert: Map<String, dynamic>.from(e),
                                      ),
                                    ),
                                  );
                                }
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
