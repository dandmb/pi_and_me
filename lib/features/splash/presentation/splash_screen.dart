import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../navigation/presentation/main_shell_screen.dart';
import '../../onboarding/presentation/onboarding_carousel_screen.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../profile/presentation/profile_controller.dart';

/// Écran 0 : Splash Screen de lancement de MathPup.
/// Dégradé bleu ciel, saut réaliste de Pi et chargement silencieux du profil.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _jumpController;
  late final Animation<double> _jumpAnimation;
  late final Animation<double> _shadowAnimation;
  double _loadProgress = 0.0;

  @override
  void initState() {
    super.initState();

    // Animation de saut vertical continu de Pi
    _jumpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _jumpAnimation = Tween<double>(begin: 0, end: -28.0).animate(
      CurvedAnimation(
        parent: _jumpController,
        curve: Curves.easeOutQuad,
        reverseCurve: Curves.easeInQuad,
      ),
    );

    _shadowAnimation = Tween<double>(begin: 1.0, end: 0.70).animate(
      CurvedAnimation(
        parent: _jumpController,
        curve: Curves.easeOutQuad,
        reverseCurve: Curves.easeInQuad,
      ),
    );

    _startBootstrap();
  }

  Future<void> _startBootstrap() async {
    // 1. Récupération instantanée du profil actif (déjà en mémoire via SharedPreferences)
    dynamic profile;
    try {
      profile = await ref
          .read(activeProfileProvider.future)
          .timeout(const Duration(milliseconds: 1000));
    } catch (_) {
      profile = ref.read(activeProfileProvider).valueOrNull;
    }

    if (!mounted) return;
    setState(() {
      _loadProgress = 1.0;
    });

    // 2. Micro-pause (100 ms) pour une transition visuelle douce et ultra-rapide
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    bool hasSeenIntro = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      hasSeenIntro = prefs.getBool(kHasSeenOnboardingIntroKey) ?? false;
    } catch (_) {}

    if (!mounted) return;

    final Widget targetScreen;
    if (profile != null) {
      targetScreen = const MainShellScreen();
    } else if (!hasSeenIntro) {
      targetScreen = const OnboardingCarouselScreen();
    } else {
      targetScreen = const OnboardingScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: AppMotion.fast,
      ),
    );
  }

  @override
  void dispose() {
    _jumpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.sky500, AppColors.sky700],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;

              if (isLandscape) {
                return Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.s6,
                        vertical: AppSpace.s3,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 1. Mascotte Pi sautillante compacte
                          SizedBox(
                            height: 130,
                            width: 130,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  bottom: 6,
                                  child: AnimatedBuilder(
                                    animation: _shadowAnimation,
                                    builder: (context, child) {
                                      final scale = _shadowAnimation.value;
                                      return Transform.scale(
                                        scaleX: scale,
                                        scaleY: scale,
                                        child: Container(
                                          width: 70,
                                          height: 12,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.18 * scale,
                                            ),
                                            borderRadius: const BorderRadius.all(
                                              Radius.elliptical(70, 12),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: _jumpAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, _jumpAnimation.value * 0.65),
                                      child: child,
                                    );
                                  },
                                  child: Image.asset(
                                    'assets/images/pi_transparent.png',
                                    height: 95,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(
                                          Icons.pets,
                                          size: 65,
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: AppSpace.s6),

                          // 2. Titre, Badge et Barre de chargement
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                strings.appTitle,
                                style: AppText.h1.copyWith(
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  fontSize: 26,
                                ),
                              ),
                              const SizedBox(height: AppSpace.s2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpace.s3,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(AppRadius.pill),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.verified_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: AppSpace.s1),
                                    Text(
                                      strings.splashBadge,
                                      style: AppText.bodyS.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppSpace.s4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.pill),
                                child: Container(
                                  height: 6,
                                  width: 160,
                                  color: Colors.white.withValues(alpha: 0.25),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: _loadProgress.clamp(0.0, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.pill,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                strings.loading,
                                style: AppText.bodyS.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Mode portrait classique
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Mascotte Pi sautillante avec son ombre de contact au sol
                  SizedBox(
                    height: 180,
                    width: 180,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 1. Ombre de contact au sol (reste au sol, s'ajuste en taille)
                        Positioned(
                          bottom: 8,
                          child: AnimatedBuilder(
                            animation: _shadowAnimation,
                            builder: (context, child) {
                              final scale = _shadowAnimation.value;
                              return Transform.scale(
                                scaleX: scale,
                                scaleY: scale,
                                child: Container(
                                  width: 90,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(
                                      alpha: 0.18 * scale,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.elliptical(90, 16),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // 2. Chiot Pi qui s'élève et redescend
                        AnimatedBuilder(
                          animation: _jumpAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _jumpAnimation.value),
                              child: child,
                            );
                          },
                          child: Image.asset(
                            'assets/images/pi_transparent.png',
                            height: 140,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.pets,
                                  size: 100,
                                  color: Colors.white,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpace.s5),

                  // Titre de l'application
                  Text(
                    strings.appTitle,
                    style: AppText.display.copyWith(
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: AppSpace.s3),

                  // Badge officiel rassurant (conforme Google Play Familles)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.s4,
                      vertical: AppSpace.s2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: AppSpace.s2),
                        Text(
                          strings.splashBadge,
                          style: AppText.bodyS.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Barre de chargement douce
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpace.s12),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: Container(
                            height: 8,
                            width: 180,
                            color: Colors.white.withValues(alpha: 0.25),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: _loadProgress.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.pill,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpace.s2),
                        Text(
                          strings.loading,
                          style: AppText.bodyS.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpace.s8),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
