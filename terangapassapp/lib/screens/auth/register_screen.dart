import 'package:flutter/material.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_theme_extensions.dart';
import '../../services/api_error_messages.dart';
import '../../services/api_service.dart';
import '../../state/app_state.dart';
import '../../utils/email_normalize.dart';
import '../../utils/login_identifier.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  CountryCode _countryCode = CountryCode.fromCountryCode('SN');

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _nameFieldError;
  String? _emailFieldError;
  String? _phoneFieldError;
  String? _passwordFieldError;
  String? _confirmPasswordFieldError;

  String _nationalPhoneDigitsOnly() =>
      _phoneController.text.replaceAll(RegExp(r'\D'), '');

  String _internationalPhoneE164() {
    final nat = _nationalPhoneDigitsOnly();
    if (nat.isEmpty) return '';
    final dc = _countryCode.dialCode ?? '+221';
    final normalized = dc.startsWith('+') ? dc : '+$dc';
    return '$normalized$nat';
  }

  int _minNationalPhoneLength() {
    switch ((_countryCode.code ?? 'SN').toUpperCase()) {
      case 'SN':
        return 9;
      case 'US':
      case 'CA':
        return 10;
      default:
        return 8;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

  bool _validateRegisterFields(AppLocalizations l10n) {
    String? nameErr;
    final name = _nameController.text.trim();
    if (name.isEmpty) nameErr = l10n.registerFullNameRequired;

    String? emailErr;
    final emailRaw = _emailController.text;
    if (emailRaw.trim().isEmpty) {
      emailErr = l10n.loginEmailRequired;
    } else if (!isRegisterEmailValid(emailRaw)) {
      emailErr = l10n.loginEmailInvalid;
    }

    String? phoneErr;
    final phoneTrim = _phoneController.text.trim();
    final natLen = _nationalPhoneDigitsOnly().length;
    if (phoneTrim.isEmpty) {
      phoneErr = l10n.registerPhoneRequired;
    } else if (natLen < _minNationalPhoneLength() || natLen > 15) {
      phoneErr = l10n.loginPhoneInvalid;
    }

    String? passwordErr;
    final password = _passwordController.text;
    if (password.isEmpty) {
      passwordErr = l10n.registerPasswordRequired;
    } else if (password.length < 6) {
      passwordErr = l10n.loginPasswordMinLength;
    }

    String? confirmErr;
    final confirm = _confirmPasswordController.text;
    if (confirm.isEmpty) {
      confirmErr = l10n.registerConfirmPasswordRequired;
    } else if (confirm != password) {
      confirmErr = l10n.registerPasswordsNotMatch;
    }

    setState(() {
      _nameFieldError = nameErr;
      _emailFieldError = emailErr;
      _phoneFieldError = phoneErr;
      _passwordFieldError = passwordErr;
      _confirmPasswordFieldError = confirmErr;
    });
    return nameErr == null &&
        emailErr == null &&
        phoneErr == null &&
        passwordErr == null &&
        confirmErr == null;
  }

  Widget _compactField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String? errorText,
    required VoidCallback onClearError,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    bool autocorrect = true,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
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
              color: hasError
                  ? AppTheme.primaryRed
                  : const Color(0xFFE5E7EB),
              width: hasError ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            autocorrect: autocorrect,
            textCapitalization: textCapitalization,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.2,
            ),
            onChanged: (_) => onClearError(),
            decoration: InputDecoration(
              isDense: true,
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF9CA3AF),
              ),
              prefixIcon: Icon(icon, size: 20),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 38,
              ),
              prefixIconColor: const Color(0xFF6B7280),
              suffixIcon: suffixIcon,
              suffixIconColor: const Color(0xFF6B7280),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        _fieldErrorBelow(errorText),
      ],
    );
  }

  Widget _phoneWithCountryPicker(AppLocalizations l10n) {
    final hasError = _phoneFieldError != null && _phoneFieldError!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.profilePhoneLabel,
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
              color: hasError
                  ? AppTheme.primaryRed
                  : const Color(0xFFE5E7EB),
              width: hasError ? 1.5 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CountryCodePicker(
                onChanged: (CountryCode c) {
                  setState(() => _countryCode = c);
                },
                initialSelection: 'SN',
                favorite: const [
                  'SN',
                  'FR',
                  'CI',
                  'ML',
                  'MA',
                  'GM',
                  'GN',
                  'GW',
                  'US',
                  'GB',
                  'DE',
                  'IT',
                ],
                showFlagMain: true,
                showFlagDialog: true,
                showDropDownButton: true,
                showOnlyCountryWhenClosed: false,
                alignLeft: false,
                enabled: !_isLoading,
                pickerStyle: PickerStyle.bottomSheet,
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(left: 6, right: 2),
                flagWidth: 22,
                textStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF111827),
                ),
                dialogTextStyle: GoogleFonts.poppins(fontSize: 14),
                headerText: l10n.registerSelectCountry,
                headerTextStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                searchDecoration: InputDecoration(
                  hintText: l10n.filter,
                  isDense: true,
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                barrierColor: Colors.black54,
              ),
              Container(
                width: 1,
                height: 28,
                color: const Color(0xFFE5E7EB),
              ),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  autocorrect: false,
                  enabled: !_isLoading,
                  style: GoogleFonts.poppins(fontSize: 14, height: 1.2),
                  onChanged: (_) =>
                      setState(() => _phoneFieldError = null),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: l10n.registerPhoneNationalHint,
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF9CA3AF),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        _fieldErrorBelow(_phoneFieldError),
      ],
    );
  }

  Future<void> _register() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_validateRegisterFields(l10n)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = ApiService();
      final name = _nameController.text.trim();
      final email = normalizeEmailForAuth(_emailController.text);
      final phoneIntl = _internationalPhoneE164();
      final password = _passwordController.text;
      final iso = (_countryCode.code ?? 'SN').toUpperCase();

      await apiService.register(
        name,
        email,
        password,
        phone: phoneIntl.isEmpty ? null : phoneIntl,
        country: iso,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', name);
      await prefs.setString('user_email', email);
      await prefs.setString('user_phone', phoneIntl);
      var token = prefs.getString('auth_token');
      if (token == null || token.isEmpty) {
        await apiService.login(email, password);
        token = prefs.getString('auth_token');
      }

      if (token == null || token.isEmpty) {
        await apiService.clearLocalAuth();
        throw Exception(ApiErrorMessages.registerAccountNotConfirmed);
      }

      if (phoneIntl.isNotEmpty) {
        try {
          await apiService.updateUserProfile({
            'phone': phoneIntl,
            'telephone': phoneIntl,
          });
        } catch (_) {}
      }

      if (mounted) {
        isAuthenticatedNotifier.value = true;
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
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
                      l10n.registerTitle,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF111827),
                        height: 1.05,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.registerSubtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
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
                        boxShadow: [
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
                          _compactField(
                            label: l10n.registerFullNameLabel,
                            hint: l10n.registerFullNameHint,
                            icon: Icons.person_outlined,
                            controller: _nameController,
                            errorText: _nameFieldError,
                            onClearError: () => setState(
                              () => _nameFieldError = null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _compactField(
                            label: l10n.loginEmailLabel,
                            hint: l10n.loginEmailHint,
                            icon: Icons.email_outlined,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textCapitalization: TextCapitalization.none,
                            autocorrect: false,
                            errorText: _emailFieldError,
                            onClearError: () => setState(
                              () => _emailFieldError = null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _phoneWithCountryPicker(l10n),
                          const SizedBox(height: 12),
                          _compactField(
                            label: l10n.loginPasswordLabel,
                            hint: l10n.loginPasswordHint,
                            icon: Icons.lock_outlined,
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            textCapitalization: TextCapitalization.none,
                            autocorrect: false,
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
                            errorText: _passwordFieldError,
                            onClearError: () => setState(
                              () => _passwordFieldError = null,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _compactField(
                            label: l10n.registerConfirmPasswordLabel,
                            hint: l10n.loginPasswordHint,
                            icon: Icons.lock_outlined,
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            textCapitalization: TextCapitalization.none,
                            autocorrect: false,
                            suffixIcon: IconButton(
                              constraints: const BoxConstraints(
                                minWidth: 40,
                                minHeight: 38,
                              ),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            errorText: _confirmPasswordFieldError,
                            onClearError: () => setState(
                              () => _confirmPasswordFieldError = null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _register,
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
                                    l10n.registerSignUp,
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
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              l10n.registerHaveAccount,
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
