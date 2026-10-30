import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/audio/audio_service.dart';
import '../../../../core/localization/locale_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../../care/presentation/widgets/animated_pi_mascot.dart';
import '../rating_controller.dart';

/// Dialogue modal récompensant un « Moment de Victoire » et sollicitant avec bienveillance
/// une note sur le Store (In-App Review).
class RatingMilestoneDialog extends ConsumerWidget {
  const RatingMilestoneDialog({super.key});

  /// Affiche le dialogue modal de notation.
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const RatingMilestoneDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s4,
        vertical: AppSpace.s5,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(AppSpace.s4),
        decoration: BoxDecoration(
          color: context.appSurface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: context.appBorder,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: context.appShadow,
              offset: const Offset(0, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge "Victoire / Étoiles"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.amber50,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.gold600, width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('⭐', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 4),
                  Text(
                    'SUPER CHAMPION',
                    style: TextStyle(
                      color: AppColors.amber900,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text('⭐', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),

            const SizedBox(height: AppSpace.s2),

            // Mascotte Pi qui célèbre
            const SizedBox(
              height: 105,
              width: 120,
              child: AnimatedPiMascot(
                piSize: 95,
                isCelebrating: true,
              ),
            ),

            const SizedBox(height: AppSpace.s2),

            // Titre & Sous-titre
            Text(
              strings.ratingDialogTitle,
              textAlign: TextAlign.center,
              style: AppText.h3.copyWith(
                color: context.appText,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              strings.ratingDialogSubtitle,
              textAlign: TextAlign.center,
              style: AppText.bodyS.copyWith(
                color: AppColors.sky600,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: AppSpace.s3),

            // Texte descriptif engageant
            Text(
              strings.ratingDialogBody,
              textAlign: TextAlign.center,
              style: AppText.body.copyWith(
                color: context.appSubText,
                fontSize: 13,
                height: 1.35,
              ),
            ),

            const SizedBox(height: AppSpace.s4),

            // Bouton Principal : ⭐ Donner 5 étoiles
            ChunkyButton(
              key: const Key('rating_dialog_confirm_button'),
              label: strings.ratingActionRate,
              variant: ChunkyButtonVariant.primary,
              height: 50,
              onPressed: () async {
                ref.read(audioServiceProvider).playBark();
                final navigator = Navigator.of(context);
                final messenger = ScaffoldMessenger.of(context);

                await ref.read(ratingControllerProvider.notifier).rateApp();

                if (navigator.mounted) {
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        strings.ratingThankYouMessage,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      backgroundColor: AppColors.green600,
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: AppSpace.s2),

            // Bouton Secondaire : Plus tard
            TextButton(
              key: const Key('rating_dialog_later_button'),
              onPressed: () {
                ref.read(audioServiceProvider).playPop();
                ref.read(ratingControllerProvider.notifier).dismissLater();
                Navigator.of(context).pop();
              },
              child: Text(
                strings.ratingActionLater,
                style: AppText.bodyS.copyWith(
                  color: isDark ? AppColors.darkInk500 : AppColors.ink500,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
