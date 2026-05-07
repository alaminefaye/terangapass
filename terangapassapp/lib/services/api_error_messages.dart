import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

/// Textes d’erreur API pour l’utilisateur, alignés sur la locale de l’app
/// ([AppConstants.localeNotifier], défaut `fr`).
class ApiErrorMessages {
  ApiErrorMessages._();

  static bool _isEnglish() {
    final code = AppConstants.localeNotifier.value?.languageCode ??
        AppConstants.defaultLanguage;
    return code == 'en';
  }

  static String _p(String fr, String en) => _isEnglish() ? en : fr;

  static String get serverEmpty => _p('Réponse serveur vide', 'Empty server response');

  static String get serverInvalid =>
      _p('Réponse serveur invalide', 'Invalid server response');

  static String get loginEmptyOrNoToken => _p(
        'Connexion impossible: réponse serveur vide. Vérifiez l’URL API et le serveur.',
        'Unable to sign in: empty server response. Check the API URL and server.',
      );

  static String get loginFailed =>
      _p('Échec de la connexion', 'Sign-in failed');

  /// Après [ApiService.login] : jeton encore absent en local (mal configuré / HTML).
  static String get loginIncompleteNoToken => _p(
        'Connexion incomplète : aucun jeton reçu depuis l’API. '
            'Vérifiez l’URL de l’API (…/api/v1).',
        'Incomplete sign-in: no token from the API. '
            'Check that the API URL ends with /api/v1.',
      );

  static String get registerEmptyOrHtml => _p(
        'Inscription impossible: réponse API vide ou non JSON. '
            'L’URL doit finir par /api/v1 (ex. https://votredomaine.com/api/v1).',
        'Registration failed: empty or non-JSON API response. '
            'The URL must end with /api/v1 (e.g. https://yourdomain.com/api/v1).',
      );

  static String get registerIncompleteToken => _p(
        'Inscription incomplète : aucun jeton reçu. Réessayez ou connectez-vous.',
        'Incomplete registration: no token received. Try again or sign in.',
      );

  static String get registerFailed =>
      _p('Échec de l\'inscription', 'Registration failed');

  /// Après inscription + éventuel login : toujours pas de jeton (réponse serveur).
  static String get registerAccountNotConfirmed => _p(
        'Compte non confirmé par le serveur (pas de jeton). '
            'Vérifiez que l’URL API est bien …/api/v1 et que le serveur répond en JSON.',
        'Account not confirmed by the server (no token). '
            'Check that the API URL ends with /api/v1 and returns JSON.',
      );

  static String get aiInvalidResponse =>
      _p('Réponse IA invalide', 'Invalid AI response');

  static String httpStatusFallback(int statusCode) {
    switch (statusCode) {
      case 400:
        return _p('Requête invalide', 'Invalid request');
      case 401:
        return _p(
          'Non autorisé. Veuillez vous reconnecter.',
          'Unauthorized. Please sign in again.',
        );
      case 403:
        return _p('Accès refusé', 'Access denied');
      case 404:
        return _p('Ressource non trouvée', 'Resource not found');
      case 422:
        return _p('Données invalides', 'Invalid data');
      case 500:
        return _p(
          'Erreur serveur. Veuillez réessayer plus tard.',
          'Server error. Please try again later.',
        );
      case 502:
        return _p(
          'Passerelle incorrecte. Le serveur est temporairement indisponible.',
          'Bad gateway. The server is temporarily unavailable.',
        );
      case 503:
        return _p(
          'Service temporairement indisponible. Veuillez réessayer dans quelques instants.',
          'Service temporarily unavailable. Please try again shortly.',
        );
      case 504:
        return _p(
          'Délai passerelle dépassé. Le serveur met trop longtemps à répondre.',
          'Gateway timeout. The server is taking too long to respond.',
        );
      default:
        return _p(
          'Une erreur est survenue ($statusCode)',
          'Something went wrong ($statusCode)',
        );
    }
  }

  static String dioTypeMessage(DioExceptionType type, {String? rawMessage}) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
        return _p(
          'Délai de connexion dépassé. Vérifiez votre connexion internet.',
          'Connection timed out. Check your internet connection.',
        );
      case DioExceptionType.sendTimeout:
        return _p(
          'Délai d\'envoi dépassé. Vérifiez votre connexion internet.',
          'Send timed out. Check your internet connection.',
        );
      case DioExceptionType.receiveTimeout:
        return _p(
          'Délai de réception dépassé. Le serveur met trop longtemps à répondre.',
          'Receive timed out. The server is taking too long to respond.',
        );
      case DioExceptionType.connectionError:
        return _p(
          'Erreur de connexion. Vérifiez votre connexion internet et réessayez.',
          'Connection error. Check your internet connection and try again.',
        );
      case DioExceptionType.badCertificate:
        return _p(
          'Erreur de certificat SSL. Vérifiez la configuration du serveur.',
          'SSL certificate error. Check the server configuration.',
        );
      case DioExceptionType.badResponse:
        return _p(
          'Réponse invalide du serveur.',
          'Invalid response from the server.',
        );
      case DioExceptionType.cancel:
        return _p('Requête annulée.', 'Request cancelled.');
      case DioExceptionType.unknown:
        return _p(
          'Une erreur est survenue: ${rawMessage ?? "Erreur inconnue"}',
          'Something went wrong: ${rawMessage ?? "Unknown error"}',
        );
    }
  }
}
