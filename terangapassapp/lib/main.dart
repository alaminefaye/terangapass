import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

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
        '/register': (context) => const RegisterScreen(),
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
  /// TODO: Implémenter quand Firebase Messaging sera configuré
  /// Pour l'instant, cette méthode est vide car Firebase n'est pas encore configuré
  Future<void> _registerDeviceToken() async {
    // Cette méthode sera implémentée quand Firebase Messaging sera configuré
    // pour envoyer les push notifications aux utilisateurs
    debugPrint(
      'Device token registration: À implémenter avec Firebase Messaging',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}
