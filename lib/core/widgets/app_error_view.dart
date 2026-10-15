import 'package:flutter/material.dart';
import '../localization/app_language.dart';
import '../localization/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text.dart';
import 'chunky_button.dart';

/// Vue d'erreur rassurante et adaptée aux enfants (6-15 ans).
/// Remplace les écrans d'erreur techniques par un visuel chaleureux et une action de reprise.
class AppErrorView extends StatelessWidget {
  final String? customMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onHome;
  final bool isFrench;

  const AppErrorView({
    super.key,
    this.customMessage,
    this.onRetry,
    this.onHome,
    this.isFrench = true,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(isFrench ? AppLanguage.fr : AppLanguage.en);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          margin: const EdgeInsets.all(AppSpace.s5),
          padding: const EdgeInsets.all(AppSpace.s6),
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: context.appBorder, width: 2),
            boxShadow: [
              BoxShadow(
                color: context.appShadow,
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône pansement / soin doux
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: context.isDark ? AppColors.darkSky50 : AppColors.sky50,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.sky500.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.healing_rounded,
                  size: 40,
                  color: AppColors.sky600,
                ),
              ),

              const SizedBox(height: AppSpace.s4),

              // Titre rassurant
              Text(
                strings.errorTitle,
                style: AppText.h3.copyWith(color: context.appText),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpace.s2),

              // Message bienveillant
              Text(
                customMessage ?? strings.errorMessage,
                style: AppText.body.copyWith(color: context.appSubText),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpace.s5),

              // Bouton Réessayer (si callback fournie)
              if (onRetry != null) ...[
                ChunkyButton(
                  label: strings.retry,
                  variant: ChunkyButtonVariant.primary,
                  height: 48,
                  onPressed: onRetry,
                ),
                const SizedBox(height: AppSpace.s2),
              ],

              // Bouton Retour au salon (si callback fournie)
              if (onHome != null) ...[
                ChunkyButton(
                  label: strings.returnToHome,
                  variant: ChunkyButtonVariant.secondary,
                  height: 44,
                  onPressed: onHome,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
