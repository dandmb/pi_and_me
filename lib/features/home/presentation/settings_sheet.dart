import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/theme/theme_mode_controller.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/audio/sound_mode_controller.dart';
import '../../profile/presentation/widgets/profile_switcher_sheet.dart';
import '../../parent/presentation/parent_dashboard_screen.dart';
import '../../parent/presentation/widgets/parental_gate_dialog.dart';

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
    final themeMode = ref.watch(themeModeProvider);
    final isSoundEnabled = ref.watch(soundEnabledProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpace.s5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
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
                  color: isDark ? AppColors.darkInk200 : AppColors.ink200,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),

            // Titre « Paramètres » / « Settings »
            Text(
              strings.settings,
              style: AppText.h3.copyWith(
                color: isDark ? AppColors.darkInk900 : AppColors.ink900,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpace.s5),

            // Carte de réglage de la langue
            Container(
              padding: const EdgeInsets.all(AppSpace.s4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceAlt : AppColors.bg,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: isDark ? AppColors.darkInk200 : AppColors.ink200,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.languageTitle,
                        style: AppText.label.copyWith(
                          color: isDark ? AppColors.darkInk900 : AppColors.ink900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        strings.languageActiveDescription,
                        style: AppText.bodyS.copyWith(
                          color: isDark ? AppColors.darkInk500 : AppColors.ink600,
                        ),
                      ),
                    ],
                  ),
                  const LanguageSwitcher(),
                ],
              ),
            ),

            const SizedBox(height: AppSpace.s3),

            // Effets Sonores (Activer / Désactiver)
            Container(
              padding: const EdgeInsets.all(AppSpace.s4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceAlt : AppColors.bg,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: isDark ? AppColors.darkInk200 : AppColors.ink200,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpace.s2),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : AppColors.sky50,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      isSoundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      color: isSoundEnabled ? AppColors.sky600 : AppColors.ink500,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpace.s3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.soundEffectsTitle,
                          style: AppText.label.copyWith(
                            color: isDark ? AppColors.darkInk900 : AppColors.ink900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isSoundEnabled ? strings.soundEnabled : strings.soundDisabled,
                          style: AppText.bodyS.copyWith(
                            color: isDark ? AppColors.darkInk500 : AppColors.ink600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    key: const Key('sound_effects_switch'),
                    value: isSoundEnabled,
                    activeTrackColor: AppColors.sky600,
                    onChanged: (val) {
                      ref.read(soundEnabledProvider.notifier).setSoundEnabled(val);
                      if (val) {
                        ref.read(audioServiceProvider).playPop();
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpace.s3),

            // Profils des enfants (lister et switcher de profil)
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
                ProfileSwitcherSheet.show(context);
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpace.s4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceAlt : AppColors.bg,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isDark ? AppColors.darkInk200 : AppColors.ink200,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpace.s2),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSky50 : AppColors.sky50,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.supervised_user_circle_rounded,
                        color: AppColors.sky600,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpace.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.profilesTitle,
                            style: AppText.label.copyWith(
                              color: isDark ? AppColors.darkInk900 : AppColors.ink900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            strings.changeProfile,
                            style: AppText.bodyS.copyWith(
                              color: isDark ? AppColors.darkInk500 : AppColors.ink600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? AppColors.darkInk500 : AppColors.ink500,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpace.s3),

            // Espace Parents sécurisé par le Parental Gate
            GestureDetector(
              key: const Key('parent_dashboard_entry_tile'),
              onTap: () async {
                final navigator = Navigator.of(context);
                final unlocked = await ParentalGateDialog.show(context);
                if (unlocked == true && navigator.mounted) {
                  navigator.pop();
                  navigator.push(
                    MaterialPageRoute(
                      builder: (_) => const ParentDashboardScreen(),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpace.s4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceAlt : AppColors.bg,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isDark ? AppColors.darkInk200 : AppColors.ink200,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpace.s2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : AppColors.sky50,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: AppColors.sky600,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpace.s3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                strings.parentSettingsEntryTitle,
                                style: AppText.label.copyWith(
                                  color: isDark ? AppColors.darkInk900 : AppColors.ink900,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.lock_rounded, size: 14, color: AppColors.sky600),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            strings.parentSettingsEntrySubtitle,
                            style: AppText.bodyS.copyWith(
                              color: isDark ? AppColors.darkInk500 : AppColors.ink600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? AppColors.darkInk500 : AppColors.ink500,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpace.s3),

            // Réglage du Mode Sombre / Thème
            Container(
              padding: const EdgeInsets.all(AppSpace.s4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceAlt : AppColors.bg,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: isDark ? AppColors.darkInk200 : AppColors.ink200,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                        size: 20,
                        color: isDark ? const Color(0xFF818CF8) : AppColors.gold600,
                      ),
                      const SizedBox(width: AppSpace.s2),
                      Text(
                        strings.themeTitle,
                        style: AppText.label.copyWith(
                          color: isDark ? AppColors.darkInk900 : AppColors.ink900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.s3),
                  Row(
                    children: [
                      Expanded(
                        child: _buildThemeOption(
                          context,
                          ref,
                          mode: ThemeMode.light,
                          label: strings.lightTheme,
                          icon: Icons.wb_sunny_rounded,
                          isSelected: themeMode == ThemeMode.light,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildThemeOption(
                          context,
                          ref,
                          mode: ThemeMode.dark,
                          label: strings.darkTheme,
                          icon: Icons.bedtime_rounded,
                          isSelected: themeMode == ThemeMode.dark,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildThemeOption(
                          context,
                          ref,
                          mode: ThemeMode.system,
                          label: strings.systemTheme,
                          icon: Icons.auto_mode_rounded,
                          isSelected: themeMode == ThemeMode.system,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
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
    ),
  );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref, {
    required ThemeMode mode,
    required String label,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
  }) {
    final activeColor = AppColors.sky600;
    final inactiveBg = isDark ? AppColors.darkSurface : AppColors.surface;
    final activeBg = isDark ? AppColors.darkSky50 : AppColors.sky50;

    return GestureDetector(
      onTap: () {
        ref.read(themeModeProvider.notifier).setTheme(mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? activeColor : (isDark ? AppColors.darkInk200 : AppColors.ink200),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    offset: const Offset(0, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? activeColor : (isDark ? AppColors.darkInk500 : AppColors.ink500),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppText.bodyS.copyWith(
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                fontSize: 11.5,
                color: isSelected ? activeColor : (isDark ? AppColors.darkInk600 : AppColors.ink600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
