import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../care/presentation/care_controller.dart';
import '../../care/presentation/widgets/animated_pi_mascot.dart';
import '../../navigation/presentation/main_shell_screen.dart';
import '../../profile/presentation/profile_controller.dart';
import '../../shop/presentation/shop_controller.dart';
import 'quiz_controller.dart';

/// Écran 3 : Résultats du Quiz & Célébration bienveillante avec Pi.
/// Attribue les récompenses en Os dorés 🦴, croquettes 🍖 et balles 🎾.
class QuizResultsScreen extends ConsumerWidget {
  const QuizResultsScreen({super.key});

  void _finishAndNavigate(BuildContext context, WidgetRef ref, int targetIndex) {
    final quizState = ref.read(quizControllerProvider);
    ref.read(careControllerProvider.notifier).addRewards(
          bones: quizState.bonesEarned,
          croquettes: quizState.croquettesEarned,
          balls: quizState.ballsEarned,
        );
    ref.read(quizControllerProvider.notifier).resetQuiz();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainShellScreen(initialIndex: targetIndex),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizControllerProvider);
    final profile = ref.watch(activeProfileProvider).value;
    final strings = ref.watch(stringsProvider);
    final shopState = ref.watch(shopControllerProvider);

    final childName = profile?.name ?? 'Ami';
    final score = quizState.score;
    final total = quizState.totalQuestions > 0 ? quizState.totalQuestions : 6;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _finishAndNavigate(context, ref, 0);
        }
      },
      child: Scaffold(
        backgroundColor: context.appBg,
        body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s4,
            vertical: AppSpace.s3,
          ),
          child: Column(
            children: [
              // 1. En-tête : Badge & Félicitations
              _buildHeader(context, strings, childName, score, total),

              const SizedBox(height: AppSpace.s3),

              // Contenu défilant pour adapter tous les écrans
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 2. Mascotte Pi qui célèbre + Badge du Score
                      _buildMascotCelebration(
                        score,
                        total,
                        strings,
                        shopState.equippedAccessoryIds,
                      ),

                      const SizedBox(height: AppSpace.s4),

                      // 3. Carte des Récompenses gagnées (Os, Croquettes, Balles)
                      _buildRewardsCard(context, quizState, strings),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpace.s3),

              // 4. Boutons d'action : Soigner Pi & Retour au Salon
              _buildActionButtons(context, ref, strings),
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildHeader(
    BuildContext context,
    dynamic strings,
    String childName,
    int score,
    int total,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s3,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: context.isDark ? const Color(0xFF064E3B) : const Color(0xFFE8F8F5),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: context.isDark ? const Color(0xFF059669) : const Color(0xFFA7F3D0),
              width: 1,
            ),
          ),
          child: Text(
            strings.quizCompleted,
            style: AppText.bodyS.copyWith(
              color: context.isDark ? const Color(0xFF6EE7B7) : const Color(0xFF15803D),
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: AppSpace.s2),
        Text(
          strings.quizBravo(childName),
          style: AppText.h2.copyWith(
            color: context.appText,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpace.s1),
        Text(
          strings.quizEncouragement(score, total),
          style: AppText.body.copyWith(
            color: context.appSubText,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMascotCelebration(
    int score,
    int total,
    dynamic strings,
    List<String> equippedAccessoryIds,
  ) {
    return SizedBox(
      height: 185,
      width: 185,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Halo doré lumineux
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold400.withValues(alpha: 0.35),
            ),
          ),

          // Pi qui saute de joie (yeux rieurs ^ ^, bouche ouverte, queue qui bat et coeurs)
          Positioned(
            bottom: 22,
            child: AnimatedPiMascot(
              piSize: 122,
              isCelebrating: true,
              equippedAccessoryIds: equippedAccessoryIds,
            ),
          ),

          // Pastille du score superposée en bas de Pi
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.s4,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.sky600,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.sky700,
                    offset: Offset(0, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                strings.quizSummary(score, total),
                style: AppText.mathM.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsCard(BuildContext context, QuizState quizState, dynamic strings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.s4),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
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
        children: [
          Text(
            strings.rewardsEarned,
            style: AppText.overline.copyWith(
              color: context.appSubText,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpace.s3),

          // 3 récompenses : Os dorés, Croquettes, Balles
          Row(
            children: [
              Expanded(
                child: _buildRewardBadge(
                  context,
                  icon: '🦴',
                  count: '+${quizState.bonesEarned}',
                  label: strings.goldenBones,
                  bgColor: context.isDark ? const Color(0xFF451A03) : AppColors.amber50,
                  borderColor: context.isDark ? const Color(0xFFD97706) : const Color(0xFFFDE68A),
                  textColor: context.isDark ? const Color(0xFFFDE68A) : AppColors.amber900,
                ),
              ),
              const SizedBox(width: AppSpace.s2),
              Expanded(
                child: _buildRewardBadge(
                  context,
                  icon: '🍖',
                  count: '+${quizState.croquettesEarned}',
                  label: strings.croquettes,
                  bgColor: context.isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                  borderColor: context.isDark ? const Color(0xFF059669) : const Color(0xFFA7F3D0),
                  textColor: context.isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
                ),
              ),
              const SizedBox(width: AppSpace.s2),
              Expanded(
                child: _buildRewardBadge(
                  context,
                  icon: '🎾',
                  count: '+${quizState.ballsEarned}',
                  label: strings.balls,
                  bgColor: context.isDark ? const Color(0xFF0C4A6E) : const Color(0xFFF0F9FF),
                  borderColor: context.isDark ? const Color(0xFF0284C7) : const Color(0xFFBAE6FD),
                  textColor: context.isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpace.s3),

          // Bannière de série
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.s3,
              vertical: AppSpace.s2,
            ),
            decoration: BoxDecoration(
              color: context.appBg,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: context.appBorder, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.streakDays(quizState.streakDays),
                  style: AppText.bodyS.copyWith(
                    color: context.appText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  strings.isFrench ? '🌱 Rythme parfait !' : '🌱 Great pace!',
                  style: AppText.bodyS.copyWith(
                    color: AppColors.green600,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardBadge(
    BuildContext context, {
    required String icon,
    required String count,
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s2, horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 2),
          Text(
            count,
            style: AppText.mathM.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppText.bodyS.copyWith(
                color: context.appSubText,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    dynamic strings,
  ) {
    return Column(
      children: [
        ChunkyButton(
          label: strings.feedAndCare,
          variant: ChunkyButtonVariant.primary,
          height: 52,
          onPressed: () => _finishAndNavigate(context, ref, 1),
        ),
        const SizedBox(height: AppSpace.s2),
        ChunkyButton(
          label: strings.backToHome,
          variant: ChunkyButtonVariant.secondary,
          height: 48,
          onPressed: () => _finishAndNavigate(context, ref, 0),
        ),
      ],
    );
  }
}
