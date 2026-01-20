import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:io'; // Décommenter quand Firebase est configuré
// import 'services/api_service.dart'; // Décommenter quand Firebase est configuré
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const TerangaPassApp());
}

class TerangaPassApp extends StatelessWidget {
  const TerangaPassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teranga Pass',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final isAuthenticated = token != null && token.isNotEmpty;

      setState(() {
        _isAuthenticated = isAuthenticated;
      });

      // Si l'utilisateur est authentifié, enregistrer le device token
      if (isAuthenticated) {
        _registerDeviceToken();
      }
    } catch (e) {
      setState(() {
        _isAuthenticated = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Enregistre le device token pour les push notifications
  /// Note: Cette méthode nécessite firebase_messaging pour obtenir le token FCM
  /// Pour l'instant, c'est une structure prête à être utilisée
  Future<void> _registerDeviceToken() async {
    try {
      // TODO: Décommenter et configurer quand Firebase est configuré
      //
      // import 'package:firebase_messaging/firebase_messaging.dart';
      // import 'dart:io';
      //
      // final apiService = ApiService();
      // final fcmToken = await FirebaseMessaging.instance.getToken();
      // if (fcmToken != null) {
      //   await apiService.registerDeviceToken(
      //     token: fcmToken,
      //     platform: Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Web',
      //   );
      //   debugPrint('Device token enregistré avec succès');
      // }

      // Pour l'instant, on peut utiliser un token de test ou attendre Firebase
      // Exemple avec un token de test (à remplacer par le vrai token FCM)
      // final apiService = ApiService();
      // await apiService.registerDeviceToken(
      //   token: 'test_token_${DateTime.now().millisecondsSinceEpoch}',
      //   platform: Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Web',
      // );

      debugPrint(
        'Device token registration: En attente de configuration Firebase',
      );
    } catch (e) {
      // Erreur silencieuse - ne pas bloquer l'application
      debugPrint('Erreur enregistrement device token: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}
