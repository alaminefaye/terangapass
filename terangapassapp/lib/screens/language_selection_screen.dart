import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import 'auth/login_screen.dart';

/// Écran de sélection de langue affiché une seule fois au premier lancement,
/// avant la connexion. Permet à l'utilisateur de choisir parmi 5 langues.
class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _selected;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  static const List<_LangOption> _langs = [
    _LangOption(
      code: 'fr',
      flag: '🇫🇷',
      nativeName: 'Français',
      subtitle: 'French',
    ),
    _LangOption(
      code: 'en',
      flag: '🇬🇧',
      nativeName: 'English',
      subtitle: 'Anglais',
    ),
    _LangOption(
      code: 'ar',
      flag: '🇸🇦',
      nativeName: 'العربية',
      subtitle: 'Arabic',
      rtl: true,
    ),
    _LangOption(
      code: 'es',
      flag: '🇪🇸',
      nativeName: 'Español',
      subtitle: 'Spanish',
    ),
    _LangOption(
      code: 'pt',
      flag: '🇧🇷',
      nativeName: 'Português',
      subtitle: 'Portuguese',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final code = _selected;
    if (code == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.languageKey, code);
    await prefs.setBool(AppConstants.languageChosenKey, true);
    AppConstants.localeNotifier.value = Locale(code);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF7F0),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  // Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E8B57),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E8B57).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'T',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Teranga Pass',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1F2E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Prompt multilingue
                  Text(
                    'Choisissez votre langue\nChoose your language\nاختر لغتك\nElige tu idioma\nEscolha seu idioma',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12.5,
                      color: const Color(0xFF6B7080),
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Liste des langues
                  Expanded(
                    child: ListView.separated(
                      itemCount: _langs.length,
                      separatorBuilder: (context, idx) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final lang = _langs[index];
                        final isSelected = _selected == lang.code;
                        return _LangTile(
                          lang: lang,
                          selected: isSelected,
                          onTap: () => setState(() => _selected = lang.code),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Bouton continuer
                  AnimatedOpacity(
                    opacity: _selected != null ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 250),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _selected != null ? _confirm : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E8B57),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFF2E8B57),
                          disabledForegroundColor:
                              Colors.white.withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _continueLabelFor(_selected),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _continueLabelFor(String? code) {
    switch (code) {
      case 'fr':
        return 'Continuer';
      case 'ar':
        return 'متابعة';
      case 'es':
        return 'Continuar';
      case 'pt':
        return 'Continuar';
      default:
        return 'Continue';
    }
  }
}

class _LangTile extends StatelessWidget {
  const _LangTile({
    required this.lang,
    required this.selected,
    required this.onTap,
  });

  final _LangOption lang;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2E8B57) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFF2E8B57)
                : const Color(0xFFE5DFD3),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color:
                        const Color(0xFF2E8B57).withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Text(lang.flag, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: lang.rtl
                  ? Directionality(
                      textDirection: TextDirection.rtl,
                      child: nameColumn(selected),
                    )
                  : nameColumn(selected),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  Widget nameColumn(bool selected) {
    final primaryColor = selected ? Colors.white : const Color(0xFF1A1F2E);
    final secondaryColor =
        selected
            ? Colors.white.withValues(alpha: 0.75)
            : const Color(0xFF6B7080);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          lang.nativeName,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
        Text(
          lang.subtitle,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: secondaryColor,
          ),
        ),
      ],
    );
  }
}

class _LangOption {
  const _LangOption({
    required this.code,
    required this.flag,
    required this.nativeName,
    required this.subtitle,
    this.rtl = false,
  });

  final String code;
  final String flag;
  final String nativeName;
  final String subtitle;
  final bool rtl;
}
