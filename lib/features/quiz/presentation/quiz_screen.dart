import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/audio/audio_service.dart';
import '../../profile/domain/school_grade.dart';
import '../../profile/presentation/profile_controller.dart';
import 'quiz_controller.dart';
import 'quiz_results_screen.dart';

/// Écran 2 : Quiz Mathématiques (6 questions adaptées, temps d'écran maîtrisé).
/// Interface tactile, boutons 3D réactifs, feedback bienveillant avec Pi le chiot.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  @override
  void initState({SchoolGrade? gradeOverride}) {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quizState = ref.read(quizControllerProvider);
      if (quizState.questions.isEmpty) {
        final profile = ref.read(activeProfileProvider).value;
        final grade = profile?.grade ?? SchoolGrade.cm1;
        ref.read(quizControllerProvider.notifier).startQuiz(grade);
      }
    });
  }

  void _confirmExit(BuildContext context) {
    final strings = ref.read(stringsProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.appSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(
          strings.quitQuizTitle,
          style: AppText.h3.copyWith(color: context.appText),
        ),
        content: Text(
          strings.quitQuizMessage,
          style: AppText.body.copyWith(color: context.appSubText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              strings.stay,
              style: AppText.buttonM.copyWith(color: AppColors.sky600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(quizControllerProvider.notifier).resetQuiz();
              Navigator.of(context).pop();
            },
            child: Text(
              strings.quit,
              style: AppText.buttonM.copyWith(color: AppColors.coral500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizState = ref.watch(quizControllerProvider);
    final strings = ref.watch(stringsProvider);
    final question = quizState.currentQuestion;

    if (question == null) {
      return Scaffold(
        backgroundColor: context.appBg,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.sky600),
        ),
      );
    }

    final isFrench = strings.isFrench;
    final currentNumber = quizState.currentIndex + 1;
    final total = quizState.totalQuestions;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit(context);
      },
      child: Scaffold(
        backgroundColor: context.appBg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.s4,
              vertical: AppSpace.s2,
            ),
            child: Column(
              children: [
                // 1. Barre supérieure : Quitter, Progression, Sans stress, Solde Os
                _buildHeader(context, currentNumber, total, quizState.progress),

                const SizedBox(height: AppSpace.s2),

                // Contenu : 2 colonnes en paysage, colonne unique en portrait
                Expanded(
                  child: isLandscape
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Colonne gauche : Question et indice Pi
                            Expanded(
                              flex: 5,
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildQuestionCard(question, isFrench),
                                    const SizedBox(height: AppSpace.s2),
                                    _buildMascotBanner(
                                      quizState,
                                      question,
                                      isFrench,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpace.s3),
                            // Colonne droite : Choix 2x2 et bouton d'action
                            Expanded(
                              flex: 5,
                              child: SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildOptionsGrid(
                                      quizState,
                                      question,
                                      isLandscape: true,
                                    ),
                                    const SizedBox(height: AppSpace.s2),
                                    _buildActionButton(
                                      context,
                                      quizState,
                                      strings,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 2. Carte de la Question
                              _buildQuestionCard(question, isFrench),

                              const SizedBox(height: AppSpace.s3),

                              // 3. Grille des 4 options de réponse (2x2)
                              _buildOptionsGrid(quizState, question),

                              const SizedBox(height: AppSpace.s3),

                              // 4. Bulle d'encouragement de Pi
                              _buildMascotBanner(quizState, question, isFrench),
                            ],
                          ),
                        ),
                ),

                if (!isLandscape) ...[
                  const SizedBox(height: AppSpace.s2),
                  // 5. Bouton d'action inférieur (Valider ou Suivant) en portrait
                  _buildActionButton(context, quizState, strings),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    int current,
    int total,
    double progress,
  ) {
    final strings = ref.watch(stringsProvider);

    return Row(
      children: [
        // Bouton Quitter (croix tactile)
        GestureDetector(
          onTap: () => _confirmExit(context),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: context.appSurface,
              shape: BoxShape.circle,
              border: Border.all(color: context.appBorder, width: 1.5),
            ),
            child: Icon(
              Icons.close_rounded,
              size: 20,
              color: context.appSubText,
            ),
          ),
        ),

        const SizedBox(width: AppSpace.s3),

        // Jauge de progression & Badge sans stress
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    strings.questionProgress(current, total),
                    style: AppText.bodyS.copyWith(
                      color: context.appSubText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    strings.stressFree,
                    style: AppText.bodyS.copyWith(
                      color: AppColors.green600,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.s1),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: context.isDark
                      ? AppColors.darkInk200
                      : AppColors.ink200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.green500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: AppSpace.s3),

        // Solde d'Os dorés
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s2,
            vertical: AppSpace.s1,
          ),
          decoration: BoxDecoration(
            color: context.isDark ? const Color(0xFF451A03) : AppColors.amber50,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(
              color: context.isDark
                  ? const Color(0xFFD97706)
                  : const Color(0xFFFDE68A),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              const Text('🦴', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                '50',
                style: AppText.bodyS.copyWith(
                  fontWeight: FontWeight.w900,
                  color: context.isDark
                      ? const Color(0xFFFDE68A)
                      : AppColors.amber900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(dynamic question, bool isFrench) {
    return Container(
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
          // Catégorie pédagogique
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.s3,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: context.isDark
                  ? const Color(0xFF042F2E)
                  : const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              question.getCategory(isFrench),
              style: AppText.bodyS.copyWith(
                color: context.isDark
                    ? const Color(0xFF2DD4BF)
                    : const Color(0xFF00897B),
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(height: AppSpace.s2),

          // Énoncé
          Text(
            question.getPrompt(isFrench),
            style: AppText.question.copyWith(color: context.appText),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpace.s3),

          // Expression mathématique en Lexend
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpace.s3,
              horizontal: AppSpace.s4,
            ),
            decoration: BoxDecoration(
              color: context.appBg,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.appBorder, width: 1.5),
            ),
            child: Text(
              question.mathExpression,
              style: AppText.mathL.copyWith(
                color: context.appText,
                fontSize: 26,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(
    QuizState quizState,
    dynamic question, {
    bool isLandscape = false,
  }) {
    const letters = ['A', 'B', 'C', 'D'];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpace.s2,
        crossAxisSpacing: AppSpace.s2,
        childAspectRatio: isLandscape ? 2.2 : 1.6,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final optionText = question.options[index] as String;
        final letter = letters[index];
        final isSelected = quizState.selectedIndex == index;
        final isCorrect = question.correctIndex == index;
        final isAnswered = quizState.isAnswered;

        // Détermination du style selon l'état
        Color bgColor = context.appSurface;
        Color borderColor = context.appBorder;
        Color shadowColor = context.appShadow;
        Color textColor = context.appText;
        Widget? badge;

        if (isAnswered) {
          if (isCorrect) {
            bgColor = context.isDark
                ? const Color(0xFF064E3B)
                : const Color(0xFFE8F8F5);
            borderColor = AppColors.green500;
            shadowColor = const Color(0xFF15803D);
            textColor = context.isDark
                ? const Color(0xFF86EFAC)
                : const Color(0xFF15803D);
            badge = Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.green500,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 12, color: Colors.white),
            );
          } else if (isSelected) {
            bgColor = context.isDark
                ? const Color(0xFF7F1D1D)
                : const Color(0xFFFEE2E2);
            borderColor = AppColors.coral500;
            shadowColor = const Color(0xFFB91C1C);
            textColor = context.isDark
                ? const Color(0xFFFCA5A5)
                : AppColors.coral500;
            badge = Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: AppColors.coral500,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            );
          } else {
            bgColor = context.appSurface.withValues(alpha: 0.6);
            textColor = context.appSubText;
          }
        } else if (isSelected) {
          bgColor = context.isDark
              ? AppColors.darkSky50
              : const Color(0xFFE0F2FE);
          borderColor = AppColors.sky600;
          shadowColor = AppColors.sky700;
          textColor = context.isDark ? AppColors.darkSky500 : AppColors.sky700;
        }

        return GestureDetector(
          onTap: isAnswered
              ? null
              : () {
                  ref.read(audioServiceProvider).playPop();
                  ref.read(quizControllerProvider.notifier).selectOption(index);
                },
          child: Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  offset: const Offset(0, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                if (badge != null) Positioned(top: 6, right: 6, child: badge),
                Padding(
                  padding: const EdgeInsets.all(AppSpace.s2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        letter,
                        style: AppText.bodyS.copyWith(
                          color: isSelected && !isAnswered
                              ? AppColors.sky600
                              : context.appSubText,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          optionText,
                          style: AppText.mathM.copyWith(
                            color: textColor,
                            fontSize: 19,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMascotBanner(
    QuizState quizState,
    dynamic question,
    bool isFrench,
  ) {
    final strings = ref.watch(stringsProvider);
    String message;

    if (!quizState.isAnswered) {
      message = question.getHint(isFrench);
    } else if (quizState.isCurrentCorrect == true) {
      message = strings.correctFeedback;
    } else {
      message = strings.wrongFeedback(question.correctAnswer);
    }

    return Container(
      padding: const EdgeInsets.all(AppSpace.s3),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.appBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: context.appShadow,
            offset: const Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Mascotte Pi miniature
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.isDark
                  ? AppColors.darkSurfaceAlt
                  : AppColors.amber50,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: context.isDark
                    ? AppColors.darkInk200
                    : const Color(0xFFFDE68A),
                width: 1,
              ),
            ),
            child: Image.asset(
              'assets/images/pi_transparent.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.pets, color: AppColors.sky600, size: 28),
            ),
          ),

          const SizedBox(width: AppSpace.s3),

          // Message de Pi
          Expanded(
            child: Text(
              message,
              style: AppText.label.copyWith(
                color: context.appText,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    QuizState quizState,
    dynamic strings,
  ) {
    if (!quizState.isAnswered) {
      final hasSelected = quizState.selectedIndex != null;
      return ChunkyButton(
        label: strings.validateAnswer,
        variant: ChunkyButtonVariant.primary,
        height: 52,
        onPressed: hasSelected
            ? () {
                ref.read(quizControllerProvider.notifier).validateAnswer();
                final isCorrect = ref
                    .read(quizControllerProvider)
                    .isCurrentCorrect;
                if (isCorrect == true) {
                  ref.read(audioServiceProvider).playSuccess();
                } else {
                  ref.read(audioServiceProvider).playError();
                }
              }
            : null,
      );
    }

    // Réponse validée -> Passer à la suite ou voir les résultats
    final isLast = quizState.isLastQuestion;
    return ChunkyButton(
      label: isLast ? strings.seeResults : strings.nextQuestion,
      variant: ChunkyButtonVariant.primary,
      height: 52,
      onPressed: () {
        ref.read(audioServiceProvider).playPop();
        ref.read(quizControllerProvider.notifier).nextQuestion();
        if (isLast) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const QuizResultsScreen()),
          );
        }
      },
    );
  }
}
