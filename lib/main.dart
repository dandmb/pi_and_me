import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_error_view.dart';
import 'features/splash/presentation/splash_screen.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('pi_profiles_list')) {
    final defaultProfiles = jsonEncode([
      {
        'id': 'profile_1',
        'name': 'Léa',
        'avatar': 'paw',
        'grade': 'cm1',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'profile_2',
        'name': 'Thomas',
        'avatar': 'rabbit',
        'grade': 'ce2',
        'createdAt': DateTime.now().toIso8601String(),
      },
    ]);
    await prefs.setString('pi_profiles_list', defaultProfiles);
    await prefs.setString('pi_active_profile_id', 'profile_1');
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

class PiEtMoiApp extends StatelessWidget {
  const PiEtMoiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pi & Moi',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const SplashScreen(),
    );
  }
}
