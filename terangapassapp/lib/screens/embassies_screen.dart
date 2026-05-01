import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class EmbassiesScreen extends StatefulWidget {
  const EmbassiesScreen({super.key});

  @override
  State<EmbassiesScreen> createState() => _EmbassiesScreenState();
}

class _EmbassiesScreenState extends State<EmbassiesScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _embassies = [];

  @override
  void initState() {
    super.initState();
    _loadEmbassies();
  }

  Future<void> _loadEmbassies() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ApiService().getEmbassies();
      if (!mounted) return;
      setState(() {
        _embassies = data.map((e) => e as Map<String, dynamic>).toList();
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

  Future<void> _openMap(Map<String, dynamic> embassy) async {
    final q =
        (embassy['address'] ?? embassy['name'] ?? 'Dakar').toString().trim();
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(q)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _call(String phone) async {
    await launchUrl(Uri(scheme: 'tel', path: phone));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F1EA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
        title: Text(
          'Ambassades',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
          : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _embassies.length,
              itemBuilder: (context, index) {
                final item = _embassies[index];
                final name = (item['name'] ?? '-').toString();
                final address = (item['address'] ?? '-').toString();
                final phone = (item['phone'] ?? '').toString().trim();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        address,
                        style: GoogleFonts.poppins(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _openMap(item),
                            icon: const Icon(Icons.map_rounded, size: 16),
                            label: const Text('Carte'),
                          ),
                          const SizedBox(width: 8),
                          if (phone.isNotEmpty)
                            ElevatedButton.icon(
                              onPressed: () => _call(phone),
                              icon: const Icon(Icons.phone_rounded, size: 16),
                              label: const Text('Appeler'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E8B57),
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

