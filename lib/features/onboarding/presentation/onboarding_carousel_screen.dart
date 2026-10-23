import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import 'onboarding_screen.dart';

/// Clé SharedPreferences indiquant si l'enfant ou le parent a déjà vu l'introduction.
const String kHasSeenOnboardingIntroKey = 'has_seen_onboarding_intro_v1';

/// Écran d'accueil explicatif (Carousel Onboarding) présentant le concept de l'application
/// au tout premier lancement :
/// 1. Les quiz mathématiques ludiques et bienveillants
/// 2. Le chiot Pi à soigner et câliner
/// 3. Les récompenses (os dorés) et la boutique d'accessoires
class OnboardingCarouselScreen extends ConsumerStatefulWidget {
  const OnboardingCarouselScreen({super.key});

  @override
  ConsumerState<OnboardingCarouselScreen> createState() =>
      _OnboardingCarouselScreenState();
}

class _OnboardingCarouselScreenState
    extends ConsumerState<OnboardingCarouselScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _currentPage = 0;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeIntro() async {
    ref.read(audioServiceProvider).playPop();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kHasSeenOnboardingIntroKey, true);
    } catch (_) {}

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: AppMotion.fast,
      ),
    );
  }

  void _onNext() {
    if (_currentPage < 2) {
      ref.read(audioServiceProvider).playPop();
      _pageController.nextPage(
        duration: AppMotion.base,
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeIntro();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);

    final slides = [
      (
        tag: strings.onboardingSlide1Tag,
        title: strings.onboardingSlide1Title,
        description: strings.onboardingSlide1Desc,
        imagePath: 'assets/images/onboarding/onboarding_quiz.png',
        tagBgColor: const Color(0xFFE0F7FC),
        tagTextColor: AppColors.sky600,
        accentColor: AppColors.sky600,
        icon: Icons.calculate_rounded,
      ),
      (
        tag: strings.onboardingSlide2Tag,
        title: strings.onboardingSlide2Title,
        description: strings.onboardingSlide2Desc,
        imagePath: 'assets/images/onboarding/onboarding_care.png',
        tagBgColor: const Color(0xFFE6FAF3),
        tagTextColor: AppColors.green600,
        accentColor: AppColors.green600,
        icon: Icons.pets_rounded,
      ),
      (
        tag: strings.onboardingSlide3Tag,
        title: strings.onboardingSlide3Title,
        description: strings.onboardingSlide3Desc,
        imagePath: 'assets/images/onboarding/onboarding_shop.png',
        tagBgColor: AppColors.amber50,
        tagTextColor: AppColors.gold600,
        accentColor: AppColors.gold600,
        icon: Icons.shopping_bag_rounded,
      ),
    ];

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: context.appBg,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpace.maxContentWidth,
              ),
              child: Column(
                children: [
                  // Barre supérieure : Sauter / Passer l'onboarding
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.s5,
                      vertical: AppSpace.s2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo / Nom discret
                        Row(
                          children: [
                            const Icon(
                              Icons.pets_rounded,
                              size: 20,
                              color: AppColors.sky600,
                            ),
                            const SizedBox(width: AppSpace.s2),
                            Text(
                              strings.appTitle,
                              style: AppText.h3.copyWith(
                                color: context.appText,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),

                        // Bouton Passer
                        TextButton(
                          onPressed: _completeIntro,
                          style: TextButton.styleFrom(
                            foregroundColor: context.appSubText,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.s3,
                              vertical: AppSpace.s1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                          ),
                          child: Text(
                            strings.onboardingSkip,
                            style: AppText.body.copyWith(
                              fontWeight: FontWeight.w700,
                              color: context.appSubText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Carousel d'écrans PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: slides.length,
                      onPageChanged: (idx) {
                        setState(() {
                          _currentPage = idx;
                        });
                      },
                      itemBuilder: (context, index) {
                        final slide = slides[index];
                        return _CarouselSlideView(slide: slide);
                      },
                    ),
                  ),

                  // Barre inférieure : Indicateur de pages & Bouton d'action
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpace.s5,
                      AppSpace.s2,
                      AppSpace.s5,
                      MediaQuery.of(context).orientation == Orientation.landscape
                          ? AppSpace.s2
                          : AppSpace.s4,
                    ),
                    child: Column(
                      mainAxisSize: minAxisSize,
                      children: [
                        // Indicateur de points (Dots)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(slides.length, (idx) {
                            final isActive = idx == _currentPage;
                            return AnimatedContainer(
                              duration: AppMotion.base,
                              curve: Curves.easeOutCubic,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: isActive ? 28 : 8,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? AppColors.sky600
                                    : context.appBorder,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                            );
                          }),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                              ? AppSpace.s2
                              : AppSpace.s4,
                        ),

                        // Bouton Suivant / Rencontrer Pi
                        ChunkyButton(
                          label: _currentPage == slides.length - 1
                              ? strings.onboardingMeetPi
                              : strings.onboardingNext,
                          variant: ChunkyButtonVariant.primary,
                          height: MediaQuery.of(context).orientation ==
                                  Orientation.landscape
                              ? 44
                              : 56,
                          onPressed: _onNext,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const minAxisSize = MainAxisSize.min;
}

/// Vue individuelle d'un slide du carousel
class _CarouselSlideView extends StatelessWidget {
  final ({
    String tag,
    String title,
    String description,
    String imagePath,
    Color tagBgColor,
    Color tagTextColor,
    Color accentColor,
    IconData icon,
  })
  slide;

  const _CarouselSlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.s5),
        child: Row(
          children: [
            // Mockup miniature à gauche
            Expanded(
              flex: 4,
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  margin: const EdgeInsets.symmetric(vertical: AppSpace.s1),
                  decoration: BoxDecoration(
                    color: context.appSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: context.appBorder,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.ink900.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AspectRatio(
                      aspectRatio: 9 / 19.5,
                      child: Image.asset(
                        slide.imagePath,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              slide.icon,
                              size: 48,
                              color: slide.accentColor,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpace.s4),
            // Texte explicatif à droite
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.s3,
                        vertical: AppSpace.s1,
                      ),
                      decoration: BoxDecoration(
                        color: slide.tagBgColor,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(slide.icon, size: 15, color: slide.tagTextColor),
                          const SizedBox(width: AppSpace.s1),
                          Flexible(
                            child: Text(
                              slide.tag,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: AppText.label.copyWith(
                                color: slide.tagTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpace.s2),
                    Text(
                      slide.title,
                      style: AppText.h2.copyWith(
                        color: context.appText,
                        fontSize: 18,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpace.s2),
                    Text(
                      slide.description,
                      style: AppText.body.copyWith(
                        color: context.appSubText,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.s5),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpace.s2),

                  // Mockup du screenshot de l'app dans un cadre moderne
                  Expanded(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 380),
                        margin: const EdgeInsets.symmetric(
                          vertical: AppSpace.s2,
                        ),
                        decoration: BoxDecoration(
                          color: context.appSurface,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: context.appBorder,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.ink900.withValues(alpha: 0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: AspectRatio(
                            aspectRatio: 9 / 19.5,
                            child: Image.asset(
                              slide.imagePath,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    slide.icon,
                                    size: 64,
                                    color: slide.accentColor,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpace.s3),

                  // Tag thématique coloré
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.s3,
                      vertical: AppSpace.s1,
                    ),
                    decoration: BoxDecoration(
                      color: slide.tagBgColor,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(slide.icon, size: 15, color: slide.tagTextColor),
                        const SizedBox(width: AppSpace.s1),
                        Text(
                          slide.tag,
                          style: AppText.label.copyWith(
                            color: slide.tagTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpace.s2),

                  // Titre accrocheur
                  Text(
                    slide.title,
                    textAlign: TextAlign.center,
                    style: AppText.h2.copyWith(
                      color: context.appText,
                      fontSize: 22,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: AppSpace.s2),

                  // Explication claire & rassurante
                  Text(
                    slide.description,
                    textAlign: TextAlign.center,
                    style: AppText.body.copyWith(
                      color: context.appSubText,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: AppSpace.s3),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
