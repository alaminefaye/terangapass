import 'email_normalize.dart';

enum LoginIdentifierValidationError { empty, invalidEmail, phoneTooShort }

/// Valeur à envoyer dans le champ `email` du POST /auth/login (email normalisé ou tel. brut).
String normalizedLoginIdentifierForApi(String raw) {
  final t = raw.trim();
  if (t.contains('@')) {
    return normalizeEmailForAuth(t);
  }
  return t;
}

LoginIdentifierValidationError? validateLoginIdentifier(String? value) {
  if (value == null || value.trim().isEmpty) {
    return LoginIdentifierValidationError.empty;
  }
  final t = value.trim();
  if (t.contains('@')) {
    final n = normalizeEmailForAuth(t);
    if (!_emailPattern.hasMatch(n)) {
      return LoginIdentifierValidationError.invalidEmail;
    }
    return null;
  }
  final digits = t.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 9) {
    return LoginIdentifierValidationError.phoneTooShort;
  }
  return null;
}

final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
