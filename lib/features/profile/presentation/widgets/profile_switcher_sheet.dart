import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/locale_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_text.dart';
import '../../../../core/widgets/chunky_button.dart';
import '../../../onboarding/presentation/onboarding_screen.dart';
import '../../data/profile_repository.dart';
import '../../domain/child_profile.dart';
import '../profile_controller.dart';

/// Feuille modale permettant de lister tous les profils enfants créés,
/// de basculer de l'un à l'autre en un tap, d'en créer de nouveaux (jusqu'à 4),
/// ou de supprimer un profil secondaire en toute sécurité.
class ProfileSwitcherSheet extends ConsumerWidget {
  const ProfileSwitcherSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ProfileSwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final profilesAsync = ref.watch(allProfilesProvider);
    final activeProfileAsync = ref.watch(activeProfileProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpace.s5),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
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
                  color: context.appBorder,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),

            // Titre « Profils des enfants »
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.supervised_user_circle_rounded,
                  color: AppColors.sky600,
                  size: 26,
                ),
                const SizedBox(width: AppSpace.s2),
                Text(
                  strings.profilesTitle,
                  style: AppText.h3.copyWith(color: context.appText),
                ),
              ],
            ),

            const SizedBox(height: AppSpace.s4),

            // Liste des profils enregistrés
            profilesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpace.s6),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.sky600),
                ),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpace.s4),
                child: Text(
                  '${strings.errorTitle} ($err)',
                  style: AppText.bodyS.copyWith(color: AppColors.coral500),
                  textAlign: TextAlign.center,
                ),
              ),
              data: (profiles) {
                final activeProfile = activeProfileAsync.valueOrNull;

                return Column(
                  children: [
                    for (final profile in profiles)
                      _ProfileCard(
                        profile: profile,
                        isActive: profile.id == activeProfile?.id,
                        canDelete: profiles.length > 1,
                        onSelect: () async {
                          if (profile.id != activeProfile?.id) {
                            await ref
                                .read(activeProfileProvider.notifier)
                                .switchProfile(profile.id);
                          }
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${strings.profileActivated} (${profile.name})',
                                  style: AppText.bodyS.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: AppColors.sky700,
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        onDelete: () => _confirmDelete(context, ref, profile),
                      ),

                    const SizedBox(height: AppSpace.s2),

                    // Bouton « Ajouter un profil » (si < 4 profils)
                    if (profiles.length < ProfileRepository.maxProfiles)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpace.s2),
                        child: ChunkyButton(
                          label: strings.addProfile,
                          variant: ChunkyButtonVariant.secondary,
                          height: 48,
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const OnboardingScreen(canCancel: true),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpace.s2,
                        ),
                        child: Text(
                          strings.maxProfilesReached,
                          style: AppText.bodyS.copyWith(
                            color: AppColors.ink500,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: AppSpace.s4),

            // Bouton Fermer
            ChunkyButton(
              label: strings.close,
              variant: ChunkyButtonVariant.secondary,
              height: 44,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ChildProfile profile,
  ) {
    final strings = ref.read(stringsProvider);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: context.appSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.coral500),
            const SizedBox(width: AppSpace.s2),
            Expanded(
              child: Text(
                strings.deleteProfileConfirm,
                style: AppText.h3.copyWith(
                  fontSize: 18,
                  color: context.appText,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          strings.deleteProfileWarning(profile.name),
          style: AppText.body.copyWith(color: context.appSubText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(strings.cancel, style: AppText.label),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral500,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await ref
                  .read(activeProfileProvider.notifier)
                  .deleteProfile(profile.id);
            },
            child: Text(strings.delete, style: AppText.buttonM),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  final ChildProfile profile;
  final bool isActive;
  final bool canDelete;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  const _ProfileCard({
    required this.profile,
    required this.isActive,
    required this.canDelete,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final gradeLabel = strings.getGradeLabel(profile.grade);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.s3),
      decoration: BoxDecoration(
        color: isActive
            ? (context.isDark ? AppColors.darkSky50 : AppColors.sky50)
            : context.appSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isActive ? AppColors.sky500 : context.appBorder,
          width: isActive ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive
                ? (context.isDark ? Colors.transparent : AppColors.sky50)
                : context.appShadow,
            offset: const Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: onSelect,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.s4,
              vertical: AppSpace.s3,
            ),
            child: Row(
              children: [
                // Avatar vectoriel
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.sky500
                        : (context.isDark
                              ? AppColors.darkSurfaceAlt
                              : AppColors.ink100),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getAvatarIcon(profile.avatar),
                    color: isActive ? Colors.white : context.appSubText,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpace.s3),

                // Nom et Classe
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: AppText.h3.copyWith(
                          fontSize: 17,
                          color: context.appText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        gradeLabel,
                        style: AppText.bodyS.copyWith(
                          color: context.appSubText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge Actif ou Bouton Supprimer
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.s3,
                      vertical: AppSpace.s1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.green500,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          strings.activeProfileLabel,
                          style: AppText.label.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (canDelete)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: context.appSubText,
                      size: 22,
                    ),
                    tooltip: strings.delete,
                    onPressed: onDelete,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getAvatarIcon(String avatarId) {
    switch (avatarId) {
      case 'avatar_dog':
        return Icons.pets_rounded;
      case 'avatar_cat':
        return Icons.cruelty_free_rounded;
      case 'avatar_fox':
        return Icons.forest_rounded;
      case 'avatar_bear':
        return Icons.theater_comedy_rounded;
      default:
        return Icons.face_rounded;
    }
  }
}
