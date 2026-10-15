import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/chunky_button.dart';
import 'kibble_widget.dart';

/// Tutoriel interactif guidé pas-à-pas pour la partie "Nourrir",
/// pointant successivement vers les 4 éléments clés (Stock, Assiette, Servir, Viens manger).
class FeedWalkthroughDialog extends StatefulWidget {
  static const String prefKey = 'pi_feed_walkthrough_shown';
  final bool isFrench;

  const FeedWalkthroughDialog({
    super.key,
    required this.isFrench,
  });

  /// Affiche le tutoriel et persiste l'affichage dans SharedPreferences
  static Future<void> show(BuildContext context, {required bool isFrench}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKey, true);

    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => FeedWalkthroughDialog(isFrench: isFrench),
    );
  }

  /// Vérifie si le tutoriel doit être proposé au premier accès à "Nourrir"
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefKey) != true;
  }

  @override
  State<FeedWalkthroughDialog> createState() => _FeedWalkthroughDialogState();
}

class _FeedWalkthroughDialogState extends State<FeedWalkthroughDialog> {
  int _currentStep = 0; // 0, 1, 2, 3

  List<_TutorialStep> _getSteps(bool isFr, BuildContext context) {
    return [
      _TutorialStep(
        badge: isFr ? 'Étape 1 sur 4' : 'Step 1 of 4',
        title: isFr ? '1. Ton stock de croquettes' : '1. Your kibble stock',
        description: isFr
            ? 'La rangée en haut affiche tes croquettes gagnées grâce à tes bonnes réponses aux quiz mathématiques.'
            : 'The top row shows your kibbles earned through correct math quiz answers.',
        icon: Icons.inventory_2_rounded,
        accentColor: AppColors.green600,
        customGraphic: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            KibbleWidget(size: 24),
            SizedBox(width: 6),
            KibbleWidget(size: 24),
            SizedBox(width: 6),
            KibbleWidget(size: 24),
          ],
        ),
      ),
      _TutorialStep(
        badge: isFr ? 'Étape 2 sur 4' : 'Step 2 of 4',
        title: isFr ? '2. L\'assiette dans le coin' : '2. The bowl in the corner',
        description: isFr
            ? 'Regarde dans le coin inférieur du décor : l\'assiette de Pi t\'y attend, posée sur son tapis.'
            : 'Look in the bottom corner: Pi\'s bowl is waiting on its feeding mat.',
        icon: Icons.pets,
        accentColor: AppColors.sky600,
        customGraphic: Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            color: context.isDark ? AppColors.darkSky50 : AppColors.sky50,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.sky500, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.pets, size: 16, color: AppColors.sky600),
          ),
        ),
      ),
      _TutorialStep(
        badge: isFr ? 'Étape 3 sur 4' : 'Step 3 of 4',
        title: isFr ? '3. Remplir l\'assiette' : '3. Fill the bowl',
        description: isFr
            ? 'Appuie sur le bouton « Servir ». À chaque pression, une croquette tombe dans l\'assiette et la remplit peu à peu !'
            : 'Tap the "Serve" button. Each tap drops a kibble into the bowl, filling it up!',
        icon: Icons.soup_kitchen_rounded,
        accentColor: AppColors.green600,
        customGraphic: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: context.isDark ? const Color(0xFF064E3B) : AppColors.green50,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.green600, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.soup_kitchen_rounded,
                size: 16,
                color: context.isDark ? const Color(0xFF6EE7B7) : AppColors.green700,
              ),
              const SizedBox(width: 6),
              Text(
                isFr ? 'Servir' : 'Serve',
                style: AppText.bodyS.copyWith(
                  fontWeight: FontWeight.w900,
                  color: context.isDark ? const Color(0xFF6EE7B7) : AppColors.green700,
                ),
              ),
            ],
          ),
        ),
      ),
      _TutorialStep(
        badge: isFr ? 'Étape 4 sur 4' : 'Step 4 of 4',
        title: isFr ? '4. Viens manger !' : '4. Come eat!',
        description: isFr
            ? 'Dès que l\'assiette est prête, appuie sur « Viens manger ! ». Pi accourt, prend 5 secondes pour se régaler, puis retourne joyeusement au centre.'
            : 'Once the bowl is ready, tap "Come eat!". Pi runs over, takes 5 seconds to feast, then happily returns to the center.',
        icon: Icons.restaurant_rounded,
        accentColor: AppColors.sky600,
        customGraphic: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: context.isDark ? AppColors.darkSky50 : AppColors.sky50,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.sky600, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.restaurant_rounded,
                size: 16,
                color: context.isDark ? AppColors.darkSky500 : AppColors.sky700,
              ),
              const SizedBox(width: 6),
              Text(
                isFr ? 'Viens manger !' : 'Come eat!',
                style: AppText.bodyS.copyWith(
                  fontWeight: FontWeight.w900,
                  color: context.isDark ? AppColors.darkSky500 : AppColors.sky700,
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final steps = _getSteps(widget.isFrench, context);
    final step = steps[_currentStep];
    final isLast = _currentStep == steps.length - 1;

    return Dialog(
      backgroundColor: context.appSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.s5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barre supérieure : Badge d'étape et bouton Passer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 4),
                  decoration: BoxDecoration(
                    color: step.accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    step.badge,
                    style: AppText.bodyS.copyWith(
                      fontWeight: FontWeight.w900,
                      color: step.accentColor,
                      fontSize: 11,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Text(
                    widget.isFrench ? 'Passer' : 'Skip',
                    style: AppText.bodyS.copyWith(
                      color: context.appSubText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpace.s4),

            // Illustration de l'élément ciblé
            Center(
              child: Container(
                width: 90,
                height: 70,
                decoration: BoxDecoration(
                  color: context.appBg,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: context.appBorder, width: 2),
                ),
                child: Center(child: step.customGraphic),
              ),
            ),

            const SizedBox(height: AppSpace.s4),

            // Titre de l'étape
            Text(
              step.title,
              style: AppText.h3.copyWith(
                color: context.appText,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpace.s2),

            // Description explicative détaillée
            Text(
              step.description,
              style: AppText.bodyS.copyWith(
                color: context.appSubText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpace.s5),

            // Indicateurs de progression (petits points)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                steps.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentStep == index ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _currentStep == index
                        ? step.accentColor
                        : (context.isDark ? AppColors.darkInk200 : AppColors.ink200),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpace.s5),

            // Bouton Suivant / Compris
            ChunkyButton(
              label: isLast
                  ? (widget.isFrench ? 'C\'est parti !' : 'Let\'s go!')
                  : (widget.isFrench ? 'Suivant' : 'Next'),
              variant: ChunkyButtonVariant.primary,
              height: 48,
              onPressed: () {
                if (isLast) {
                  Navigator.of(context).pop();
                } else {
                  setState(() {
                    _currentStep++;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialStep {
  final String badge;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Widget customGraphic;

  const _TutorialStep({
    required this.badge,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.customGraphic,
  });
}
