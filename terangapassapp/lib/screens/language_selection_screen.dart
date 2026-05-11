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
    with TickerProviderStateMixin {
  String? _selected;
  bool _isConfirming = false;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final AnimationController _btnController;
  late final Animation<double> _btnPulse;

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

    // Animation du bouton : pulse continu + scale au tap
    _btnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _btnPulse = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _btnController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _btnController.dispose();
    super.dispose();
  }

  void _onSelectLang(String code) {
    setState(() => _selected = code);
    // Lancer le pulse quand une langue est choisie
    _btnController.repeat(reverse: true);
  }

  Future<void> _confirm() async {
    final code = _selected;
    if (code == null || _isConfirming) return;

    // Animation de press : shrink → expand → navigate
    _btnController.stop();
    await _btnController.animateTo(1.0,
        duration: const Duration(milliseconds: 120), curve: Curves.easeIn);
    await _btnController.animateTo(0.0,
        duration: const Duration(milliseconds: 120), curve: Curves.easeOut);

    if (!mounted) return;
    setState(() => _isConfirming = true);

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
    final screenH = MediaQuery.of(context).size.height;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: Stack(
          children: [
            // Fond dégradé vert → crème
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E8B57), Color(0xFF1A5C38)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Cercles décoratifs en arrière-plan
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              top: screenH * 0.12,
              left: -40,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            // Carte blanche en bas (fond des langues)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: screenH * 0.72,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFAF7F0),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                ),
              ),
            ),
            // Contenu principal
            FadeTransition(
              opacity: _fadeAnim,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    // Logo + titre (zone verte)
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Teranga Pass',
                      style: GoogleFonts.robotoSlab(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dakar 2026 · JOJ',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.75),
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Carte blanche
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 0),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFAF7F0),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            20,
                            22,
                            20,
                            MediaQuery.of(context).viewPadding.bottom + 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Titre section
                              Text(
                                'Choisissez votre langue',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1A1F2E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Choose your language · اختر لغتك',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF8A8FA0),
                                ),
                              ),
                              const SizedBox(height: 14),
                              // Liste des langues
                              Expanded(
                                child: ListView.separated(
                                  itemCount: _langs.length,
                                  separatorBuilder: (context, idx) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final lang = _langs[index];
                                    final isSelected = _selected == lang.code;
                                    return _LangTile(
                                      lang: lang,
                                      selected: isSelected,
                                      onTap: () => _onSelectLang(lang.code),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              // Bouton continuer animé
                              AnimatedBuilder(
                                animation: _btnController,
                                builder: (context, child) {
                                  final scale = _selected != null
                                      ? _btnPulse.value
                                      : 0.97;
                                  return Transform.scale(
                                    scale: scale,
                                    child: child,
                                  );
                                },
                                child: GestureDetector(
                                  onTapDown: (_) {
                                    if (_selected != null) {
                                      _btnController.animateTo(1.0,
                                          duration: const Duration(
                                              milliseconds: 80),
                                          curve: Curves.easeIn);
                                    }
                                  },
                                  onTapUp: (_) => _confirm(),
                                  onTapCancel: () {
                                    _btnController.animateTo(0.0,
                                        duration:
                                            const Duration(milliseconds: 150),
                                        curve: Curves.easeOut);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: double.infinity,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      gradient: _selected != null
                                          ? const LinearGradient(
                                              colors: [
                                                Color(0xFF38A169),
                                                Color(0xFF2E8B57),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color: _selected == null
                                          ? const Color(0xFFB0C4BC)
                                          : null,
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: _selected != null
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF2E8B57)
                                                    .withValues(alpha: 0.45),
                                                blurRadius: 14,
                                                offset: const Offset(0, 5),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: _isConfirming
                                        ? const Center(
                                            child: SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                _continueLabelFor(_selected),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              if (_selected != null) ...[
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons.arrow_forward_rounded,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ],
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2E8B57) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(0xFF2E8B57)
                : const Color(0xFFE8E4DC),
            width: selected ? 2 : 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2E8B57).withValues(alpha: 0.30),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Drapeau dans un cercle
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withValues(alpha: 0.15)
                    : const Color(0xFFF2EFE9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(lang.flag, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: lang.rtl
                  ? Directionality(
                      textDirection: TextDirection.rtl,
                      child: nameColumn(selected),
                    )
                  : nameColumn(selected),
            ),
            AnimatedOpacity(
              opacity: selected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF2E8B57),
                  size: 18,
                ),
              ),
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
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
        Text(
          lang.subtitle,
          style: GoogleFonts.poppins(
            fontSize: 11,
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
