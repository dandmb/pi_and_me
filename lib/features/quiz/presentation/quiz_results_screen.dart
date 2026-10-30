import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/audio/audio_service.dart';
import '../../care/presentation/care_controller.dart';
import '../../care/presentation/widgets/animated_pi_mascot.dart';
import '../../navigation/presentation/main_shell_screen.dart';
import '../../profile/domain/school_grade.dart';
import '../../profile/presentation/profile_controller.dart';
import '../../shop/presentation/shop_controller.dart';
import '../../parent/domain/daily_limit_state.dart';
import '../../parent/presentation/daily_limit_controller.dart';
import '../../parent/presentation/parent_dashboard_controller.dart';
import '../../parent/presentation/widgets/daily_quota_indicator.dart';
import '../data/quiz_stats_repository.dart';
import '../domain/quiz_session_record.dart';
import 'quiz_controller.dart';

/// Écran 3 : Résultats du Quiz & Célébration bienveillante avec Pi.
/// Attribue les récompenses en Os dorés 🦴, croquettes 🍖 et balles 🎾
/// avec une animation progressive interactive et des aboiements joyeux de Pi.
class QuizResultsScreen extends ConsumerStatefulWidget {
  const QuizResultsScreen({super.key});

  @override
  ConsumerState<QuizResultsScreen> createState() => _QuizResultsScreenState();
}

