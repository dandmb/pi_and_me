import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_dimens.dart';
import 'core/theme/app_text.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/chunky_button.dart';

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
      home: const DesignSystemShowcase(),
    );
  }
}

class DesignSystemShowcase extends StatelessWidget {
  const DesignSystemShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.s5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/pi_transparent.png',
                height: 120,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.pets,
                  size: 80,
                  color: AppColors.sky600,
                ),
              ),
              const SizedBox(height: AppSpace.s4),
              Text(
                'Pi & Moi',
                style: AppText.display.copyWith(color: AppColors.sky600),
              ),
              const SizedBox(height: AppSpace.s2),
              Text(
                'Programmes officiels du CP à la 3e',
                style: AppText.bodyS.copyWith(color: AppColors.ink600),
              ),
              const SizedBox(height: AppSpace.s8),
              ChunkyButton(
                label: 'C\'est parti !',
                variant: ChunkyButtonVariant.primary,
                onPressed: () {},
              ),
              const SizedBox(height: AppSpace.s3),
              ChunkyButton(
                label: 'Espace Parents',
                variant: ChunkyButtonVariant.secondary,
                height: 48,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
