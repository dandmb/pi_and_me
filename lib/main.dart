import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'core/widgets/app_error_view.dart';
import 'features/navigation/presentation/main_shell_screen.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SharedPreferences.getInstance().timeout(
      const Duration(seconds: 3),
    );
  } catch (e) {
    debugPrint('[Bootstrap] SharedPreferences init warning: $e');
  }

  // Gestion des erreurs de rendu Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[FlutterError] ${details.exceptionAsString()}');
  };

  // Gestion des erreurs asynchrones
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[PlatformDispatcher] Unhandled error: $error');
    return true;
  };

  // Fallback visuel rassurant adapté aux enfants
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AppErrorView(),
      ),
    );
  };

  runApp(const ProviderScope(child: PiEtMoiApp()));
}

/// Observateur de routes permettant de détecter si la pile Navigator devient vide
/// (cause classique d'écran noir au retour sur l'application) et de restaurer l'accueil.
class _RootRouteCounterObserver extends NavigatorObserver {
  int routeCount = 0;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routeCount++;
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routeCount = (routeCount - 1).clamp(0, 999);
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routeCount = (routeCount - 1).clamp(0, 999);
    super.didRemove(route, previousRoute);
  }
}

class PiEtMoiApp extends ConsumerStatefulWidget {
  const PiEtMoiApp({super.key});

  @override
  ConsumerState<PiEtMoiApp> createState() => _PiEtMoiAppState();
}

class _PiEtMoiAppState extends ConsumerState<PiEtMoiApp>
    with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final _RootRouteCounterObserver _routeObserver = _RootRouteCounterObserver();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Force le moteur Flutter à redessiner immédiatement une frame après recréation de la surface Android
      WidgetsBinding.instance.scheduleForcedFrame();

      // Si la pile de navigation a été vidée accidentellement (ex: back système), restaure le Salon
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final nav = _navigatorKey.currentState;
        if (nav != null && _routeObserver.routeCount <= 0) {
          nav.pushReplacement(
            MaterialPageRoute(builder: (_) => const MainShellScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      navigatorKey: _navigatorKey,
      navigatorObservers: [_routeObserver],
      title: 'Pi & Moi',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildAppDarkTheme(),
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}

