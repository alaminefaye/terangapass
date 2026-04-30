import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants/app_constants.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/notifications_screen.dart';
import 'services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  final stopwatch = Stopwatch()..start();
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final prefs = await SharedPreferences.getInstance();
  final language =
      (prefs.getString(AppConstants.languageKey) ??
              AppConstants.defaultLanguage)
          .trim();
  if (language.isNotEmpty) {
    AppConstants.localeNotifier.value = Locale(language);
  }
  await NotificationService().initialize(navigatorKey: navigatorKey);
  runApp(const TerangaPassApp());

  final remainingMs = 3000 - stopwatch.elapsedMilliseconds;
  if (remainingMs > 0) {
    await Future.delayed(Duration(milliseconds: remainingMs));
  }
  FlutterNativeSplash.remove();
}

class TerangaPassApp extends StatelessWidget {
  const TerangaPassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: AppConstants.localeNotifier,
      builder: (context, locale, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          navigatorKey: navigatorKey,
          locale: locale ?? const Locale(AppConstants.defaultLanguage),
          supportedLocales: const [Locale('fr'), Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          home: const AuthWrapper(),
          routes: {
            '/home': (context) => const HomeScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
          },
        );
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
  /// NOTE: Implémenter quand Firebase Messaging sera configuré
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