class _QuizResultsScreenState extends ConsumerState<QuizResultsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rewardsController;
  late final Animation<double> _rewardsAnimation;

  bool _showBarkBubble = false;
  String? _activeRewardFeedback;
  int _highlightedRewardIndex = -1;
  int _lastTickedBones = 0;
  Timer? _barkTimer;
  Timer? _feedbackTimer;

  bool get _isTestEnv {
    try {
      return Platform.environment.containsKey('FLUTTER_TEST');
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();

    _rewardsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _rewardsAnimation = CurvedAnimation(
      parent: _rewardsController,
      curve: Curves.easeOutCubic,
    );

    _rewardsAnimation.addListener(() {
      final quizState = ref.read(quizControllerProvider);
      final currentBones =
          (_rewardsAnimation.value * quizState.bonesEarned).round();
      if (currentBones > _lastTickedBones &&
          currentBones % 2 == 0 &&
          !_isTestEnv) {
        _lastTickedBones = currentBones;
        ref.read(audioServiceProvider).playPop();
      }
    });

    _rewardsController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final score = ref.read(quizControllerProvider).score;
      if (score >= 4) {
        ref.read(audioServiceProvider).playCelebration();
        if (_isTestEnv) {
          ref.read(audioServiceProvider).playBark();
        } else {
          // Pi aboie joyeusement après le début de la fanfare de célébration
          _barkTimer = Timer(const Duration(milliseconds: 650), () {
            if (mounted) {
              ref.read(audioServiceProvider).playBark();
              setState(() => _showBarkBubble = true);
              _barkTimer = Timer(const Duration(milliseconds: 2200), () {
                if (mounted) setState(() => _showBarkBubble = false);
              });
            }
          });
        }
      } else {
        // En cas de score intermédiaire, Pi aboie avec tendresse pour encourager l'enfant
        ref.read(audioServiceProvider).playBark();
        if (!_isTestEnv) {
          setState(() => _showBarkBubble = true);
          _barkTimer = Timer(const Duration(milliseconds: 2200), () {
            if (mounted) setState(() => _showBarkBubble = false);
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _barkTimer?.cancel();
    _feedbackTimer?.cancel();
    _rewardsController.dispose();
    super.dispose();
  }

  void _onPiTapped() {
    ref.read(audioServiceProvider).playBark();
    _barkTimer?.cancel();
    setState(() => _showBarkBubble = true);
    if (!_isTestEnv) {
      _barkTimer = Timer(const Duration(milliseconds: 2000), () {
        if (mounted) setState(() => _showBarkBubble = false);
      });
    }
  }

  void _onRewardTapped(int index, String feedback, VoidCallback playSound) {
    playSound();
    _feedbackTimer?.cancel();
    setState(() {
      _highlightedRewardIndex = index;
      _activeRewardFeedback = feedback;
    });
    if (!_isTestEnv) {
      _feedbackTimer = Timer(const Duration(milliseconds: 2500), () {
        if (mounted && _highlightedRewardIndex == index) {
          setState(() {
            _activeRewardFeedback = null;
            _highlightedRewardIndex = -1;
          });
        }
      });
    }
  }

  void _finishAndNavigate(BuildContext context, int targetIndex) {
    ref.read(audioServiceProvider).playPop();
    final quizState = ref.read(quizControllerProvider);
    final activeProfile = ref.read(activeProfileProvider).value;
    final profileId = activeProfile?.id ?? 'default';
    final grade = activeProfile?.grade ?? SchoolGrade.cp;

    // Enregistrement des statistiques pédagogiques réelles
    final totalByDomain = <String, int>{};
    final correctByDomain = <String, int>{};

    for (int i = 0; i < quizState.questions.length; i++) {
      final q = quizState.questions[i];
      final domainKey = q.domain.name;
      totalByDomain[domainKey] = (totalByDomain[domainKey] ?? 0) + 1;
      final isCorrect =
          i < quizState.answersHistory.length && quizState.answersHistory[i];
      if (isCorrect) {
        correctByDomain[domainKey] = (correctByDomain[domainKey] ?? 0) + 1;
      }
    }

    final record = QuizSessionRecord(
      id: 'quiz_${DateTime.now().millisecondsSinceEpoch}',
      profileId: profileId,
      timestamp: DateTime.now(),
      grade: grade,
      totalQuestions: quizState.totalQuestions,
      correctAnswers: quizState.score,
      totalByDomain: totalByDomain,
      correctByDomain: correctByDomain,
    );

    ref.read(quizStatsRepositoryProvider).recordSession(record);
    ref.read(parentDashboardControllerProvider.notifier).loadStats();

    ref
        .read(careControllerProvider.notifier)
        .addRewards(
          bones: quizState.bonesEarned,
          croquettes: quizState.croquettesEarned,
          balls: quizState.ballsEarned,
        );
    ref.read(dailyLimitControllerProvider.notifier).recordCompletedQuiz();
    ref.read(quizControllerProvider.notifier).resetQuiz();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainShellScreen(initialIndex: targetIndex),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizControllerProvider);
    final profile = ref.watch(activeProfileProvider).value;
    final strings = ref.watch(stringsProvider);
    final shopState = ref.watch(shopControllerProvider);
    final limitState = ref.watch(dailyLimitControllerProvider);

    final childName = profile?.name ?? 'Ami';
    final score = quizState.score;
    final total = quizState.totalQuestions > 0 ? quizState.totalQuestions : 6;

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            _finishAndNavigate(context, 0);
          }
        },
        child: Scaffold(
          backgroundColor: context.appBg,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.s4,
                vertical: AppSpace.s2,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Colonne gauche : Félicitations et Mascotte qui célèbre
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildHeader(
                            context,
                            strings,
                            childName,
                            score,
                            total,
                            limitState,
                          ),
                          const SizedBox(height: AppSpace.s2),
                          _buildMascotCelebration(
                            score,
                            total,
                            strings,
                            shopState.equippedAccessoryIds,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.s4),
                  // Colonne droite : Carte des récompenses et boutons d'action
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildRewardsCard(context, quizState, strings),
                          const SizedBox(height: AppSpace.s3),
                          _buildActionButtons(context, strings),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _finishAndNavigate(context, 0);
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
                _buildHeader(
                  context,
                  strings,
                  childName,
                  score,
                  total,
                  limitState,
                ),

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
                _buildActionButtons(context, strings),
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
    DailyLimitState limitState,
  ) {
    final projectedSessions = (limitState.usedSessionsToday + 1).clamp(
      0,
      limitState.maxDailySessions,
    );
    final isLimitNowReached = projectedSessions >= limitState.maxDailySessions;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.s3,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? const Color(0xFF064E3B)
                      : const Color(0xFFE8F8F5),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                    color: context.isDark
                        ? const Color(0xFF059669)
                        : const Color(0xFFA7F3D0),
                    width: 1,
                  ),
                ),
                child: Text(
                  strings.quizCompleted,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: AppText.bodyS.copyWith(
                    color: context.isDark
                        ? const Color(0xFF6EE7B7)
                        : const Color(0xFF15803D),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpace.s2),
            DailyQuotaIndicator(
              usedSessions: projectedSessions,
              maxSessions: limitState.maxDailySessions,
              isLimitReached: isLimitNowReached,
            ),
          ],
        ),
        const SizedBox(height: AppSpace.s2),
        Text(
          strings.quizBravo(childName),
          style: AppText.h2.copyWith(color: context.appText, fontSize: 24),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 195,
          width: 200,
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

              // Bulle de dialogue quand Pi aboie
              if (_showBarkBubble)
                Positioned(
                  top: -6,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.7, end: 1.0),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.elasticOut,
                    builder: (context, scale, child) => Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.s3,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? const Color(0xFF1E293B)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: AppColors.gold400,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        strings.isFrench ? 'Wouf ! Wouf !' : 'Woof! Woof!',
                        style: AppText.label.copyWith(
                          color: const Color(0xFFB45309),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),

              // Pi qui saute de joie (yeux rieurs ^ ^, bouche ouverte, queue qui bat et coeurs)
              // Taper sur Pi déclenche un jappement joyeux immédiat !
              Positioned(
                bottom: 22,
                child: GestureDetector(
                  onTap: _onPiTapped,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedPiMascot(
                    piSize: 122,
                    isCelebrating: true,
                    equippedAccessoryIds: equippedAccessoryIds,
                    enableTapInteraction: true,
                    onTap: _onPiTapped,
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
        ),
      ],
    );
  }

  Widget _buildRewardsCard(
    BuildContext context,
    QuizState quizState,
    dynamic strings,
  ) {
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

          // 3 récompenses avec animation progressive et réactivité tactile
          AnimatedBuilder(
            animation: _rewardsAnimation,
            builder: (context, _) {
              final t = _rewardsAnimation.value;
              final currentBones = (t * quizState.bonesEarned).round();
              final currentCroquettes =
                  (t * quizState.croquettesEarned).round();
              final currentBalls = (t * quizState.ballsEarned).round();

              return Row(
                children: [
                  Expanded(
                    child: _buildInteractiveRewardBadge(
                      context,
                      index: 0,
                      icon: '🦴',
                      count: '+$currentBones',
                      label: strings.goldenBones,
                      bgColor: context.isDark
                          ? const Color(0xFF451A03)
                          : AppColors.amber50,
                      borderColor: context.isDark
                          ? const Color(0xFFD97706)
                          : const Color(0xFFFDE68A),
                      textColor: context.isDark
                          ? const Color(0xFFFDE68A)
                          : AppColors.amber900,
                      isHighlighted: _highlightedRewardIndex == 0,
                      onTap: () => _onRewardTapped(
                        0,
                        strings.isFrench
                            ? '🦴 +${quizState.bonesEarned} Os dorés pour la boutique !'
                            : '🦴 +${quizState.bonesEarned} Golden bones for the shop!',
                        () => ref.read(audioServiceProvider).playBone(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.s2),
                  Expanded(
                    child: _buildInteractiveRewardBadge(
                      context,
                      index: 1,
                      icon: '🍖',
                      count: '+$currentCroquettes',
                      label: strings.croquettes,
                      bgColor: context.isDark
                          ? const Color(0xFF064E3B)
                          : const Color(0xFFECFDF5),
                      borderColor: context.isDark
                          ? const Color(0xFF059669)
                          : const Color(0xFFA7F3D0),
                      textColor: context.isDark
                          ? const Color(0xFF6EE7B7)
                          : const Color(0xFF065F46),
                      isHighlighted: _highlightedRewardIndex == 1,
                      onTap: () => _onRewardTapped(
                        1,
                        strings.isFrench
                            ? '🍖 +${quizState.croquettesEarned} Croquettes pour régaler Pi !'
                            : '🍖 +${quizState.croquettesEarned} Kibbles to feed Pi!',
                        () => ref.read(audioServiceProvider).playFeed(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.s2),
                  Expanded(
                    child: _buildInteractiveRewardBadge(
                      context,
                      index: 2,
                      icon: '🎾',
                      count: '+$currentBalls',
                      label: strings.balls,
                      bgColor: context.isDark
                          ? const Color(0xFF0C4A6E)
                          : const Color(0xFFF0F9FF),
                      borderColor: context.isDark
                          ? const Color(0xFF0284C7)
                          : const Color(0xFFBAE6FD),
                      textColor: context.isDark
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF0369A1),
                      isHighlighted: _highlightedRewardIndex == 2,
                      onTap: () => _onRewardTapped(
                        2,
                        strings.isFrench
                            ? '🎾 +${quizState.ballsEarned} Balles pour jouer avec Pi !'
                            : '🎾 +${quizState.ballsEarned} Balls to play with Pi!',
                        () => ref.read(audioServiceProvider).playBall(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Message interactif au toucher d'une récompense
          if (_activeRewardFeedback != null) ...[
            const SizedBox(height: AppSpace.s2),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.85, end: 1.0),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) => Transform.scale(
                scale: scale,
                child: child,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.s3,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: context.isDark
                        ? const Color(0xFFD97706)
                        : const Color(0xFFF59E0B),
                    width: 1,
                  ),
                ),
                child: Text(
                  _activeRewardFeedback!,
                  textAlign: TextAlign.center,
                  style: AppText.bodyS.copyWith(
                    color: context.isDark
                        ? const Color(0xFFFDE68A)
                        : AppColors.amber900,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],

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
                Flexible(
                  child: Text(
                    strings.streakDays(quizState.streakDays),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: AppText.bodyS.copyWith(
                      color: context.appText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.s2),
                Flexible(
                  child: Text(
                    strings.isFrench ? '🌱 Rythme parfait !' : '🌱 Great pace!',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: AppText.bodyS.copyWith(
                      color: AppColors.green600,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveRewardBadge(
    BuildContext context, {
    required int index,
    required String icon,
    required String count,
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required bool isHighlighted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.diagonal3Values(
          isHighlighted ? 1.05 : 1.0,
          isHighlighted ? 1.05 : 1.0,
          1.0,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpace.s2,
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isHighlighted ? AppColors.gold400 : borderColor,
            width: isHighlighted ? 2.5 : 1.5,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: AppColors.gold400.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
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
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, dynamic strings) {
    return Column(
      children: [
        ChunkyButton(
          label: strings.feedAndCare,
          variant: ChunkyButtonVariant.primary,
          height: 52,
          onPressed: () => _finishAndNavigate(context, 1),
        ),
        const SizedBox(height: AppSpace.s2),
        ChunkyButton(
          label: strings.backToHome,
          variant: ChunkyButtonVariant.secondary,
          height: 48,
          onPressed: () => _finishAndNavigate(context, 0),
        ),
      ],
    );
  }
}
