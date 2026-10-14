import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
