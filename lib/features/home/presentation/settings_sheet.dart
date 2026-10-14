import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/language_switcher.dart';

/// Feuille modale des Paramètres (accessible via l'icône engrenage).
/// Contient le réglage de la langue (EN / FR) et les préférences.
class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpace.s5),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Poignée de glissement
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpace.s4),
                decoration: BoxDecoration(
                  color: AppColors.ink200,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),

            // Titre « Paramètres » / « Settings »
            Text(
              strings.settings,
              style: AppText.h3,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpace.s5),

            // Carte de réglage de la langue
            Container(
              padding: const EdgeInsets.all(AppSpace.s4),
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.ink200, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.languageTitle,
                        style: AppText.label.copyWith(color: AppColors.ink900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        strings.isFrench ? 'Français activé' : 'English active',
                        style: AppText.bodyS.copyWith(color: AppColors.ink600),
                      ),
                    ],
                  ),
                  const LanguageSwitcher(),
                ],
              ),
            ),

            const SizedBox(height: AppSpace.s6),

            // Bouton Fermer
            ChunkyButton(
              label: strings.close,
              variant: ChunkyButtonVariant.secondary,
              height: 48,
              onPressed: () => Navigator.of(context).pop(),
            ),

            const SizedBox(height: AppSpace.s2),
          ],
        ),
      ),
    );
  }
}
