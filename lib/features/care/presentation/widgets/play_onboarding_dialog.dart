import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/chunky_button.dart';

/// Dialogue d'onboarding affiché la première fois que l'enfant accède au jeu de balle.
/// Consultable à nouveau à tout moment depuis les Paramètres.
class PlayOnboardingDialog extends StatelessWidget {
  static const String prefKey = 'pi_play_onboarding_shown';
  final bool isFrench;

  const PlayOnboardingDialog({
    super.key,
    required this.isFrench,
  });

  /// Affiche le dialogue et persiste le choix dans SharedPreferences
  static Future<void> show(BuildContext context, {required bool isFrench}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefKey, true);

    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => PlayOnboardingDialog(isFrench: isFrench),
    );
  }

  /// Vérifie si l'onboarding doit être affiché automatiquement
  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefKey) != true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
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
            // En-tête
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpace.s2),
                  decoration: BoxDecoration(
                    color: AppColors.sky50,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.sports_tennis_rounded,
                    color: AppColors.sky600,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSpace.s3),
                Expanded(
                  child: Text(
                    isFrench
                        ? 'Comment jouer avec Pi ?'
                        : 'How to play with Pi?',
                    style: AppText.h3.copyWith(
                      color: AppColors.ink900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpace.s4),

            // Étape 1 : Lancer la balle
            _buildStep(
              icon: Icons.send_rounded,
              title: isFrench ? '1. Lance la balle' : '1. Toss the ball',
              description: isFrench
                  ? 'Appuie sur "Lancer la balle" pour l\'envoyer sur le terrain.'
                  : 'Tap "Throw the ball" to send it onto the field.',
            ),

            const SizedBox(height: AppSpace.s3),

            // Étape 2 : Guider ou laisser courir
            _buildStep(
              icon: Icons.touch_app_rounded,
              title: isFrench ? '2. Va la chercher' : '2. Fetch it',
              description: isFrench
                  ? 'Touche l\'écran pour guider Pi, ou attends 2 secondes pour qu\'il coure tout seul !'
                  : 'Tap the screen to guide Pi, or wait 2 seconds for him to fetch it!',
            ),

            const SizedBox(height: AppSpace.s3),

            // Étape 3 : Rapporter la balle
            _buildStep(
              icon: Icons.sentiment_very_satisfied_rounded,
              title: isFrench ? '3. Rapporte la balle' : '3. Bring it back',
              description: isFrench
                  ? 'Pi te rapporte la balle à sa place. C\'est là qu\'elle est jouée et qu\'il gagne de la Joie !'
                  : 'Pi brings the ball back to his spot. Only then is it counted and boosts his Joy!',
            ),

            const SizedBox(height: AppSpace.s4),

            // Indication pour revoir dans les réglages
            Container(
              padding: const EdgeInsets.all(AppSpace.s3),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.ink200, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.ink500),
                  const SizedBox(width: AppSpace.s2),
                  Expanded(
                    child: Text(
                      isFrench
                          ? 'Tu pourras revoir ce guide à tout moment dans les Paramètres ⚙️.'
                          : 'You can review this guide anytime in Settings ⚙️.',
                      style: AppText.bodyS.copyWith(
                        fontSize: 11,
                        color: AppColors.ink600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpace.s4),

            // Bouton de validation
            ChunkyButton(
              label: isFrench ? 'C\'est compris !' : 'Got it!',
              variant: ChunkyButtonVariant.primary,
              height: 50,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.sky50,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            border: Border.all(color: AppColors.sky500.withValues(alpha: 0.3), width: 1),
          ),
          child: Icon(icon, color: AppColors.sky600, size: 18),
        ),
        const SizedBox(width: AppSpace.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppText.label.copyWith(
                  color: AppColors.ink900,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppText.bodyS.copyWith(
                  color: AppColors.ink600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
