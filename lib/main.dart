import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';
import 'core/theme/util.dart';
import 'core/widgets/app_error_view.dart';
import 'features/navigation/presentation/main_shell_screen.dart';
import 'features/splash/presentation/splash_screen.dart';

/// Point d'entrée principal de l'application MathPup.
void main() async {
  // 1. Initialise les liaisons internes de Flutter avant d'appeler du code asynchrone
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Pré-initialise le stockage local (SharedPreferences) pour sauvegarder les données
  try {
    await SharedPreferences.getInstance().timeout(
      const Duration(seconds: 3),
    );
  } catch (e) {
    debugPrint('[Bootstrap] SharedPreferences init warning: $e');
  }

  // 3. Gestion globale des erreurs de rendu (ex: widgets mal dimensionnés)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('[FlutterError] ${details.exceptionAsString()}');
  };

  // 4. Gestion des erreurs asynchrones non interceptées
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[PlatformDispatcher] Unhandled error: $error');
    return true;
  };

  // 5. Écran de secours rassurant affiché à l'enfant en cas de problème imprévu
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AppErrorView(),
      ),
    );
  };

  // 6. Lance l'application avec Riverpod (ProviderScope)
  runApp(const ProviderScope(child: MathPupApp()));
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

/// Widget racine de l'application MathPup.
class MathPupApp extends ConsumerStatefulWidget {
  const MathPupApp({super.key});

  @override
  ConsumerState<MathPupApp> createState() => _MathPupAppState();
}

/// Alias conservé pour la compatibilité avec d'anciens tests de widgets
typedef PiEtMoiApp = MathPupApp;

class _MathPupAppState extends ConsumerState<MathPupApp>
    with WidgetsBindingObserver {
  // Clé globale pour contrôler la navigation à la racine
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final _RootRouteCounterObserver _routeObserver = _RootRouteCounterObserver();

  @override
  void initState() {
    super.initState();
    // Enregistre l'observateur pour surveiller la mise en veille / reprise de l'app
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Nettoie l'observateur quand le widget est détruit (bonne pratique Flutter)
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // 🔄 Quand l'utilisateur revient sur l'application :
      // 1. Force Flutter à redessiner immédiatement l'écran
      WidgetsBinding.instance.scheduleForcedFrame();

      // 2. Si la pile de navigation a été fermée accidentellement, rouvre le Salon
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
    // 🎨 Écoute le mode de thème choisi par l'utilisateur (clair, sombre ou système)
    final themeMode = ref.watch(themeModeProvider);

    // 🔤 Prépare la typographie officielle de l'app (ABeeZee pour les textes, Abril Fatface pour les titres)
    final textTheme = createTextTheme(context, "ABeeZee", "Abril Fatface");

    return MaterialApp(
      navigatorKey: _navigatorKey,
      navigatorObservers: [_routeObserver],
      title: 'MathPup',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(textTheme),
      darkTheme: buildAppDarkTheme(textTheme),
      themeMode: themeMode,
      home: const SplashScreen(), // 🐾 Premier écran : le SplashScreen avec le saut joyeux de Pi !
    );
  }
}

