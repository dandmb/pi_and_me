import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../home/presentation/home_screen.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../profile/presentation/profile_controller.dart';

/// Écran 0 : Splash Screen de lancement de Pi & Moi.
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
    // Progression fluide de la barre de chargement
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() {
        _loadProgress = i / 10.0;
      });
    }

    if (!mounted) return;

    // Vérification du profil actif
    final profile = await ref.read(activeProfileProvider.future);

    if (!mounted) return;

    if (profile == null) {
      // Aucun profil -> Onboarding
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: AppMotion.base,
        ),
      );
    } else {
      // Profil existant -> Salon de Pi
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: AppMotion.base,
        ),
      );
    }
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
            colors: [
              AppColors.sky500,
              AppColors.sky700,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
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
                                color: Colors.black.withValues(alpha: 0.18 * scale),
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
                        errorBuilder: (context, error, stackTrace) => const Icon(
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
                                borderRadius: BorderRadius.circular(AppRadius.pill),
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
          ),
        ),
      ),
    );
  }
}
