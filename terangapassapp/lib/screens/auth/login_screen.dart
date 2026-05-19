import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_theme_extensions.dart';
import '../../services/api_error_messages.dart';
import '../../services/api_service.dart';
import '../../state/app_state.dart';
import '../../utils/login_identifier.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.returnOnSuccess = false});

  /// Si vrai, ferme l'écran avec `true` après connexion (depuis un garde invité).
  final bool returnOnSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true;
  String? _identifierFieldError;
  String? _passwordFieldError;

  @override
  void initState() {
    super.initState();
    _loadRememberPrefs();
  }

  Future<void> _loadRememberPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(AppConstants.loginSavedEmailKey);
    final rememberPref = prefs.getBool(AppConstants.loginRememberMePrefKey);
    if (!mounted) return;
    setState(() {
      _rememberMe = rememberPref ?? true;
      if (savedEmail != null && savedEmail.trim().isNotEmpty) {
        _emailController.text = savedEmail.trim();
      }
    });
  }

  Future<void> _persistRememberCheckbox(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.loginRememberMePrefKey, value);
  }

  void _setRememberMe(bool value) {
    setState(() => _rememberMe = value);
    _persistRememberCheckbox(value);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateLoginFields(AppLocalizations l10n) {
    String? identErr;
    String? passErr;

    switch (validateLoginIdentifier(_emailController.text)) {
      case LoginIdentifierValidationError.empty:
        identErr = l10n.loginIdentifierRequired;
        break;
      case LoginIdentifierValidationError.invalidEmail:
        identErr = l10n.loginEmailInvalid;
        break;
      case LoginIdentifierValidationError.phoneTooShort:
        identErr = l10n.loginPhoneInvalid;
        break;
      case null:
        break;
    }

    final p = _passwordController.text;
    if (p.isEmpty) {
      passErr = l10n.loginPasswordRequired;
    } else if (p.length < 6) {
      passErr = l10n.loginPasswordMinLength;
    }

    setState(() {
      _identifierFieldError = identErr;
      _passwordFieldError = passErr;
    });
    return identErr == null && passErr == null;
  }

  Widget _fieldErrorBelow(String? message) {
    if (message == null || message.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 2, right: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Semantics(
          liveRegion: true,
          label: message,
          child: Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 11,
              height: 1.3,
              color: AppTheme.primaryRed,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_validateLoginFields(l10n)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final rawIdentifier = _emailController.text;
      final identifierForApi =
          normalizedLoginIdentifierForApi(rawIdentifier);
      final password = _passwordController.text;
      final loginResult =
          await apiService.login(identifierForApi, password);

      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        final rt = loginResult['token'];
        if (rt is String && rt.trim().isNotEmpty) {
          token = rt.trim();
          await prefs.setString('auth_token', token);
        }
      }
      if (token == null || token.isEmpty) {
        await apiService.clearLocalAuth();
        throw Exception(ApiErrorMessages.loginIncompleteNoToken);
      }

      await prefs.setBool(AppConstants.authPersistSessionKey, _rememberMe);
      await prefs.setBool(AppConstants.loginRememberMePrefKey, _rememberMe);
      if (_rememberMe) {
        await prefs.setString(
          AppConstants.loginSavedEmailKey,
          rawIdentifier.trim(),
        );
      } else {
        await prefs.remove(AppConstants.loginSavedEmailKey);
      }

      var profileEmail = identifierForApi;
      final userJson = loginResult['user'];
      if (userJson is Map && userJson['email'] != null) {
        final e = userJson['email'].toString().trim();
        if (e.isNotEmpty) profileEmail = e;
      }
      await prefs.setString('user_email', profileEmail);

      if (mounted) {
        isAuthenticatedNotifier.value = true;
        if (widget.returnOnSuccess) {
          Navigator.of(context).pop(true);
        } else {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        String errorMessage = l10n.loginUnknownError;

        if (e is Exception) {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        } else {
          errorMessage = e.toString();
        }

        if (errorMessage.isEmpty || errorMessage == 'Exception') {
          errorMessage = l10n.loginConnectionError;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: GoogleFonts.poppins()),
            backgroundColor: AppTheme.primaryRed,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.tp.scaffold,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryYellow.withValues(alpha: 0.12),
                    const Color(0xFFF3FBF6),
                    AppTheme.primaryGreen.withValues(alpha: 0.12),
                    AppTheme.primaryGreen.withValues(alpha: 0.18),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.primaryGreen.withValues(alpha: 0.14),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.primaryGreen.withValues(alpha: 0.22),
                      AppTheme.primaryGreen.withValues(alpha: 0.30),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -90,
            right: -60,
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryYellow.withValues(alpha: 0.18),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -70,
            child: Container(
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGreen.withValues(alpha: 0.14),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        height: 72,
                        width: 72,
                        decoration: BoxDecoration(
                          color: context.tp.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: context.tp.border),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.appTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: context.tp.textPrimary,
                        height: 1.05,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.loginTagline,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: context.tp.textSecondary,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.loginValueProps,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      decoration: BoxDecoration(
                        color: context.tp.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: context.tp.border),
                        boxShadow: context.tp.isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 22,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.loginIdentifierLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _identifierFieldError != null
                                    ? AppTheme.primaryRed
                                    : const Color(0xFFE5E7EB),
                                width:
                                    _identifierFieldError != null ? 1.5 : 1,
                              ),
                            ),
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.text,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                height: 1.2,
                              ),
                              onChanged: (_) {
                                if (_identifierFieldError != null) {
                                  setState(() => _identifierFieldError = null);
                                }
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: l10n.loginIdentifierHint,
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF9CA3AF),
                                ),
                                prefixIcon: const Icon(
                                  Icons.alternate_email,
                                  size: 20,
                                ),
                                prefixIconColor: const Color(0xFF6B7280),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 38,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          _fieldErrorBelow(_identifierFieldError),
                          const SizedBox(height: 12),
                          Text(
                            l10n.loginPasswordLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _passwordFieldError != null
                                    ? AppTheme.primaryRed
                                    : const Color(0xFFE5E7EB),
                                width: _passwordFieldError != null ? 1.5 : 1,
                              ),
                            ),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                height: 1.2,
                              ),
                              onChanged: (_) {
                                if (_passwordFieldError != null) {
                                  setState(() => _passwordFieldError = null);
                                }
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: l10n.loginPasswordHint,
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: const Color(0xFF9CA3AF),
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_outlined,
                                  size: 20,
                                ),
                                suffixIcon: IconButton(
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 38,
                                  ),
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                prefixIconColor: const Color(0xFF6B7280),
                                suffixIconColor: const Color(0xFF6B7280),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 38,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          _fieldErrorBelow(_passwordFieldError),
                          const SizedBox(height: 12),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 28,
                                width: 28,
                                child: Checkbox(
                                  value: _rememberMe,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  activeColor: AppTheme.primaryGreen,
                                  onChanged: _isLoading
                                      ? null
                                      : (v) {
                                          if (v != null) _setRememberMe(v);
                                        },
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _isLoading
                                      ? null
                                      : () => _setRememberMe(!_rememberMe),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Text(
                                      l10n.loginRememberMe,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: const Color(0xFF374151),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 1,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 13,
                              ),
                              minimumSize: const Size(double.infinity, 48),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    l10n.loginSignIn,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      height: 1.15,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 8),
                          if (!widget.returnOnSuccess) ...[
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      Navigator.of(context)
                                          .pushReplacementNamed('/home');
                                    },
                              child: Text(
                                'Explorer sans compte',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              l10n.loginNoAccount,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
