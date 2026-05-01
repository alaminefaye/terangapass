import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'constants/app_constants.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/sos_screen.dart';
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
          builder: (context, child) => _GlobalSosOverlay(
            navigatorKey: navigatorKey,
            child: child ?? const SizedBox.shrink(),
          ),
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

class _GlobalSosOverlay extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const _GlobalSosOverlay({
    required this.child,
    required this.navigatorKey,
  });

  @override
  State<_GlobalSosOverlay> createState() => _GlobalSosOverlayState();
}

class _GlobalSosOverlayState extends State<_GlobalSosOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  double _dx = 0;
  double _dy = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openSos() {
    final context = widget.navigatorKey.currentContext;
    if (context == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SOSScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        const btnSize = 60.0;
        const margin = 16.0;
        final minX = margin;
        final maxX = maxW - btnSize - margin;
        final minY = margin + MediaQuery.of(context).padding.top;
        final maxY = maxH - btnSize - margin - MediaQuery.of(context).padding.bottom;

        if (!_initialized) {
          _dx = math.max(minX, maxX - 10);
          _dy = math.max(minY, maxY - 120);
          _initialized = true;
        }

        _dx = _dx.clamp(minX, maxX);
        _dy = _dy.clamp(minY, maxY);

        return Stack(
          children: [
            widget.child,
            Positioned(
              left: _dx,
              top: _dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _dx += details.delta.dx;
                    _dy += details.delta.dy;
                    _dx = _dx.clamp(minX, maxX);
                    _dy = _dy.clamp(minY, maxY);
                  });
                },
                onTap: _openSos,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, _) {
                    final t = _pulseController.value;
                    double waveOpacity(double phase) => (1 - phase).clamp(0, 1) * 0.34;
                    double waveScale(double phase) => 1.0 + (phase * 0.85);
                    final phase1 = t;
                    final phase2 = (t + 0.5) % 1.0;
                    final blink = 0.82 + (math.sin(t * math.pi * 6) * 0.18);
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: waveScale(phase1),
                          child: Container(
                            width: btnSize,
                            height: btnSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFC73E1D).withValues(alpha: waveOpacity(phase1)),
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: waveScale(phase2),
                          child: Container(
                            width: btnSize,
                            height: btnSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFC73E1D).withValues(alpha: waveOpacity(phase2)),
                            ),
                          ),
                        ),
                        Container(
                          width: btnSize,
                          height: btnSize,
                          decoration: BoxDecoration(
                            color: const Color(0xFFC73E1D).withValues(alpha: blink),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFC73E1D).withValues(alpha: 0.42),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'SOS',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 0,
                                decoration: TextDecoration.none,
                                decorationColor: Colors.transparent,
                                decorationThickness: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
