import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screens.dart';
import 'screens/parent_screens.dart';
import 'screens/driver_screens.dart';
import 'screens/admin_screens.dart';
import 'screens/notification_control_screen.dart';
import 'services/auth_service.dart';
import 'services/localization_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('Firebase init error: $e');
    debugPrint('Stack trace: $stackTrace');
    // Continue app execution even if Firebase fails
  }

  // Initialize localization early
  try {
    await AppLocalizations().init();
  } catch (e) {
    debugPrint('Localization init error: $e');
  }

  runApp(const ProviderScope(child: MasarSmartBusApp()));
}

class MasarSmartBusApp extends StatelessWidget {
  const MasarSmartBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MASAR SMART',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppBootstrap(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/parent-home': (context) => const ParentHomeScreen(),
        '/driver-home': (context) => const DriverHomeScreen(),
        '/admin-home': (context) => const AdminHomeScreen(),
        '/notifications': (context) => const NotificationControlScreen(),
      },
    );
  }
}

/// Simple bootstrap - just check auth and navigate
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  @override
  void initState() {
    super.initState();
    // Schedule navigation after the first frame is rendered to ensure Navigator is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    // Brief splash display
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    try {
      // Check auth and navigate
      final authService = AuthService();
      final user = await authService.getCurrentUser();

      if (!mounted) return;

      String route;
      if (user == null) {
        route = '/login';
      } else {
        switch (user.role) {
          case UserRole.parent:
            route = '/parent-home';
            break;
          case UserRole.driver:
            route = '/driver-home';
            break;
          case UserRole.admin:
            route = '/admin-home';
            break;
          default:
            route = '/login';
            break;
        }
      }

      Navigator.of(context).pushReplacementNamed(route);
    } catch (e) {
      debugPrint('Auth check error: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

/// Wrapper widget that provides RTL/LTR support for any screen
class LocalizedScreen extends StatefulWidget {
  final Widget child;
  const LocalizedScreen({super.key, required this.child});

  @override
  State<LocalizedScreen> createState() => _LocalizedScreenState();
}

class _LocalizedScreenState extends State<LocalizedScreen> {
  @override
  void initState() {
    super.initState();
    AppLocalizations().addListener(_rebuild);
  }

  @override
  void dispose() {
    AppLocalizations().removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: AppLocalizations().textDirection,
      child: widget.child,
    );
  }
}
