import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../care/presentation/care_controller.dart';
import '../../care/presentation/care_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../profile/presentation/profile_controller.dart';
import 'quiz_controller.dart';

/// Écran 3 : Résultats du Quiz & Célébration bienveillante avec Pi.
/// Attribue les récompenses en Os dorés 🦴, croquettes 🍖 et balles 🎾.
class QuizResultsScreen extends ConsumerWidget {
  const QuizResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizControllerProvider);
    final profile = ref.watch(activeProfileProvider).value;
    final strings = ref.watch(stringsProvider);

    final childName = profile?.name ?? 'Ami';
    final score = quizState.score;
    final total = quizState.totalQuestions > 0 ? quizState.totalQuestions : 6;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s4,
            vertical: AppSpace.s3,
          ),
          child: Column(
            children: [
              // 1. En-tête : Badge & Félicitations
              _buildHeader(strings, childName, score, total),

              const SizedBox(height: AppSpace.s3),

              // Contenu défilant pour adapter tous les écrans
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 2. Mascotte Pi qui célèbre + Badge du Score
                      _buildMascotCelebration(score, total, strings),

                      const SizedBox(height: AppSpace.s4),

                      // 3. Carte des Récompenses gagnées (Os, Croquettes, Balles)
                      _buildRewardsCard(quizState, strings),
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
    );
  }

  Widget _buildHeader(
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
            color: const Color(0xFFE8F8F5),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: const Color(0xFFA7F3D0), width: 1),
          ),
          child: Text(
            strings.quizCompleted,
            style: AppText.bodyS.copyWith(
              color: const Color(0xFF15803D),
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: AppSpace.s2),
        Text(
          strings.quizBravo(childName),
          style: AppText.h2.copyWith(
            color: AppColors.ink900,
            fontSize: 24,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpace.s1),
        Text(
          strings.quizEncouragement(score, total),
          style: AppText.body.copyWith(
            color: AppColors.ink600,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMascotCelebration(int score, int total, dynamic strings) {
    return SizedBox(
      height: 180,
      width: 180,
      child: Stack(
        alignment: Alignment.center,
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

          // Pi avec son ombre au sol
          Positioned(
            bottom: 22,
            child: Container(
              width: 100,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.all(
                  Radius.elliptical(100, 16),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            child: Image.asset(
              'assets/images/pi_transparent.png',
              height: 130,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.pets,
                size: 90,
                color: AppColors.sky600,
              ),
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

  Widget _buildRewardsCard(QuizState quizState, dynamic strings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.s4),
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
      child: Column(
        children: [
          Text(
            strings.rewardsEarned,
            style: AppText.overline.copyWith(
              color: AppColors.ink500,
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
                  icon: '🦴',
                  count: '+${quizState.bonesEarned}',
                  label: strings.goldenBones,
                  bgColor: AppColors.amber50,
                  borderColor: const Color(0xFFFDE68A),
                  textColor: AppColors.amber900,
                ),
              ),
              const SizedBox(width: AppSpace.s2),
              Expanded(
                child: _buildRewardBadge(
                  icon: '🍖',
                  count: '+${quizState.croquettesEarned}',
                  label: strings.croquettes,
                  bgColor: const Color(0xFFECFDF5),
                  borderColor: const Color(0xFFA7F3D0),
                  textColor: const Color(0xFF065F46),
                ),
              ),
              const SizedBox(width: AppSpace.s2),
              Expanded(
                child: _buildRewardBadge(
                  icon: '🎾',
                  count: '+${quizState.ballsEarned}',
                  label: strings.balls,
                  bgColor: const Color(0xFFF0F9FF),
                  borderColor: const Color(0xFFBAE6FD),
                  textColor: const Color(0xFF0369A1),
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
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.ink200, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.streakDays(quizState.streakDays),
                  style: AppText.bodyS.copyWith(
                    color: AppColors.ink900,
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

  Widget _buildRewardBadge({
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
                color: AppColors.ink600,
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
    final quizState = ref.watch(quizControllerProvider);

    return Column(
      children: [
        ChunkyButton(
          label: strings.feedAndCare,
          variant: ChunkyButtonVariant.primary,
          height: 52,
          onPressed: () {
            ref.read(careControllerProvider.notifier).addRewards(
                  bones: quizState.bonesEarned,
                  croquettes: quizState.croquettesEarned,
                  balls: quizState.ballsEarned,
                );
            ref.read(quizControllerProvider.notifier).resetQuiz();
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const CareScreen()),
            );
          },
        ),
        const SizedBox(height: AppSpace.s2),
        ChunkyButton(
          label: strings.backToHome,
          variant: ChunkyButtonVariant.secondary,
          height: 48,
          onPressed: () {
            ref.read(careControllerProvider.notifier).addRewards(
                  bones: quizState.bonesEarned,
                  croquettes: quizState.croquettesEarned,
                  balls: quizState.ballsEarned,
                );
            ref.read(quizControllerProvider.notifier).resetQuiz();
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
      ],
    );
  }
}
