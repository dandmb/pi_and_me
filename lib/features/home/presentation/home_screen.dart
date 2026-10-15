import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/app_error_view.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../care/presentation/care_controller.dart';
import '../../care/presentation/care_screen.dart';
import '../../profile/domain/school_grade.dart';
import '../../profile/presentation/profile_controller.dart';
import '../../profile/presentation/widgets/profile_switcher_sheet.dart';
import '../../quiz/presentation/quiz_controller.dart';
import '../../quiz/presentation/quiz_screen.dart';
import '../../shop/presentation/shop_controller.dart';
import '../../shop/presentation/shop_screen.dart';
import '../../shop/presentation/widgets/accessory_overlay_widget.dart';
import 'settings_sheet.dart';

/// Écran 1 bis : Le Salon de Pi (Hub Principal bilingue EN/FR).
/// Présente l'enfant, l'état de Pi et le point d'accès au Quiz.
class HomeScreen extends ConsumerWidget {
  final bool isEmbedded;
  final ValueChanged<int>? onSwitchTab;

  const HomeScreen({
    super.key,
    this.isEmbedded = false,
    this.onSwitchTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(activeProfileProvider);
    final strings = ref.watch(stringsProvider);
    final companion = ref.watch(careControllerProvider);
    final shopState = ref.watch(shopControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.sky600),
          ),
          error: (err, _) => AppErrorView(
            isFrench: strings.isFrench,
            onRetry: () => ref.invalidate(activeProfileProvider),
          ),
          data: (profile) {
            final childName = profile?.name ?? 'Ami';
            final gradeLabel = profile != null
                ? strings.getGradeLabel(profile.grade)
                : (strings.isFrench ? 'CM1' : 'Grade 4');

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.s5,
                vertical: AppSpace.s3,
              ),
              child: Column(
                children: [
                  // Barre supérieure : Pastille profil, Solde d'Os & Sélecteur de langue (si non embarqué)
                  if (!isEmbedded) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Pastille profil enfant
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.s3,
                          vertical: AppSpace.s1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: AppColors.ink200, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.face_rounded,
                              size: 18,
                              color: AppColors.sky700,
                            ),
                            const SizedBox(width: AppSpace.s2),
                            Text(
                              '$childName ($gradeLabel)',
                              style: AppText.label.copyWith(color: AppColors.ink900),
                            ),
                          ],
                        ),
                      ),

                      // Pastille Os dorés
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.s3,
                          vertical: AppSpace.s1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.amber50,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: const Color(0xFFFDE68A),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.stars_rounded,
                              size: 18,
                              color: AppColors.gold600,
                            ),
                            const SizedBox(width: AppSpace.s1),
                            Text(
                              '${companion.bones}',
                              style: AppText.mathS.copyWith(
                                color: AppColors.amber900,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Bouton Paramètres (ouvre la feuille des réglages et du choix de langue)
                      GestureDetector(
                        onTap: () => SettingsSheet.show(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.ink200, width: 1.5),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.ink100,
                                offset: Offset(0, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.settings_rounded,
                            size: 22,
                            color: AppColors.ink600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.s4),
                ],

                  // Bulle de dialogue de Pi
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.s5,
                      vertical: AppSpace.s3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: AppColors.ink200, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.ink100,
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      strings.readyForQuiz(childName),
                      style: AppText.bodyL.copyWith(color: AppColors.ink900),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: AppSpace.s4),

                  // Mascotte Pi avec ombre au sol (Cliquer ouvre l'aire de jeu / soins)
                  GestureDetector(
                    onTap: () {
                      if (onSwitchTab != null) {
                        onSwitchTab!(1);
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CareScreen()),
                        );
                      }
                    },
                    child: SizedBox(
                      height: 160,
                      width: 160,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            bottom: 8,
                            child: Container(
                              width: 90,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.12),
                                borderRadius: const BorderRadius.all(
                                  Radius.elliptical(90, 16),
                                ),
                              ),
                            ),
                          ),
                          Image.asset(
                            'assets/images/pi_transparent.png',
                            height: 130,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.pets,
                              size: 90,
                              color: AppColors.sky600,
                            ),
                          ),
                          AccessoryOverlayWidget(
                            accessoryId: shopState.equippedAccessoryId,
                            piSize: 130,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpace.s4),

                  // Jauges de Pi (cliquables pour ouvrir l'aire de jeu)
                  GestureDetector(
                    onTap: () {
                      if (onSwitchTab != null) {
                        onSwitchTab!(1);
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CareScreen()),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpace.s4),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(color: AppColors.ink200, width: 2),
                      ),
                      child: Column(
                        children: [
                          _GaugeRow(
                            icon: Icons.restaurant_rounded,
                            label: strings.hunger,
                            value: companion.hunger,
                            color: AppColors.green500,
                          ),
                          const SizedBox(height: AppSpace.s3),
                          _GaugeRow(
                            icon: Icons.sports_tennis_rounded,
                            label: strings.joy,
                            value: companion.joy,
                            color: AppColors.sky500,
                          ),
                          const SizedBox(height: AppSpace.s3),
                          _GaugeRow(
                            icon: Icons.nightlight_round,
                            label: strings.energy,
                            value: companion.energy,
                            color: AppColors.teal400,
                          ),
                          const SizedBox(height: AppSpace.s3),
                          _GaugeRow(
                            icon: Icons.auto_awesome_rounded,
                            label: strings.cleanliness,
                            value: companion.cleanliness,
                            color: const Color(0xFF8B5CF6),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpace.s4),

                  // Bouton principal pour lancer le quiz
                  ChunkyButton(
                    label: strings.playQuiz,
                    variant: ChunkyButtonVariant.primary,
                    height: 56,
                    onPressed: () {
                      final grade = profile?.grade ?? SchoolGrade.cm1;
                      ref.read(quizControllerProvider.notifier).startQuiz(grade);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const QuizScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpace.s2),

                  // Bouton secondaire pour prendre soin et jouer avec Pi
                  ChunkyButton(
                    label: strings.feedAndCare,
                    variant: ChunkyButtonVariant.secondary,
                    height: 48,
                    onPressed: () {
                      if (onSwitchTab != null) {
                        onSwitchTab!(1);
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CareScreen(),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: AppSpace.s2),

                  // Bouton secondaire pour changer d'enfant / profil
                  TextButton(
                    onPressed: () => ProfileSwitcherSheet.show(context),
                    child: Text(
                      strings.changeProfile,
                      style: AppText.label.copyWith(color: AppColors.sky800),
                    ),
                  ),

                  // 3-Tab Bottom Dock (si non embarqué dans MainShellScreen)
                  if (!isEmbedded) ...[
                    const SizedBox(height: AppSpace.s3),
                    _buildBottomDock(context, strings),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomDock(BuildContext context, dynamic strings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.ink200, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.ink100,
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Soigner
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CareScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    size: 18,
                    color: AppColors.ink500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    strings.careDockLabel,
                    style: AppText.bodyS.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Salon (Actif)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.sky50,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.sky500, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.home_rounded,
                  size: 18,
                  color: AppColors.sky600,
                ),
                const SizedBox(width: 6),
                Text(
                  strings.salonDockLabel,
                  style: AppText.bodyS.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.sky700,
                  ),
                ),
              ],
            ),
          ),

          // 3. Boutique
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ShopScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3, vertical: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.storefront_rounded,
                    size: 18,
                    color: AppColors.ink500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    strings.shopDockLabel,
                    style: AppText.bodyS.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink500,
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
}

class _GaugeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color color;

  const _GaugeRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).toInt();

    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpace.s2),
        SizedBox(
          width: 70,
          child: Text(label, style: AppText.label),
        ),
        const SizedBox(width: AppSpace.s2),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              height: 10,
              color: AppColors.ink100,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value.clamp(0.0, 1.0),
                child: Container(color: color),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpace.s2),
        SizedBox(
          width: 46,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              '$percent %',
              style: AppText.mathXS,
            ),
          ),
        ),
      ],
    );
  }
}
