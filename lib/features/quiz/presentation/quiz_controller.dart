import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/domain/school_grade.dart';
import '../domain/math_question.dart';
import '../domain/math_question_generator.dart';

/// État immuable d'une session de Quiz mathématique.
class QuizState {
  final List<MathQuestion> questions;
  final int currentIndex;
  final int? selectedIndex;
  final bool isAnswered;
  final bool? isCurrentCorrect;
  final int score;
  final List<bool> answersHistory;
  final bool isCompleted;
  final int bonesEarned;
  final int croquettesEarned;
  final int ballsEarned;
  final int streakDays;

  const QuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedIndex,
    this.isAnswered = false,
    this.isCurrentCorrect,
    this.score = 0,
    this.answersHistory = const [],
    this.isCompleted = false,
    this.bonesEarned = 0,
    this.croquettesEarned = 0,
    this.ballsEarned = 0,
    this.streakDays = 1,
  });

  MathQuestion? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;

  int get totalQuestions => questions.length;

  double get progress => totalQuestions > 0
      ? (currentIndex + (isAnswered ? 1 : 0)) / totalQuestions
      : 0.0;

  bool get isLastQuestion => currentIndex == totalQuestions - 1;

  QuizState copyWith({
    List<MathQuestion>? questions,
    int? currentIndex,
    int? selectedIndex,
    bool clearSelectedIndex = false,
    bool? isAnswered,
    bool? isCurrentCorrect,
    bool clearIsCurrentCorrect = false,
    int? score,
    List<bool>? answersHistory,
    bool? isCompleted,
    int? bonesEarned,
    int? croquettesEarned,
    int? ballsEarned,
    int? streakDays,
  }) {
    return QuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedIndex: clearSelectedIndex ? null : (selectedIndex ?? this.selectedIndex),
      isAnswered: isAnswered ?? this.isAnswered,
      isCurrentCorrect: clearIsCurrentCorrect ? null : (isCurrentCorrect ?? this.isCurrentCorrect),
      score: score ?? this.score,
      answersHistory: answersHistory ?? this.answersHistory,
      isCompleted: isCompleted ?? this.isCompleted,
      bonesEarned: bonesEarned ?? this.bonesEarned,
      croquettesEarned: croquettesEarned ?? this.croquettesEarned,
      ballsEarned: ballsEarned ?? this.ballsEarned,
      streakDays: streakDays ?? this.streakDays,
    );
  }
}

/// Contrôleur Riverpod pour piloter une session de quiz de 6 questions.
class QuizController extends StateNotifier<QuizState> {
  final MathQuestionGenerator _generator;

  QuizController({MathQuestionGenerator? generator})
      : _generator = generator ?? MathQuestionGenerator(),
        super(const QuizState());

  /// Démarre une nouvelle session de quiz pour la classe demandée
  void startQuiz(SchoolGrade grade, {int count = 6}) {
    final questions = _generator.generateSession(grade: grade, count: count);
    state = QuizState(
      questions: questions,
      currentIndex: 0,
      selectedIndex: null,
      isAnswered: false,
      isCurrentCorrect: null,
      score: 0,
      answersHistory: [],
      isCompleted: false,
      bonesEarned: 0,
      croquettesEarned: 0,
      ballsEarned: 0,
      streakDays: 1,
    );
  }

  /// Sélectionne une des 4 réponses proposées (avant validation)
  void selectOption(int index) {
    if (state.isAnswered) return; // Verrouillé après validation
    state = state.copyWith(selectedIndex: index);
  }

  /// Valide la réponse sélectionnée par l'enfant
  void validateAnswer() {
    if (state.isAnswered || state.selectedIndex == null) return;
    final currentQ = state.currentQuestion;
    if (currentQ == null) return;

    final isCorrect = currentQ.isAnswerCorrect(state.selectedIndex!);
    final newScore = isCorrect ? state.score + 1 : state.score;
    final updatedHistory = [...state.answersHistory, isCorrect];

    state = state.copyWith(
      isAnswered: true,
      isCurrentCorrect: isCorrect,
      score: newScore,
      answersHistory: updatedHistory,
    );
  }

  /// Passe à la question suivante ou termine le quiz
  void nextQuestion() {
    if (!state.isAnswered) return;

    if (state.isLastQuestion) {
      // Fin du quiz : calcul des récompenses bienveillantes
      // 5 os par bonne réponse + 5 os bonus de complétion
      final bones = state.score * 5 + 5;
      final croquettes = state.score >= 3 ? 3 : 1;
      final balls = state.score >= 4 ? 2 : 1;

      state = state.copyWith(
        isCompleted: true,
        bonesEarned: bones,
        croquettesEarned: croquettes,
        ballsEarned: balls,
      );
    } else {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        clearSelectedIndex: true,
        isAnswered: false,
        clearIsCurrentCorrect: true,
      );
    }
  }

  /// Réinitialise l'état du quiz
  void resetQuiz() {
    state = const QuizState();
  }
}

/// Provider global du contrôleur de Quiz
final quizControllerProvider =
    StateNotifierProvider<QuizController, QuizState>((ref) {
  return QuizController();
});
